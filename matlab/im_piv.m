function piv=im_piv(obj,m,dv,rmode)
%IM_PIV performs PIV analysis on PICS data.  
%  Although the methods should work in general case, algorithm is intended
%  for analysis of particle settling image sequences.
%
%SYNTAX: piv=im_piv(obj,m,dv,rmode)
% where,
%     piv = struct containing raw PIV results.  Fields:
%         .x,.y   = centroid positions of subgrid (pixel space)
%         .di,.dj = inter-frame displacement vectors at subgrid positions 
%                   (units: pix/frame)
%                   (interframe displacements between frame k,k+1 stored at
%                   index k+1.)
%     obj = mmreader object
%       m = background illumination (uint8)
%      dv = image subdivision factor (number of subdivisions)
%   rmode = small particle replacement mode {'bw','bwrep','gsrep'}
%
%
%NOTE: This file contains potentially patentable material.  The author
%requests that you do not distribute without prior consent.

% Jarrell Smith
% US Army Engineer Research and Development Center
% Coastal and Hydraulics Laboratory
% Vicksburg, MS 39180
% Jarrell.Smith@usace.army.mil

%% Parameters
%psdvb: bwt=3; maxESD=6;
bwt=10/255; %grayscale threshold-Original
%bwt=2/255; %Currituck, NC
maxESD=2; %largest diameter permitted in small part. set
% rmode='grep';  %Options: 'bw','bwrep','gsrep'
%% Input Checking
%assign subdivision levels in [i,j]
if length(dv)==1
   dv1=dv;
   dv2=dv;
elseif length(dv)==2
   dv1=dv(1);
   dv2=dv(2);
else
   error('Max length of image subdivision is 2.')
end
%determine sequence file type
switch class(obj)
    case 'mmreader'
        filetype='mmreader';
    case 'char'
        filetype='seq';
end
%% Subdivide Image for PIV analysis
switch filetype
    case 'mmreader'
        ni=obj.Height; %number of i pix
        nj=obj.Width; %number of j pix
        nF=obj.NumberOfFrames; %number of frames in image
    case 'seq'
        hdr=load_SEQ(obj);
        ni=hdr.ImageHeight; %number of i pix
        nj=hdr.ImageWidth; %number of j pix
        nF=hdr.AllocatedFrames; %number of frames in image
end
sdi=ni/dv1; %increment of i pix in subdivisions
sdj=nj/dv2; %increment of j pix in subdivisions
%check that subdivisions result in even integer
if mod(sdi,2)>0 || mod(sdj,2)>0
   error('Image subdivision must result in even integer.')
end
ibnd=0:sdi:ni; %subdomain bounds in i
jbnd=0:sdj:nj; %subdomain bounds in j
[di,dj]=deal(nan(dv1,dv2,nF)); %storage for displacement vectors
N=zeros(dv1,dv2,nF); %storage for number of particles
x=midval(ibnd); %midpoint locations in pix space
y=midval(jbnd);

%% Perform PIV on each sub-domain
fprintf(1,'PIV Processing (%g frames)...\nFrame:    ',nF);
switch filetype
    case 'mmreader'
        F=read(obj,1);
        f2=imsubtract(squeeze(F(:,:,1)),m);
    case 'seq'
        [~,F]=load_SEQ(obj,1);
        f2=imsubtract(F,m);
end
switch rmode
   case 'bw'
      n2=bwsmall(f2,bwt,maxESD);
   case 'bwrep'
      n2=bwrep(f2,bwt,maxESD);
   case 'gsrep'
      n2=gsrep(f2,bwt,maxESD);
end
for K=1:nF-1 %loop in time for all I,J
  fprintf(1,'\b\b\b%3.0f',K);
  n1=n2;
  %   F=read(obj,K+1);
  %   f2=imsubtract(squeeze(F(:,:,1)),m);
  switch filetype
      case 'mmreader'
          F=read(obj,K+1);
          f2=imsubtract(squeeze(F(:,:,1)),m);
      case 'seq'
          [~,F]=load_SEQ(obj,K+1);
          f2=imsubtract(F,m);
  end
  switch rmode
     case 'bw'
        n2=bwsmall(f2,bwt,maxESD);
     case 'bwrep'
        n2=bwrep(f2,bwt,maxESD);
     case 'gsrep'
        n2=gsrep(f2,bwt,maxESD);
  end
  %check for blank frame
  if ~any(n1(:))
     di(:,:,K+1)=0; %displacement of max correlation ...
     dj(:,:,K+1)=0; %from kernel center
