# -*- coding: utf-8 -*-
"""
Created on Fri Nov 18 09:25:40 2016

@author: RDCHLMTR
"""

import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import pickle

os.chdir('e:/Projects/Mobile')

site_name = 'tr'

data = pd.read_table('{}_turb.csv'.format(site_name), delimiter=',',
                     index_col=0, parse_dates=True)

turb = pd.DataFrame(data['turb_NTU']).dropna()
sal = pd.DataFrame(data['sal_ppt']).dropna()
depth = pd.DataFrame(data['depth_m']).dropna()

#%%

turb.to_pickle('{}_turb.pkl'.format(site_name))
sal.to_pickle('{}_sal.pkl'.format(site_name))
depth.to_pickle('{}_depth.pkl'.format(site_name))