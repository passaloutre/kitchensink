function adj=correct_noaa2002adcp(adcp)
%CORRECT_NOAA2002ADCP function to adjust water velocities due to apparent
%   compass errors in 2002 NOAA adcp data at Knik Arm
%
% SYNTAX: adj=correct_noaa2002adcp(adcp)
% where, adj = struct containing adjusted parameters
%       adcp = struct containing adcp data (from rdradcp function)
%

% Jarrell Smith
% USACE-ERDC-CHL
% Vicksburg, MS
% 8/17/2007 

%% Parameters
w=3;  %averaging filter window size
bdval=-32768; %value of bad BT velocities in raw ADCP file
%% Clean up data and determine velocities
%time
t=adcp.mtime;
%%Estimate GPS velocities
lat=adcp.nav_latitude;
lon=adcp.nav_longitude;
in1=lat~=0 | lon~=0;   %filter out bad GPS data
lat=lat(in1);
lon=lon(in1);
t=t(in1);
[dr,az]=dist(lat,lon,'wgs84');
[dy,dx]=pol2cart(az*pi/180,dr);
x=[0,cumsum(dx)];
y=[0,cumsum(dy)];
et=(t-t(1))*86400; %[sec]
gpsu=gradient(x,et);
gpsv=gradient(y,et);
%Get Bottom Track Velocities
btu=adcp.bt_vel(1,in1);
in=btu==bdval;  %bad data
btu(in)=NaN;
btv=adcp.bt_vel(2,in1);
in=btv==bdval;  %bad data
btv(in)=NaN;
btu=-btu/1000; %convert from mm/s to m/s and rotate by pi (reverse sign)
btv=-btv/1000; %convert from mm/s to m/s and rotate by pi (reverse sign)
%% Apply averaging filter on GPS and BT velocities
%filter gps velocities
guf=filtfilt(ones(1,w)/w,1,gpsu);
gvf=filtfilt(ones(1,w)/w,1,gpsv);
%filter bottom track velocities (handle dropped data)
in=~isnan(btu);  %logical flag on good data
I(2,:)=find(diff([0,in,0])==-1)-1; %indices for end of good data
I(1,:)=find(diff([0,in,0])==1);  %indices for start of good data
N=size(I,2); %number of sections of good data
%preallocate filtered variables
[buf,bvf]=deal(NaN(size(btu)));
for k=1:N,   %filter BT data piecewise
   if diff(I(:,k))<3*2*w,continue,end
   J=I(1,k):I(2,k);
   buf(J)=filtfilt(ones(1,w)/w,1,btu(J));
   bvf(J)=filtfilt(ones(1,w)/w,1,btv(J));
end
%% Compute angle correction for BotTrack
thg=atan2(gvf,guf); %directions mathematical sense
thb=atan2(bvf,buf);
adj.dth=thg-thb;
%interpolate for dth==NaN
in=isnan(adj.dth);
I=find(in);
if all(in) %no bottom track data
   btrack=false;
else
   btrack=true;
   adj.dth(in)=interp1(find(~in),adj.dth(~in),I,'linear','extrap');
end
%% Apply corrections to bottom track and velocities
Nens=length(adj.dth);
Ncell=adcp.config.n_cells;
adj.bc=NaN(2,Nens);
[adj.east_vel,adj.north_vel]=deal(NaN(Ncell,Nens));
if btrack
   for k=1:length(adj.dth),
      d=adj.dth(k);
      A=[cos(d),sin(d);-sin(d),cos(d)];
      adj.bc(:,k)=A'*[buf(k);bvf(k)];
      Ucorr=[adcp.east_vel(:,k),adcp.north_vel(:,k)]*A;
      adj.east_vel(:,k)=Ucorr(:,1);
      adj.north_vel(:,k)=Ucorr(:,2);
   end
end
adj.nav_u=guf;
adj.nav_v=gvf;
end
% %development plots -- filtering
% figure(1)
% plot(et,gpsu,'b',et,btu,'g',et,guf,'b--.',et,buf,'g--.')
% figure(3)
% plot(et,gpsv,'b',et,btv,'g',et,gvf,'b--.',et,bvf,'g--.')

% %% check phase shift in BT and GPS data
% mxlag=20;
% for k=1:N,   %filter BT data piecewise
%    if diff(I(:,k))<3*2*w,continue,end
%    J=I(1,k):I(2,k);
%    cu(k,:)=xcorr(buf(J),guf(J),mxlag);
%    cv(k,:)=xcorr(bvf(J),gvf(J),mxlag);
% end
% figure(4)
% plot(-mxlag:mxlag,cu,'b.-',-mxlag:mxlag,cv,'g.-')
% xlabel('lag (samples)')
% ylabel('xcorr')

% %development plots -- Corrections
% figure(4)
% plot(et,thg,et,thb)
% title('Raw directions')
% legend('GPS','BT')
% figure(5)
% plot(et,dth)
% title('Direction difference (GPS-BT)')
% figure(6)
% plot(et,guf,'b',et,bc(:,1),'g')
% title('Corrected BT u')
% figure(7)
% plot(et,gvf,'b',et,bc(:,2),'g')
% title('Corrected BT v')

% %% Vector plot
% k=1;
% figure(8)
% plot([0,guf(k)],[0,gvf(k)],'b',...
%    [0,buf(k)],[0,bvf(k)],'g',...
%    [0,adj.bc(1,k)],[0,adj.bc(2,k)],'g--',...
%    [0,adcp.east_vel(1,k)],[0,adcp.north_vel(1,k)],'r-',...
%       [0,adj.east_vel(1,k)],[0,adj.north_vel(1,k)],'r--')
% % xlm=max(abs([guf(k),gvf(k),buf(k),bvf(k)]));
% xlm=4;
% set(gca,'XLim',ceil(xlm)*[-1,1],'YLim',ceil(xlm)*[-1,1])
% axis square
% grid on
