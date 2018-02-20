function [Idb,alf]=backscatter(adcp,varargin)
%BACKSCATTER function to estimate backscatter intensity (dB) from RDI ADCP
%
% [Idb,alf]=backscatter(adcp)
% [Idb,alf]=backscatter(adcp,args)
% where,
%  Idb = backscatter intensity in dB
%  alf = complex sound absorption coeffs [dB/m]
% adcp = struct array in rdradcp format
%        {Note: if time/depth variable T,S required,
%         add .temp & .sal fields with size (nbin,nens)}
% args = struct array containing optional information with fields:
%    .T = temperature [C]{default: mean of transducer temp}
%    .S = salinity [ppt] {default: 10}
%    .C = concentration [mg/L] {default: 0}
%         if not constant, specify for [nbins,nens] matrix
%    .d = median diameter of suspended sediment [um]
%  .zet = scattering parameter (zet>=1) {default: 1}
%    (NOTE: data fields must be of same size or scalar.)
%  .method_bs = backscatter method ({'WinRiver'},'Deines')
%  .method_sa = sound absorption method ({'am'},'fg','rdi')
%             Note: Add 's' to method name to include sediment.
%                   e.g. 'ams' or 'fgs'. 
%                   Fields .C, .d, and .zet are used only for sediment
%                   absorption.
%NOTES: 
%   1. Approximate equation used here from WinRiver Users Guide 
%      (Feb2007), pg 47-48.
%
%   2. Supported instruments are BB and WH ADCP
%
%   3. In future will implement method of 
%      Deines paper: "Backscatter estimation using broadband ADCPs"
%   4. Deines method has been implemented, but produces unexpected results.
%      Suspect there is an error in his Eqn 2

%Jarrell Smith
%5/4/2008   Initial coding
%7/21/2009  Modified to make use of .temp & .sal fields in adcp
%           struct.

%% Parameters
%defaults
S=10;
Cs=0;
T=mean(adcp.temperature);
Method='Winriver';  %WinRiver or Deines
Method_sa='am';
%system characteristics
%broadband
bb.nfreq=[75,150,300,600,1200]; %kHz
bb.freq=[76.8,153.6,307.2,614.4,1228.8]; %kHz
bb.C=-[163.3,153.3,148.2,141.4,129.5]; %dB
bb.Pdbw=[23.8,23.8,15.4,15.4,12.6]; %
bb.Ro=[3.15,1.88,2.64,2.90,1.67]; %m
%workhorse
wh.nfreq=[75,300,600,1200]; %kHz
wh.freq=[76.8,307.2,614.4,1228.8]; %kHz
wh.C=-[159.1,143.5,139.3,129.1]; %dB
wh.Pdbw=[24,14,9.0,4.8]; %
wh.Ro=[1.3,0.98,1.96,1.67]; %m

%% Check Input
error(nargchk(1,2,nargin));
if nargin==2,
   args=varargin{1};
   if isfield(args,'S')
      S=args.S;
   end
   if isfield(args,'T')
      T=args.T;
   end
   if isfield(args,'C')
      Cs=args.C;
   end
   if isfield(args,'method_bs')
      Method=args.method_bs;
   end
   if isfield(args,'method_sa')
      Method_sa=args.method_sa;
   end
end
switch adcp.config.name
   case 'bb-adcp'
      I=find(bb.nfreq==adcp.config.beam_freq); %index into system characteristics
      freq=bb.freq(I);
      C=bb.C(I);
      Pdbw=bb.Pdbw(I);
      Ro=bb.Ro(I);
   case 'wh-adcp'
      I=find(wh.nfreq==adcp.config.beam_freq); %index into system characteristics
      freq=wh.freq(I);
      C=wh.C(I);
      Pdbw=wh.Pdbw(I);
      Ro=wh.Ro(I);
   otherwise
      error('ADCP type: %s is not supported.',adcp.config.name);
end
%sound absorption coeff (compute attenuation coeff at each bin)
args.T=T;
args.S=S;
args.C=Cs;
args.f=freq;
args.method_sa=Method_sa;
%sound speed
% c=sndspd(S,mean(adcp.temperature),10); %not used now. maybe later

