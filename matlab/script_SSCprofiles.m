%script to plot SSC profiles with Salinity Profile

%% Parameters & Data
RM=[ -1.5, 1.5, 4.5, 6.0, 9.0, 13.0, 16.0, 21.0,  26,  36];
Tdep=[ 52,  55,  55,  54,  63,  64,    88,  150, 100, 105]; %total depth, ft
Tdep=Tdep*0.3048; %convert to m
%load data
psample=load('LwrMSRV_ssc.mat'); %loads physical sample SSC
load('pics.mat') %loads struct: pics, containing T,Sal, Depth

%% Plot SSC & salinity profiles for each station
figure(22),clf
hfig=gcf;
hfig.PaperPositionMode='auto';
ax1=gca;
ax2=axes('Position',ax1.Position);
linkaxes([ax1,ax2],'y')
for k=1:length(pics)
    %ax1, Salinty
    d=[pics(k).depth_m,pics(k).salinity];
    d=sortrows(d);
    h1=plot(ax1,d(:,2),d(:,1),'o-');
    ax1.XLim=[0,35];
    set(ax1,'YDir','reverse','XColor',h1.Color,'Box','off')
    xlabel(ax1,'salinity [ppt]')
    ylabel(ax1,'depth [m]')
    %ax2, SSC
    in=psample.RM==RM(k); %selects physical samples
    if ~any(in),continue,end
    d=[0.3048*psample.depth_ft(in),psample.ssc(in)];
    d=sortrows(d);
    h2=plot(ax2,d(:,2),d(:,1),'*');
    h2.Color=ax2.ColorOrder(2,:);
    xlabel(ax2,'ssc [mg/L]')
%     xlm=ax2.XLim;
%     xlm(1)=0;
    ax2.XLim=[0,200];
    ax2.YLim=[0,Tdep(k)];
    xlm=ax2.XLim;
    set(ax2,'XAxisLocation','top',...
        'YDir','reverse',...
        'YTick',[],...
        'Color','none',...
        'XColor',h2.Color,...
        'Box','off');
    text(0.98*xlm(2),0.02*ax2.YLim(2),sprintf('RM %g',RM(k)),...
        'Parent',ax2,...
        'HorizontalAlignment','right',...
        'VerticalAlignment','top')
    %print to graphic
    fnpng=sprintf('sscppt_RM_%05.1f',RM(k));
    fnpng=strrep(fnpng,'.','-');
    print('-dpng',fnpng)

end
