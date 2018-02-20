%script to plot salinity profiles from T,S associated with PICS data

%% Parameters
xlsfile='ptvpiv_LowerMSRV_SaltWedge.xlsx';
[~,sheet]=xlsfinfo(xlsfile);
RM=[ -1.5, 1.5, 4.5, 6.0, 9.0, 13.0, 16.0, 21.0,  26,  36];
Tdep=[ 52,  55,  55,  54,  63,  64,    88,  150, 100, 105]; %total depth, ft
Tdep=Tdep*0.3048; %convert to m
%% Load data
for k=1:length(sheet)
    s(k)=loadxls_struct(xlsfile,sheet{k});
end

%% Plot salinity profiles
figure(21),cla
hold on
h(length(s))=nan; %prealloc
for k=1:length(s)
    plot(RM(k)*[1,1],[0,Tdep(k)],'k:')
    d=[s(k).depth_m,s(k).salinity];
    d=sortrows(d);
    h(k)=plot(RM(k)+d(:,2)/10,d(:,1));
end
plot(RM,Tdep,'k-')
hold off
set(gca,'YDir','reverse')
xlabel('river mile')
ylabel('depth [m]')
