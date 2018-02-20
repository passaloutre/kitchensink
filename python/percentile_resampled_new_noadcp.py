#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 10 16:45:38 2016

@author: mtr
"""
import os
import numpy as np
import pandas as pd
import scipy.optimize as opt
import matplotlib.pyplot as plt
import matplotlib.dates as dates

#plt.xkcd(scale=2,length=500,randomness=2)
#plt.rc('xtick.major', size=0)
#plt.rc('ytick.major', size=0)
plt.rc('lines', lw=2)


# %% user inputs

site_name = 'nmr'

# processing parameters
bin_size       = 5       # size of percentile bins for histogram
turb_threshold = 150     # cut off turbidity values greater than
#adcp_threshold = 200     # cut off adcp intensities greater than
#adcp_binrange  = [1,5]   # range of adcp bins to average (actual bins, not indices)
turb_fit_type  = 'quad'  # 'lin' or 'quad' or 'exp' or 'thrd'
#adcp_fit_type  = 'exp'   # 'lin' or 'quad' or 'exp' or 'thrd'
limit_overlap  = 1       # 0 or 1 , limit time series to period of overlap

# %% import pickle, faster than reading the xlsx

#os.chdir('/home/rdchlmtr/Documents')
os.chdir('e:/Projects/Mobile/2017')

#adcp = pd.read_pickle('{}_hadcp_2017.pkl'.format(site_name))
isco = pd.read_pickle('{}_isco_2017.pkl'.format(site_name))
turb = pd.read_pickle('{}_turb_2017.pkl'.format(site_name))

#adcp_filt = adcp.resample('60T').mean().dropna()
isco_filt = isco.resample('60T').mean().dropna()
turb_filt = turb.resample('60T').mean().dropna()

# get adcp bin range values
#adcp_binrange = np.array(adcp_binrange) - 1
#bincenters = [float(list(adcp)[i]) for i in np.arange(len(list(adcp)))]
#binsizes = np.diff(bincenters)
#rangestart = bincenters[adcp_binrange[0]] - binsizes[adcp_binrange[0]] * 0.5
#rangeend = bincenters[adcp_binrange[1]] + binsizes[adcp_binrange[1]] * 0.5
#rangetext = 'ADCP Range: {:.1f} to {:.1f} m (bins {:d} to {:d})'.format(rangestart,rangeend,*adcp_binrange+1)

# find timespan where all data overlap
#timestart = max(adcp_filt.index[0],isco_filt.index[0],turb_filt.index[0])
#timeend = min(adcp_filt.index[-1],isco_filt.index[-1],turb_filt.index[-1])
timestart = max(isco_filt.index[0],turb_filt.index[0])
timeend = min(isco_filt.index[-1],turb_filt.index[-1])

# chop data to period of overlap
if limit_overlap == 1:
#    adcp_filt = adcp_filt[timestart:timeend]
    isco_filt = isco_filt[timestart:timeend]
    turb_filt = turb_filt[timestart:timeend]

#%% data processing loop

# filter turbidity
#turb = turb[turb['turb_NTU'] < turb_threshold]
turb_filt = turb_filt[turb_filt['turb_NTU'] < turb_threshold]

# average adcp bins
#adcp = pd.DataFrame(adcp.ix[:,adcp_binrange[0]:adcp_binrange[1]].mean(axis=1))
#adcp = adcp[adcp > adcp_threshold].dropna()
#adcp_filt = pd.DataFrame(adcp_filt.ix[:,adcp_binrange[0]:adcp_binrange[1]].mean(axis=1))
#adcp_filt = adcp_filt[adcp_filt < adcp_threshold].dropna()

# initialize output lists
isco_perc = np.zeros(100//bin_size) # // denotes integer division
turb_perc = np.zeros(100//bin_size)
#adcp_perc = np.zeros(100//bin_size)

# add percentile values to output lists
for i in range(100//bin_size):
    isco_perc[i] = np.percentile(isco_filt, i * bin_size)
    turb_perc[i] = np.percentile(turb_filt, i * bin_size)
#    adcp_perc[i] = np.percentile(adcp_filt, i * bin_size)

# add 100th percentile
#isco_perc[-1] = max(isco_filt.values)
#turb_perc[-1] = max(turb_filt.values)
#adcp_perc[-1] = max(adcp_filt.values)

#%% calibration fits

# linear fits

def lin_func(x, a, b):
    return(a * x + b)

if turb_fit_type == 'lin':
    turb_coeffs, turb_cov = opt.curve_fit(lin_func, turb_perc, isco_perc)
    turb_ffit_x = np.concatenate(([0],turb_perc,[np.max(turb_filt.values)]),axis=0)
    turb_ffit_y = lin_func(turb_ffit_x, *turb_coeffs)
    turb_fit_eq = 'y = {:.4f} * x + {:.4f}'.format(*turb_coeffs)
    output_turb_mgl = lin_func(turb_filt, *turb_coeffs)
    turb_fit_text = 'Linear Fit'
#if adcp_fit_type == 'lin':
#    adcp_coeffs, adcp_cov = opt.curve_fit(lin_func, adcp_perc, isco_perc)
#    adcp_ffit_x = np.concatenate(([0],adcp_perc,[np.max(adcp_filt.values)]),axis=0)
#    adcp_ffit_y = lin_func(adcp_ffit_x, *adcp_coeffs)
#    adcp_fit_eq = 'y = {:.4f} * x + {:.4f}'.format(*adcp_coeffs)
#    output_adcp_mgl = lin_func(adcp_filt, *adcp_coeffs)
#    adcp_fit_text = 'Linear Fit'

# quadratic fits

def quad_func(x, a, b, c):
    return(a * x **2 + b * x + c)

if turb_fit_type == 'quad':
    turb_coeffs, turb_cov = opt.curve_fit(quad_func, turb_perc, isco_perc)
    turb_ffit_x = np.concatenate(([0],turb_perc,[np.max(turb_filt.values)]),axis=0)
    turb_ffit_y = quad_func(turb_ffit_x, *turb_coeffs)
    turb_fit_eq = 'y = {:.2} * x^2 {:+.2} * x {:+.4f}'.format(*turb_coeffs)
    output_turb_mgl = quad_func(turb_filt, *turb_coeffs)
    turb_fit_text = 'Quadratic Fit'
#if adcp_fit_type == 'quad':
#    adcp_coeffs, adcp_cov = opt.curve_fit(quad_func, adcp_perc, isco_perc)
#    adcp_ffit_x = np.concatenate(([0],adcp_perc,[np.max(adcp_filt.values)]),axis=0)
#    adcp_ffit_y = quad_func(adcp_ffit_x, *adcp_coeffs)
#    adcp_fit_eq = 'y = {:.2} * x^2 {:+.2} * x {:+.4f}'.format(*adcp_coeffs)
#    output_adcp_mgl = quad_func(adcp_filt, *adcp_coeffs)
#    adcp_fit_text = 'Quadratic Fit'

# exponential fits

def exp_func(x, a, b):
    return(a * np.exp(b/10 * x))

if turb_fit_type == 'exp':
    turb_coeffs, turb_cov = opt.curve_fit(exp_func, turb_perc, isco_perc)
    turb_ffit_x = np.concatenate(([0],turb_perc,[np.max(turb_filt.values)]),axis=0)
    turb_ffit_y = exp_func(turb_ffit_x, *turb_coeffs)
    turb_fit_eq = 'y = {:.3f} * e^({:.3f} * x)'.format(turb_coeffs[0],turb_coeffs[1]/10)
    output_turb_mgl = exp_func(turb_filt, *turb_coeffs)
    turb_fit_text = 'Exponential Fit'
#if adcp_fit_type == 'exp':
#    adcp_coeffs, adcp_cov = opt.curve_fit(exp_func, adcp_perc, isco_perc)
#    adcp_ffit_x = np.concatenate(([0],adcp_perc,[np.max(adcp_filt.values)]),axis=0)
#    adcp_ffit_y = exp_func(adcp_ffit_x, *adcp_coeffs)
#    adcp_fit_eq = 'y = {:.3f} * e^({:.3f} * x)'.format(adcp_coeffs[0],adcp_coeffs[1]/10)
#    output_adcp_mgl = exp_func(adcp_filt, *adcp_coeffs)
#    adcp_fit_text = 'Exponential Fit'

def thrd_func(x, a, b, c, d):
    return(a * x **3 + b * x **2 + c * x + d)

if turb_fit_type == 'thrd':
    turb_coeefs, turb_cov = opt.curve_fit(thrd_func, turb_perc, isco_perc)
    turb_ffit_x = np.concatenate(([0],turb_perc,[np.max(turb_filt.values)]),axis=0)
    turb_ffit_y = thrd_func(turb_ffit_x, *turb_coeffs)
    turb_fit_eq = 'y = {:.3f} * x^3 {:+.3f} * x^2 {:+.3f} * x {:+.3f}'.format(*turb_coeffs)
    output_turb_mgl = thrd_func(turb_filt, *turb_coeffs)
    turb_fit_text = 'Third Order Fit'
#if adcp_fit_type == 'thrd':
#    adcp_coeffs, adcp_cov = opt.curve_fit(thrd_func, adcp_perc, isco_perc)
#    adcp_ffit_x = np.concatenate(([0],adcp_perc,[np.max(adcp_filt.values)]),axis=0)
#    adcp_ffit_y = thrd_func(adcp_ffit_x, *adcp_coeffs)
#    adcp_fit_eq = 'y = {:.3f} * x^3 {:+.3f} * x^2 {:+.3f} * x {:+.3f}'.format(*adcp_coeffs)
#    output_adcp_mgl = thrd_func(adcp_filt, *adcp_coeffs)
#    adcp_fit_text = 'Third Order Fit'


# r squared calculations

turb_err = (turb_ffit_y[1:-1] - isco_perc) # predicted minus observed
turb_r_num = np.sum(turb_err ** 2) # sum of errors squared
turb_r_den = np.sum((isco_perc - np.mean(isco_perc)) ** 2) # sum of squared distances from mean
turb_r_squ = (1 - (turb_r_num / turb_r_den)) ** 2
turb_r_text = 'R^2 = {:.2f}'.format(turb_r_squ)

#adcp_err = (adcp_ffit_y[1:-1] - isco_perc)
#adcp_r_num = np.sum(adcp_err **2)
#adcp_r_den = np.sum((isco_perc - np.mean(isco_perc)) ** 2)
#adcp_r_squ = (1 - (adcp_r_num / adcp_r_den)) ** 2
#adcp_r_text = 'R^2 = {:.2f}'.format(adcp_r_squ)

# resample calibrated time series, this makes the plots prettier
calib_turb = output_turb_mgl.resample('1H').mean()
#calib_adcp = output_adcp_mgl.resample('1H').mean()


#%% plots

# close any existing plots
plt.close('all')


# generate a new figure object
fig2 = plt.figure(figsize=(11,8.5))

# generate a new subplot for turbidity histogram
ax0 = plt.subplot2grid((4,6),(0,0),colspan=2)
ax0.hist(turb_filt.values,100/bin_size) # plot histogram
ax0.set_title('{} Turbidity Histogram'.format(site_name.upper()))
ax0.set_xlabel('Turbidity NTU')
ax0.set_ylabel('Counts')

#ax0.grid('on')

# generate a new subplot for isco histogram
ax1 = plt.subplot2grid((4,6),(0,2),colspan=2)
ax1.hist(isco_filt.values,100/bin_size) # plot histogram
ax1.set_title('{} ISCO Histogram'.format(site_name.upper()))
ax1.set_xlabel('ISCO mg/L')
ax1.set_ylabel('Counts')
#ax1.grid('on')

# generate a new subplot for adcp intensity histogram
#ax2 = plt.subplot2grid((4,6),(0,4),colspan=2)
#ax2.hist(adcp_filt.values,100/bin_size) # plot histogram
#ax2.set_title('{} HADCP Histogram'.format(site_name.upper()))
#ax2.set_xlabel('ADCP Intensity')
#ax2.set_ylabel('Counts')
#ax2.grid('on')

# generate a new suplot for turbidity-isco correlation
ax3 = plt.subplot2grid((4,6),(1,0),colspan=3)
ax3.plot(turb_ffit_x, turb_ffit_y, 'r--') # plot polyfit function
ax3.plot(turb_perc, isco_perc, 'b.', markersize=10) # plot percentile correlation
ax3.set_xlabel('Turbidity NTU')
ax3.set_ylabel('ISCO mg/L')
ax3.set_title('{} Turbidity-ISCO Percentile Correlation'.format(site_name.upper()))
# add polyfit equation text
ax3.set_xlim(left=0)
ax3.set_ylim(bottom=0)
ax3.text(ax3.get_xlim()[1]*0.05, ax3.get_ylim()[1]*0.5, turb_fit_text + '\n' + turb_fit_eq + '\n' + turb_r_text, backgroundcolor=((1, 1, 1, 0.5)))
ax3.grid('on')

# generate a new subplot for adcp-isco correlation
#ax4 = plt.subplot2grid((4,6),(1,3),colspan=3)
#ax4.plot(adcp_ffit_x, adcp_ffit_y, 'r--') # plot polyfit function
#ax4.plot(adcp_perc, isco_perc, 'b.', markersize=10) # plot percentile correlation
#ax4.set_xlabel('ADCP Intensity')
#ax4.set_ylabel('ISCO mg/L')
#ax4.set_title('{} ADCP-ISCO Percentile Correlation'.format(site_name.upper()))
## add polyfit equation text
#ax4.set_xlim(left=0)
#ax4.set_ylim(bottom=0)
#ax4.text(ax4.get_xlim()[1]*0.05, ax4.get_ylim()[1]*0.35, adcp_fit_text + '\n' + adcp_fit_eq + '\n' + adcp_r_text + '\n' + rangetext, backgroundcolor=((1, 1, 1, 0.5)))
#ax4.grid('on')

# generate a new subplot for time series
ax5 = plt.subplot2grid((4, 6), (2, 0), colspan=6, rowspan=2)
#ax5.plot(calib_adcp, 'g-', label='Calibrated ADCP') # plot adcp time series
ax5.plot(calib_turb, 'b-', label='Calibrated Turbidity') # plot turbidity series
ax5.plot(isco_filt, 'r.', markersize=10, label='ISCO') # plot isco samples
ax5.set_xlabel('Date')
ax5.set_ylabel('SSC, mg/L')
ax5.set_ylim(bottom=0)
#ax5.set_xlim(timestart,timeend)
ax5.legend(numpoints=1, loc='best')
ax5.set_title('{} Time Series'.format(site_name.upper()))
ax5.xaxis.set_major_formatter(dates.DateFormatter('%d %b'))
ax5.grid('on')
plt.tight_layout(pad=1)
plt.show

