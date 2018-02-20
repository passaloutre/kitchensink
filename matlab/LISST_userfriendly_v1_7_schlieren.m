%LISST Data processing
%
%This code processes LISST Data for a deployment or for a downcast using
%Matlab codes and equations from Sequoia Scientific
%%%%%%%%%%%%%%%%%%%%%%%
% The Sequoia Scientific Codes are:
% getscat.m
% tt2mat.m  (not called in this code, but provided by Sequoia; reads binary data into Matlab)
% invert.p
% compute_mean.m
% vdcorr.m
%
% Instructions from Sequoia on these codes can be found in
% 'Processing LISST-100 and LISST-100X data in MATLAB' on Sequoia Scientific, Inc.'s website:
% http://www.sequoiasci.com/article/processing-lisst-100-and-lisst-100x-data-in-matlab/
%%%%%%%%%%%%%%%%%%%%%%
%
%Follow the on-screen prompts to process the data.
%
%The code prompts the user to select files as input data. It then prompts the user to enter other
%necessary information such as the whether or not the data is from a deployment,
%the path reduction module (prm) amount, the number of samples per burst (for
%deployments), and the year in which the data was collected.
%
%Processing follows these steps:
%STEP 1: COMPUTE THE CORRECTED SCATTER (cscat)
%   [scat,tau,zsc,data,cscat] = getscat(‘datafile’,’zscfile’,X,’ringarefile’);
%STEP 1A: CALCULATE BEAM ATTENUATION
%    -ln(tau)*(1/0.05m) --> 0.05m is the distance over which the laser travels
%STEP 1B: GET DATE AND TIME
%STEP 2: COMPUTE UNCALIBRATED VOLUME DISTRUBTION AND MIDPOINT OF SIZE BINS
%   [vd dias]=invert(cscat,instrument_type,ST,RANDOM,SHARPEN,GREEN,WAITBARSHOW)
%STEP 3: CONVERT THE VOLUME DISTRIBUTION INTO CALIBRATED UNITS
%   vd_cal = vdcorr(vd,VCC,flref,lref);
%STEP 4: ACCOUNT FOR PRM MODULE
%   prm_corr = 1/(1-prm); %prm correction factor;
%STEP 5: FIND MEAN OF vd_cal BASED ON SAMPLING  (EG FIND HOURLY MEAN)
%STEP 6: FIND DIAMETERS OF SEDIMENT (Based on on vd_mean)
%  diameters = compute_mean(vd, type, transmission)
%
%The workspaced is saved after STEP 2 and again (overwritten) after all the
%analyses are finished.
%
%
%INPUTS:
%LISST raw data
%Background zscat data
%Ring Area file
%Factory Zscat
%Instrument Data File
%Number of samples per burst (if using burst sampling for deployment --
%       used for averaging)
%PRM (Path Reduction Module): enter the amount of path reduction (eg.
%       0.80);necessary for correcting the volume concentration and beam
%       attenuation
%Year the data was collected in
%Operator name in single quotes
%Depth adjustment: Enter the appropriate distance to the center of the
%   measurement window based on the LISST that collected the data.
%Downcast: Is the data a downcast or a deployment? (1 for downcast, other
%   for deployment)
%   Optional clipping for downcast: If the user chooses, this code can
%       automatically clip off the upcast and the first few centimeters of
%       the downcast. (reccommended, especially for deep river casts)
%
%OUTPUTS:
% A .csv file is saved with the following outputs:
%   date, time, D50, mean diameter, standard deviation of diameter, total
%   volume concentration, 2-32µm Sed Conc(mg/L),32-62µm Sed Conc (mg/L),62-125µm Sed Conc (mg/L), >125µm Sed 
%   Conc (mg/L), 32 columns of size bin data, laser power
%   transmission, battery, external analog voltage (AuxIn), laser reference
%   power, depth (m), temperature
%
%There are many more variables output to the workspace and saved as a .mat
%file. A partial list is found here and in the variable 'notes':
%     'batt: battery voltage';
%     'beam_att: beam attenuation calculated from tau; dependent on path length; corrected for use of PRM';
%     'bins: columns = size bin #, lower limit of sediment size bin, upper limit, midpoint; 1 row for each ring of LISST; from manual';
%     'burst_start_time: first time in the burst (datenumber format); same number of elements as the mean of vd'
%     'cscat: corrected scattering as calculated by getscat.m; corrected based on ring area file';
%     'clip: amount of auto clipping of the first few centimeters (units of meters); 0.25m is a standard value';
%     'data: the raw LISST data read in by getscat.m';
%     'DataFilename: filename of the raw LISST data';
%     'ddate: date and time of samples; [year month day hour minute second];';
%     'datenumber: combination of date and time, but in MATLAB date format';
%     'depth: depth of sample in meters; depth at the center of measurement window';
%     'depth_avg: depth averaged for the burst in meters';
%     'diameters: diameters of sediment from compute_mean; using vd_mean; for info on each column see compute_mean.m';
%     'dias: midpoint of bins as output by invert.p';
%     'downcast: 1 if the data is a downcast, other if a deployment';
%     'exvolt: external analog voltage';
%     'FactoryZscatFilename: filename of the factory zscat file used in the processing';
%     'InstrumentDataFile: filename of the Instrument Data File used int he processing';
%     'vd_mean: mean of the volume distribution over the burst';
%     'nsample: number of samples per burst';
%     'operator_name: the name of the person who ran this code to produce this workspace';
%     'prm: amount of path reduction from the PRM (eg: 0.8)';
%     'prm_corr: prm correction factor; prm_corr = 1/(1-prm)';
%     'processing_date: the date the data was processed and the .mat file was created';
%     'rawdepth: depth at the transducer in meters; not corrected to be at the laser';
%     'refpwr: laser reference power; dig counts';
%     'RingAreaFilename: filename of the ring area file for correcting the scatter';
%     'save_filepath: filename and path used to save the .mat workspace; the same as the input filename and path (with a .mat extension)';
%     'scat: uncorrected scatter as calculated by getscat.m';
%     'sdate: the date and time as a string; eg, 25-Jul-2014 00:00:01; see also burst_start_time';
%     'surface: 1 if the top few centimeters is auto clipped, other if not';
%     'tau: the transmission of the laser as calculated by getscat.m';
%     'temp: temperature; deg C';
%     'upcast: 1 if the upcast was auto clipped off, other if not';
%     'VCC: volume conversion constant from instrument data file (4th column)';
%     'vd: volume distribution as calculated by invert.p; uncalibrated';
%     'warning: stores any warning messages';
%     'ZscatFilename: filename of the zscat background file used in the processing';
%     '_write: the variable as it is written to the .csv file'};
%
%
%AN IMPORTANT NOTE ON RINGS AND SEDIMENT SIZES:
%Rings DO NOT directly correspond to sediment size.
%   The manual may have a chart that says otherwise. The manual is wrong.
%   All the rings read all the sizes.
%When you read one of the raw, binary data files, the columns correspond to
%   the rings (ie column 1 is ring 1). After the raw file has been processed
%   (ie inverted) the columns correspond to the size bins (ie column 1 is size bin 1)
%
%
%Written by Diana Di Leonardo with contributions from Dallon Weathers
%Original: August 2014
%
%

