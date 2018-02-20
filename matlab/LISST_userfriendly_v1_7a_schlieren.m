%LISST Data processing
%
%This code processes LISST Data for a deployment or for a downcast using
%Matlab codes and equations from Sequoia Scientific
%
%This version will split and save both the
%   upcast and the downcast to compare them. This version will ONLY BE APPLICABLE
%   TO CASTS, NOT TO DEPLOYMENTS. v 1.7a
%
%The top 0.25 m of the cast is clipped off.
%
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
%A .csv file is saved with the following outputs:
%   date, time, D50, mean diameter, standard deviation of diameter, total
%   volume concentration, 32 columns of size bin data, laser power
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
%   data is a downcast the prm is 0.8 and the depth adjustment is 0.626
%3/12/15: The prm and depth adjustment will now also print to the screen if
%   they are automatically selected (see changes made 2/11/15).
%3/12/15: Files that have no nonzero depths will raise an error when the
%   metadata file is written. This is now prevented by checking that all
%   files have at least one nonzero depth before processing begins. Files
%   with no nonzero depths are skipped, and a message stating that the file
%   is skipped is printed to the screen.
%3/30/15: NEW, COMPLEMENTARY VERSION. This version will split and save both the
%   upcast and the downcast to compare them. This version will ONLY BE APPLICABLE
%   TO CASTS, NOT TO DEPLOYMENTS. v 1.5a
%   The top 0.25m of the cast is automatically clipped off. The depth
%   adjustment is automatically chosen based on the selection of the serial
%   number and prm value. The variable 'nsamples' no longer exists because
%   every file is a cast which does not need burst averaging.
%   There are two csv files (1 for the upcast and 1 for the downcast), but 
%   still only 1 metadata file and 1 .mat file.
%7/13/16: NEW VERSION. Updated version 5a to be the same as version 7. This 
%   version will be used to reprocess the Mekong data for 2015, saving the upcast
%   and downcast, while also setting the first 4 rings to zero to mitigate
%   the effect of schlieren. This will be accomplished by changing the
%   cscat (the data after subtracting the background. Added a variable called 
%   units to mark that the concentration units are in ul/L. The minimum 
%   transmission remains as 15% to be consistent with the rest of the Mekong data. 


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

%Cast clipping
%clip = input('\nHow much of the top of the cast would you like to clip off? 25 cm is standard. \nEnter the amount in meters (ie 0.25m)\n');
clip = 0;

%Path Reduction Module
if serialnum ==1406
    prm = 0.8;
    fprintf('\nThis LISST has a permanent prm of 0.8.')
else
    prm = input('\nEnter the amount of path reduction from the path reduction module (PRM) (eg: 0.8). \n     Enter 0 if not using a PRM.\n');
end

if serialnum == 1406
    dep_adj = 0.626;
    fprintf('\nThe depth adjustment for this LISST is 0.626.')
elseif prm==0.8
    dep_adj = 0.628;
    
elseif prm == 0
    dep_adj = 0.648;
    
else
    error('Error: You have entered a value for the path reduction module that is not recognized. The offsets have only been measured for a prm of 80% (prm = 0.8) or no prm.');
end

year = input('\nEnter the year the data was collected.\n');
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
        
    %The minimum transmission for useable data is 15% (or 0.15 tau).
    %Any data that has a tau less than 0.15 = NaN
    %Keep the tau values for the record.
    blocked = find(tau<0.15);
    data(blocked,1:32) = NaN; %keep the date and time
    cscat(blocked,:) = NaN;
    scat(blocked,:) = NaN;
    zsc(blocked,:) = NaN;
    
    
    
    %Variables besides ring data from raw data
    %laser power transmission,battery,AuxIn,laser ref, raw depth,temp
    %Sequoia stores all values on the LISST as integers so everything is
    %multiplied by 100, eg V*100; m*100, deg C*100
    laspwr = data(:,33); %laser power transmitted through water; dig counts
    batt = data(:,34)/100; %battery voltage;
    exvolt = data(:,35)/100; %external analog voltage
    refpwr = data(:,36);  %laser reference power; dig counts
    temp = data(:,38)/100;  %temperature; deg C
    
    rawdepth = data(:,37)/100; %raw depth in meters (depth at the pressure gauge; top of instrument)
    depth = rawdepth + dep_adj; %depth in meters; add the depth adjustment
    %to account for difference in the
    %depth of the transducer and the
    %depth of the measurement window.
    
    if any(rawdepth)>0  && any(any(data(:,1:32))) %only proceed if there is at least one non zero depth & one data point
        
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
        
        %%%%%%%%%%FOR CASTS THIS IS NOT NECESSARY BECAUSE THEY ARE FAST TO RUN%%%%%
        %         fprintf('Saving the workspace so far....\n')
        %
        %         %Save the resulting mat file because it takes a long time to run (esp large
        %         %deployment data sets)
        %         save(save_filepath)
        %         fprintf('Done saving. Continuing the analysis....\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
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
        %Don't average anything for a cast.
        
        
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
        
        diameters = compute_mean(vd_cal,type_diameter);
        
        
        
        %% EXPLANATION OF VARIABLE NAMES
        fprintf('See the variable notes for an explanation of selected output variables.\n')
        notes = {'batt: battery voltage';
            'beam_att: beam attenuation calculated from tau; dependent on path length; corrected for use of PRM';
            'bins: columns = size bin #, lower limit of sediment size bin, upper limit, midpoint; 1 row for each ring of LISST; from manual';
            'cscat: corrected scattering as calculated by getscat.m; corrected based on ring area file';
            'clip: amount of auto clipping of the first few centimeters (units of meters); 0.25m is a standard value';
            'data: the raw LISST data read in by getscat.m';
            'DataFilename: filename of the raw LISST data';
            'ddate: date and time of samples; [year month day hour minute second];';
            'datenumber: combination of date and time, but in MATLAB date format';
            'depth: depth of sample in meters; depth at the center of measurement window';
            'diameters: diameters of sediment from compute_mean; using vd_mean; for info on each column see compute_mean.m';
            'dias: midpoint of bins as output by invert.p';
            'exvolt: external analog voltage';
            'FactoryZscatFilename: filename of the factory zscat file used in the processing';
            'InstrumentDataFile: filename of the Instrument Data File used int he processing';
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
                
        %Clip the top (minimum depths) of both the upcast and downcast
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
        
        %Split the upcast and downcast
        %Discard bounces
            %find first occurrence of max depth
            maxDepth1 = find(depth_write == max(depth_write),1,'first'); %this is an index, not a value
            downcast = depth_write(1:maxDepth1);
            
            %find last occurence of max depth
            maxDepth2 = find(depth_write == max(depth_write),1,'last');  %this is an index not a value
            upcast = depth_write(maxDepth2:end);            
            
            %data between first and last occurence are bounces
            %throw away this data by not assigning it to either upcast or
            %downcast
            
        %Split the rest of the variables for the upcast and downcast
        %DOWNCAST
        vdWriteDown = vd_write(1:maxDepth1,:);
        depthWriteDown = depth_write(1:maxDepth1);
        
        laspwrWriteDown = laspwr_write(1:maxDepth1);
        battWriteDown = batt_write(1:maxDepth1);
        exvoltWriteDown = exvolt_write(1:maxDepth1);
        refpwrWriteDown = refpwr_write(1:maxDepth1);
        tempWriteDown = temp_write(1:maxDepth1);
        
        tauWriteDown = tau_write(1:maxDepth1);
        beam_attWriteDown = beam_att_write(1:maxDepth1);
        datenumberWriteDown = datenumber_write(1:maxDepth1);
        diametersDown = diameters_write(1:maxDepth1,:);
        
        %UPCAST
        vdWriteUp = vd_write(maxDepth2:end,:);
        depthWriteUp = depth_write(maxDepth2:end);
        
        laspwrWriteUp = laspwr_write(maxDepth2:end);
        battWriteUp = batt_write(maxDepth2:end);
        exvoltWriteUp = exvolt_write(maxDepth2:end);
        refpwrWriteUp = refpwr_write(maxDepth2:end);
        tempWriteUp = temp_write(maxDepth2:end);
        
        tauWriteUp = tau_write(maxDepth2:end);
        beam_attWriteUp = beam_att_write(maxDepth2:end);
        datenumberWriteUp = datenumber_write(maxDepth2:end);
        diametersUp = diameters_write(maxDepth2:end,:);    
                
        units = 'ul/L';
        
        %Compute sums for size classes
        
        clayDown = nansum(vdWriteDown(:,1:17),2); %clay and fine silt
        crsiltDown = nansum(vdWriteDown(:,18:21),2); %coarse silt
        vfsandDown = nansum(vdWriteDown(:,22:25),2); %vf sand
        crsandDown = nansum(vdWriteDown(:,26:32),2); %fine to coarse sand
        
        clayUp = nansum(vdWriteUp(:,1:17),2); %clay and fine silt
        crsiltUp = nansum(vdWriteUp(:,18:21),2); %coarse silt
        vfsandUp = nansum(vdWriteUp(:,22:25),2); %vf sand
        crsandUp = nansum(vdWriteUp(:,26:32),2); %fine to coarse sand
        
        
        fprintf('Writing the .csv file....\n')
        
        
        % WRITE DATA FILE
        %Write separate csv files for the upcast and downcast
        % Make header
        hdr = ['Date,Time,D50 (µm),meanD (µm),stdD (µm),Total Vol Conc (µl/l),2-32µm Sed Conc (µl/l),'...
            '32-62µm Sed Conc (µl/l),62-125µm Sed Conc (µl/l),>125µm Sed Conc (µl/l),'];
        % Label the header from size bin 1-size bin 32 per the SOP output
        for j=1:32
            hdr=[hdr,'SizeBin_',num2str(j),'(µl/l),'];
        end
        hdr=[hdr,['laser power transmission(digital counts),battery(V),AuxIn(V),LaserRef(digital counts),'...
            'depth(m),temp(C),opticTrans,beam attenuation(m^-1)']];
        
        
        %%%%%%%%%
        %Downcast
        %%%%%%%%%
        fout =[DataFilename(1:end-4),'Down.csv'];  %Use the same filename as the input file
        fid = fopen(fout,'w');
        
        %print header
        fprintf(fid,'%s\n',hdr);
      
        %make the date format for the csv file
        %datenumber_write(isnan(datenumber_write)) = 0;  %datestr can't handle NaNs
        % 00-Jan-0000 00:00:00 is the date equivalent of a NaN
        sdateDown = datestr(datenumberWriteDown);%string date

        % Write data to .csv
        
        for ii=1:length(depthWriteDown)  %write data line by line
            sp = strfind(sdateDown(ii,:),' ');  %find the space in the string date
            fprintf(fid,'%s,',sdateDown(ii,1:sp-1));  %Date eg: 12-Feb-14
            fprintf(fid,'%s,',sdateDown(ii,sp+1:end)); %Time; eg: HH:MM:SS
            
            fprintf(fid,'%.2f,',diametersDown(ii,7)); %D50
            fprintf(fid,'%.2f,',diametersDown(ii,2)); %meanD
            fprintf(fid,'%.2f,',diametersDown(ii,3)); %stdD
            fprintf(fid,'%.2f,',diametersDown(ii,1)); %tot conc
            
            fprintf(fid,'%.2f,',clayDown(ii));%clay and fine silt concentration
            fprintf(fid,'%.2f,',crsiltDown(ii));%coarse silt concentration
            fprintf(fid,'%.2f,',vfsandDown(ii));%very fine sand concentration
            fprintf(fid,'%.2f,',crsandDown(ii));%fine to coarse sand concentration
            
            
            for k=1:32                          %ring data
                fprintf(fid,'%.2f,',vdWriteDown(ii,k));
            end
            
            fprintf(fid,'%.2f,',laspwrWriteDown(ii));   %laser power transmission
            fprintf(fid,'%.2f,',battWriteDown(ii));%battery
            fprintf(fid,'%.2f,',exvoltWriteDown(ii));%external analog voltage; AuxIn
            fprintf(fid,'%.2f,',refpwrWriteDown(ii));%laser reference power
            fprintf(fid,'%.2f,',depthWriteDown(ii));%depth
            fprintf(fid,'%.2f,',tempWriteDown(ii));%temp
            
            fprintf(fid,'%.2f,', tauWriteDown(ii));    %calculated transmission (tau)
            fprintf(fid,'%.2f\n',beam_attWriteDown(ii));  %beam attenuation
        end
        
        fclose(fid);
        
        %%%%%%%%
        %Upcast
        %%%%%%%%
        foutUp =[DataFilename(1:end-4),'Up.csv'];  %Use the same filename as the input file
        fidUp = fopen(foutUp,'w');
        
    	%Print header
        fprintf(fidUp,'%s\n',hdr);
        
        
        %make the date format for the csv file
        %datenumber_write(isnan(datenumber_write)) = 0;  %datestr can't handle NaNs
        % 00-Jan-0000 00:00:00 is the date equivalent of a NaN
        sdateUp = datestr(datenumberWriteUp);%string date

        
        
        % Write data to .csv
        
        for ii=1:length(depthWriteUp)  %write data line by line
            sp = strfind(sdateUp(ii,:),' ');  %find the space in the string date
            fprintf(fidUp,'%s,',sdateUp(ii,1:sp-1));  %Date eg: 12-Feb-14
            fprintf(fidUp,'%s,',sdateUp(ii,sp+1:end)); %Time; eg: HH:MM:SS
            
            fprintf(fidUp,'%.2f,',diametersUp(ii,7)); %D50
            fprintf(fidUp,'%.2f,',diametersUp(ii,2)); %meanD
            fprintf(fidUp,'%.2f,',diametersUp(ii,3)); %stdD
            fprintf(fidUp,'%.2f,',diametersUp(ii,1)); %tot conc
            
            fprintf(fidUp,'%.2f,',clayUp(ii));%clay and fine silt concentration
            fprintf(fidUp,'%.2f,',crsiltUp(ii));%coarse silt concentration
            fprintf(fidUp,'%.2f,',vfsandUp(ii));%very fine sand concentration
            fprintf(fidUp,'%.2f,',crsandUp(ii));%fine to coarse sand concentration
            
            
            for k=1:32                          %ring data
                fprintf(fidUp,'%.2f,',vdWriteUp(ii,k));
            end
            
            fprintf(fidUp,'%.2f,',laspwrWriteUp(ii));   %laser power transmission
            fprintf(fidUp,'%.2f,',battWriteUp(ii));%battery
            fprintf(fidUp,'%.2f,',exvoltWriteUp(ii));%external analog voltage; AuxIn
            fprintf(fidUp,'%.2f,',refpwrWriteUp(ii));%laser reference power
            fprintf(fidUp,'%.2f,',depthWriteUp(ii));%depth
            fprintf(fidUp,'%.2f,',tempWriteUp(ii));%temp
            
            fprintf(fidUp,'%.2f,', tauWriteUp(ii));    %calculated transmission (tau)
            fprintf(fidUp,'%.2f\n',beam_attWriteUp(ii));  %beam attenuation
        end
        
        fclose(fidUp);
        
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
            'Clip (amount of auto clipping of the first few centimeters (units of meters) of a downcast): ';
            };
    
        
        if isempty(sdateDown)
            sdateDown = NaN;
        end
        if isempty(sdateUp)
            sdateUp = NaN;
        end
        
        metadata = {[DataFilename(1:end-4),'.csv'];[DataFilename(1:end-4),'.mat'];DataFilename; ZscatFilename; FactoryZscatFilename; InstrumentDataFilename; RingAreaFilename;...
            num2str(prm); processing_date; operator_name;  sdateDown(1,:); sdateUp(end,:); num2str(dep_adj); num2str(min(depth)); num2str(max(depth));...
            clip;};
        
        
        fout2 =[DataFilename(1:end-4),'_meta.txt'];  %Use the same filename as the input file
        fid2 = fopen(fout2,'wt');
        
        
        % Write data to .txt
        for bb=1:length(metadata)  %write metadata line by line
            fprintf(fid2,'%s ',cell2mat(metaname(bb)));  %Write the metadata label
            fprintf(fid2,'%s\n\n',cell2mat(metadata(bb)));  %Write the metadata
            
        end
        
        fprintf(fid2,'%s','Upcast and downcast saved.\n');
        
        fprintf(fid2,'%s','Warning Messages (if any): \n');
        
        for cc = 1:length(warning)
            fprintf(fid2,'%s\n',cell2mat(warning(cc)));
        end
        
        
        
        fclose(fid2);
        
        
        %% Save the Workspace
        
        fprintf('Saving the workspace after all analysis...\n')
        
        %SAVE THE .MAT FILE
        
        save(save_filepath)
        
        
        if n<repeat
            fprintf(['Moving on to file ' num2str(n+1) ' of ' num2str(length(rawfiles)) '\n\n'])
        end
        
        %clear some function outputs to prvent unforeseen problems
        clear scat tau zsc data cscat vd dias
        
        %Re-initialize warning variable
        warning = {};
        
        
        
    else %if there are no nonzero depths
        fprintf(['\n ' DataFilename(end-11:end) ' has no data.\nMoving on to next file.\n\n']);
        
    end  %end check for at least one nonzero depth
    
end  %end repeat loop
%% Final message
fprintf('\nAll done!\n')
