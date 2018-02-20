# -*- coding: utf-8 -*-
"""
Created on Sun Feb 11 15:01:59 2018

@author: RDCHLMTR
"""

import numpy as np
import matplotlib.pyplot as plt
import os
from scipy import spatial, interpolate
import time

os.chdir('E:/Projects/diss/fullchannelmbs/')

center = np.genfromtxt('centerline_points.csv', delimiter = ',', skip_header = 1)
bathy = np.genfromtxt('bathy_subset.txt')

#plt.scatter(center[:,2], center[:,3], c=center[:,0])
#plt.axis('equal')
#plt.show()

dx = 100

r = 100
points_list = center[::dx,2:4]
bathy_list = bathy[:,0:2]

def do_kdtree(bathy_list, points):
    mytree = spatial.cKDTree(bathy_list)
    indexes = mytree.query_ball_point(points, r)
    return indexes

start = time.time()
results = do_kdtree(bathy_list, points_list)
end = time.time()
print('completed in {}'.format(end-start))


depths = np.zeros(len(points_list))
deep = -16.491

for i in range(len(depths)):
    if results[i]:
        deep = np.nanmin(bathy[results[i],2])
    depths[i] = deep
    

dxx = 1
x = np.arange(0, np.max(center[:,0]), dxx)

depths_pchip = interpolate.pchip_interpolate(center[::dx,0], depths, x)

plt.plot(x,depths_pchip)
plt.show()

output = np.array((x, depths_pchip)).T
