%script to generate profiles of PICS data

%% Parameters

%% Select path for processing & load data
pn=uigetdir();
files=dir(fullfile(pn,'*.mat'));
for k=1:length(files)
    s(k)=load(fullfile(pn,files(k).name));
end

%% Extract data and plot profile
hfig=figure(23);
hfig.PaperPositionMode='auto';

dep=[s.depth_m];
sal=[s.salinity];
temp=[s.temperature];
d50m=[s.d50m];
ws50m=[s.ws50m];

%% plot
ax1=subplot(1,2,1);
plot(sal,dep,d50m,dep)
set(gca,'YDir','reverse')
xlabel('salinity [ppt], d50m [\mum]')
ylabel('depth [m]')
title('RM 1.5')
legend('salinity','d50')

ax2=subplot(1,2,2);
plot(ws50m,dep)
set(gca,'YDir','reverse')
xlabel('ws50m [mm/s]')
ylabel('depth [m]')
title('RM 1.5')
ax2.XLim(1)=0;
