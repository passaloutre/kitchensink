function a2=im_piv_correct(a)
%IM_PIV_CORRECT evaluates PIV velocity field and performs corrections
%SYNTAX: a2=im_piv_correct(a)
%        a2=im_piv_correct(a)
%  a2 = corrected velocities
%   a = raw velocity fields (struct)
% method = inpaint_nans method {0,1,3,4 recommended} default=1

%TODO: Generalize with argument passing and nested functions
%
%NOTE: This file contains potentially patentable material.  The author
%requests that you do not distribute without prior consent.

% Jarrell Smith
% US Army Engineer Research and Development Center
% Coastal and Hydraulics Laboratory
% Vicksburg, MS 39180
% Jarrell.Smith@usace.army.mil

%% Parameters
%particle count
Nthresh=5; %min # small particles for PIV
%spatial domain
method_inpaint=1; %inpainting method
method_detect='nmt';
nhood=[3,3];
%time domain
filt.order=1;
filt.cutoff=0.25; %cutoff frequency (fraction of Nyquist Freq)
ethold=0.33; %error fraction of filtered velocity
ufloor=10;  %minimum velocity for normalizing
%% Check Input
error(nargchk(1,1,nargin))

%% Processing
a2=a;
sz=size(a.u); %size of problem
%correct earlier error in piv_analysis code
[a2.Y,a2.X]=meshgrid(a2.y,a2.x);

%% Spatial Domain detection and replacement
a2.in=false(size(a2.u)); %prealloc. For storing replacement indicator.
for k=1:sz(3) %time loop
   u=a2.u(:,:,k);
   v=a2.v(:,:,k);

   %Detect low particle counts
   if isfield(a2,'N')
     in0=a2.N(:,:,k)<Nthresh;
   else
     in0=false(size(u));
   end

   %Detect Outliers
   switch lower(method_detect)
      case 'nmt' %Normalized Median Test (vector)
         in1=im_nlfilter(u+v*1i,nhood,@im_piv_nmt);
   end
   
   %Combine spatial filters
   in=in0|in1;
   
   %Correction
   if any(in(:))
      u(in)=nan;
      v(in)=nan;
      a2.u(:,:,k)=inpaint_nans(u,method_inpaint);
      a2.v(:,:,k)=inpaint_nans(v,method_inpaint);
   end
   a2.in(:,:,k)=in;
end %spatial domain end

%% Time Domain detection and replacement
ncell=numel(a2.X);
sz=size(a2.u);
%Filter design
[fb,fa]=butter(filt.order,filt.cutoff,'low');
%Frame numbers
f=1:sz(3);
for k=1:ncell
   %Extract data in time-domain
   [I,J]=ind2sub(sz(1:2),k);
   u=squeeze(a2.u(I,J,:));
   v=squeeze(a2.v(I,J,:));
   %filter in time-domain
   uv=filtfilt(fb,fa,u+v*1i);
   uf=real(uv);
   vf=imag(uv);
   %flag bad velocities
   eu=abs(u-uf)./max(abs(uf),ufloor);
   ev=abs(v-vf)./max(abs(vf),ufloor);
   eflag=eu>ethold | ev>ethold;
   %replace bad velocities
   if any(eflag)
      Kflag=find(eflag(:));
      zz=ones(size(Kflag));
      Ir=sub2ind(sz,I*zz,J*zz,Kflag);
      if sum(~eflag)<2
         a2.u(Ir)=0;
         a2.v(Ir)=0;
      else
%       %replace bad velocities with filtered
%       a2.u(Ir)=uf(eflag);
%       a2.v(Ir)=vf(eflag);
      %replace bad velocities with interpolated
      a2.u(Ir)=interp1(f(~eflag),u(~eflag),f(eflag),'linear','extrap');
      a2.v(Ir)=interp1(f(~eflag),v(~eflag),f(eflag),'linear','extrap');
      %set replacement flag
      end
      a2.in(Ir)=true;
   end
end
end %function end