%% Edits:
%9/10/14: Changed mean_vd to vd_mean for clarity
%9/22/14: Improved handling of date and time based on Dallon's code;
%   replaced date and time variables with ddate
%10/13/14: Added the ability to repeat the file processing for multiple
%   files using the same background data files(ie When you have a number of
%   casts that all use the same zscat file, you do not have to enter the
%   starting data multiple times.)
%10/14/14: Fixed error in csv writing section due to changes in date
%   handling from 9/22/14; added sdate variable
%10/14/14: Added processing_date variable to record the date the data was
%   processed and the .mat file was created
%10/20/14: Finalized changes from 10/13/14 ti allow the user to to repeat the file
%   processing for multiple files using the same background data files (v1.1)
%10/20/14: Changed the writing of processed deployment files to use
%   datenumber_write and sdate from datenumber_write so the date gets
%   trimmed too
%10/20/14: NEW VERSION. User is now able to select multiple files at once for processing.
%   The files must use the same background files (zscat, factory, zscat,
%   ring area, InstrumentData) (v1.2)
%10/22/14: Removed the plotting section and moved it to the LISST data
%   checking script, LISST_check
%10/30/14: After computing the corrected scatter, added a check that the
%   LISST did not cut out mid-sampling burst. If the LISST did cut out
%   mid-sampling burst, truncate the data after the last full burst
%11/3/14: Corrected a misunderstanding of the relationship of the rings to
%   size bins (see above: AN IMPORTANT NOTE ON RINGS AND SEDIMENT SIZES). The
%   bins variable no longer has a column for ring #. The header of the .csv
%   file now reads size bin # instead of ring #
%11/10/14: NEW VERSION. The LISST depth transducer is located at the top of the LISST,
%   not at the measurement window. Older versions of this processing code used
%   the depth as it came out of the raw data file. Version 1.3 asks the user
%   to enter a depth adjustment, which is the distance from the LISST depth transducer
%   to the measurement window. The raw depth from the raw data is corrected
%   to the depth of the middle of the measurment window.
%
%   depth = raw depth + depth adjustment.
%
%   The adjustment is made at the same time that the depth is converted from cm to m.
%   1406: 62.3 cm + ((2.5 cm * 0.2)/2) = 62.6 cm  (permanent 80% prm)
%   (1406 was specially machined to have a shorter measurement window.)
%   1403/1580/1589: 62.3 cm + (5 cm/2) = 64.8 cm (no prm)
%   1403/1580/1589: 62.3 cm + ((5 cm * 0.2)/2) = 62.8 cm (with 80% prm)
%
%   Additionally, in previous versions, the variable Vars33to38 has recorded the laser
%   power transmitted through water, battery voltage, external analog
%   voltage, laser reference power, and temperature.  Vars33to38 has been
%   replaced by the following variables:
%       laspwr:laser power transmitted through water; dig counts
%       batt: battery voltage;
%       exvolt: external analog voltage
%       refpwr: laser reference power; dig counts
%       temp: temperature; deg C
%   To Do:
%   2- measure 1403
%   (v1.3)
%11/18/14: Added a message that prints if the total number of samples is
%   not evenly divisible by the number of samples per burst. The message tells
%   the user how many samples were cut off.
%
%   The minimum transmission (tau) for usable data is 0.15. After Step 1
%   (compute the corrected scatter), all ring data with a tau less than 0.15 is
%   made a NaN. The values in columsn 33 to 38 are kept for the record.
%   The burst average section now uses nanmean instead of mean.
%11/19/14: Added the variable 'warning' to store warning messages. The only
%   message it potenitally stores currently is that the LISST has cut out
%   in the middle of a sample burst.
%
%   The beam attenutation calculation was fixed for 1406 to take into
%   account the shorter path length (For 1406 the path length is 2.5cm,
%   while for the other LISSTs the path length is 5 cm). Added the variable
%   serialnum to choose the correct path length.
%11/24/14: NEW VERSION. Added columns to the csv file for the followng size
%   classes: clay and fine silt (2-32µm), coarse silt (32-62µm), very fine
%   sand (62-125µm), fine to coarse sand (>125µm). Start writing a .txt
%   file with some metadata (eliminates the need to open a .mat file to
%   view metadata).  v1.4
%11/25/14: Added code to print the name of the input files to the command
%   window so the user can confirm the right files have been chosen.
%2/9/15: Added a tab to the print command from 11/25/14 to make output more
%   clear. Fixed a typo in downcst clipping procedure. Fixed problem with
%   print statement for the current file name (line 329).
%2/11/15: NEW VERSION. If you enter 1406 as the serial number the prm is
%   automatically selected as 0.8. If you enter that the LISST is 1406 and the
%   data is a downcast the prm is 0.8 and the depth adjustment is 0.626.
%   v1.5
%3/12/15: The prm and depth adjustment will now also print to the screen if
%   they are automatically selected (see changes made 2/11/15).
%3/12/15: Files that have no nonzero depths will raise an error when the
%   metadata file is written. This is now prevented by checking that all 
%   files have at least one nonzero depth before processing begins. Files
%   with no nonzero depths are skipped, and a message stating that the file
%   is skipped is printed to the screen.
%3/30/15: The version of the variable diameters that is written was corrected 
%   to undergo surface and upcast clipping along with the rest of the
%   pertinent variables.
%6/16/15: NEW VERSION. Changed the units in the output from ul/L to mg/L by
%   multiplying the appropriate values by the density of quartz (2.65 g/cm^3)
%   v1.6
%6/22/15: Added a variable called units that is set to 'mg/L'. It only
%   marks that the units of the data have been converted to mg/L from ul/L.
%7/30/15: Reversed the 'conversion' to mg/L. You can't actually convert to
%   mg/L because you can't differentiate between a quartz grain and a floc
%   (which has a very different density)
%3/21/16: NEW VERSION. Changed the minimum allowable transmission to 30%
%   based on a literature review. Literature states that a 30% transmission is
%   the lowest allowable transmission to avoid the effects of multiple
%   scattering. v1.7
%7/13/16: Setting first 4 rings to zero to mitigate effect of
%   schilieren (changing the cscat - the data after subtracting the background).



