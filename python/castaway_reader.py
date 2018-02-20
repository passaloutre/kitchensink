import pandas as pd

pn = 'E:\\Projects\\SaltWedge\\CastAway\\'
fn = 'CC1533011_20161206_140716.csv'

pnfn = pn + fn

hdr = pd.read_table(pnfn,delimiter='%|,',nrows=27,header=None,engine='python')
hdr2 = hdr.T.ix[2:,:]
hdr2.columns = [hdr.T.ix[1,:]]

body = pd.read_csv(pnfn,delimiter=',',header=28,index_col=None)

dat = {'hdr':hdr2.T,'body':body}