# -*- coding: utf-8 -*-
"""
Created on Thu Jan 25 14:40:58 2018

@author: RDCHLMTR
"""
import os
import paramiko
from paramiko import SSHClient
import time

days = 14 # only get files this old
mtime = time.time() - (days * 60 * 60 * 24)

stations = ['md1','md2']
ip_address = ['107.80.215.157','107.80.215.145']
local_root = 'F:/projects/houston/'
local_paths = [['md1/echo/','md1/ms5','md1/wavestaff'],
               ['md2/ms5/','md2/wavestaff']]
remote_root = '/home/ftpuser/datamux/'
remote_paths = [['Echo','ms5','wavestaff'],
                ['ms5','wavestaff']]

os.chdir(local_root)

ssh = SSHClient()
ssh.load_system_host_keys()

ssh.load_system_host_keys()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

for i in range(len(stations)):
    ssh.connect(ip_address[i], port=9922, username='root', password='pfjkroot')
    sftp = ssh.open_sftp()
    print('Connecting to {}:{}\n'.format(stations[i],ip_address[i]))
    for j in range(len(local_paths[i])):
        sftp.chdir('{}{}'.format(remote_root, remote_paths[i][j]))
        print('Remote Directory: {}{}'.format(remote_root,remote_paths[i][j]))
        remote_files = sftp.listdir()
        for k in range(len(remote_files)):
            if (sftp.stat(remote_files[k]).st_mtime) > mtime:
                sftp.get(remote_files[k],'{}/{}/{}'.format(local_root,local_paths[i][j],remote_files[k]))
                print('Downloading {}'.format(remote_files[k]))
    sftp.close()
    ssh.close()