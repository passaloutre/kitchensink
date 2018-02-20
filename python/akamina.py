#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 30 12:11:40 2017

@author: mtr
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

#%% getting data

# input filename and path here
pn = 'C:\\Users\\RDCHLMTR\\Downloads\\'
fn = '18021700.test'

pnfn = pn + fn

f = open(pnfn, 'rb')

# read file header
indat = {}
indat['filename'] = pnfn
indat['filetype'] = ''.join(map(chr, np.fromfile(f, count = 20, dtype = 'u1')))
indat['mystery'] = ''.join(map(chr, np.fromfile(f, count = 15, dtype = 'u1')))
indat['serial'] = ''.join(map(chr, np.fromfile(f, count = 6, dtype = 'u1')))

print(indat['filename'])
print(indat['filetype'])
print(indat['mystery'])
print(indat['serial'])
print('\n')

# get file length
f.seek(0, 2)
eof = f.tell()

numens = int((eof - 41) / 7213)

# go to first burst
i = 0
f.seek(41)

# preallocate burst headers
indat['nsamp'] = np.zeros(numens)
indat['fsamp'] = np.zeros(numens)
indat['year'] = np.zeros(numens)
indat['month'] = np.zeros(numens)
indat['day'] = np.zeros(numens)
indat['hour'] = np.zeros(numens)
indat['minute'] = np.zeros(numens)
indat['second'] = np.zeros(numens)
indat['data'] = np.zeros((numens, 3600))

# parsing burst data
for i in range(numens):
    
    indat['nsamp'][i] = np.fromfile(f, count = 1, dtype = 'uint16')
    indat['fsamp'][i] = np.fromfile(f, count = 1, dtype = 'float32')
    indat['year'][i] = np.fromfile(f, count = 1, dtype = 'uint16')
    indat['month'][i] = np.fromfile(f, count = 1, dtype = 'uint8')
    indat['day'][i] = np.fromfile(f, count = 1, dtype = 'uint8')
    indat['hour'][i] = np.fromfile(f, count = 1, dtype = 'uint8')
    indat['minute'][i] = np.fromfile(f, count = 1, dtype = 'uint8')
    indat['second'][i] = np.fromfile(f, count = 1, dtype = 'uint8')
    indat['data'][i, :] = np.fromfile(f, count = 3600, dtype= 'uint16')
    
    print('{} of {}'.format(i + 1, numens))
    
f.close()

#%% processing data

# format timestamps
times = []
t = (pd.to_datetime(pd.DataFrame({'year':indat['year'],
                                  'month':indat['month'],
                                  'day':indat['day'],
                                  'hour':indat['hour'],
                                  'minute':indat['minute'],
                                  'second':indat['second']})))
    
deltat = pd.timedelta_range(start='0us', periods=3600, freq='33333us')
    
for i in range(len(t)):
    for j in range(len(deltat)):
        times.append(t[i] + deltat[j])

#%% generate output data 
dat = pd.DataFrame({},index=times)
dat.index.name = 'yymmddss'
dat['counts'] = indat['data'].flatten()
dat['volts'] = dat['counts'] * 1.399e-04 - 4.600 
dat['cm'] = dat['volts'] * 26.959 + 122.256 # these are the values for simon
# dat['cm'] = dat['volts'] * 26.532 + 122.016 # these are the values for garfunkel

# plot data
plt.plot(dat.counts)
plt.xlabel('Date')
plt.ylabel('centimeters')
plt.show()

#save output file
dat.to_csv('{}.csv'.format(pnfn.strip('.dat')))