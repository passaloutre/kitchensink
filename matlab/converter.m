% script for converting lisst dat to proper fmt for load_lisstasc.m

pn = 'E:\Projects\LISST\Venice9_10_2013LISST';
dirinfo = dir(sprintf('%s\\*.xlsx',pn));
validfiles = false(length(dirinfo),1);
for i =1:length(dirinfo)
    disp(dirinfo(i).name)
    if dirinfo(i).name(1) ~= '~'
        validfiles(i) = 1;
    end
end

dirinfo = dirinfo(validfiles);

%%

for i=1:length(dirinfo)
    infile = fullfile(dirinfo(i).folder,dirinfo(i).name);
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
    
    rings = [dat.Ring_1_ul_l,dat.Ring_2_ul_l,dat.Ring_3_ul_l,dat.Ring_4_ul_l,dat.Ring_5_ul_l,dat.Ring_6_ul_l,dat.Ring_7_ul_l,dat.Ring_8_ul_l,dat.Ring_9_ul_l,dat.Ring_10_ul_l,...
        dat.Ring_11_ul_l,dat.Ring_12_ul_l,dat.Ring_13_ul_l,dat.Ring_14_ul_l,dat.Ring_15_ul_l,dat.Ring_16_ul_l,dat.Ring_17_ul_l,dat.Ring_18_ul_l,dat.Ring_19_ul_l,dat.Ring_20_ul_l,...
        dat.Ring_21_ul_l,dat.Ring_22_ul_l,dat.Ring_23_ul_l,dat.Ring_24_ul_l,dat.Ring_25_ul_l,dat.Ring_26_ul_l,dat.Ring_28_ul_l,dat.Ring_28_ul_l,dat.Ring_29_ul_l,dat.Ring_30_ul_l,...
        dat.Ring_31_ul_l,dat.Ring_32_ul_l];
    
    laser_trans = dat.transmission_mW;
    battery = dat.batt_V;
    aux1 = dat.AuxIn_mW;
    laser_ref = dat.LaserRef_mW;
    pressure = dat.depth_m;
    temperature = dat.temp_C;
    % ddhh = ddhh';
    % mmss = mmss';
    trans = dat.opticTrans;
    beamc = dat.beam_attenuation_m_1;
    
    
    out = [rings,laser_trans,battery,aux1,laser_ref,pressure,temperature,ddhh,mmss,trans,beamc];
    outfile = strcat(strtok(infile,'.'),'.asc');
    
    fileID = fopen(outfile,'w');
    formatSpec = strcat(repmat('%f ',1,42),'\n');
    for k =1:numrows
        fprintf(fileID,formatSpec,out(k,:));
    end
    fclose(fileID);
    
    data = load_lisstasc(outfile,'b');
    fig = figure();
    pcolor(data.d,-data.pressure,data.vc)
    filesplit = strsplit(outfile,'\');
    title(filesplit(end),'interpreter','none')
    ylim([-max(data.pressure) 0]);
end
