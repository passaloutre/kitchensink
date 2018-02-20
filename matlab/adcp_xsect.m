% apply backscatter calibration to cross-sections
clear; close('all')

% ctd_file and adcp_file contain information about the stations and adcp files
ctd_file = 'lms_ssc_ctd.xlsx';
adcp_xsect_file = 'adcp_files.xlsx';
pn = 'E:\Projects\SaltWedge';

year = '2015';

% variables
dt = 30/3600/24; % averaging period

% load metadata
adcp_info = loadxls_struct(fullfile(pn,adcp_xsect_file),year);
ctd_info = loadxls_struct(fullfile(pn,ctd_file),year);
[station_names,ia,ic] = unique(adcp_info.RM,'stable');
river_miles = zeros(length(station_names),1);
for i=1:length(station_names)
    river_miles(i)=(str2double(station_names{i}(3:end)));
end

% assemble metadata and load adcp data
profiles = struct([]); %prealloc
% adcpr = struct([]);
% adcpl = struct([]);

for i=1:length(station_names)
    % assemble metadata for each station
    ctd_indices = find((contains(ctd_info.station,station_names{i})));
    profiles(i).name = station_names{i};
    profiles(i).depth = ctd_info.depth_m(ctd_indices);
    profiles(i).temp = ctd_info.temp(ctd_indices);
    profiles(i).sal = ctd_info.sal(ctd_indices);
    profiles(i).ssc = ctd_info.ssc_mgL(ctd_indices);
    adcp_indices = find((contains(adcp_info.RM,station_names{i})));
    profiles(i).path = adcp_info.Path{adcp_indices};
    profiles(i).adcpl = adcp_info.L2R{adcp_indices};
    profiles(i).adcpr = adcp_info.R2L{adcp_indices};
    profiles(i).matl = strcat(strtok(profiles(i).adcpl,'.'),'.mat');
    profiles(i).matr = strcat(strtok(profiles(i).adcpr,'.'),'.mat');
    
    % load adcp mat files (pre-converted)
    adcpr(i) = load(fullfile(profiles(i).path,profiles(i).matr));
    adcpl(i) = load(fullfile(profiles(i).path,profiles(i).matl));
end



% reloop to add ctd info to adcp structs
for i = 1:length(station_names)
    adcpr(i).numbins = length(adcpr(i).east_vel(:,1));
    adcpl(i).numbins = length(adcpl(i).east_vel(:,1));
    adcpr(i).numens = length(adcpr(i).east_vel(1,:));
    adcpl(i).numens = length(adcpl(i).east_vel(1,:));
    adcpr(i).bindepths = adcpr(i).config.ranges*cosd(20);
    adcpl(i).bindepths = adcpl(i).config.ranges*cosd(20);
    [adcpr(i).dmin,adcpr(i).imin] = min(profiles(i).depth);
    [adcpl(i).dmin,adcpl(i).imin] = min(profiles(i).depth);
    [adcpr(i).dmax,adcpr(i).imax] = max(profiles(i).depth);
    [adcpl(i).dmax,adcpl(i).imax] = max(profiles(i).depth);
    % TODO: check if ctd profile is empty (e.g. 2015 rm13)
    if ~isempty(profiles(i).depth)
        % interpolate sal/temp samples to depths of bins
        adcpr(i).sal = pchip(profiles(i).depth,profiles(i).sal,adcpr(i).bindepths);
        adcpr(i).temp = pchip(profiles(i).depth,profiles(i).temp,adcpr(i).bindepths);
        adcpr(i).conc = pchip(profiles(i).depth,profiles(i).ssc,adcpr(i).bindepths);
        
        adcpr(i).sal(adcpr(i).bindepths < adcpr(i).dmin) = profiles(i).sal(adcpr(i).imin);
        adcpr(i).sal(adcpr(i).bindepths > adcpr(i).dmax) = profiles(i).sal(adcpr(i).imax);
        adcpr(i).sal = repmat(adcpr(i).sal,[1 4 adcpr(i).numens]);
        
        adcpr(i).temp(adcpr(i).bindepths < adcpr(i).dmin) = profiles(i).temp(adcpr(i).imin);
        adcpr(i).temp(adcpr(i).bindepths > adcpr(i).dmax) = profiles(i).temp(adcpr(i).imax);
        adcpr(i).temp = repmat(adcpr(i).temp,[1 4 adcpr(i).numens]);
        
        adcpr(i).conc(adcpr(i).bindepths < adcpr(i).dmin) = profiles(i).ssc(adcpr(i).imin);
        adcpr(i).conc(adcpr(i).bindepths > adcpr(i).dmax) = profiles(i).ssc(adcpr(i).imax);
        adcpr(i).conc = repmat(adcpr(i).conc,[1 4 adcpr(i).numens]);
        
        
        adcpl(i).sal = pchip(profiles(i).depth,profiles(i).sal,adcpl(i).bindepths);
        adcpl(i).temp = pchip(profiles(i).depth,profiles(i).temp,adcpl(i).bindepths);
        adcpl(i).conc = pchip(profiles(i).depth,profiles(i).ssc,adcpl(i).bindepths);
        
        adcpl(i).sal(adcpl(i).bindepths < adcpl(i).dmin) = profiles(i).sal(adcpl(i).imin);
        adcpl(i).sal(adcpl(i).bindepths > adcpl(i).dmax) = profiles(i).sal(adcpl(i).imax);
        adcpl(i).sal = repmat(adcpl(i).sal,[1 4 adcpl(i).numens]);
        
        adcpl(i).temp(adcpl(i).bindepths < adcpl(i).dmin) = profiles(i).temp(adcpl(i).imin);
        adcpl(i).temp(adcpl(i).bindepths > adcpl(i).dmax) = profiles(i).temp(adcpl(i).imax);
        adcpl(i).temp = repmat(adcpl(i).temp,[1 4 adcpl(i).numens]);
        
        adcpl(i).conc(adcpl(i).bindepths < adcpl(i).dmin) = profiles(i).ssc(adcpl(i).imin);
        adcpl(i).conc(adcpl(i).bindepths > adcpl(i).dmax) = profiles(i).ssc(adcpl(i).imax);
        adcpl(i).conc = repmat(adcpl(i).conc,[1 4 adcpl(i).numens]);
    elseif isempty(profiles(i).depth)
        
        adcpr(i).sal = adcpr(i-1).sal;
        adcpr(i).temp = adcpr(i-1).sal;
        adcpr(i).conc = adcpr(i-1).conc;
        adcpl(i).sal = adcpl(i-1).sal;
        adcpl(i).temp = adcpl(i-1).temp;
        adcpl(i).conc = adcpl(i-1).conc;
    end
    
    args.T = nanmean(ctd_info.temp);
    args.S = nanmean(profiles(i).sal);
    args.C = nanmean(profiles(i).ssc);
    
    [adcpr(i).Idb,adcpr(i).alf] = backscatter_MTR(adcpr(i),args);
    [adcpl(i).Idb,adcpl(i).alf] = backscatter_MTR(adcpl(i),args);
end

