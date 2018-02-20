# -*- coding: utf-8 -*-
"""
Created on Mon Nov 21 08:43:08 2016

@author: RDCHLMTR
"""

import numpy as np
import matplotlib.pyplot as plt
import scipy.optimize as opt

x = np.array([41,79,82,85,87,89,90,92,93,94,95,96,97,98,99,100,101,102,103,106])
y = np.array([4,11,14,16,17,18,21,23,25,27,30,32,34,37,40,44,47,50,57,73])

plt.plot(x,y,'ro',label='original data')

def func(x,a,b):
   return a*np.exp(0.1*b*x)

popt, pcov = opt.curve_fit(func, x, y)
fit = func(x, *popt)

print('y = {:.2f} * e ^ (x * {:.2f})'.format(popt[0],popt[1]/10))
#
plt.plot(x, fit, label='fitted curve')
plt.legend(loc='best')
plt.show()