clc; clear; close all

processing_date = date;
%% INPUTS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Given parameters

%getscat.m
X=1; %for LISST 100X

%invert.p
instrument_type = 3; %For LISST type C
ST = 0; %for LISST-100X
Random = 1; %for randomly shaped particles
SHARPEN = 0; %    SHARPEN = 1 causes the routine to check if the size distribution is narrow and, if so, increases the number of inversions. Use this setting if you expect a narrow size distribution (e.g. if you are analyzing narrow-size standard particles).
GREEN = 0;  %    GREEN = 1 if inversion is for a green laser unit (only for type B instruments as of September 2010)
WAITBARSHOW = 1; %Show WAITBAR during processing in order to keep track of progress; 0 for off

%compute_mean.m
type_diameter = 31; %randomly shaped particles with instrument type C

%Initialize a variable to hold potential warnings
warning = {};

fprintf('These characteristics are used in the processing. Open the script to change them.\n')
fprintf(' LISST-100X is used.\n LISST is type C. \n Particles are randomly shaped.\n No ''sharpening'' See invert.p instructions for explanation.\n This is NOT a GREEN laser unit.\n')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Select the run specific files (eg the data you want to process)
fprintf('\nYou will now select the files to use in the processing.')

pause(2)

% Select the Data file to be processed
fprintf('\nSelect the raw data file(s)')
pause(2)
[rawfiles, rawpath]=uigetfile('*.*','Choose 1 (or more) raw LISST file(s) (*.log or *.dat) that you would like to process', 'MultiSelect','on');


% Select the zscat file to use
fprintf('\nSelect the LAB zscat background file you would like to use.')
pause(2)
[filename, pathname]=uigetfile('*.*','Choose the ZSCAT to be removed from the data');
ZscatFilename=[pathname, filename];
fprintf(['\n\t' filename]);

%Select the factory zscat file for calibration
fprintf('\nSelect the FACTORY zscat file')
pause(2)
[filename,pathname] = uigetfile('*.*', 'Choose the factory zscat file for this LISST');
FactoryZscatFilename = [pathname filename];
fprintf(['\n\t' filename]);

%Select the ring area file
fprintf('\nSelect the ring area file for this LISST.')
pause(2)
[filename,pathname] = uigetfile('*.*', 'Choose the Ring Area file for this LISST');
RingAreaFilename = [pathname filename];
fprintf(['\n\t' filename]);

%Select the Instrument Data file to use
fprintf('\nSelect the Instument Data file to use')
pause(2)
[filename, pathname] = uigetfile('*.*','Choose the Instrument Data File for this LISST');
InstrumentDataFilename = [pathname filename];
fprintf(['\n\t' filename]);

%Now input a few other things specific to this data
serialnum = input('\nEnter the serial number of the LISST (1403; 1406; 1580; 1589).\n');

downcast = input('\nIs this a downcast (ie not a deployment)? Enter 1 for yes, another number for no.\n');
%optional downcast clipping
if downcast ==1
    upcast = input(['\nWould you like to automatically clip off the UPCAST? This will remove all data \nafter the deepest point in the cast is reached. '...
        'The upcast data will be preserved \nin a Matlab variable, but will not be written to the csv file. \nClipping reccommended. \nEnter 1 to clip off the UPCAST, '...
        'another number to keep it. \n']);
    surface = input(['\nWould you like to clip off the first few cm of the cast? This is the part of the \ncast where the LISST and CTD sit at the top of the water column '...
        'and \nequilibrate. Clipping reccommended, epsecially for MS River casts. \nClipping may not work well for very shallow casts (ie shallow marsh areas \nwhere the ' ...
        'depth is 2m or less. \nEnter 1 to clip the first few cm, another number to keep them. \n']);
    
    if surface == 1
        clip = input('\nHow much of the top of the cast would you like to clip off? 25 cm is standard. \nEnter the amount in meters (ie 0.25m)\n');
    else 
        clip = 0;
    end
    
