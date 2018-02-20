import pandas as pd
import numpy as np

pn = 'E:\\Projects\\SaltWedge\\CastAway\\'
fn = 'CC1533011_20161206_140716.csv'

pnfn = pn + fn

dat = {}
dat['hdr'] = {}

header = np.genfromtxt(pnfn,dtype='<U64',delimiter=',',max_rows=26)
hdr_vars = ';'.join(header[:,0]).replace('% ','').replace('(','').replace(')','').replace(' ','_').split(';')

for i in range(len(hdr_vars)):
    dat['hdr'][hdr_vars[i]] = header[i,1]

body = np.genfromtxt(pnfn,dtype='<U64',delimiter=',',skip_header=28)
body_vars = ';'.join(body[0,:]).replace('(','').replace(')','').replace(' ','_').split(';')

for i in range(len(body_vars)):
    dat[body_vars[i]] = body[1:,i]
