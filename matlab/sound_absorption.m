function [alf,alfw,alfs]=sound_absorption(args)
%SOUND_ABSORPTION estimates sound absorption in seawater
%
%SYNTAX:  [alf,alfw,alfs]=sound_absorption(args)
%
% where,
%        alf = sound absorption coefficient [dB/m]
%       alfw = sound absorption coeff. for seawater [dB/m]
%       alfs = sound absorption coeff. for suspended sed [dB/m]
%
%       args = struct containing optional input parameters
%         .f = acoustic frequency [kHz] (required)
%         .T = temperature [C] {default: 10}
%         .S = salinity [ppt] {default: 35}
%         .z = depth [m] {default: 10}
%         %Following fields applicable to sediment methods
%         .C = concentration [mg/L] {default: 25}
%         .d = median suspended sediment diameter [um] {default: 40}
%       .zet = scattering parameter [zet>=1] {default: 1}
% .method_sa = sound absorption method (see below)
%              'am' : Ainslie&McColm(1998) {default}
%              'ams': Ainslie&McColm(1998) with Richards(1998) sediment
%              'fg' : Francois&Garrison(1982)
%              'fgs': Francois&Garrison(1982) & Richards(1998) sediment
%             'rdi' : RDI simple estimate (f only, 4degC, 35ppt)
%

%% Process inputs
error(nargchk(1,1,nargin,'struct'));
error(nargoutchk(0,3,nargout,'struct'));
%defaults
T=10;
S=35;
z=10;
C=25;
a=20; %d/2
zet=1;
Method='am';
ised=false;
%process input arguments
%get required field .f (system frequency)
if isfield(args,'f')
   f=args.f;
else
   error('Frequency (.f) is a required field in input struct.')
end
%get method name if specified
if isfield(args,'method_sa')
   switch lower(args.method_sa)
      case {'am','fg','rdi'}
         Method=lower(args.method_sa);
      case {'ams','fgs'}
         Method=lower(args.method_sa);
         ised=true;
      otherwise
         error('Method ''%s'' is not currently supported.',varargin{end});
   end
end
%process other fields in input argument
fld=fieldnames(args);
for k=1:length(fld)
   switch lower(fld{k})
      case 't'
         T=args.(fld{k});
      case 's'
         S=args.(fld{k});
      case 'z'
         z=args.(fld{k});
      case 'c'
         C=args.(fld{k});
      case 'd'
         a=args.(fld{k})/2;
      case 'zet'
         zet=max(args.(fld{k}),1); %limit lower bound of zet to 1
   end
end
%% reshape for vectorized input
sz={size(f);size(T);size(S);size(z);size(C);size(a);size(zet)};
ne=[numel(f);numel(T);numel(S);numel(z);numel(C);numel(a);numel(zet)];
nemx=max(ne);
Imx=find(ne==nemx,1,'first'); %whos the largest
if ~isequal(sz{:}) %inputs don't have equal sizes
   for k=1:length(ne)
      if ne(k)==nemx && isequal(sz{k},sz{Imx}), %make column vector
         switch k
            case 1
               f=f(:);
            case 2
               T=T(:);
            case 3
               S=S(:);
            case 4
               z=z(:);
            case 5
               C=C(:);
            case 6
               a=a(:);
            case 7
               zet=zet(:);
         end
      elseif ne(k)==1 %input is scalar
         switch k
            case 1
               f=repmat(f,nemx,1);
            case 2
               T=repmat(T,nemx,1);
            case 3
               S=repmat(S,nemx,1);
            case 4
               z=repmat(z,nemx,1);
            case 5
               C=repmat(C,nemx,1);
            case 6
               a=repmat(a,nemx,1);
            case 7
               zet=repmat(zet,nemx,1);
         end
      else
         error('inputs must be same size or scalar.');
      end %check if max size or scalar
   end %loop through input variables
end %if unequal sizes
   
%% Call subfunction to estimate seawater absorption
switch Method
   case {'am','ams'}
      alfw=ainslie_mccolm(f,T,S,z);
   case {'fg','fgs'}
      alfw=francois_garrison(f,T,S,z);
   case 'rdi'
      alfw=rdi(f);
end
if ised %compute sediment attenuation
   alfs=richards(f,T,S,z,C,a,zet);
else
   alfs=zeros(size(alfw));
end
%% reshape output
alfw=reshape(alfw,sz{Imx});
alfs=reshape(alfs,sz{Imx});
alf=alfw+alfs;

