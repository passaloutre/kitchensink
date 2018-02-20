function [data] = readLISSTcsv(filepath, filename)
%
%Reads in a csv file created by the LISST processing code (eg.
%LISST_userfirendly_v1_6.m). Creates a structure variable containing each
%of the variables within the csv file
%
%INPUTS
%filepath: the file path for the LISST file of interest (no trailing \)
%filename: the name of the file of interested (with the .csv extension)
%
%OUTPUTS
%data: a structure variable containing each of the columns of the csv file;
%   the date and time are contained in one date string variable
%
%Diana Di Leonardo
%July 7, 2015

fid = fopen([filepath '\' filename]);

dum = textscan(fid, '%s%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f',...
    'headerlines',1,'delimiter',',');
fclose(fid);

if length(dum{1})>0

%Date and Time
dum2 = [dum{1} dum{2}];

for ii = 1: length(dum2(:,1))
    %Create Date and Time String (Col A & B)
    datetime(ii,:) = [cell2mat(dum2(ii,1)) ' ' cell2mat(dum2(ii,2))];
    
end

%D50 (Col C)
D50 = dum{3};

%mean Diameter (col D)
meanD = dum{4};

%Standard deviation (col E)
stdD = dum{5};

%total volume (col F)
TotalVol = dum{6};

%clay fraction (col G)
clay = dum{7};

%coarse silt fraction (col H)
crsilt = dum{8};

%very fine sand fraction (col I)
vfsand = dum{9};

%coarse san (col J)
crsand = dum{10};

%Volume Distribution (Col K through Col AP -- 32 columns)
for jj = 11:42
    vd(:,jj-10) = dum{jj};
end

%laser power (Col AQ)
laspwr = dum{43};

%Battery power (voltage) (col AR)
batt = dum{44};

%External analog voltage (col AS)
auxin = dum{45};

%Laser Reference power (Col AT)
lasref = dum{46};

%Depth (m) (Col AU)
depth = dum{47};

%Temperature (deg C) (Col AV)
temp = dum{48};

%Optic Transmission (Col AW)
tau = dum{49};

%Beam attenutation (Col AX)
atten = dum{50};


%Create output structure
data = struct('datetime', datetime, 'D50',D50,'meanD', meanD,'stdD',stdD,'TotalVol',TotalVol,...
    'clay',clay,'crsilt',crsilt,'vfsand',vfsand,'crsand',crsand,'vd',vd,'laspwr',laspwr,'batt',batt,...
    'auxin',auxin,'lasref',lasref,'depth',depth,'temp',temp,'tau',tau,'atten',atten);


else
    data = struct([]);
end