end


if serialnum ==1406
    prm = 0.8;
    fprintf('\nThis LISST has a permanent prm of 0.8.')
else
    prm = input('\nEnter the amount of path reduction from the path reduction module (PRM) (eg: 0.8). \n     Enter 0 if not using a PRM.\n');
end

if serialnum == 1406 && downcast == 1
    dep_adj = 0.626;
    fprintf('\nThe depth adjustment for this LISST is 0.626.\n')
else
    dep_adj = input(['\nEnter the depth adjustment. This is the vertical difference in depth between the \n   transducer and the measurment window.' ...
        '\n   For a horizontal deployment, enter 0. For a vertical deploment or cast, \n   enter the following adjustments (units of meters), based on serial number.' ...
        '\n   1406 (permanent 80% prm): 0.626  \n   1403/1580/1589 (no prm): 0.648 \n   1403/1580/1589 (with 80% prm): 0.628 \n']);
end

year = input('\nEnter the year the data was collected.\n');

nsample = input('\nEnter the number of samples per burst (number to be averaged)\n');

operator_name = input('\nWithin single quotations, enter the name of the person running this code.\n');

%% Processing - Uses the Sequoia Scientfic matlab functions

%See this article for more information:
%http://www.sequoiasci.com/article/processing-lisst-100-and-lisst-100x-data-in-matlab/

if iscell(rawfiles)  %if rawfiles is a cell array, meaning there is more than 1 file to
    %process, then repeat = the # of files
    repeat = length(rawfiles);
else                %if raw files is not a cell array, there is only 1 file to process
    repeat =1;
end

