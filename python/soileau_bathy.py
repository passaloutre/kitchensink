# -*- coding: utf-8 -*-
"""
Created on Sun Feb 11 18:31:55 2018

@author: RDCHLMTR
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import os
from scipy import interpolate
from matplotlib.animation import FuncAnimation
from matplotlib.gridspec import GridSpec

plt.style.use('ggplot')

os.chdir('E:/Projects/diss/fullchannelmbs')

# from bathy
centerline = np.genfromtxt('output_centerline_depths.txt')[:100000,:]

hydrograph = pd.read_csv('E:/Projects/diss/hydrograph_bc.txt', names=(('date','cms')), parse_dates = [0])[0:366]
dq = np.insert(np.diff(hydrograph.cms), 0, 0)

# from soileau
rkm_tra1 = np.array([0,16,32,48,64,80,97,100]) * 1000. # with sill in place
cms_tra1 = np.array([8240.,7079,6272,5607,5069,4658,4318,4248]) # with sill

rkm_reg1 = np.array([0,16,32,48,64,80,91,98,99,100]) * 1000. # with sill
cms_reg1 = np.array([8240.,8226,8212,8184,8155,8141,7900,7079,5663,4248]) # with sill

rkm_pchip = np.arange(100000.)

cms_tra_pchip = interpolate.pchip_interpolate(rkm_tra1, cms_tra1, rkm_pchip)
cms_reg_pchip = interpolate.pchip_interpolate(rkm_reg1, cms_reg1, rkm_pchip)

test_q = np.zeros(len(hydrograph))
rk_head = np.zeros(len(hydrograph))
path = np.zeros(len(hydrograph))

for i in range(len(hydrograph)):
    
    if hydrograph.cms[i] >= max(cms_tra_pchip): # salt wedge is downstream of HOP
        rk_head[i] = 0
        
    elif (hydrograph.cms[i] < max(cms_tra_pchip)) & (hydrograph.cms[i] >= min(cms_tra_pchip)): # discharge within curve range
        j = np.abs(cms_tra_pchip - hydrograph.cms[i]).argmin()
        rk_head[i] = rkm_pchip[j]
            
        if dq[i] > 0: # if regressing

#         find index along regressive curve for current river km
            i_qtobeat = (np.abs(rkm_pchip - rk_head[i])).argmin()
            test_q[i] = cms_reg_pchip[i_qtobeat]
            if hydrograph.cms[i] > test_q[i]:
                j  = np.abs(cms_reg_pchip - hydrograph.cms[i]).argmin()
                rk_head[i] = rkm_pchip[j];
                path[i] = 1
            else:
                rk_head[i] = rk_head[i-1] - 5 * dq[i]
                path[i] = 2

#%%
def animate(i):
    hydropoint.set_xdata(hydrograph.date[i])
    hydropoint.set_ydata(hydrograph.cms[i])

#    bedpoint.set_xdata([rk_head[i],rk_head[i]])
    bedpoint.set_xdata(rk_head[i])
    bedpoint.set_ydata(centerline[int(rk_head[i]),1])
        
    if path[i] == 0:
        locpoint.set_xdata(cms_tra_pchip[int(rk_head[i])])
        locpoint.set_ydata(rk_head[i])
        locpoint.set_color('black')
        bedpoint.set_color('black')
    elif path[i] == 1:
        locpoint.set_xdata(cms_reg_pchip[int(rk_head[i])])
        locpoint.set_ydata(rk_head[i])
        locpoint.set_color('white')
        bedpoint.set_color('white')
    elif path[i] == 2:
        locpoint.set_xdata(cms_tra_pchip[int(rk_head[i])])
        locpoint.set_ydata(rk_head[i])
        locpoint.set_color('white')
        bedpoint.set_color('white')

fig = plt.figure(figsize=(10,6))
gs = GridSpec(2,2)

ax1 = plt.subplot(gs[0,0])
ax1.set(xlim=(0, 100000), ylim=(-60, 3))

ax2 = plt.subplot(gs[0,1])
ax2.set(xlim=(4000, 9000), ylim=(0, 110000))

ax3 = plt.subplot(gs[1,:])
ax3.set(xlim=(np.min(hydrograph.date),np.max(hydrograph.date)))

bedline = ax1.plot(centerline[:,0], centerline[:,1])
waterline = ax1.plot(centerline[:,0], (0.00001 * np.ones(len(centerline))), 'b-')
bedpoint = ax1.plot(centerline[:,0], centerline[:,1], 'k.')[0]
#bedpoint = ax1.plot([0,0],[-60,10])[0]

transgression = ax2.plot(cms_tra_pchip, rkm_pchip, 'r-')
regression = ax2.plot(cms_reg_pchip, rkm_pchip, 'b-')
locpoint = ax2.plot(cms_tra_pchip, rkm_pchip, 'k.')[0]

hydroline = ax3.plot(hydrograph.date, hydrograph.cms)
thresholdline = ax3.plot(hydrograph.date, np.ones(len(hydrograph)) * 8240, 'b-')
hydropoint = ax3.plot(hydrograph.date, hydrograph.cms, 'k.')[0]


anim = FuncAnimation(fig, animate, frames=np.arange(100,len(hydrograph),1), interval = 100)
 
plt.draw()
plt.show()
