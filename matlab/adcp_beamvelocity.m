%% script for reading custom adcp ASCII file for beam velocities

% ensemble number 1
% number of bins 2
% time 3-9
% depth 10-numbins
% intensity beam 1
% intensity beam 2
% intensity beam 3
% intensity beam 4
% east vel
% north vel
% up vel
% magnitude vel
% direction vel
% beam 1 vel
% beam 2 vel
% beam 3 vel
% beam 4 vel
% beam 1 depth
% beam 2 depth
% beam 3 depth
% beam 4 depth
% beam 1 depth raw?
% beam 2 depth raw
% beam 3 depth raw
% beam 4 depth raw
% beam angle
% system freq
% transducer pattern
% sensor config
% coordinate system
% bin size
% bin 1 range
% heading
% pitch
% roll
% temp
% river depth
% gga latitude
% gga longitude
% gga altitude
% adcp heading
%%

pn = 'E:\Projects\SaltWedge\beam_velocity\testing';
dirinfo = dir(sprintf('%s\\*ASC*',pn));
filelist = {dirinfo.name};

for i=1
   indat = csvread(fullfile(pn,filelist{i}));
   numbins = indat(1,2);
   numens = size(indat,1);
   dat = struct('ensnum',indat(:,1),'numbins',indat(:,2),'year',indat(:,3),...
       'month',indat(:,4),'day',indat(:,5),'hour',indat(:,6),'minute',indat(:,7),...
       'second',indat(:,8),'hundredth',indat(:,9),'bindepth',indat(:,10:10+numbins-1),...
       'int1',indat(:,10+numbins:10+2*numbins-1),'int2',indat(:,10+2*numbins:10+3*numbins-1),...
       'int3',indat(:,10+3*numbins:10+4*numbins-1),'int4',indat(:,10+4*numbins:10+5*numbins-1),...
       'east',indat(:,10+5*numbins:10+6*numbins-1),'north',indat(:,10+6*numbins:10+7*numbins-1));
end