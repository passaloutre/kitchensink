function [avg] = readLISSTavg2(filepath, filename)

%Reads the csv files written by LISST_makeDepthAvgs which 
%contain the grain size and depth averaged volume concentration values for 
%LISST casts as well as the total volume concentrations. If there is no
%data to calculate a total volume concentration, the maximum volume
%concentration for that cast is estimated
%
%Inputs
%filepath: the file path for the csv file of interest (no trailing \)
%filename: the name of the file of interest (with the .csv extension);
%
%Outputs
%avg: a structure variable containing the grain size and depth averaged
%   LISST concentration values and the total concentrations
%

%count the number of row in the file
nrows = rowcounter([filepath '\' filename]);

%Open and read the file
fid = fopen([filepath '\' filename]);
%read the file but skip the first and last lines (ie apply the format
%nrows-2 times)
dum = textscan(fid,'%f%f%f%f%f%f',nrows-2,'headerlines',1,'delimiter',',');
%read the last line which is the total volume data
%skip the first column which is jsut the word total
totdis = textscan(fid,'%*s%f%f%f%f%f','delimiter',',');
fclose(fid);


%volume distribution data
avg.grainsize = dum{1};
avg.FD01 = dum{2};
avg.FD03 = dum{3};
avg.FD05 = dum{4};
avg.FD07 = dum{5};
avg.FD09 = dum{6};

%The last row is the total volume data
avg.totalVol = [0.1 totdis{1}; 0.3 totdis{2}; 0.5 totdis{3}; 0.7 totdis{4}; 0.9 totdis{5}];




