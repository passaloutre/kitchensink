#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Nov  7 14:22:00 2017

@author: mtr
"""

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import xml.etree.ElementTree as ET

tree = ET.parse('/home/mtr/Scripts/NOCOVER.GPX')
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

df2 = df

plt.plot(df.lon,df.lat,'.')