#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 10 16:45:38 2016

@author: mtr
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as dates
import pandas as pd
import os
import datetime as dt
from scipy import stats

#plt.close('all')
#plt.xkcd()

# %% import pickle, faster than rereading the xlsx

site_name = 'smr'  # user input site name

turb_threshold = 120
turb_smooth = 10

datastart = '2016-01-01 00:00:00'
datastop  = '2018-02-12 15:00:00'

os.chdir('E:/Projects/Mobile/smr2016/')

#adcp = pd.read_pickle('{}_hadcp_2017.pkl'.format(site_name))
isco = pd.read_pickle('{}_isco_2016.pkl'.format(site_name))
turb = pd.read_pickle('{}_turb_2016.pkl'.format(site_name))
#turb = pd.read_pickle('tr_turb_mod.pkl')
#%%
#adcp = adcp.ix[datastart:datastop]
isco = isco.ix[datastart:datastop]
turb = turb.ix[datastart:datastop]

turb = turb[turb['Turbidity_NTU'] < turb_threshold]

# smoothing
turb = turb.rolling(center=True,window=turb_smooth).mean()

# masking
if site_name == 'nmr':
    turb_ind0 = turb.index > '2017-02-01'
    turb_ind1 = turb.index < '2017-04-01'
    turb_ind2 = turb.values > 75
    turb_ind2 = turb_ind2[:,0]
    turb[turb_ind0 & turb_ind1 & turb_ind2] = np.nan
elif site_name == 'tr':
    turb_ind0 = turb.index > '2017-02-08'
    turb_ind1 = turb.index < '2017-03-16 18:00:00'
    turb_ind2 = turb.index > '2017-03-27'
    turb_ind3 = turb.index < '2017-03-30'
    turb[(turb_ind0 & turb_ind1) | (turb_ind2 & turb_ind3)] = np.nan

## %% plot time series
#
#fig = plt.figure(figsize=((15,8)))
#
#ax0 = plt.subplot2grid((2,2),(0,0))
##ax0.set_title('HADCP Ensemble-Averaged Echo Intensity, counts')
##ax0.plot(adcp.ix[:,0:90].mean(axis=1),linewidth=1)
#ax0.plot(turb,linewidth=1)
#ax0.set_title('{} Turbidity, NTU'.format(site_name.upper()))
#
#ax1 = plt.subplot2grid((2,2),(1,0), sharex=ax0)
#ax1.set_title('{} ISCO Sample SSC, mg/L'.format(site_name.upper()))
#ax1.plot(isco, 'r.', marker='o',markersize=5)
#ax1.xaxis.set_major_formatter(dates.DateFormatter('%m/%d'))

# %% correlation processing

window = 120 # minutes

corr = []

# loop through isco sample times +/- window time
for index, row in isco.iterrows():
    start = index - dt.timedelta(minutes=window/2)
    stop = index + dt.timedelta(minutes=window/2)

    # find isco concentration at index
    window_isco = isco.ix[index,0]

    # find hadcp measurements within sampling window
#    window_adcp = (adcp.sort_index().ix[start:stop])

    window_turb = (turb.sort_index().ix[start:stop])

    # if there are measurements in window, average them and add to list
#    if len(window_adcp) > 0:
#        avg_adcp = window_adcp.ix[:,10:80].mean(axis=1).mean(axis=0)
##        print(index,window_isco,avg_adcp)
#        window_pair = (avg_adcp, window_isco)
#        # add paired isco and turbidity values to list of points
#        corr.append([*window_pair])

    if len(window_turb) > 0:
        avg_turb = window_turb.ix[:,0].mean(axis=0)

        window_pair = (avg_turb, window_isco)

        corr.append([*window_pair])

# convert list of points to array for plotting
corr = np.asarray(corr)

corr_ind = ~np.isnan(corr[:,0])
corr = corr[corr_ind,:]


#ax2 = plt.subplot2grid((1,2),(0,1),rowspan=2)
#ax2.scatter(corr[:,0],corr[:,1])
##ax2.set_xlabel('ADCP Intensity')
#ax2.set_xlabel('Turb NTU')
#ax2.set_ylabel('ISCO SSC')
#ax2.set_title('{} ISCO-Turb Correlation'.format(site_name.upper()))
#
#regressx = np.arange(np.min(corr[:,0]),np.max(corr[:,0]))
#slope, intercept, rsq, *__ = stats.linregress(corr[:,0],corr[:,1])
#

