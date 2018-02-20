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
bathy = np.genfromtxt('centerline_bathy.csv', delimiter = ',', skip_header = 1)

#plt.scatter(center[:,2], center[:,3], c=center[:,0])
#plt.axis('equal')
#plt.show()

dx = 100

r = 50
points_list = center[::dx,2:4]
bathy_list = bathy[:,1:3]

def do_kdtree(bathy_list, points):
    mytree = spatial.cKDTree(bathy_list)
    dist, indexes = mytree.query(points)
    return indexes

start = time.time()
results2 = do_kdtree(bathy_list, points_list)
end = time.time()
print('completed in {}'.format(end-start))


depths = bathy[results2,3]

dxx = 1
x = np.arange(0, np.max(center[:,0]), dxx)

depths_pchip = interpolate.pchip_interpolate(center[::dx,0], depths, x)

plt.plot(x,depths_pchip)
plt.show()

