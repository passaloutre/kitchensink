% script for converting lisst dat to proper fmt for load_lisstasc.m

% user input files to convert
[fn,pn] = uigetfile('*.xlsx','Multiselect','on','E:\Projects\LISST');

%% processing
for i=1:length(fn)
        disp(fn{i})
    infile = fullfile(pn,fn{i});
    [~,sheets] = xlsfinfo(infile);
    clear dat
    dat = loadxls_struct(infile,sheets{1});
    numrows = length(dat.Date);
    
    ddhh = zeros(size(dat.Date));
    mmss = zeros(size(dat.Date));
    
    for j =1:numrows
        datecell = strsplit(cell2mat(dat.Date(j)),'/');
        months(j) = str2double(datecell{1});
        days(j) = str2double(datecell{2});
        years(j) = str2double(datecell{3});
        jdays(j) = day((datetime(years(j),months(j),days(j))),'dayofyear');
        hours(j) = floor(dat.Time(j)*24);
        minutes(j) = floor((dat.Time(j)-hours(j)/24)*60*24);
        seconds(j) = round((dat.Time(j)-hours(j)/24-minutes(j)/60/24)*60*60*24);
        ddhh(j) = jdays(j)*100+hours(j);
        mmss(j) = minutes(j)*100+seconds(j);
    end
    
 %     rings = [dat.Ring_1__l_l,dat.Ring_2__l_l,dat.Ring_3__l_l,dat.Ring_4__l_l,dat.Ring_5__l_l,dat.Ring_6__l_l,dat.Ring_7__l_l,dat.Ring_8__l_l,dat.Ring_9__l_l,dat.Ring_10__l_l,...
%         dat.Ring_11__l_l,dat.Ring_12__l_l,dat.Ring_13__l_l,dat.Ring_14__l_l,dat.Ring_15__l_l,dat.Ring_16__l_l,dat.Ring_17__l_l,dat.Ring_18__l_l,dat.Ring_19__l_l,dat.Ring_20__l_l,...
%         dat.Ring_21__l_l,dat.Ring_22__l_l,dat.Ring_23__l_l,dat.Ring_24__l_l,dat.Ring_25__l_l,dat.Ring_26__l_l,dat.Ring_28__l_l,dat.Ring_28__l_l,dat.Ring_29__l_l,dat.Ring_30__l_l,...
%         dat.Ring_31__l_l,dat.Ring_32__l_l];

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
    % ddhh = ddhh';
    % mmss = mmss';
    trans = dat.opticTrans;
    beamc = dat.beamAttenuation_m__1_;
    
    
    out = [rings,laser_trans,battery,aux1,laser_ref,pressure,temperature,ddhh,mmss,trans,beamc];
    outfile = strcat(strtok(infile,'.'),'.asc');
    
    fileID = fopen(outfile,'w');
    formatSpec = strcat(repmat('%f ',1,42),'\n');
    for k =1:numrows
        fprintf(fileID,formatSpec,out(k,:));
    end
    fclose(fileID);
    
    data = load_lisstasc(outfile,'c');
    fig = figure();
    pcolor(data.d,-data.pressure,data.vc)
    filesplit = strsplit(outfile,'\');
    title(filesplit(end),'interpreter','none')
    ylim([-max(data.pressure) 0]);
end
