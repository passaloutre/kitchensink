%CTD Match file with cast
%
%Use this code to match a ctd file with a ctd cast in the field book to
%know which ctd fileis from which station
%
%ATTENTION: Have the relevant field book open before running this code.
%
%This code will do the following:
%   1- Read a CTD ascii file*: the file must have the following format:
%       -	Time, elapsed (seconds)
%       -	Depth (salt water m) lat 30
%       -	Salinity (PSU)
%       -	Temperature (ITS-90, deg C)
%       -	OBS, backscatterance (D&A) (NTU)
%       -	Beam transmissions, Chelsea Seatech
%       -	Sound Velocity (Chen-Millero m/s)
%   *The ascii file should be made from a cnv file that was converted from
%   a hex file using the option to convert the upcast AND downcast. This
%   setting is important for the QAQC procedure.
%
%   2- Print the filename and first timestamp of each file to the screen so that 
%   you can easily match cast files to stations with the field book.
%
%Diana Di Leonardo
%02/16/2017

clear; clc; close all;

initpath = 'C:\Users\diana\Dropbox (Water Institute)\Sediment_Systems\TO14_CalcasieuPhaseII\Data\CTD\201701';

%Choose files
[filelist, pathname]= uigetfile([initpath '\*.asc'],'Select ctd asc file','MultiSelect','on');


%How many were chosen?
if iscell(filelist)
    repeat = length(filelist);
else
    repeat=1;
end


for n = 1:repeat
    
    %Read data
    if iscell(filelist)
        fid = fopen([pathname cell2mat(filelist(n))]);
    else
        fid = fopen([pathname filelist]);
    end
    
    dum = textscan(fid,'%s%f%f%f%f%f%f%f',1,'headerlines',1,'delimiter',',');
    
    fclose(fid);
     
    datedum = dum{1};
       
   %print timestamp and file name to screen to match with station name in
   %the notebook

    if iscell(filelist)
        cell2mat(filelist(n))
    else
        filelist
    end
    
     datestr(datedum{1})
    

    pause
    
end


