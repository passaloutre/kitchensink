# -*- coding: utf-8 -*-
"""
Created on Mon Nov 21 17:37:11 2016

@author: RDCHLMTR
"""

import os
import glob
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

from mpl_toolkits.mplot3d import Axes3D

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
for i in range(20):
    ax.plot(np.arange(0,4*np.pi,np.pi/100),np.sin(np.pi/4 + i*np.pi/20 + np.arange(0,4*np.pi,np.pi/100)))