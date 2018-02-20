%script for calibrating ADCP Data
%Project: Pearl Harbor PICS

%% Parameters
% pnbase='C:\Users\PICS\Documents\active_jobs\NavyPropwash\PearlHarbor';
pnbase='Z:\Jarrell\LMS_SaltWedge\mcode';
fnxls=fullfile(pnbase,'PearlHarbor_SSC.xlsx');
sheet='Aug 29';
%load SSC/CTD data
s=loadxls_struct(fnxls,sheet);
s.mtime=datenum(s.date)+s.time;
s.dB=nan(size(s.time)); %prealloc
s.dB_std=s.dB; %a duplicate
%load ADCP data
dt=(30)/3600/24; %averaging period (sec) -> days
[fnadcp,pn]=uigetfile('*.mat','Select ADCP data',...
    'MultiSelect','on');
if ~iscell(fnadcp),fnadcp={fnadcp};end
fnadcp=sort(fnadcp);
clear adcp
datelim=nan(length(fnadcp),2); %prealloc
for k=1:length(fnadcp);
    adcp(k)=load(fullfile(pn,fnadcp{k}));
    datelim(k,:)=minmax(adcp(k).mtime);
end
%% loop through samples and gather the required ADCP parameters
args.T=mean(s.temp); % this needs to be a temp profile (bins x ensembles)
args.S=mean(s.sal); % this needs to be a sal profile (bins x ensembles)
Iold=0;
for k=1:length(s.time);
    %TODO: get temperature and salinity profiles
    %+extract required parameters to adcp dataset
    I=find(datelim(:,1)<=s.mtime(k) & datelim(:,2)>=s.mtime(k));
    if I~=Iold
        Iold=I;
        adcp(I).temp=args.T; % 
        adcp(I).sal=args.S;  % 
        [adcp(I).Idb,adcp(I).alf]=backscatter(adcp(I),args);
    end
    in_time=adcp(I).mtime>=s.mtime(k) & adcp(I).mtime<=s.mtime(k)+dt;
    depkey=abs(adcp(I).config.ranges-s.depth_m(k));
    in_bin=depkey == min(depkey);
    Idb=adcp(I).Idb(in_bin,:,in_time);
    s.dB(k)=mean(Idb(:));
    s.dB_std(k)=std(Idb(:));
end

%% Perform calibration
ssc_offset=4; %?? check to see if this is valid
ssc=s.ssc_mgL+ssc_offset;
in=ssc>0; %ignore any negative concentrations
ssc=ssc(in);
dB=s.dB(in); %neglect the associated backscatter
%plot data
figure(10);
plot(dB,ssc,'b*');
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
title(sprintf('SSC=10^{%g + %g*\\beta}',p(2),p(1)))

%% Apply calibration to ADCP struct
for k=1:length(adcp)
    adcp(k).fnadcp=fnadcp{k};
    adcp(k).temp=args.T;
    adcp(k).sal=args.S;
    [adcp(k).Idb,adcp(k).alf]=backscatter(adcp(k),args);
    Idb=squeeze(mean(adcp(k).Idb,2));
    adcp(k).ssc=10.^polyval(p,Idb);
end
save ADCPcal_29Aug adcp

%% Visualize the resulting data
figure(11);
K=3; %select the file
ssc=adcp(K).ssc;
%filter out the bottom echo
for k=1:length(adcp(K).mtime)
   in=adcp(K).config.ranges>0.96*min(adcp(K).bt_range(:,k),[],1); %min
%    in=adcp(K).config.ranges>0.94*mean(adcp(K).bt_range(:,k),1); %mean
   ssc(in,k)=1e-3;
end
imagesc(adcp(K).mtime,adcp(K).config.ranges,log10(ssc));
datetick('x','keeplimits')
set(gca,'CLim',[0,2]);
title(adcp(K).fnadcp,'Interpreter','none');
%adjust the colorbar ticks for log scale
hcb=colorbar;
ytc=[1,5,10,20,40,60,100];
set(hcb,'YTick',log10(ytc),...
    'YTickLabel',num2str(ytc'));
set(get(hcb,'Title'),'String','ssc (mg/L)')
%axis labels
xlabel('time')
ylabel('depth (m)')

%Save the figure (automatically)
% print('-dpng',sprintf('sscVz&time_%s',strrep(adcp(K).fnadcp,'r.mat','.png')))

%% Export the data to text file
fid=fopen('SSC_pos_20120829.txt','wt');
fprintf(fid,'t:time  X:lon  Y:lat  C:conc  Z:depth \n');%colheaders
for K=1:length(adcp)
    N=length(adcp(K).mtime); %number of ensembles
    Z=adcp(K).config.ranges;
    
    %!CORRECT ERRORS IN GPS STRING! (Pearl Harbor only)
    in_perr=isnan(adcp(K).nav_latitude) | adcp(K).nav_longitude>=0; %flag errors
    %interpolate for missing position data
    LAT=interp1(find(~in_perr),adcp(K).nav_latitude(~in_perr),1:N,'linear','extrap');
    LON=interp1(find(~in_perr),adcp(K).nav_longitude(~in_perr),1:N,'linear','extrap');
    
    for n=1:N, %N is the number of ensembles
        in=Z>0.96*min(adcp(K).bt_range(:,n),[],1); %min
        I=find(~in,1,'last'); %last good bin
        dstr=datestr(adcp(K).mtime(n),'mm/dd/yyyy HH:MM:SS');
        lon=LON(n);
        lat=LAT(n);
        for k=1:I
            fprintf(fid,'%s,%12.7f,%12.7f,%5.1f,%5.2f\n',...
                dstr,lon,lat,adcp(K).ssc(k,n),Z(k));
        end
    end
end
fclose(fid);

