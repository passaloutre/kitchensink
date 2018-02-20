load('E:\DATA TO BE PROCESSED - PROCESSED_MBT\Dauphin Island 2015\Aquadop\20150620_20150823\DPHN102_out.mat')

%amplitudes
h_fig=figure(523);
ax1=subplot(2,1,1);
plot(ax1,cur.dtime,cur.amp_1_avg,...
    cur.dtime,cur.amp_2_avg,...
    cur.dtime,cur.amp_3_avg,...
    cur.dtime,mean([cur.amp_1_avg,cur.amp_2_avg,cur.amp_3_avg],2))
legend('amp\_1\_avg','amp\_2\_avg','amp\_3\_avg','amp\_all\_avg')
grid
ylabel('Amplitude [counts]')
ylim([30,160])
title('Aquadopp Amplitude')

%Hm0
ax2=subplot(2,1,2);
plot(ax2,wav.wap.dtime,wav.wap.Hm0)
grid
ylabel('Hm0 [m]')
xlabel('UTC')

%global
linkaxes([ax1,ax2],'x')
set([ax1,ax2],'FontSize',16,'XLim',datenum({'20-Jun-2015 08:06:15','24-Aug-2015 00:07:35'}))
h_fig.Position=[2784 9 2329 1348];
