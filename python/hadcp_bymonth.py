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
import datetime as dt
from scipy import stats

plt.close('all')

# %%

site_name = 'nmr'  # user input site name


# %% import and pickle raw data
'''
os.chdir('/home/mtr/Documents')

isco = pd.read_table('{}_isco.csv'.format(site_name), delimiter=',',
                     header=0, index_col=0, parse_dates=True).dropna()
isco.to_pickle('{}_isco.pkl'.format(site_name))
print('{} ISCO imported'.format(site_name))
turb = pd.read_table('{}_turb.csv'.format(site_name), delimiter=',',
                     header=0, index_col=0, parse_dates=True).dropna()
turb.to_pickle('{}_turb.pkl'.format(site_name))
print('{} TURB imported'.format(site_name))
adcp = pd.read_table('{}_hadcp.csv'.format(site_name), delimiter=',',
                     header=0, index_col=0, parse_dates=True).dropna()
adcp.to_pickle('{}_hadcp.pkl'.format(site_name))
print('{} HADCP imported'.format(site_name))
'''
# %% import pickle, faster than rereading the xlsx

os.chdir('E:/Projects/Mobile/2017/')

adcp = pd.read_pickle('{}_hadcp_2017.pkl'.format(site_name))
isco = pd.read_pickle('{}_isco_2017.pkl'.format(site_name))
#turb = pd.read_pickle('{}_turb.pkl'.format(site_name))

# %% plot time series

fig = plt.figure(figsize=((15,10)))

ax0 = plt.subplot2grid((4,2),(0,0))
ax0.set_title('HADCP Ensemble-Averaged Echo Intensity, counts')
ax0.plot(adcp.ix[:,10:80].mean(axis=1),linewidth=1)

ax1 = plt.subplot2grid((4,2),(1,0), sharex=ax0)
ax1.set_title('ISCO Sample SSC, mg/L')
ax1.plot(isco, 'r.', marker='o',markersize=5)

# %% correlation processing

isco_jan = isco.ix['2017-01-01':'2017-01-31']

window = 120 # minutes

corr = []

# loop through isco sample times +/- window time
for index, row in isco.iterrows():
    start = index - dt.timedelta(minutes=window/2)
    stop = index + dt.timedelta(minutes=window/2)

    # find isco concentration at index
    window_isco = isco.ix[index,0]

    # find hadcp measurements within sampling window
    window_adcp = (adcp.sort_index().ix[start:stop])

    # if there are measurements in window, average them and add to list
    if len(window_adcp) > 0:
        avg_adcp = window_adcp.ix[:,150:80].mean(axis=1).mean(axis=0)
#        print(index,window_isco,avg_adcp)
        window_pair = (avg_adcp, window_isco)
        # add paired isco and turbidity values to list of points
        corr.append([*window_pair])

# convert list of points to array for plotting
corr = np.asarray(corr)


ax2 = plt.subplot2grid((4,2),(0,1),rowspan=2)
ax2.scatter(corr[:,0],corr[:,1])
ax2.set_xlabel('ADCP Intensity')
ax2.set_ylabel('ISCO SSC')
ax2.set_title('ISCO-ADCP Correlation')

regressx = np.arange(np.min(corr[:,0]),np.max(corr[:,0]))
slope, intercept, rsq, *__ = stats.linregress(corr[:,0],corr[:,1])
regressy = regressx*slope + intercept
ax2.plot(regressx,regressy)

text_loc = (ax2.get_xlim()[0] + 0.1 * (ax2.get_xlim()[1] - ax2.get_xlim()[0]),
            ax2.get_ylim()[0] + 0.1 * (ax2.get_ylim()[1] - ax2.get_ylim()[0]))
ax2.text(*text_loc, 'R^2 = {:.4f}'.format(rsq**2), bbox={'facecolor':'w'})

# %%

ax3 = plt.subplot2grid((4,2),(2,0),colspan=2,rowspan=2)
ax3.set_title('Month-Averaged ADCP ECHO Intensity')
ax3.plot(adcp.ix['2016-05-01':'2016-05-31'].mean(axis=0), label='May 2016')
ax3.plot(adcp.ix['2016-06-01':'2016-06-30'].mean(axis=0), label='June 2016')
ax3.plot(adcp.ix['2016-07-01':'2016-07-31'].mean(axis=0), label='July 2016')
ax3.plot(adcp.ix['2016-08-01':'2016-08-30'].mean(axis=0), label='Aug 2016')
ax3.plot(adcp.ix['2016-09-01':'2016-09-30'].mean(axis=0), label='Sept 2016')
ax3.plot(adcp.ix['2016-10-01':'2016-10-31'].mean(axis=0), label='Oct 2016')
ax3.plot(adcp.ix['2016-05-01':'2016-10-31'].mean(axis=0), label='Average',
         linewidth=3, color='k')
ax3.set_xlabel('Bin #')
ax3.set_ylabel('Echo Intensity')
ax3.legend(loc='best')

fig.suptitle('{}'.format(site_name.upper()))
fig.tight_layout()
plt.show()