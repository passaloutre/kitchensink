#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Nov  5 16:54:45 2017

@author: mtr
"""

import numpy as np
import os
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import pandas as pd
import time

os.chdir('/mnt/data/Projects/diss/belle_chasse')

turb_cols = ['agency','siteno','dt','turb_min','turb_min_cd','turb_mean','turb_mean_cd','turb_max','turb_max_cd','gage','gage_cd','cfs','cfs_cd']
turb = pd.read_csv('turbidity.txt',header=33,delimiter='\t',names=turb_cols,skiprows=1,parse_dates=['dt'])


boat_cols = ['agency','siteno','bdate','btime','edate','etime','tdatum','tdatum_cd','asc_cd','med_cd','tuid','bodypart','param','remark','value','method','quality','level','leveltype','std','anal']
boat = pd.read_csv('boat_data.txt',header=82,delimiter='\t',names=boat_cols,index_col=False,parse_dates=[['bdate','btime']])
#boat.dt = boat.bdate + ' ' + boat.btime

turb.set_index(pd.DatetimeIndex(turb['dt']),inplace=True)
boat.set_index(pd.DatetimeIndex(boat['bdate_btime']),inplace=True)

'''
fig1 = plt.figure()
ax1 = plt.subplot(2,1,1)
plt.plot(turb.dt,turb.turb_mean)
plt.xlabel('Date')
plt.ylabel('Turb')
plt.xlim(np.datetime64('2012-09-01'),np.datetime64('2015-12-31'))
plt.grid()

ax2 = plt.subplot(2,1,2)
plt.plot(boat.bdate_btime,boat.value,'*')
plt.xlabel('Date')
plt.ylabel('Q_s, tons/day')
plt.xlim(np.datetime64('2012-09-01'),np.datetime64('2015-12-31'))
plt.grid()
plt.tight_layout()

'''
window_pair = np.zeros((len(boat),2))
for i in range(len(boat)):
    window = [boat.bdate_btime[i]-np.timedelta64(1,'D'),boat.bdate_btime[i]+np.timedelta64(1,'D')]
    mask = (turb.dt > window[0]) & (turb.dt < window[1])
    
    window_pair[i,:] = [boat.value[i],np.nanmean((turb.turb_mean[window[0]:window[1]]))]

pairs = pd.DataFrame(data=window_pair,index=boat.index,columns=['boat','turb']).dropna(axis=0)
mask = (pairs.turb > 8) & (pairs.boat < 800000)
pairs = pairs[mask]

#%%
fig1 = plt.figure()
ax1 = plt.subplot(111)

plt.scatter((pairs.turb),(pairs.boat),c=pairs.index.month,marker='*')

p = np.polyfit(pairs.turb,pairs.boat,1)
faketurb = np.arange(np.min(pairs.turb),np.max(pairs.turb))
fakeboat = np.polyval(p,faketurb)

plt.plot(faketurb,fakeboat,'--')

sse = np.sum((pairs.boat - np.polyval(p,pairs.turb))**2)
sst = np.sum((pairs.boat - np.mean(pairs.boat))**2)
r2 = 1 - (sse/sst)

label = ('y = {:.2f} * x + {:.2f}\nR^2 = {:.2f}'.format(p[0],p[1],r2))
plt.text(0.05, 0.9, label, transform=ax1.transAxes)
plt.grid()

#%%

newturb = pd.DataFrame({'turb' : turb.turb_mean, 'turb_regress' : np.polyval(p, turb.turb_mean)},index=turb.dt)

fig2 = plt.figure()
ax2 = plt.subplot(111)
plt.plot(newturb.turb_regress,label='Q_s from OBS')
plt.plot(boat.value,'*', label='Q_s from boat-measurement')
plt.xlim('2012-09-01','2015-12-31')
plt.ylim(0,1000000)
plt.legend()
plt.xticks(pd.date_range('2012-09-01','2015-12-31',freq='m'))
ax2.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m-%d'))
fig2.autofmt_xdate()
#newturb.to_csv('/mnt/data/Projects/diss/belle_chasse/calibrated_obs.txt')