ind = np.isfinite(corr[:,1])
corr = corr[ind,:]

regressx = np.arange(np.nanmin(corr[:,0]),np.nanmax(corr[:,0]))
slope, intercept, rsq, *__ = stats.linregress(corr[:,0],corr[:,1])

turb_conv = turb * slope + intercept
#
#regressy = regressx*slope + intercept
#ax2.plot(regressx,regressy)
#ax2.set_ylim(bottom=0)
#ax2.set_xlim(left=0)
#text_loc = (ax2.get_xlim()[0] + 0.5 * (ax2.get_xlim()[1] - ax2.get_xlim()[0]),
#            ax2.get_ylim()[0] + 0.1 * (ax2.get_ylim()[1] - ax2.get_ylim()[0]))
#ax2.text(*text_loc, 'R^2 = {:.4f}\ny = {:.4f} * x + {:.4f}'.format(rsq**2,slope,intercept), bbox={'facecolor':'w'})

# %%

#ax3 = plt.subplot2grid((4,2),(2,0),colspan=2,rowspan=2)
#ax3.set_title('Month-Averaged ADCP ECHO Intensity')
#ax3.plot(adcp.ix['2016-05-01':'2016-05-31'].mean(axis=0), label='May 2016')
#ax3.plot(adcp.ix['2016-06-01':'2016-06-30'].mean(axis=0), label='June 2016')
#ax3.plot(adcp.ix['2016-07-01':'2016-07-31'].mean(axis=0), label='July 2016')
#ax3.plot(adcp.ix['2016-08-01':'2016-08-30'].mean(axis=0), label='Aug 2016')
#ax3.plot(adcp.ix['2016-09-01':'2016-09-30'].mean(axis=0), label='Sept 2016')
#ax3.plot(adcp.ix['2016-10-01':'2016-10-31'].mean(axis=0), label='Oct 2016')
#ax3.set_xlabel('Bin #')
#ax3.set_ylabel('Echo Intensity')
#ax3.legend(loc='best')

# %% plot time series

fig = plt.figure(num=1125,figsize=(15,8))

#%%

ax0 = plt.subplot2grid((2,2),(0,0))
#ax0.set_title('HADCP Ensemble-Averaged Echo Intensity, counts')
#ax0.plot(adcp.ix[:,0:90].mean(axis=1),linewidth=1)
ax0.plot(turb,linewidth=1)
ax0.set_title('{} Turbidity, NTU'.format(site_name.upper()))

ax1 = plt.subplot2grid((2,2),(1,0), sharex=ax0)
ax1.set_title('{} SSC, mg/L'.format(site_name.upper()))
ax1.plot(isco, 'r.', marker='o',markersize=5,zorder=1,label='Physical Sample')
ax1.plot(turb_conv,linewidth=1,zorder=0,label='Converted Turbidity')
ax1.xaxis.set_major_formatter(dates.DateFormatter('%Y/%m/%d'))
ax1.legend(loc='best')
ax1.set_ylim(bottom=0)

ax2 = plt.subplot2grid((1,2),(0,1),rowspan=2)
ax2.scatter(corr[:,0],corr[:,1])
#ax2.set_xlabel('ADCP Intensity')
ax2.set_xlabel('Turb NTU')
ax2.set_ylabel('ISCO SSC')
ax2.set_title('{} ISCO-Turb Correlation'.format(site_name.upper()))





regressy = regressx*slope + intercept
ax2.plot(regressx,regressy)
ax2.set_ylim(bottom=0)
ax2.set_xlim(left=0)
text_loc = (ax2.get_xlim()[0] + 0.06 * (ax2.get_xlim()[1] - ax2.get_xlim()[0]),
            ax2.get_ylim()[0] + 0.9 * (ax2.get_ylim()[1] - ax2.get_ylim()[0]))
ax2.text(*text_loc, 'R^2 = {:.4f}\ny = {:.4f} * x + {:.4f}'.format(rsq**2,slope,intercept), bbox={'facecolor':'w'})


fig.tight_layout()
plt.show()