%%%%%%%%%%%%%%%%%%%%%%
%%%% Subfunctions %%%%
function alf=ainslie_mccolm(f,T,S,z)
%from Ainslie & McColm (1998) J. Acoustical Society of America
ph=repmat(8,size(f));
z=z*1e-3; %convert depth from m to km
f1=0.78*sqrt(S/35).*exp(T/26); %boron
f2=42*exp(T/17); %magnesium
alf=0.106*f1.*f.^2./(f.^2+f1.^2) .* exp(ph-8)./0.56 ...
   +0.52*(1+T/43).*(S./35).*(f2.*f.^2)./(f.^2+f2.^2).*exp(-z./6)...
   +4.9e-4*f.^2.*exp(-(T./27+z./17));
alf=alf*1e-3; %convert from dB/km to dB/m

function alf=francois_garrison(f,T,S,z)
%from Francois & Garrison (1982a,b) J. Acoustical Society of America
ph=repmat(8,size(f));
%%Francois&Garrison method
c=1412+3.21*T+1.19*S+0.0167*z; %speed of sound in water (m/s)
theta=273+T; %temperature in Kelvin
%Boric Acid Contribution
A1=8.86./c.*10.^(0.78*ph-5);
P1=1;
f1=2.8*sqrt(S/35).*10.^(4-1245./theta);
%Magnesium Sulfate (MgS04) Contribution
A2=21.44*S./c.*(1+0.025*T);
P2=1-1.37e-4*z+6.2e-9*z.^2;
f2=8.17*10.^(8-1990./theta)./(1+0.0018*(S-35));
%Pure Water Contribution
in=T<=20;
A3(in,1)=4.937e-4 - 2.59e-5*T(in) +9.11e-7*T(in).^2 - 1.5e-8*T(in).^3;
in=T>20;
A3(in,1)=3.964e-4 - 1.146e-5*T(in) +1.45e-7*T(in).^2 - 6.5e-10*T(in).^3;
P3=1 -3.83e-5*z +4.9e-10*z.^2;
%Attenuation equation
alf=A1.*P1.*f1.*f.^2./(f.^2+f1.^2) + A2.*P2.*f2.*f.^2./(f.^2+f2.^2)...
   + A3.*P3.*f.^2;
alf=alf*1e-3; %convert from dB/km to dB/m

function alf=rdi(f)
%from RDI ADCP backscatter paper (Deines)
%only good for 4C seawater (35ppt)
fbase=[75,150,300,600,1200];
abase=[27,44,69,153,480]*1e-3;
alf=interp1(fbase,abase,f);

function alf=richards(f,T,S,z,C,a,zet)
%from Richards(1998) JASA paper
%
%% Parameters
f=f*1e3; %convert frequency from kHz to Hz
a=a*1e-6; %convert particle radius from um to m
rho=denfun(T,S); %water density (kg/m3)
kvis=kvisfun(T); %water kinematic viscosity (m2/s2)
c=sndspd(S,T,z); %sound speed (m/s)
rhos=2650*ones(size(rho)); %sediment density (kg/m3)
s=rhos./rho; %SG of sediment
kap=4.6e-10*ones(size(rho));  %bulk compressibility of water 
kaps=3.3e-10*ones(size(rho)); %bulk compressibility of sediment
phi=1e-3*C./rhos; %volumetric sediment concentration
omg=2*pi.*f; %wave angular frequency (rad/s)
k=omg./c; %wave number (rad/m)
beta=sqrt(0.5*omg./kvis); %reciprocal of skin depth for visc. shear waves
%% Attenuation by viscous absorption
delta=0.5*(1+9./(2*beta.*a));
tau=9./(4*beta.*a) .* (1+1./(beta.*a));
alfv=10*log10(exp(1)^2) * 0.5*phi.*k.*(s-1).^2 ...
   .* tau./(tau.^2+(s+delta).^2);
%% Attenuation by viscous absorption
x=k.*a;
gamk=(kaps-kap)./kap;
gamr=3*(rhos-rho)./(2*rhos+rho);
Ka=1/6*(gamk.^2+gamr.^2/3);
alfs=10*log10(exp(1)^2) * phi.*Ka.*x.^4./(a.*(1+zet.*x.^2+4/3*Ka.*x.^4));

%% Total sediment attenuation
alf=alfv+alfs;
