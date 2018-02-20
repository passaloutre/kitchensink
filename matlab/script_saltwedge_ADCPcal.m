%script for calibrating ADCP Data
%Project: Salt Wedge PICS

%% Parameters
% pnbase='C:\Users\PICS\Documents\active_jobs\NavyPropwash\PearlHarbor';
colormap('jet')

pnbase='E:\Projects\SaltWedge';
fnxls=fullfile(pnbase,'lms_ssc_ctd.xlsx');
sheet='2016';

%%

%load SSC/CTD data
s=loadxls_struct(fnxls,sheet);
s.mtime=datenum(s.date)+s.time;
s.dB=nan(size(s.time)); %prealloc
s.dB_std=s.dB; %a duplicate
s.mile = nan(size(s.time));

for i =1:length(s.mile)
    mile = s.station{i};
    s.mile(i) = str2double(mile(3:end));
end

date = datevec(s.mtime(1));
year = date(1);

%% generate temp/salinity profiles, with list of relevant adcp files

[filelist,ia,ic] = unique(s.adcp_file,'stable'); % get adcp filenames and indices for each station
profiles = struct([]); % prealloc

for i = 1: length(filelist)
    profiles(i).station = s.station(ic==i);
    profiles(i).filename = s.adcp_file(ic==i);
    profiles(i).paths = s.adcp_path(ic==i);
    profiles(i).depth = s.depth_m(ic==i);
    profiles(i).ssc = s.ssc_mgL(ic==i);
    profiles(i).temp = s.temp(ic==i);
    profiles(i).sal = s.sal(ic==i);
    profiles(i).time = s.mtime(ic==i);
    profiles(i).mile = s.mile(ic==i);
    % convert adcp filenames to .mat filenames
    profiles(i).matname = strcat(strtok(profiles(i).filename{1},'.'),'.mat');
    
    
end

%%

%load ADCP data
dt=(30)/3600/24; %averaging period (sec) -> days

% for gui selection of .mat files
% [fnadcp,pn]=uigetfile('*.mat','Select ADCP data',...
%     'MultiSelect','on');
% if ~iscell(fnadcp),fnadcp={fnadcp};end
% fnadcp=sort(fnadcp);

fnadcp = {profiles.matname};
pn = pnbase;

clear adcp
% adcp = struct(); %prealloc
datelim=nan(length(fnadcp),2); %prealloc
for k=1:length(fnadcp)
    adcp(k)=load(fullfile(pn,fnadcp{k}));
    datelim(k,:)=minmax(adcp(k).mtime);
end
% adcp.conc = ([]);

%% construct temp sal and conc matrices size nbins x nens
for k = 1:length(fnadcp)
    numbins = length(adcp(k).east_vel(:,1)); % get number of bins
    numens = length(adcp(k).east_vel(1,:)); % get number of ensembles
    binranges = adcp(k).config.ranges; % get bin ranges
    bindepths = binranges*cosd(20); % convert range to depth
    [dmin,imin] = min(profiles(k).depth); % get min depth of ssc samples
    [dmax,imax] = max(profiles(k).depth); % get max depth of ssc samples
    
    % interpolate sal/temp samples to depths of bins
    adcp(k).sal = pchip(profiles(k).depth,profiles(k).sal,bindepths);
    adcp(k).temp = pchip(profiles(k).depth,profiles(k).temp,bindepths);
    adcp(k).conc = pchip(profiles(k).depth,profiles(k).ssc,bindepths);
    
    adcp(k).sal(bindepths < dmin) = profiles(k).sal(imin);
    adcp(k).sal(bindepths > dmax) = profiles(k).sal(imax);
    adcp(k).sal = repmat(adcp(k).sal,[1 4 numens]);
    
    adcp(k).temp(bindepths < dmin) = profiles(k).temp(imin);
    adcp(k).temp(bindepths > dmax) = profiles(k).temp(imax);
    adcp(k).temp = repmat(adcp(k).temp,[1 4 numens]);
    
    adcp(k).conc(bindepths < dmin) = profiles(k).ssc(imin);
    adcp(k).conc(bindepths > dmax) = profiles(k).ssc(imax);
    adcp(k).conc = repmat(adcp(k).conc,[1 4 numens]);
end

%% loop through samples and gather the required ADCP parameters
args.T=mean(s.temp); % this needs to be a temp profile (bins x ensembles)
args.S=mean(s.sal); % this needs to be a sal profile (bins x ensembles)
args.C=mean(s.ssc_mgL);
Iold=0;

%%
for k=1:length(s.time)
    %TODO: get temperature and salinity profiles
    %+extract required parameters to adcp dataset
    I=find(datelim(:,1)<=s.mtime(k) & datelim(:,2)>=s.mtime(k));
    if I~=Iold
        Iold=I;
        %         args.T=adcp(I).temp;
        %         args.S = adcp(I).sal;
        [adcp(I).Idb,adcp(I).alf]=backscatter_MTR(adcp(I),args);
    end
    in_time=adcp(I).mtime>=s.mtime(k) & adcp(I).mtime<=s.mtime(k)+dt;
    depkey=abs(adcp(I).config.ranges-s.depth_m(k));
    in_bin=depkey == min(depkey);
    Idb=adcp(I).Idb(in_bin,:,in_time);
    s.dB(k)=mean(Idb(:));
    s.dB_std(k)=std(Idb(:));
