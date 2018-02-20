# -*- coding: utf-8 -*-
"""
Created on Tue Jun  6 10:32:00 2017

@author: RDCHLMTR
"""

import os
import glob
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

folder = 's8'

os.chdir('E:/Projects/BedformRoughness/new/VICKS_10032012/{}/'.format(folder))

filelist = glob.glob('*.xyz')

for i in range(len(filelist)):
    os.chdir('E:/Projects/BedformRoughness/new/VICKS_10032012/{}/'.format(folder))

    dat = np.loadtxt(filelist[i],skiprows=1)

    np.savetxt('{}.txt'.format(filelist[i].split('.')[0]),dat, fmt='%1.2f')
#%%
os.chdir('E:/Projects/BedformRoughness/new/VICKS_10032012/')

filelist = ['1_1756.txt','2_1802.txt','3_1807.txt','4_1814.txt','5_1821.txt',
            '6_1826.txt','7_1833.txt','8_1839.txt']

f = open('points_10032012.txt','ab')

for i in range(len(filelist)):
    a = np.loadtxt(filelist[i])
    np.savetxt(f,a,fmt='%1.2f')

f.close()
#%%
os.chdir('E:/Projects/BedformRoughness/new/VICKS_10032012/')

a = np.loadtxt('points_10032012.txt')
b = np.zeros_like(a)
b[:,0] = a[:,0]
b[:,1] = a[:,1]
b[:,2] = a[:,2]*0.3048
np.savetxt('points_10032012m.txt',b,fmt='%1.2f')