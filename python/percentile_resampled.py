#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 10 16:45:38 2016

@author: mtr
"""

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import os

# %% user inputs

site_name = 'ar'

# processing parameters
bin_size =       1
turb_fit_order = 3
adcp_fit_order = 2
turb_threshold = 100
percent_labels = 0  # 0 or 1 , on or off

# %% import pickle, faster than reading the xlsx

#os.chdir('/home/rdchlmtr/Documents')
os.chdir('e:/Projects/Mobile/2017')

adcp = pd.read_pickle('{}_hadcp_2017.pkl'.format(site_name))
isco = pd.read_pickle('{}_isco_2017.pkl'.format(site_name))
turb = pd.read_pickle('{}_turb_2017.pkl'.format(site_name))

#%% data processing loop

# filter turbidity
turb = turb[turb.turb_NTU < turb_threshold]

# average adcp bins
adcp = pd.DataFrame(adcp.ix[:,0:4].mean(axis=1))

# initialize output lists
isco_perc = []
turb_perc = []
adcp_perc =  []

# add percentile values to output lists
for i in range(0, 100, bin_size):
    isco_perc.append(np.percentile(isco, i))
    turb_perc.append(np.percentile(turb, i))
    adcp_perc.append(np.percentile(adcp, i))
#isco_perc.append(np.max(isco))
#turb_perc.append(np.max(turb))
#adcp_perc.append(np.max(adcp))

#%% calibration fits

# use polyfit to calulate polynomial coefficients
turb_coeffs = np.polyfit(turb_perc, isco_perc, turb_fit_order)
adcp_coeffs = np.polyfit(adcp_perc, isco_perc, adcp_fit_order)

# calculate regression functions from polynomials
turb_ffit = np.polyval(turb_coeffs, turb_perc)
adcp_ffit = np.polyval(adcp_coeffs, adcp_perc)

# apply regression to original time series datasets
if turb_fit_order == 1:
    calib_turb = turb * turb_coeffs[0] + turb_coeffs[1]
if turb_fit_order == 2:
    calib_turb = (turb ** 2) * turb_coeffs[0] + turb * turb_coeffs[1] + turb_coeffs[2]
if adcp_fit_order == 1:
    calib_adcp = adcp * adcp_coeffs[0] + adcp_coeffs[1]
if adcp_fit_order == 2:
    calib_adcp = (adcp ** 2) * adcp_coeffs[0] + adcp * adcp_coeffs[1] + adcp_coeffs[2]

# resample calibrated time series, this makes the plots prettier
calib_turb = calib_turb.resample('1H').mean()
calib_adcp = calib_adcp.resample('1H').mean()

#adcp_err = (calib_adcp - isco_perc)
#adcp_r_num = np.sum(adcp_err **2)
#adcp_r_den = np.sum((isco_perc - np.mean(isco_perc)) ** 2)
#adcp_r_squ = (1 - (adcp_r_num / adcp_r_den)) ** 2

#%% plots

# close any existing plots
#plt.close('all')

# generate a new figure object
fig2 = plt.figure(figsize=(11.5,8))

# generate a new subplot for turbidity histogram
ax0 = plt.subplot2grid((4,6),(0,0),colspan=2)
ax0.hist(turb.values,100/bin_size) # plot histogram
ax0.set_title('{} Turbidity Histogram'.format(site_name.upper()))
ax0.set_xlabel('Turbidity NTU')
ax0.set_ylabel('Counts')

# generate a new subplot for isco histogram
ax1 = plt.subplot2grid((4,6),(0,2),colspan=2)
ax1.hist(isco.values,100/bin_size) # plot histogram
ax1.set_title('{} ISCO Histogram'.format(site_name.upper()))
ax1.set_xlabel('ISCO mg/L')
ax1.set_ylabel('Counts')

# generate a new subplot for adcp intensity histogram
ax2 = plt.subplot2grid((4,6),(0,4),colspan=2)
ax2.hist(adcp.values,100/bin_size) # plot histogram
ax2.set_title('{} HADCP Histogram'.format(site_name.upper()))
ax2.set_xlabel('ADCP Intensity')
ax3.set_ylabel('Counts')

# generate a new suplot for turbidity-isco correlation
ax3 = plt.subplot2grid((4,6),(1,0),colspan=3)
ax3.plot(turb_perc, isco_perc, 'bo') # plot percentile correlation
ax3.plot(turb_perc, turb_ffit, 'r-') # plot polyfit function
ax3.set_xlabel('Turbidity NTU')
ax3.set_ylabel('ISCO mg/L')
ax3.set_title('{} Turbidity-ISCO Correlation'.format(site_name.upper()))
# add polyfit equation text
if turb_fit_order == 1:
    turb_fit_eq = 'y = {:.3f} * x + {:.3f}\nPolyfit Order {}'.format(*turb_coeffs,turb_fit_order)
if turb_fit_order == 2:
    turb_fit_eq = 'y = {:.3f} * x ** 2 + {:.3f} * x + {:.3f}\nPolyfit Order {}'.format(*turb_coeffs,turb_fit_order)
ax3.set_xlim(left=0)
ax3.set_ylim(bottom=0)
ax3.text(ax3.get_xlim()[1]*0.01, ax3.get_ylim()[1]*0.7, turb_fit_eq)

# generate a new subplot for adcp-isco correlation
ax4 = plt.subplot2grid((4,6),(1,3),colspan=3)
ax4.plot(adcp_perc, isco_perc, 'bo') # plot percentile correlation
ax4.plot(adcp_perc, adcp_ffit, 'r-') # plot polyfit function
ax4.set_xlabel('ADCP Intensity')
ax4.set_ylabel('ISCO mg/L')
ax4.set_title('{} ADCP-ISCO Correlation'.format(site_name.upper()))
# add polyfit equation text
if adcp_fit_order == 1:
    adcp_fit_eq = 'y = {:.3f} * x + {:.3f}\nPolyfit Order {}'.format(*adcp_coeffs,adcp_fit_order)
if adcp_fit_order == 2:
    adcp_fit_eq = 'y = {:.3f} * x ** 2 + {:.3f} * x + {:.3f}\nPolyfit Order {}'.format(*adcp_coeffs,adcp_fit_order)
ax4.set_xlim(left=0)
ax4.set_ylim(bottom=0)
ax4.text(ax4.get_xlim()[1]*0.01, ax4.get_ylim()[1]*0.7, adcp_fit_eq)

# generate a new subplot for time series
ax5 = plt.subplot2grid((4, 6), (2, 0), colspan=6, rowspan=2)
ax5.plot(calib_adcp, 'g-', label='Calibrated ADCP') # plot adcp time series
ax5.plot(calib_turb, 'b-', label='Calibrated Turbidity') # plot turbidity series
ax5.plot(isco, 'r.', label='ISCO') # plot isco samples
ax5.set_xlabel('Date')
ax5.set_ylabel('SSC, mg/L')
ax5.set_ylim(bottom=0)
ax5.legend(numpoints=1, loc='best')
ax5.set_title('{} Time Series'.format(site_name.upper()))

plt.tight_layout(pad=0)
plt.show