end

%% Perform calibration

ssc_offset=0; %?? check to see if this is valid
ssc=s.ssc_mgL+ssc_offset;

in=ssc>0; %ignore any negative concentrations
ssc=ssc(in);
mile = s.mile(in);
dB=s.dB(in); %neglect the associated backscatter
valid = ~isnan(dB);
dB = dB(valid);
ssc = ssc(valid);
mile = mile(valid);
%plot data
figure(10);
scatter(dB,ssc,25,mile,'filled','markeredgecolor','k');
set(gca,'YScale','log');
xlabel('backscatter (dB)')
ylabel('ssc (mg/L)')
% determine calibration
p=polyfit(dB,log10(ssc),1);
hold on
xlm=get(gca,'XLim');
xplot=linspace(xlm(1),xlm(2));
yplot=10.^polyval(p,xplot);
plot(xplot,yplot,'k-')
title(sprintf('%.0f: SSC=10^{%g + %g*\\beta}',year,p(2),p(1)))

hcb=colorbar;
set(get(hcb,'Title'),'String','River Mile')
grid on

%% Apply calibration to ADCP struct
for k=1:length(adcp)
    adcp(k).fnadcp=fnadcp{k};
    %     adcp(k).temp=args.T;
    %     adcp(k).sal=args.S;
    %     [adcp(k).Idb,adcp(k).alf]=backscatter_MTR(adcp(k),args);
    Idb=squeeze(mean(adcp(k).Idb,2));
    adcp(k).ssc=10.^polyval(p,Idb);
end
% save ADCPcal_2016 adcp

%% Visualize the resulting data
figure(11);
K=7; %select the file
ssc=adcp(K).ssc;
%filter out the bottom echo
for k=1:length(adcp(K).mtime)
    in=adcp(K).config.ranges>0.96*min(adcp(K).bt_range(:,k),[],1); %min
    %    in=adcp(K).config.ranges>0.94*mean(adcp(K).bt_range(:,k),1); %mean
    ssc(in,k)=1e-3;
    %     ssc(in,k) = nan;
end
imagesc(adcp(K).mtime,adcp(K).config.ranges,log10(ssc));
datetick('x','keeplimits')
set(gca,'CLim',[0,2]);
title(adcp(K).fnadcp,'Interpreter','none');
ylim([0 nanmax(adcp(K).bt_range(:))]);
%adjust the colorbar ticks for log scale
hcb=colorbar;
ytc=[1,5,10,20,40,60,100];
set(hcb,'YTick',log10(ytc),...
    'YTickLabel',num2str(ytc'));
set(get(hcb,'Title'),'String','SSC [mg/L]')
%axis labels
xlabel('Time')
ylabel('Depth [m]')

hold on
scatter(profiles(K).time,profiles(K).depth,15,log10(profiles(K).ssc),'filled','markeredgecolor','k')
plot(adcp(K).mtime,mean(adcp(K).bt_range,1),'k-')
%Save the figure (automatically)
% print('-dpng',sprintf('sscVz&time_%s',strrep(adcp(K).fnadcp,'r.mat','.png')))

% %% Export the data to text file
% fid=fopen('SSC_pos_20120829.txt','wt');
% fprintf(fid,'t:time  X:lon  Y:lat  C:conc  Z:depth \n');%colheaders
% for K=1:length(adcp)
%     N=length(adcp(K).mtime); %number of ensembles
%     Z=adcp(K).config.ranges;
%
%     %!CORRECT ERRORS IN GPS STRING! (Pearl Harbor only)
%     in_perr=isnan(adcp(K).nav_latitude) | adcp(K).nav_longitude>=0; %flag errors
%     %interpolate for missing position data
%     LAT=interp1(find(~in_perr),adcp(K).nav_latitude(~in_perr),1:N,'linear','extrap');
%     LON=interp1(find(~in_perr),adcp(K).nav_longitude(~in_perr),1:N,'linear','extrap');
%
%     for n=1:N, %N is the number of ensembles
%         in=Z>0.96*min(adcp(K).bt_range(:,n),[],1); %min
%         I=find(~in,1,'last'); %last good bin
%         dstr=datestr(adcp(K).mtime(n),'mm/dd/yyyy HH:MM:SS');
%         lon=LON(n);
%         lat=LAT(n);
%         for k=1:I
%             fprintf(fid,'%s,%12.7f,%12.7f,%5.1f,%5.2f\n',...
%                 dstr,lon,lat,adcp(K).ssc(k,n),Z(k));
%         end
%     end
% end
% fclose(fid);
%