%% Calculations 
switch lower(Method)
   case 'winriver'
      [Idb,alf]=bs_winriver(adcp,args,Ro);
   case 'deines'
      Idb=bs_deines(adcp,args,C,Pdbw,Ro);
end

%%%%%%%%%%%%%%%%%%%%%%
%%%% SUBFUNCTIONS %%%%
%%%%%%%%%%%%%%%%%%%%%%
function [Idb,alpha]=bs_winriver(adcp,args,Ro)
%From WinRiver Users Guide (Feb 2007)
szI=size(adcp.intens);
Idb=zeros(szI);
alpha=complex(Idb,Idb); %alfw in real, alfs in imag
Rmx=2*pi*Ro/4;
ct=cosd(adcp.config.beam_angle);      
C=127.3./(adcp.temperature + 273);
R=repmat((adcp.config.ranges+0.5*adcp.config.cell_size)/ct,[1,szI(2)]);
dR=diff([zeros(1,size(R,2));R],[],1);
phi=(2+max(R,Rmx)./R)./3; %Hill et al (2003)
Cs=args.C; %sediment concentration
%TODO: update temperature and salinity in args specification as
%time-variant constants
T=adcp.temp; 
S=adcp.sal; 
% alf1=sound_absorption(args);
for k=1:szI(3)
   if isscalar(Cs)
      args.C=repmat(Cs,szI(1:2));
   else
      args.C=Cs(:,:,k);
   end
   if isscalar(T)
       args.T=repmat(T,szI(1:2));
   else
      args.T=T(:,:,k);
   end
   if isscalar(S)
       args.S=repmat(S,szI(1:2));
   else
      args.S=S(:,:,k);
   end
   [alf,alfw,alfs]=sound_absorption(args);
%    alf=alf1(:,:,k);
   Idb(:,:,k)=C(k)*adcp.intens(:,:,k) + 20*phi.*log10(R) + 2*cumsum(alf.*dR) ...
      - 10*log10(adcp.config.cell_size/ct);
   alpha(:,:,k)=complex(alfw,alfs);
end

% function Idb=bs_deines(adcp,alf,C,Pdbw,Ro)
% %From Deines paper "Backscatter Estimation Using Broadband Acoustic Doppler
% %Current Profilers".  Author: Kent L. Deines, IEEE conference paper (1999)
% %TODO:  Seems to produce poor results. Not verified.
% %Suspect there is an error in his Eqn 2
% %% System Characteristics
% E=adcp.intens; %echo intensity (count)
% Er=min(E(:)); %reference echo intensity
% L=adcp.config.xmit_pulse; %transmit pulse length (m)
% T=adcp.temperature; %transducer temperature (C)
% theta=adcp.config.beam_angle; %beam angle(deg)
% Rmx=2*pi*Ro/4;
% Kc=127.3./(T+273); %typical value (dB/LSB)
% % B=adcp.config.blank; %blank after transmit (m)
% % D=adcp.config.cell_size; %depth cell length (m)
% % N=1:adcp.config.n_cells; %cell indices
% % c=1; %sound speed (logged)
% % cp=1; %sound speed (corrected)
% %% Calculations
% %preallocate
% Idb=nan(size(E));
% %R, slant range
% % R=(B+(L+D)/2+(N-1)*D+D/4)/cosd(theta)*c/cp; %from Deines (Eqn 3)
% R=repmat(adcp.config.ranges/cosd(theta),[1,4]);
% phi=(2+max(R,Rmx)./R)./3; %Hill et al (2003)
% %Eqn 2
% for k=1:size(E,3)
% %    Idb(:,:,k)=C + 10*phi.*log10((T(k)+273.16)*R.^2)...
% %       -10*log10(L) - Pdbw + 2*alf*R + Kc(k)*(E(:,:,k)-Er); %as given
%    Idb(:,:,k)=20*phi.*log10(R)...
%       -10*log10(L) + 2*alf*R + Kc(k)*(E(:,:,k)); %corrected?
% end
