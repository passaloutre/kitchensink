# -*- coding: utf-8 -*-
"""
Created on Mon Mar  6 11:19:37 2017

@author: RDCHLMTR
"""

import os
import glob
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


x = np.arange(10)

t = np.arange(100)

y = x **2

for i in range(len(t)):
    y = y + 2
    plt.plot(x,y)
    plt.show()