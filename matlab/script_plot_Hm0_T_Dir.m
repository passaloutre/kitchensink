%% load data
wav(1)=load('C:\Users\rditlmbt\Documents\MSCIP\Dauphin Island\Gage Data\20150620_20150823_Aquadopp\DPHN102_wap_was.mat');
wav(2)=load('C:\Users\rditlmbt\Documents\MSCIP\Dauphin Island\Gage Data\20150831_20151120_AWAC\DPHN201_wap_was.mat');
wav(1).instr='Aquadopp'; wav(2).instr='AWAC';

%% plot wave height, wave period, wave direction
%parameters
j=2; %1 is aquadopp, 2 is AWAC
ylm_Hm0=[0,ceil(max([wav(1).wap.Hm0;wav(2).wap.Hm0]))];
ylm_Tm02=[0,ceil(max([wav(1).wap.Tm02;wav(2).wap.Tm02]))];

%plot
fig2423=figure(5234);
fig2423.Position=[2569 9 2212 1348];

ax1=subplot(3,1,1);
plot(wav(j).wap.dtime,wav(j).wap.Hm0,'LineWidth',1.5)
set(ax1,'YLim',ylm_Hm0,'YTick',ylm_Hm0(1):1:ylm_Hm0(2))
grid
title(sprintf('%s Wave Parameters',wav(j).instr))
ylabel({'Significant Wave Height [m]';' '})

ax2=subplot(3,1,2);
plot(wav(j).wap.dtime,wav(j).wap.Tm02,'LineWidth',1.5)
set(ax2,'YLim',ylm_Tm02,'YTick',ylm_Tm02(1):1:ylm_Tm02(2))
grid
ylabel({'Wave Period [s]';' '})

ax3=subplot(3,1,3);
plot(wav(j).wap.dtime,wav(j).wap.Mdir,'LineWidth',1.5)
grid
ylabel({'Wave Direction [deg]';'(Direction coming out of)'})
set(ax3,'YLim',[0,360],'YTick',0:45:360,'YTickLabels',{'N','NE','E','SE','S','SW','W','NW','N'});
xlabel('UTC')

%global
linkaxes([ax1,ax2,ax3],'x')
if j==1
    xlm=[datetime('20-Jun-2015'),datetime('24-Aug-2015')]; xlm.TimeZone='UTC';
    xtck=xlm(1):days(5):xlm(2);
else
    xlm=[datetime('01-Sep-2015'),datetime('21-Nov-2015')]; xlm.TimeZone='UTC';
    xtck=xlm(1):days(9):xlm(2);
end
set([ax1,ax2,ax3],'XLim',xlm,'XTick',xtck,'FontSize',16);

%% save

