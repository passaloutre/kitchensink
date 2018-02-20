#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Nov 14 11:56:35 2017

@author: mtr
"""

import matplotlib.pyplot as plt
import gpxread
import numpy as np
import utm

plt.close('all')


cover = gpxread.gpxread('COVER.GPX',form='utm')
nocover = gpxread.gpxread('NOCOVER.GPX',form='utm')

control = utm.from_latlon(32.298245,-90.86604527)

cstd = np.nanmean([np.nanstd(cover.north),np.nanstd(cover.east)])
ncstd = np.nanmean([np.nanstd(nocover.north),np.nanstd(nocover.east)])

cmean = [np.nanmedian(cover.east),np.nanmedian(cover.north)]
ncmean = [np.nanmedian(nocover.east),np.nanmedian(nocover.north)]

ccirc = plt.Circle((cmean[0],cmean[1]),radius=cstd,color='b',fill=False)
nccirc = plt.Circle((ncmean[0],ncmean[1]),radius=ncstd,color='r',fill=False)

fig = plt.figure(1,figsize=(8,6),dpi=96)
#plt.axis([-90.866,-90.865,32.298,32.299])
ax = fig.add_subplot(1,1,1)

plt.plot(cmean[0],cmean[1],'bo',label='Covered')
plt.plot(ncmean[0],ncmean[1],'ro',label='Uncovered')

plt.plot(cover.east,cover.north,'b-',linewidth=0.3,label='_nolegend_')
plt.plot(nocover.east,nocover.north,'r-',linewidth=0.3,label='_nolegend_')
plt.plot(control[0],control[1],'k*',markersize=15,label='Control')
ax.add_artist(ccirc)
ax.add_artist(nccirc)
plt.show()
plt.legend()
plt.xlabel('UTM{}N meters East'.format(int(cover.zone[0])))
plt.ylabel('UTM{}N meters North'.format(int(cover.zone[0])))
plt.tight_layout()
#plt.xlim([700924,700936])
#plt.ylim([3575490,3575500])
ax.set_aspect('equal')
plt.grid()
ax.get_xaxis().get_major_formatter().set_useOffset(False)
ax.get_xaxis().get_major_formatter().set_scientific(False)
ax.get_yaxis().get_major_formatter().set_useOffset(False)
ax.get_yaxis().get_major_formatter().set_scientific(False)