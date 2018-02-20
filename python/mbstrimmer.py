# -*- coding: utf-8 -*-
"""
Created on Sat Feb 10 17:23:15 2018

@author: RDCHLMTR
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import os

os.chdir('E:/Projects/diss/fullchannelmbs')

dat = np.genfromtxt('bathy2003_cfs1200_meters.txt')

goodx = dat[:,0] > 737262
goody = dat[:,1] < 3329506
goodgood = goodx & goody

datgood = dat[goodgood,:]

plt.scatter(datgood[:,0],datgood[:,1],c=datgood[:,2])
plt.axis('equal')
plt.colorbar()
plt.show()

np.savetxt('bathy_subset.txt',datgood)