%      N(:,:,K+1)=0; %number of small objects in kern {not required b/c
%      initialization values}
     continue
  end
  for I=1:dv1 %Loop through columns
    %target is 2x size of kernel
    Ikern=ibnd(I)+1:ibnd(I+1); %i-pix for kernel column
    Itarg=max(1,ibnd(I)+1-sdi/2):min(ni,ibnd(I+1)+sdi/2);
    for J=1:dv2 %Loop through rows
      Jkern=jbnd(J)+1:jbnd(J+1); %j-pix for kernel row
      Jtarg=max(1,jbnd(J)+1-sdj/2):min(nj,jbnd(J+1)+sdj/2); %j-pix for target
      kern=n1(Ikern,Jkern); %kernel image
      ckern=floor((size(kern)+1)/2); %center pel of kern
      buffer=ckern-1; 
      targ=n2(Itarg,Jtarg); %target image
      %check kern for flatness
      if all(kern(:)) || ~any(kern(:))
         di(I,J,K+1)=nan; %displacement of max correlation ...
         dj(I,J,K+1)=nan; %from kernel center
         N(I,J,K+1)=0; %number of small objects in kern
      else
         cc=normxcorr2(kern,targ); %perform cross correlations
%          %get peaks in cc space
%          [mxcc,imx]=max(cc(:)); %position of max correlation
%          [Ipk,Jpk]=ind2sub(size(cc),imx(1)); %I,J of max corr (in corr space)
%          dij=[Ipk,Jpk]-buffer-([Ikern(1),Jkern(1)]-[Itarg(1),Jtarg(1)]+ckern);
%          %get peaks in targ space
%          cc2=cc(buffer(1)+(1:size(targ,1)),buffer(2)+(1:size(targ,2)));
%          [mxcc,imx]=max(cc2(:)); %position of max correlation
%          [Ipk,Jpk]=ind2sub(size(cc2),imx(1)); %I,J of max corr (in corr space)
%          dij=[Ipk,Jpk]-([Ikern(1),Jkern(1)]-[Itarg(1),Jtarg(1)]+ckern);
         %get peaks in kern space
         cc3=cc(buffer(1) + (Ikern(1)-Itarg(1)) + (1:size(kern,1)),...
            buffer(2) + (Jkern(1)-Jtarg(1)) + (1:size(kern,2)));
         [~,imx]=max(cc3(:)); %position of max correlation
         [Ipk,Jpk]=ind2sub(size(cc3),imx(1)); %I,J of max corr (in corr space)
         dij=[Ipk,Jpk]-(ckern)-[1,1]; %
         %store results
         di(I,J,K+1)=dij(1); %displacement of max correlation ...
         dj(I,J,K+1)=dij(2); %from kernel center
         %determine number of small objects
         ConnMap=bwconncomp(kern);
         N(I,J,K+1)=ConnMap.NumObjects; %Number of small objects in kern
      end
    end %J
  end %I (
end %K (time)
fprintf(1,'\n');

%% Store in output stuct
piv.ni=ni;  %image size in I
piv.nj=nj;  %image size in J
piv.maxESD=maxESD; %maximum permissible particle size (pix)
piv.bwt=bwt; %grayscale threshold level (normalized)
piv.x=x; %center positions of PIV interrogation region
piv.y=y; %center positions of PIV interrogation region
[piv.Y,piv.X]=meshgrid(y,x); %grid of central positions
piv.N=N;  %Number of small particles in gridded image kernel
piv.u=di; %PIV displacement vectors [pix/frame]
piv.v=dj;

%% SUBFUNCTIONS %%

function mv=midval(bnds)
mv=(bnds(1:end-1)+bnds(2:end))/2;

function bw=bwsmall(f,bwt,maxESD)
%subfunction to get bw image of small particles
bw=im2bw(f,bwt);
R=regionprops(bw,{'EquivDiameter','PixelIdxList'});
d=[R.EquivDiameter];
in=d>maxESD;
pid=cat(1,R(in).PixelIdxList);
bw(pid)=false;

function bw=bwrep(f,bwt,maxESD)
%subfunction to replace particle images with 3x3 bw image
%extract small particles
bw=im2bw(f,bwt);
R=regionprops(bw,{'EquivDiameter','Centroid'});
d=[R.EquivDiameter];
in=d>maxESD;
bw(:)=false;
%get centroid positions
c=round(cat(1,R(~in).Centroid));
%if not particles in frame, return
if isempty(c),return,end
%set 3x3 space centered on centroid to true
I=sub2ind(size(bw),c(:,2),c(:,1));
bw(I)=true;
bw=imdilate(bw,strel('square',3));

function fout=gsrep(f,bwt,maxESD)
%subfunction to replace particle images with 3x3 bw image
%extract small particles
bw=im2bw(f,bwt);
R=regionprops(bw,{'EquivDiameter','Centroid'});
d=[R.EquivDiameter];
in=d>maxESD;
bw(:)=false;
%get centroid positions
c=round(cat(1,R(~in).Centroid));
%set 3x3 space surrounding each centroid to filter pattern, h
h=100*[.1,.1,.1;.1,.5,.1;.1,.1,.1]; %filter pattern
I=sub2ind(size(bw),c(:,2),c(:,1));
bw(I)=true;
fout=imfilter(single(bw),h);