for n = 1:repeat %set up repeat functionally for casts
    
    if iscell(rawfiles)
        DataFilename=[rawpath, cell2mat(rawfiles(n))];
    else
        DataFilename = [rawpath, rawfiles];
    end
    
    save_filepath = DataFilename(1:end-4);
    
    fprintf(['\n Processing: ' DataFilename(end-11:end) '\n']);
    
    
    %STEP 1: COMPUTE THE CORRECTED SCATTER (cscat)
    % [scat,tau,zsc,data,cscat] = getscat(‘datafile’,’zscfile’,X,’ringarefile’);
    %
    % ‘datafile’ is the path and file name for the binary .DAT file offloaded from your LISST-100 or -100X instrument.
    % ‘zscfile’ is the path and file name for your zscat (background) file, typically obtained using the Windows SOP.
    % ‘ringareafile’ is the path and file name for your instrument specific ringarea_xxxx.asc file, where xxxx is the serial number of your LISST instrument.
    
    [scat,tau,zsc,data,cscat] = getscat(DataFilename, ZscatFilename, X, RingAreaFilename);
    
    %Supress Schilieren by forcing the first 4 rings to zero
    cscat(:,1:4) = 0;
    
    
    %The minimum transmission for useable data is 30% (or 0.30 tau).
    %Any data that has a tau less than 0.30 = NaN
    %Keep the tau values for the record.
    blocked = find(tau<0.15);
    data(blocked,1:32) = NaN; %keep the date and time
    cscat(blocked,:) = NaN;
    scat(blocked,:) = NaN;
    zsc(blocked,:) = NaN;
    

  
    %Check that there is an evenly divisible number of samples (ie the LISST
    %did not cut out in the middle of a sampling burst)
    
    [sz, ~] = size(data);
    if sz/nsample ~= round(sz/nsample) %if sampling cut off during a burst
        %Truncate data to last full burst
        nsz = fix(sz/nsample)*nsample;
        data = data(1:nsz,:);
        tau = tau(1:nsz);
        cscat = cscat(1:nsz,:);
        
        fprintf(['WARNING: LISST cut out during the middle of a sample burst. ' num2str(sz-nsz) ' samples cut off. Hit any key to continue\n'])
        warning = {warning; ['LISST cut out during the middle of a sample burst. ' num2str(sz-nsz) ' samples cut off.']};
        pause
        
    end
    
    %Variables besides ring data from raw data
    %laser power transmission,battery,AuxIn,laser ref, raw depth,temp
    %Sequoia stores all values on the LISST as integers so everything is
    %multiplied by 100, eg V*100; m*100, deg C*100
    laspwr = data(:,33); %laser power transmitted through water; dig counts
    batt = data(:,34)/100; %battery voltage;
    exvolt = data(:,35)/100; %external analog voltage
    refpwr = data(:,36);  %laser reference power; dig counts
    temp = data(:,38)/100;  %temperature; deg C
    
    rawdepth = data(:,37)/100; %raw depth in meters (depth at the transducer)
    depth = rawdepth + dep_adj; %depth in meters; add the depth adjustment
    %to account for difference in the
    %depth of the transducer and the
    %depth of the measurement window.
    
    if any(rawdepth)>0  %only proceed if there is at least one non zero depth
        
        %STEP 1A: CALCULATE BEAM ATTENUATION
        % -ln(tau)*(1/0.05m) --> 0.05m is the distance over which the laser travels
        
        %Beam attenuation calculation when using a PRM
        % 50% 	 -ln(tau)*(1/0.025m)
        %  80% 	 -ln(tau)*(1/0.01m)
        %  90% 	 -ln(tau)*(1/0.005m)
        
        prm_corr = 1/(1-prm); %prm correction factor
        
        if serialnum == 1406
            path = 0.025;
        else
            path = 0.05;        %for 1403; 1589; 1580
        end
        
        beam_att = -log(tau)*(1/(path/prm_corr));
        
        %STEP 1B: GET DATE AND TIME
        % variable 39: day number*100+hr, and
        % variable 40: minutes*100+seconds.
        
        dhr = data(:,39); %date (day of year; aka Julian Day) & hour
        ms = data(:,40);  %minutes an seconds
        
        doy = fix(dhr./100);   %day of year
        hr = mod(dhr,100);     %hour
        m = fix(ms./100);      %minute
        s = mod(ms,100);       %seconds
        
        ddate = datevec(datenum(['jan-00-' num2str(year)])+doy);
        ddate(:,4) = hr;
        ddate(:,5) = m;
        ddate(:,6) = s;
        
        %Matlab date
        datenumber = datenum(ddate);
        
        
        %STEP 2: COMPUTE UNCALIBRATED VOLUME DISTRUBTION AND MIDPOINT OF SIZE BINS
        %[vd dias]=invert(cscat,instrument_type,ST,RANDOM,SHARPEN,GREEN,WAITBARSHOW)
        
        % where
        %    cscat is the fully corrected scattering data in n x 32 format, obtained using getscat.m
        %    instrument_type is
        %    1 for type A (5-500 µm)
        %    2 for type B (1.25-250 µm size range)
        %    3 for type C (2.5-500 µm size range)
        %    4 for FLOC (7.5-1500 µm size range)
        %    ST = 1 if the data are to be inverted in LISST-ST format (8 size bins)
        %    ST = 0 if the data are to be inverted in LISST-100/LISST-100X format (32 size bins)
        %    RANDOM = 1 if matrices based on scattering from randomly shaped particles are to be used for inversion. NOTE: Only type B and C instruments are supported for RANDOM = 1.
        %    RANDOM = 0 if matrices based on scattering from spherical particles are to be used for inversion.
        %    SHARPEN = 1 causes the routine to check if the size distribution is narrow and, if so, increases the number of inversions. Use this setting if you expect a narrow size distribution (e.g. if you are analyzing narrow-size standard particles).
        %    GREEN = 1 if inversion is for a green laser unit (only for type B instruments as of September 2010)
        %    WAITBARSHOW = 1 if user wants a waitbar to show during processing in order to keep track of progress.
        %
        %EXAMPLE: [vd dias]=invert(cscat,3,0,1,0,0,1)
        
        %    Outputs are:
        %    vd – volume distribution (NOT CALIBRATED WITH VCC)
        %    dias – the midpoint of the size bins for the 8 / 32 size classes for  the appropriate instrument, inversion type and laser color
        
        [vd, dias]=invert(cscat,instrument_type,ST,Random, SHARPEN,GREEN,WAITBARSHOW);
        
        fprintf('Saving the workspace so far....\n')
        
        %Save the resulting mat file because it takes a long time to run (esp large
        %deployment data sets)
        
        save(save_filepath)
        
        
        fprintf('Done saving. Continuing the analysis....\n')
        
        
        %STEP 3: CONVERT THE VOLUME DISTRIBUTION INTO CALIBRATED UNITS
        %vd_cal = vdcorr(vd,VCC,flref,lref);
        %VCC is the Volume Conversion Constant
        %flref is the factory laser reference value
        %lref is the laser reference value during measurement.
        
        fid = fopen(InstrumentDataFilename);
        dum = textscan(fid,'%*f%*s%*f%f%*s','delimiter',',');
        fclose(fid);
        VCC = dum{:}; %4th column of the instument data file
        
        fac_zscat = load(FactoryZscatFilename);
        flref = fac_zscat(36);
        lref = data(:,36);
        
        vd_cal = vdcorr(vd,VCC,flref,lref);
        
        %STEP 4: ACCOUNT FOR PRM MODULE
        %The output of vdcorr will underestimate the volume concentration by 80%
        %with the use of an 80% prm (by 50% with a 50% pmr). The get the correct
        %concentration, multiply the output of vd_corr by the prm correction
        %factor.
        
        %prm_corr = 1/(1-prm); %prm correction factor; calculated with beam
        %attenuation
        
        vd_cal =vd_cal*prm_corr; %multiply by prm correction factor
        
        %SEDIMENT SIZES OF BINS (From LISST Manual)
        rho=200^(1/32);
        x = 1.90; %lower limit for first size range for type C, randomly shaped particles
        bins(:,1) = 1:32; %bin #
        bins(:,2) = x*rho.^([0:31]); %lower limit (microns)
        bins(:,3) = x*rho.^([1:32]); % upper limit  (microns)
        bins(:,4) = sqrt(bins(:,2).*bins(:,3)); %mid-point  (microns)
        
        %STEP 5; FIND MEAN OF vd_cal BASED ON SAMPLING  (EG FIND HOURLY MEAN)
        if downcast ~= 1  %ie if this is a deployment
            
            ii = 1;  %counter for the start of each burst
            %nsample: user defined number of samples in each burst
            nn = 1;  %counter for creating the matrix of the means
            
            %Preallocate matrices
            burst_start_time = NaN*ones(length(datenumber)/nsample,1); %reduce the length of the full matrix by the number of samples per burst
            [a,b] = size(vd_cal); %find size of vd_cal matrix
            vd_mean = NaN*ones(a/nsample,b);
            
            laspwr_avg = NaN*ones(length(datenumber)/nsample,1);  %laser power transmitted through water
            batt_avg = NaN*ones(length(datenumber)/nsample,1);  %battery voltage
            exvolt_avg = NaN*ones(length(datenumber)/nsample,1);  %external analog voltage
            refpwr_avg = NaN*ones(length(datenumber)/nsample,1);  %laser reference power,
            temp_avg = NaN*ones(length(datenumber)/nsample,1);  %temperature
            depth_avg = NaN*ones(length(datenumber)/nsample,1);  %depth
            tau_avg = NaN*ones(length(datenumber)/nsample,1);  %avg the calculated transmission values
            beam_att_avg = NaN*ones(length(datenumber)/nsample,1);  %avg the beam transmission values
            
            
            while ii < length(tau)
                
                burst_start_time(nn) = datenumber(ii,:);  %store the first time in the burst as the sample time for the burst
                vd_mean(nn,:) = nanmean(vd_cal(ii:ii+(nsample-1),:)); %find the mean of the data over the burst
                
                %find the mean of variables over the burst
                laspwr_avg(nn) = nanmean(laspwr(ii:ii+(nsample-1)));  %laser power transmitted through water
                batt_avg(nn) = nanmean(batt(ii:ii+(nsample-1)));  %battery voltage
                exvolt_avg(nn) = nanmean(exvolt(ii:ii+(nsample-1)));  %external analog voltage
                refpwr_avg(nn) = nanmean(refpwr(ii:ii+(nsample-1)));  %laser reference power
                temp_avg(nn) = nanmean(temp(ii:ii+(nsample-1)));
                depth_avg(nn) = nanmean(depth(ii:ii+(nsample-1))); %avg depth in meters
                
                tau_avg(nn) = nanmean(tau(ii:ii+(nsample-1)));
                beam_att_avg(nn) = nanmean(beam_att(ii:ii+(nsample-1)));
                
                ii = ii+nsample;   %increment ii to the start of the next burst
                
                nn = nn+1;      %increment nn to move to the next row of the storage matrix
                
                
            end
            
            
            
        end
        
        
        %STEP 6: FIND DIAMETERS OF SEDIMENT (Based on on vd_mean)
        %  diameters = compute_mean(vd, type, transmission)
        %where vd is volume distribution (in µl/l) in n x 32 matrix
        %
        % and type is
        % 1 for type A (discontinued)
        % 2 for type B
        % 3 for type C
        % 4 for FLOC (discontinued)
        % 21 for randomly shaped type B
        % 31 for randomly shaped type C.
        %
        % and transmission (OPTIONAL) is a vector with transmission values.
        %
        % The OUTPUTS are:
        % Column 1: Total Volume Concentration in µl/l
        % Column 2: Mean Size in µm
        % Column 3: Standard Deviation in µm
        % Column 4: NaN. NOTE: Column 4 is NaN in order to comply with the general
        % data format for LISST-Portable and LISST-StreamSide, where column 4
        % contains the optical transmission. If transmission is input, it will be
        % displayed in column 4.
        % Column 5: D10 in µm.
        % Column 6: D16 in µm.
        % Column 7: D50 in µm.
        % Column 8: D60 in µm.
        % Column 9: D84 in µm.
        % Column 10: D90 in µm.
        % Column 11: D60/D10 (the Hazen uniformity coefficient).
        % Column 12: Surface area in cm2/l
        % Column 13: 'Silt Density' - The volume concentration ratio of silt
        % particles to the total volume concentration.
        % Column 14: Silt Volume - the volume concentration of all particles < 64
        % µm.
        if downcast == 1
            diameters = compute_mean(vd_cal,type_diameter);
        else
            diameters = compute_mean(vd_mean,type_diameter);
        end
        
        
        %% EXPLANATION OF VARIABLE NAMES
        fprintf('See the variable notes for an explanation of selected output variables.\n')
        notes = {'batt: battery voltage';
            'beam_att: beam attenuation calculated from tau; dependent on path length; corrected for use of PRM';
            'bins: columns = size bin #, lower limit of sediment size bin, upper limit, midpoint; 1 row for each ring of LISST; from manual';
            'burst_start_time: first time in the burst (datenumber format); same number of elements as the mean of vd'
            'cscat: corrected scattering as calculated by getscat.m; corrected based on ring area file';
            'clip: amount of auto clipping of the first few centimeters (units of meters); 0.25m is a standard value';
            'data: the raw LISST data read in by getscat.m';
            'DataFilename: filename of the raw LISST data';
            'ddate: date and time of samples; [year month day hour minute second];';
            'datenumber: combination of date and time, but in MATLAB date format';
            'depth: depth of sample in meters; depth at the center of measurement window';
            'depth_avg: depth averaged for the burst in meters';
            'diameters: diameters of sediment from compute_mean; using vd_mean; for info on each column see compute_mean.m';
            'dias: midpoint of bins as output by invert.p';
            'downcast: 1 if the data is a downcast, other if a deployment';
            'exvolt: external analog voltage';
            'FactoryZscatFilename: filename of the factory zscat file used in the processing';
            'InstrumentDataFile: filename of the Instrument Data File used int he processing';
            'vd_mean: mean of the volume distribution over the burst';
            'nsample: number of samples per burst';
            'operator_name: the name of the person who ran this code to produce this workspace';
            'prm: amount of path reduction from the PRM (eg: 0.8)';
            'prm_corr: prm correction factor; prm_corr = 1/(1-prm)';
            'processing_date: the date the data was processed and the .mat file was created';
            'rawdepth: depth at the transducer in meters; not corrected to be at the laser';
            'refpwr: laser reference power; dig counts';
            'RingAreaFilename: filename of the ring area file for correcting the scatter';
            'save_filepath: filename and path used to save the .mat workspace; the same as the input filename and path (with a .mat extension)';
            'scat: uncorrected scatter as calculated by getscat.m';
            'sdate: the date and time as a string; eg, 25-Jul-2014 00:00:01; see also burst_start_time';
            'surface: 1 if the top few centimeters is auto clipped, other if not';
            'tau: the transmission of the laser as calculated by getscat.m';
            'temp: temperature; deg C';
            'upcast: 1 if the upcast was auto clipped off, other if not';
            'VCC: volume conversion constant from instrument data file (4th column)';
            'vd: volume distribution as calculated by invert.p; uncalibrated';
            'warning: stores any warning messages';
            'ZscatFilename: filename of the zscat background file used in the processing';
            '_write: the variable as it is written to the .csv file'};
        
        
        %% OUTPUTS
        
        
        if downcast==1
            if surface == 1
                %Only relevant for casts
                %Trim off very top (before real downcast starts)
                vd_write = vd_cal(depth>=(clip+dep_adj),:);
                depth_write = depth(depth>=(clip+dep_adj));
                
                laspwr_write = laspwr(depth>=(clip+dep_adj));
                batt_write = batt(depth>=(clip+dep_adj));
                exvolt_write = exvolt(depth>=(clip+dep_adj));
                refpwr_write = refpwr(depth>=(clip+dep_adj));
                temp_write = temp(depth>=(clip+dep_adj));
                
                tau_write = tau(depth>=(clip+dep_adj));
                beam_att_write = beam_att(depth>=(clip+dep_adj));
                datenumber_write = datenumber(depth>=(clip+dep_adj));
                diameters_write = diameters(depth>=(clip+dep_adj),:);
            end
            
            if upcast == 1 && surface ==1  %if clipping both top and bottom
                %Trim off any bounces of the LISST on the bottom
                jj = find(max(depth_write)==depth_write,1,'first');
                vd_write = vd_write(1:jj,:);
                depth_write = depth_write(1:jj);
                
                laspwr_write = laspwr_write(1:jj);
                batt_write = batt_write(1:jj);
                exvolt_write = exvolt_write(1:jj);
                refpwr_write = refpwr_write(1:jj);
                temp_write = temp_write(1:jj);
                
                tau_write = tau_write(1:jj);
                beam_att_write = beam_att_write(1:jj);
                datenumber_write = datenumber_write(1:jj);
                diameters_write = diameters_write(1:jj,:);
                
            elseif upcast ==1 && surface ~=1 %if only clipping off upcast
                %Trim off any bounces of the LISST on the bottom
                jj = find(max(depth)==depth,1,'first');
                vd_write = vd_cal(1:jj,:);
                depth_write = depth(1:jj);
                
                laspwr_write = laspwr(1:jj);
                batt_write = batt(1:jj);
                exvolt_write = exvolt(1:jj);
                refpwr_write = refpwr(1:jj);
                temp_write = temp(1:jj);
                
                tau_write = tau(1:jj);
                beam_att_write = beam_att(1:jj);
                datenumber_write = datenumber(1:jj);
                diameters_write = diameters(1:jj,:);
                
            end
            
            if upcast ~=1 && surface~=1 %if no clipping, then just rename
                vd_write = vd_cal;
                depth_write = depth;
                
                laspwr_write = laspwr;
                batt_write = batt;
                exvolt_write = exvolt;
                refpwr_write = refpwr;
                temp_write = temp;
                
                tau_write = tau;
                beam_att_write = beam_att;
                datenumber_write = datenumber;
                diameters_write = diameters;
            end
            
        else %if the data is a deployment, then write the averages
            vd_write = vd_mean;
            depth_write = depth_avg;
            
            laspwr_write = laspwr_avg;
            batt_write = batt_avg;
            exvolt_write = exvolt_avg;
            refpwr_write = refpwr_avg;
            temp_write = temp_avg;
            
            tau_write = tau_avg;
            beam_att_write = beam_att_avg;
            diameters_write = diameters; %diameters is computed from vd_mean for deployments
            
        end
        

        units = 'ul/L';
                
        %Compute sums for size classes
        
        clay = nansum(vd_write(:,1:17),2); %clay and fine silt
        crsilt = nansum(vd_write(:,18:21),2); %coarse silt
        vfsand = nansum(vd_write(:,22:25),2); %vf sand
        crsand = nansum(vd_write(:,26:32),2); %fine to coarse sand
        
        
        fprintf('Writing the .csv file....\n')
        
        
        % WRITE DATA FILE
        fout =[DataFilename(1:end-4),'.csv'];  %Use the same filename as the input file
        fid = fopen(fout,'w');
        
        % Make header
        hdr = ['Date,Time,D50 (µm),meanD (µm),stdD (µm),Total Vol Conc (ul/L),2-32µm Sed Conc (ul/L),'...
            '32-62µm Sed Conc (ul/L),62-125µm Sed Conc (ul/L),>125µm Sed Conc (ul/L),'];
        
        % Label the header from size bin 1-size bin 32 per the SOP output
        for j=1:32
            hdr=[hdr,'SizeBin_',num2str(j),'(ul/L),'];
        end
        hdr=[hdr,['laser power transmission(digital counts),battery(V),AuxIn(V),LaserRef(digital counts),'...
            'depth(m),temp(C),opticTrans,beam attenuation(m^-1)']];
        fprintf(fid,'%s\n',hdr);
        
        
        %make the date format for the csv file
        if downcast ==1
            %datenumber_write(isnan(datenumber_write)) = 0;  %datestr can't handle NaNs
            % 00-Jan-0000 00:00:00 is the date equivalent of a NaN
            sdate = datestr(datenumber_write);%string date
            
        else
            %burst_start_time(isnan(burst_start_time)) = 0; %datestr can't handle NaNs
            sdate = datestr(burst_start_time);  %string date
            
        end
        
        
        
        % Write data to .csv
        
        for ii=1:length(depth_write)  %write data line by line
            sp = strfind(sdate(ii,:),' ');  %find the space in the string date
            fprintf(fid,'%s,',sdate(ii,1:sp-1));  %Date eg: 12-Feb-14
            fprintf(fid,'%s,',sdate(ii,sp+1:end)); %Time; eg: HH:MM:SS
            
            fprintf(fid,'%.2f,',diameters_write(ii,7)); %D50
            fprintf(fid,'%.2f,',diameters_write(ii,2)); %meanD
            fprintf(fid,'%.2f,',diameters_write(ii,3)); %stdD
            fprintf(fid,'%.2f,',diameters_write(ii,1)); %tot conc
            
            fprintf(fid,'%.2f,',clay(ii));%clay and fine silt concentration
            fprintf(fid,'%.2f,',crsilt(ii));%coarse silt concentration
            fprintf(fid,'%.2f,',vfsand(ii));%very fine sand concentration
            fprintf(fid,'%.2f,',crsand(ii));%fine to coarse sand concentration
            
            
            for k=1:32                          %ring data
                fprintf(fid,'%.2f,',vd_write(ii,k));
            end
            
            fprintf(fid,'%.2f,',laspwr_write(ii));   %laser power transmission
            fprintf(fid,'%.2f,',batt_write(ii));%battery
            fprintf(fid,'%.2f,',exvolt_write(ii));%external analog voltage; AuxIn
            fprintf(fid,'%.2f,',refpwr_write(ii));%laser reference power
            fprintf(fid,'%.2f,',depth_write(ii));%depth
            fprintf(fid,'%.2f,',temp_write(ii));%temp
            
            fprintf(fid,'%.2f,', tau_write(ii));    %calculated transmission (tau)
            fprintf(fid,'%.2f\n',beam_att_write(ii));  %beam attenuation
        end
        
        fclose(fid);
        
        %% WRITE METADATA FILE
        
        
        metaname = {'Processed Data File (.csv): ';
            'Processed Data File (.mat): ';
            'Raw LISST Data File: ';
            'Zscat Filename: ';
            'Factory Zscat File: ';
            'Instrument Data File: ';
            'Ring Area File: ';
            'PRM (path reduction module): ';
            'Processing date: ';
            'Operator name: ';
            'Begin date and time: ';
            'End date and time: ';
            'Depth adjustment (offset in meters between LISST transducer and center of measurement window): ';
            'Minimum depth of sample in meters at the center of measurement window: ';
            'Maximum depth of sample in meters at the center of measurement window: ';
            'Downcast (1 if the data is a downcast, other if a deployment): ';
            'Number of samples per burst: ';
            'Upcast (1 if the upcast was auto clipped off, other if not): ';
            'Surface (1 if the top few centimeters is auto clipped, other if not): ';
            'Clip (amount of auto clipping of the first few centimeters (units of meters) of a downcast): ';
            };
        %
        
        if downcast ~=1  %if the data is a deployment, these variables won't exist, so to prevent an error ...
            upcast = [];
            surface = [];
            clip = [];
        end
        
        if isempty(sdate)
            sdate = NaN;
        end
        
        metadata = {[DataFilename(1:end-4),'.csv'];[DataFilename(1:end-4),'.mat'];DataFilename; ZscatFilename; FactoryZscatFilename; InstrumentDataFilename; RingAreaFilename;...
            num2str(prm); processing_date; operator_name;  sdate(1,:); sdate(end,:); num2str(dep_adj); num2str(min(depth)); num2str(max(depth));...
            num2str(downcast); num2str(nsample); upcast; surface; clip; };
        
        
        fout2 =[DataFilename(1:end-4),'_meta.txt'];  %Use the same filename as the input file
        fid2 = fopen(fout2,'wt');
        
        % Write data to .txt
        for bb=1:length(metadata)  %write metadata line by line
            fprintf(fid2,'%s ',cell2mat(metaname(bb)));  %Write the metadata label
            fprintf(fid2,'%s\n\n',cell2mat(metadata(bb)));  %Write the metadata
            
        end
        
        fprintf(fid2,'%s','Warning Messages (if any): ');
        
        for cc = 2:length(warning)
            fprintf(fid2,'%s\n',cell2mat(warning(cc)));
        end
        
        
        fclose(fid2);
        
        
        %% Save the Workspace
        
        fprintf('Saving the workspace after all analysis...\n')
        
        % if save_mat == 1
        %Save the resulting mat file because it takes a long time to run (esp large
        %deployment data sets)
        %This is the second save. The first is after running the invert.p code
        
        save(save_filepath)
        
        % end
        
        if n<repeat
            fprintf(['Moving on to file ' num2str(n+1) ' of ' num2str(length(rawfiles)) '\n\n'])
        end
        
        %clear some function outputs to prvent unforeseen problems
        clear scat tau zsc data cscat vd dias
        
        %Re-initialize warning variable
        warning = {};
        
    else %if there are no nonzero depths
        slash = strfind(DataFilename,'\');
        fprintf(['\n ' DataFilename(slash(end)+1:end-4) ' has no data.\nMoving on to next file.\n\n']);
        
    end  %end check for at least one nonzero depth
    
end  %end repeat loop
%% Final message
fprintf('\nAll done!\n')
