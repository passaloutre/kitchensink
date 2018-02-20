#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 10 16:45:38 2016

@author: mtr
"""
import numpy as np
import pandas as pd
import scipy.optimize as opt
import matplotlib.pyplot as plt
plt.rc('lines', lw=2)

# %% user inputs

site_name = 'tcw'

# processing parameters
bin_size       = 10       # size of percentile bins for histogram
turb_threshold = 1000     # cut off turbidity values greater than
adcp_threshold = 0       # cut off adcp intensities less than
turb_fit_type  = 'lin'   # 'lin' or 'quad' or 'exp'
adcp_fit_type  = 'exp'   # 'lin' or 'quad' or 'exp'

# windows directories
input_dir      = 'e:/projects/mobile/2017/'
output_dir     = 'e:/projects/mobile/2017/output/'

## linux directories
#input_dir      = '/mnt/data/Projects/Mobile/' # directory with input pickles
#output_dir     = '/mnt/data/Projects/Mobile/output/' # directory to save figs

# %% import pickle, faster than reading the xlsx

adcp = pd.read_pickle('{}{}_hadcp_2017.pkl'.format(input_dir, site_name))
isco = pd.read_pickle('{}{}_isco_2017.pkl'.format(input_dir, site_name))
turb = pd.read_pickle('{}{}_turb_2017.pkl'.format(input_dir, site_name))

## copy and resample time series for analysis, leave raw series alone
adcp_filt = adcp.resample('60T').mean().dropna()
isco_filt = isco.resample('60T').mean().dropna()
turb_filt = turb.resample('60T').mean().dropna()

#%% data processing loop

# filter turbidity
turb = turb[turb['turb_NTU'] < turb_threshold]
turb_filt = turb_filt[turb_filt['turb_NTU'] < turb_threshold]

# average adcp bins
adcp = pd.DataFrame(adcp.ix[:, 9:79].mean(axis=1))
adcp = adcp[adcp > adcp_threshold].dropna()
adcp_filt = pd.DataFrame(adcp_filt.ix[:, 9:79].mean(axis=1))
adcp_filt = adcp_filt[adcp_filt > adcp_threshold].dropna()

# initialize output lists
isco_perc = np.zeros(100//bin_size) # // denotes integer division
turb_perc = np.zeros(100//bin_size)
adcp_perc = np.zeros(100//bin_size)

# add percentile values to output lists
for i in range(100//bin_size):
    isco_perc[i] = np.percentile(isco_filt, i * bin_size)
    turb_perc[i] = np.percentile(turb_filt, i * bin_size)
    adcp_perc[i] = np.percentile(adcp_filt, i * bin_size)

#%% calibration fits

# linear fits

def lin_func(x, a, b):
    return(a * x + b)

if turb_fit_type == 'lin':
    turb_coeffs, turb_cov = opt.curve_fit(lin_func, turb_perc, isco_perc)
    turb_ffit = lin_func(turb_perc, *turb_coeffs)
    turb_fit_eq = 'y = {:.4f} * x + {:.4f}'.format(*turb_coeffs)
    output_turb_mgl = lin_func(turb, *turb_coeffs)
if adcp_fit_type == 'lin':
    adcp_coeffs, adcp_cov = opt.curve_fit(lin_func, adcp_perc, isco_perc)
    adcp_ffit = lin_func(adcp_perc, *adcp_coeffs)
    adcp_fit_eq = 'y = {:.4f} * x + {:.4f}'.format(*adcp_coeffs)
    output_adcp_mgl = lin_func(adcp, *adcp_coeffs)

# quadratic fits

def quad_func(x, a, b, c):
    return(a * x **2 + b * x + c)

if turb_fit_type == 'quad':
    turb_coeffs, turb_cov = opt.curve_fit(quad_func, turb_perc, isco_perc)
    turb_ffit = quad_func(turb_perc, *turb_coeffs)
    turb_fit_eq = 'y = {:.2} * x ** 2 + {:.2} * x + {:.4f}'.format(*turb_coeffs)
    output_turb_mgl = quad_func(turb, *turb_coeffs)
if adcp_fit_type == 'quad':
    adcp_coeffs, adcp_cov = opt.curve_fit(quad_func, adcp_perc, isco_perc)
    adcp_ffit = quad_func(adcp_perc, *adcp_coeffs)
    adcp_fit_eq = 'y = {:.2} * x ** 2 + {:.2} * x + {:.4f}'.format(*adcp_coeffs)
    output_adcp_mgl = quad_func(adcp, *adcp_coeffs)

# exponential fits

def exp_func(x, a, b):
    return(a * np.exp(b/10 * x))

if turb_fit_type == 'exp':
    turb_coeffs, turb_cov = opt.curve_fit(exp_func, turb_perc, isco_perc)
    turb_ffit = exp_func(turb_perc, *turb_coeffs)
    turb_fit_eq = 'y = {:.4f} * $e^({:.4f} * x)$'.format(turb_coeffs[0],turb_coeffs[1]/10)
    output_turb_mgl = exp_func(turb, *turb_coeffs)
if adcp_fit_type == 'exp':
    adcp_coeffs, adcp_cov = opt.curve_fit(exp_func, adcp_perc, isco_perc)
    adcp_ffit = exp_func(adcp_perc, *adcp_coeffs)
    adcp_fit_eq = 'y = {:.5f} * e^({:.4f} * x)'.format(adcp_coeffs[0],adcp_coeffs[1]/10)
    output_adcp_mgl = exp_func(adcp, *adcp_coeffs)

# r squared calculations

turb_err = (turb_ffit - isco_perc) # predicted minus observed
turb_r_num = np.sum(turb_err ** 2) # sum of errors squared
turb_r_den = np.sum((isco_perc - np.mean(isco_perc)) ** 2) # sum of squared distances from mean
turb_r_squ = (1 - (turb_r_num / turb_r_den)) ** 2

adcp_err = (adcp_ffit - isco_perc)
adcp_r_num = np.sum(adcp_err **2)
adcp_r_den = np.sum((isco_perc - np.mean(isco_perc)) ** 2)
adcp_r_squ = (1 - (adcp_r_num / adcp_r_den)) ** 2

# resample calibrated time series, this makes the plots prettier
#calib_turb = output_turb_mgl.resample('1H').mean()
#calib_adcp = output_adcp_mgl.resample('1H').mean()

#%% plots

# close any existing plots
plt.close('all')
plt.xkcd()
# generate a new figure object
fig1 = plt.figure(figsize=(11.5,8))

# generate a new subplot for turbidity histogram
ax0 = plt.subplot2grid((2,2),(0,0))
ax0.hist(isco_filt.values, 100//bin_size) # plot histogram
ax0.set_title('{} ISCO Histogram'.format(site_name.upper()))
ax0.set_xlabel('ISCO mg/L')
ax0.set_ylabel('Counts')
ax0.grid('off')

# generate a new subplot for isco histogram
ax1 = plt.subplot2grid((2,2),(0,1))
ax1.hist(turb_filt.values, 100//bin_size) # plot histogram
ax1.set_title('{} Turbidity Histogram'.format(site_name.upper()))
ax1.set_xlabel('Turbidity NTU')
ax1.set_ylabel('Counts')
ax1.grid('off')

# generate a new suplot for turbidity-isco correlation
ax3 = plt.subplot2grid((2,1),(1,0),colspan=2)
ax3.plot(turb_perc, isco_perc, 'o', label = 'Data') # plot percentile correlation
ax3.plot(turb_perc, turb_ffit, label = 'Fit') # plot fit function
ax3.set_xlabel('Turbidity NTU')
ax3.set_ylabel('ISCO mg/L')
ax3.set_title('{} Turbidity-ISCO Correlation'.format(site_name.upper()))
ax3.legend(loc = 'best', title='{}\n$r^2$ = {:.3f}'.format(turb_fit_eq, turb_r_squ))
ax3.grid('on')

plt.tight_layout(pad=1)
plt.show

# generate a new figure object
fig2 = plt.figure(figsize=(11.5,8))

# generate a new subplot for isco histogram
ax0 = plt.subplot2grid((2,2),(0,0))
ax0.hist(isco_filt.values, 100//bin_size) # plot histogram
ax0.set_title('{} ISCO Histogram'.format(site_name.upper()))
ax0.set_xlabel('ISCO mg/L')
ax0.set_ylabel('Counts')
ax0.grid('off')

# generate a new subplot for adcp intensity histogram
ax2 = plt.subplot2grid((2,2),(0,1))
ax2.hist(adcp_filt.values,100//bin_size) # plot histogram
ax2.set_title('{} HADCP Histogram'.format(site_name.upper()))
ax2.set_xlabel('ADCP Intensity')
ax2.set_ylabel('Counts')
ax2.grid('off')

# generate a new subplot for adcp-isco correlation
ax4 = plt.subplot2grid((2,2),(1,0),colspan=2)
ax4.plot(adcp_perc, isco_perc, 'o',label = 'Data') # plot percentile correlation
ax4.plot(adcp_perc, adcp_ffit, label = 'Fit') # plot fit function
ax4.set_xlabel('ADCP Intensity')
ax4.set_ylabel('ISCO mg/L')
ax4.set_title('{} ADCP-ISCO Correlation'.format(site_name.upper()))
#ax4.set_xlim(40,80)
ax4.set_ylim(bottom=0)
#ax4.text(ax4.get_xlim()[0] + (ax4.get_xlim()[1] - ax4.get_xlim()[0]) * 0.01, ax4.get_ylim()[1]*0.7, adcp_fit_eq)
ax4.legend(loc = 'best', title='{}\n$r^2$ = {:.3f}'.format(adcp_fit_eq, adcp_r_squ))
ax4.grid('on')

plt.tight_layout(pad=1)
plt.show

##%% save time series as .csv
#
#output_turb_mgl.columns = ['turb_mg/L']
#output_adcp_mgl.columns = ['adcp_mg/L']
#
#output_turb_mgl.to_csv(path_or_buf='{}{}_turb_mgl.csv'.format(output_dir, site_name))
#output_adcp_mgl.to_csv(path_or_buf='{}{}_adcp_mgl.csv'.format(output_dir, site_name))
#
# save figures as .png

#fig1.savefig('{}{}_turb_fig.png'.format(output_dir,site_name))
#fig2.savefig('{}{}_adcp_fig.png'.format(output_dir, site_name))