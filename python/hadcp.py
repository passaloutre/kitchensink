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

# %% import raw isco data
'''
os.chdir('/home/mtr/Documents')

isco = pd.read_excel('ISCO_Turb_HADCP.xlsx', sheetname='SMR_ISCO',
                     header=0, index_col=0).dropna()

# %% save as pickle

isco.to_pickle('smr_isco.pkl')
'''
# %% import raw hadcp data
'''
os.chdir('/home/mtr/Documents')

adcp = pd.read_excel('ISCO_Turb_HADCP.xlsx', sheetname='SMR_HADCP',
                     header=0, index_col=0)

# %% save as pickle for faster reloading later

adcp.to_pickle('smr_hadcp.pkl')
'''

# %% import pickle, faster than rereading the xlsx

adcp = pd.read_pickle('smr_hadcp.pkl')
isco = pd.read_pickle('smr_isco.pkl')

# %% plot time series

fig, ax = plt.subplots(2,1,sharex=True)
fig.suptitle('ADCP-ISCO Correlation')
ax[0].set_title('HADCP Ensemble-Averaged Echo Intensity, counts')
ax[0].plot(adcp.ix[:,10:80].mean(axis=1),linewidth=1)

ax[1].set_title('ISCO Sample SSC, mg/L')
ax[1].plot(isco, 'r.', marker='o',markersize=5)

# %% correlation processing

window = 5 # minutes

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
        avg_adcp = window_adcp.ix[:,10:80].mean(axis=1).mean(axis=0)
        print(index,window_isco,avg_adcp)
        window_pair = (window_isco,avg_adcp)
        # add paired isco and turbidity values to list of points
        corr.append([*window_pair])

# convert list of points to array for plotting
corr = np.asarray(corr)

fig, ax = plt.subplots()
ax.scatter(corr[:,0],corr[:,1])
ax.set_xlabel('ISCO SSC')
ax.set_ylabel('ADCP Intensity')

regressx = np.arange(len(corr[:,0]))
slope, intercept, rsq, *__ = stats.linregress(corr[:,0],corr[:,1])
regressy = regressx*slope + intercept
ax.plot(regressx,regressy)
text_loc = (ax.get_xlim()[0] + 0.1 * (ax.get_xlim()[1] - ax.get_xlim()[0]),
            ax.get_ylim()[0] + 0.1 * (ax.get_ylim()[1] - ax.get_ylim()[0]))
ax.text(*text_loc, 'R^2 = {:.4f}'.format(rsq**2), bbox={'facecolor':'w'})
# %%

fig, ax = plt.subplots()
fig.suptitle('HADCP Echo Intensity')
ax.plot(adcp.mean(axis=0), label='Raw Intensity')
regressx = np.arange(len(adcp.mean(axis=0)))
slope, intercept, rsq, *__ = stats.linregress(regressx,adcp.mean(axis=0))
regressy = slope*regressx + intercept
ax.plot(regressx,regressy, label='Linear Regression')
flatadcp = adcp.mean(axis=0) + (regressy[0]-regressy)
ax.plot(flatadcp, label='Flattened Intensity')
ax.set_xlabel('Bin')
ax.set_ylabel('Echo Intensity')
ax.legend(loc='best')

plt.show()
