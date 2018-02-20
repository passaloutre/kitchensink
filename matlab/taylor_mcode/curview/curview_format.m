%script to convert raw adcp to curview format
%% Parameters
filein='MOTSF000.000';
fileout='test000';
name='Conc-Station 1';

%% Processing
a=rdradcp(filein,1);

%convert to curview format
bt_range=mean(a.bt_range,1)';  %mean bottom-track range (avg over 4 beams)
in=bt_range>0;  %logical index on good ranges

adcp.name=name;
adcp.time=a.mtime(in)';
adcp.bins=1:a.config.n_cells;
adcp.z=a.config.ranges';
adcp.tide=bt_range(in)-mean(bt_range(in));
adcp.u=a.east_vel(:,in)'*100;
adcp.v=a.north_vel(:,in)'*100;
adcp.corr=squeeze(mean(a.corr(:,:,in),2))';
adcp.ss=squeeze(mean(a.intens(:,:,in),2))';
adcp.bt_range=bt_range(in);
adcp.type='surface';

%save to mat file
save(fileout,'adcp','-v7')
