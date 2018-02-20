# -*- coding: utf-8 -*-
"""
Created on Sun May 14 18:05:02 2017

@author: RDCHLMTR
"""

import os
import glob
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import scipy.io

os.chdir('E:/Projects/uplooker')

mat = scipy.io.loadmat('uplooker2015.mat')