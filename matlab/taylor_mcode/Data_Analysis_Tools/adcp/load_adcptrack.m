function [adcp,cfg]=load_adcptrack(fn,ensavg,cflag)
%LOAD_ADCPTRACK function to load and depth average adcp track data
%
%SYNTAX: [adcp,cfg]=load_adcptrack
%        [adcp,cfg]=load_adcptrack(fn)
%        [adcp,cfg]=load_adcptrack(fn,ensavg,corrflag)
% where,
%    adcp = struct array with adcp data
%     cfg = adcp configuration struct
%      fn = filename to load (RDI raw binary)
%  ensavg = ensemble averaging to apply (1=raw data, n=num of ensem to avg)
%corrflag = perform heading corrections from BT and GPS track
%           1= correct heading, 0= no correction
%

%TODO: This function needs a complete or partial rewrite for flexibility in ADCP
%vessel corrections and how to identify and handle bad data.  See
%adcp_process.m for some material.

%% Parameters
didz_lim=2;
ves_spd='bt'; %Determines how vessel speed is estimated: 'bt','gps','both'
%% Check input
nargchk(0,3,nargin);
switch nargin
   case 0
      [fn,pn]=uigetfile('*r.000','Select RDI raw ADCP file.');
      if isnumeric(fn),return,end
      fn=fullfile(pn,fn);
      cflag=0;
      ensavg=4;
   case 1
      cflag=0;
      ensavg=4;
   case 2
      cflag=0;
   case 3
      if islogical(cflag)||isnumeric(cflag)
         cflag=logical(cflag);
      else
         return
      end
end
%% Load file
[adcp,cfg]=rdradcp(fn,ensavg);
adcp=removebad(adcp); %remove bad ensembles
adcp.ensavg=ensavg;
nens=length(adcp.mtime);
nbins=length(cfg.ranges);
[u1,v1]=deal(zeros(1,nens)); %water velocity (relative to transducer)
if cflag, %correct heading errors in BT and water velocities
   adj=correct_noaa2002adcp(adcp);
end
%% Compute depth averaged velocities (relative to transducer)
for k=1:nens
   intens=mean(squeeze(adcp.intens(:,:,k)),2);
   dep=mean(adcp.bt_range(:,k));
   %identify good data
   didz=gradient(intens,cfg.ranges);
   I=find(didz>didz_lim,1,'first');
   if I==1,
      I=find(didz>didz_lim,2,'first');
      try
         I=I(2);
      catch
         I=nbins;
      end
   end
   if isempty(I)
      I=nbins;
   end
   in1=(1:nbins)'<=I;
   in2=cfg.ranges<=dep;
   in=in1&in2;
   if cflag, %use heading-corrected velocities
      u1(k)=mean(adj.east_vel(in,k));
      v1(k)=mean(adj.north_vel(in,k));      
   else %use velocities from raw file
      u1(k)=mean(adcp.east_vel(in,k));
      v1(k)=mean(adcp.north_vel(in,k));
   end
end
%% Compute vessel velocity from GPS or BT
switch lower(ves_spd)
   case 'bt'
      u2=-1e-3*adcp.bt_vel(1,:); %Made negative for adcp.bins later
      v2=-1e-3*adcp.bt_vel(2,:);
      in=u2>15;
      u2(in)=nan;
      v2(in)=nan;
   case {'gps','both'}
      if cflag, %get filtered GPS velocities
         u2=adj.nav_u;
         v2=adj.nav_v;
      else  %compute GPS velocity from positioning data
         [dr,af]=dist(adcp.nav_latitude,adcp.nav_longitude);
         t=adcp.mtime;
         [dy,dx]=pol2cart(af*pi/180,dr);
         x=[0,cumsum(dx)];
         y=[0,cumsum(dy)];
         et=(t-t(1))*86400; %[sec]
         u2=gradient(x,et);
         v2=gradient(y,et);
         %    drdt=dr./diff(t)/86400;
         %    [v2,u2]=pol2cart(af([1,1:end])*pi/180,drdt([1,1:end])); %vessel velocity
      end
end
%% Earth-relative water velocity
adcp.umean=u1+u2;
adcp.vmean=v1+v2;
%TODO: Handle ship to earth coordinate transformations
switch lower(adcp.config.coord_sys)
   case 'ship'  %u=starboard, v=forward
      for k=1:nens
         ct=cosd(adcp.heading(k));
         st=sind(adcp.heading(k));
         A=[ct,st;-st,ct];
         %mean velocities
         vu=[adcp.vmean(k),adcp.umean(k)]*A;
         adcp.vmean(k)=vu(1);
         adcp.umean(k)=vu(2);
         %bin velocities
         vu=[1e-3*adcp.north_vel(:,k)+v2,1e-3*adcp.east_vel(:,k)+u2]*A;
         adcp.north_vel(:,k)=vu(:,1);
         adcp.east_vel(:,k)=vu(:,2);         
      end
   case 'enu'
end
adcp.config.coord_sys='enu';
if cflag,  %correct velocities in bins also
   adcp.east_vel=adj.east_vel+ones(adcp.config.n_cells,1)*u2;
   adcp.north_vel=adj.north_vel+ones(adcp.config.n_cells,1)*v2;
end
end %end function load_adcptrack

%% Subfunctions
function adcp=removebad(adcp)
%function to remove bad ensembles
in1=adcp.nav_latitude~=0;
in2=~isnan(adcp.nav_latitude);
in3=abs(adcp.nav_latitude-median(adcp.nav_latitude(in2)))<0.5;
in4=adcp.nav_longitude~=0;
in5=~isnan(adcp.nav_longitude);
in6=abs(adcp.nav_longitude-median(adcp.nav_longitude(in5)))<0.5;
in=all([in1;in2;in3;in4;in5;in6],1);
fld=fieldnames(adcp);
for k=1:length(fld),
   switch fld{k}
      case {'mtime','number','pitch','roll','heading',...
            'pitch_std','roll_std','heading_std','depth',...
            'temperature','salinity','pressure','pressure_std',...
            'nav_mtime','nav_longitude','nav_latitude',...
            'east_vel','north_vel','vert_vel','error_vel',...
            'bt_range','bt_vel','bt_corr','bt_ampl','bt_perc_good'}
         adcp.(fld{k})=adcp.(fld{k})(:,in);
      case {'corr','status','intens'}
         adcp.(fld{k})=adcp.(fld{k})(:,:,in);
   end
end
end %end function removebad

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
end %end function correct_noaa2002adcp
