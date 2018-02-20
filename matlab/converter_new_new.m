% script for converting lisst data to proper fmt for load_lisstasc.m

% user input files to convert
[fn,pn] = uigetfile('*.csv','Multiselect','on','E:\Projects\LISST\LISST2015');

%% processing
for i=1:length(fn)
    disp(fn{i})
    infile = fullfile(pn,fn{i});
    dat = readtable(infile);
    
    numrows = length(dat.Date);
    years = zeros(size(dat.Date));
    months = zeros(size(dat.Date));
    days = zeros(size(dat.Date));
    jdays = zeros(size(dat.Date));
    hours = zeros(size(dat.Date));
    minutes = zeros(size(dat.Date));
    seconds = zeros(size(dat.Date));
    ddhh = zeros(size(dat.Date));
    mmss = zeros(size(dat.Date));

    for j =1:numrows
        years(j) = year(dat.Date(j));
        months(j) = month(dat.Date(j));
        days(j) = day(dat.Date(j));
        jdays(j) = day(dat.Date(j),'dayofyear');
        times = str2double(strsplit(dat.Time{j},':'));
        hours(j) = times(1);
        minutes(j) = times(2);
        seconds(j) = times(3);
        ddhh(j) = jdays(j)*100+hours(j);
        mmss(j) = minutes(j)*100+seconds(j);
    end

    rings = [dat.SizeBin_1_ul_L_,dat.SizeBin_2_ul_L_,dat.SizeBin_3_ul_L_,dat.SizeBin_4_ul_L_,dat.SizeBin_5_ul_L_,dat.SizeBin_6_ul_L_,dat.SizeBin_7_ul_L_,dat.SizeBin_8_ul_L_,dat.SizeBin_9_ul_L_,dat.SizeBin_10_ul_L_,...
        dat.SizeBin_11_ul_L_,dat.SizeBin_12_ul_L_,dat.SizeBin_13_ul_L_,dat.SizeBin_14_ul_L_,dat.SizeBin_15_ul_L_,dat.SizeBin_16_ul_L_,dat.SizeBin_17_ul_L_,dat.SizeBin_18_ul_L_,dat.SizeBin_19_ul_L_,dat.SizeBin_20_ul_L_,...
        dat.SizeBin_21_ul_L_,dat.SizeBin_22_ul_L_,dat.SizeBin_23_ul_L_,dat.SizeBin_24_ul_L_,dat.SizeBin_25_ul_L_,dat.SizeBin_26_ul_L_,dat.SizeBin_27_ul_L_,dat.SizeBin_28_ul_L_,dat.SizeBin_29_ul_L_,dat.SizeBin_30_ul_L_,...
        dat.SizeBin_31_ul_L_,dat.SizeBin_32_ul_L_];

    laser_trans = dat.laserPowerTransmission_digitalCounts_;
    battery = dat.battery_V_;
    aux1 = dat.AuxIn_V_;
    laser_ref = dat.LaserRef_digitalCounts_;
    pressure = dat.depth_m_;
    temperature = dat.temp_C_;
    trans = dat.opticTrans;
    beamc = dat.beamAttenuation_m__1_;
        
    out = [rings,laser_trans,battery,aux1,laser_ref,pressure,temperature,ddhh,mmss,trans,beamc];
    outfile = strcat(strtok(infile,'.'),'.asc');
    dlmwrite(outfile,out,' ')
% 
%     
%     data = load_lisstasc(outfile,'c');
%     fig = figure();
%     pcolor(data.d,-data.pressure,data.vc)
%     filesplit = strsplit(outfile,'\');
%     title(filesplit(end),'interpreter','none')
%     ylim([-max(data.pressure) 0]);
end
