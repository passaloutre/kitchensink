#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Created on Thu Nov  9 12:22:51 2017

@author: mtr
"""

with open('config.txt','r') as confile:
    conf = confile.readline().split(',')
    
print('Content-Type text/html\r\n\r\n')
print('<html><body>')
print('This is the current configuration:<br />')
print('{}-{}-{}-{}'.format(conf[0],conf[1],conf[2],conf[3]))
print('</body></html>')