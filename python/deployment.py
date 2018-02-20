# -*- coding: utf-8 -*-
"""
Created on Tue Jan 30 15:18:48 2018

@author: RDCHLMTR
"""

import matplotlib.pyplot as plt

import os
import glob

def gpxread(fname,form='deg'):
    '''
    Import gpx file made by Garmin GPS/Sonar and output pandas dataframe with lat/lon/time/depth data
    Default export format is decimal degrees, specify form=''utm'' for utm output
    '''        
    import numpy as np
    import pandas as pd
    import xml.etree.ElementTree as ET
    import utm
    from datetime import timedelta
    
#    tree = ET.parse('/home/mtr/Scripts/NOCOVER.GPX')
    tree = ET.parse(fname)
    root = tree.getroot()
    
    latlong = []
    time = []
    depth = []
    
    for j in range(2,len(root[1])):
        for i in range(len(root[1][j])):
            latlong.append(root[1][j][i].attrib)
            time.append(root[1][j][i][0].text)
            try:
                depth.append(root[1][j][i][1][0][1].text)
            except:
                depth.append(np.nan)
        
    df = pd.DataFrame(latlong, dtype=float)
    df['time'] = pd.to_datetime(time)
    df['depth'] = pd.Series(depth)
    df.set_index('time')
    if form == 'deg':
        return df
    elif form == 'utm':
        utmn = np.zeros(len(df))
        utme = np.zeros(len(df))
        utmz = np.zeros(len(df))
        for k in range(len(df)):
            [utme[k],utmn[k],utmz[k],_] = utm.from_latlon(df.lat[k],df.lon[k])
        df['north'] = pd.Series(utmn)
        df['east'] = pd.Series(utme)
        df['zone'] = pd.Series(utmz)
        df['dx'] = np.concatenate(([0], np.diff(df['east'].values)))
        df['dy'] = np.concatenate(([0], np.diff(df['north'].values)))
        df['dt'] = np.concatenate((np.array([0]).astype('timedelta64[ns]'), np.diff(df['time'])))
        df['dt'] = df['dt']/timedelta(seconds=1)
        df['u'] = df['dx']/df['dt']
        df['v'] = df['dy']/df['dt']
        df['displacement'] = np.sqrt(df['dx']**2 + df['dy']**2)
        df['velocity'] = df['displacement']/df['dt']
        df['direction'] = (90 - np.degrees(np.arctan2(df['dy'],df['dx']))) % 360
        return df
    
plt.close('all')

#os.chdir('E:/Projects/drogue/RED_RIVER_DEPLOYMENT_20180129')
os.chdir('E:/Projects/drogue/jake')

files = glob.glob('*.GPX')

dat = {}

for i in range(len(files)):
    print('Reading {}'.format(files[i]))
    dat[i] = gpxread(files[i],form='utm')
    print('Saving {}.csv'.format(files[i].split('.')[0]))
    dat[i].to_csv('{}.csv'.format(files[i].split('.')[0]))


#cover = gpxread.gpxread('COVER.GPX',form='utm')
#nocover = gpxread.gpxread('NOCOVER.GPX',form='utm')