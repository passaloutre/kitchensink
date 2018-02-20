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


# %% import pickle, faster than rereading the xlsx

site_name = 'ar'  # user input site name
datastart = '2017-01-18 19:00:00'
datastop = '2018-01-18 15:00:00'
binrange = [10,80]
os.chdir('E:/Projects/Mobile/2017/')

adcp = pd.read_pickle('{}_hadcp_2017.pkl'.format(site_name))
isco = pd.read_pickle('{}_isco_2017.pkl'.format(site_name))
turb = pd.read_pickle('{}_turb_2017.pkl'.format(site_name))

adcp = adcp.ix[datastart:datastop]
isco = isco.ix[datastart:datastop]
turb = turb.ix[datastart:datastop]

# %% plot time series

fig = plt.figure(figsize=((15,8)))

ax0 = plt.subplot2grid((2,2),(0,0))
ax0.set_title('HADCP Ensemble-Averaged Echo Intensity, counts')
ax0.plot(adcp.ix[:,binrange[0]:binrange[1]].mean(axis=1),linewidth=1)
#ax0.plot(turb,linewidth=1)
#ax0.set_title('Turbidity, NTU')


ax1 = plt.subplot2grid((2,2),(1,0), sharex=ax0)
ax1.set_title('ISCO Sample SSC, mg/L')
ax1.plot(isco, 'r.', marker='o',markersize=5)

# %% correlation processing

window = 15 # minutes

corr = []

# loop through isco sample times +/- window time
for index, row in isco.iterrows():
    start = index - dt.timedelta(minutes=window/2)
    stop = index + dt.timedelta(minutes=window/2)

    # find isco concentration at index
    window_isco = isco.ix[index,0]

    # find hadcp measurements within sampling window
    window_adcp = (adcp.sort_index().ix[start:stop])

    window_turb = (turb.sort_index().ix[start:stop])

#     if there are measurements in window, average them and add to list
    if len(window_adcp) > 0:
        avg_adcp = window_adcp.ix[:,binrange[0]:binrange[1]].mean(axis=1).mean(axis=0)
#        print(index,window_isco,avg_adcp)
        window_pair = (avg_adcp, window_isco)
        # add paired isco and turbidity values to list of points
        corr.append([*window_pair])

        # uncomment for turbidity correlation, comment adcp lines above
#    if len(window_turb) > 0:
#        avg_turb = window_turb.ix[:,0].mean(axis=0)
#
#        window_pair = (avg_turb, window_isco)
#
#        corr.append([*window_pair])

# convert list of points to array for plotting
corr = np.asarray(corr)


ax2 = plt.subplot2grid((1,2),(0,1),rowspan=2)
ax2.scatter(corr[:,0],corr[:,1])
ax2.set_xlabel('ADCP Intensity')
#ax2.set_xlabel('Turb NTU')
ax2.set_ylabel('ISCO SSC')
ax2.set_title('ISCO-HADCP Correlation')

regressx = np.arange(np.min(corr[:,0]),np.max(corr[:,0]))
slope, intercept, rsq, *__ = stats.linregress(corr[:,0],corr[:,1])
regressy = regressx*slope + intercept
ax2.plot(regressx,regressy)

text_loc = (ax2.get_xlim()[0] + 0.1 * (ax2.get_xlim()[1] - ax2.get_xlim()[0]),
            ax2.get_ylim()[0] + 0.1 * (ax2.get_ylim()[1] - ax2.get_ylim()[0]))
ax2.text(*text_loc, 'R^2 = {:.4f}'.format(rsq**2), bbox={'facecolor':'w'})

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

fig.tight_layout()
plt.show()