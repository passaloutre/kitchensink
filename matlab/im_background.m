function m=im_background(IMG,method,nrand)
%IM_BACKGROUND function to remove background intensity
%SYNTAX: m=im_background(I,method)
%        m=im_background(I,method,nrand)
%where,
%     I = either Image data loaded from MAT file, 
%         mmreader object for AVI files, or Norpix SEQ filename
% method = 'min','mean','mode'
%  nrand = number of randomly selected frames to evaluate {default = 50}
%
%NOTE: This file contains potentially patentable material.  The author
%requests that you do not distribute without prior consent.

% Jarrell Smith
% US Army Engineer Research and Development Center
% Coastal and Hydraulics Laboratory
% Vicksburg, MS 39180
% Jarrell.Smith@usace.army.mil

%% Check input
error(nargchk(2,3,nargin))
%if nrand not given, set default
if nargin==2
   nrand=50;
end
%determine type of input and get image properties
switch class(IMG)
   case 'mmreader'
      obj=IMG;
      Itype='mmreader';
      N=obj.NumberOfFrames;
      ni=obj.Height;
      nj=obj.Width;
   case 'uint8'
      Itype='mat';
      N=size(IMG,4);
      ni=size(IMG,1);
      nj=size(IMG,2);
    case 'char' %SEQ file name
      Itype='seq';
      hdr=load_SEQ(IMG);
      N=hdr.AllocatedFrames;
      ni=hdr.ImageHeight;
      nj=hdr.ImageWidth;
   otherwise
      error('im_background:Image_Class','Image class %s not supported.',class(IMG))
end

%% Get background intensity
%randomly select nrand frames for background
% I=round(N*rand(nrand,1)+0.5); %old code
I=randperm(N,nrand);
%remove duplicates and first frame.
%(sometimes there are problems with 1st frame)
Iu=unique(I(I>1));
nI=length(Iu);
m=zeros(ni,nj,'uint8'); %prealloc
switch Itype
   case {'mmreader','seq'}
      F=repmat(m,[1,1,nI]);
      fprintf(1,'Loading %g frames\n',nI);
      fprintf(1,'Frame: %03.0f',0);
      for k=1:nI
         fprintf(1,'\b\b\b%03.0f',k);
         switch Itype
             case 'mmreader'
                 f=read(obj,Iu(k));
             case 'seq'
                 [~,f]=load_SEQ(IMG,Iu(k));
         end
         F(:,:,k)=f(:,:,1);
      end
      fprintf(1,'\n');
      switch method
         case 'min'
            m=min(F,3);
         case 'mean'
            m=mean(F,3);
         case 'mode'
            %process one row at a time (memory considerations)
            parfor k1=1:ni
               dat=single(squeeze(F(k1,:,:)));
               m(k1,:)=uint8(mode(dat,2));
            end
      end
   case 'mat'
      switch method
         case 'min'
            m=min(IMG(:,:,1,Iu),4);
         case 'mean'
            m=min(IMG(:,:,1,Iu),4);
         case 'mode'
            %process one row at a time (memory considerations)
            for k1=1:ni
               dat=single(squeeze(IMG(k1,:,1,Iu)));
               m(k1,:)=uint8(mode(dat,2));
            end
      end      
end

