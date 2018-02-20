function video_seq(obj,m,fnavi,opts)
%VIDEO_PIV function to create video of PIV results
%SYNTAX:  video_piv(obj,m,piv,fn_avi)
%         video_piv(obj,m,piv,fn_avi,opts)
%where
% obj = mmreader object referencing video sequence analyzed by PIV
%   m = background illumination (uint8, size video frame)
%       see im_background.m
% fn_avi = filename for video output
% opts = optional input arguments.  Struct with fields:
%      .fps = frames per second for output video {default: 8}
%
%NOTE: This file contains potentially patentable material.  The author
%requests that you do not distribute without prior consent.

% Jarrell Smith
% US Army Engineer Research and Development Center
% Coastal and Hydraulics Laboratory
% Vicksburg, MS 39180
% Jarrell.Smith@usace.army.mil

%% Parameters
pos=[0,0,952,680]; %figure position
default.fps=8; %default value for output fps
default.quality=90; %default value for AVI quality
%% Input checking
narginchk(3,4)
%process optional arguments 
if nargin==4
   if isfield(opts,'fps')
      fps=opts.fps;
   else
      fps=default.fps;
   end
   
   if isfield(opts,'quality')
       quality=opts.quality;
   else
       quality=default.quality;
   end
else
   fps=default.fps;
   quality=default.quality;
end

%determine filetype
switch class(obj)
    case {'mmreader','VideoReader'}
        filetype=class(obj);
    case 'char'
        filetype='seq';
end
%% Plot results
switch filetype
    case 'mmreader'
        nF=obj.NumberOfFrames;
    case 'VideoReader'
        nF=obj.FrameRate*obj.Duration;
    case 'seq'
        hdr=load_SEQ(obj);
        nF=hdr.AllocatedFrames;
end
%create VideoWriter Object
% aviobj=avifile(fnavi,'fps',fps);
% vobj=VideoWriter(fnavi,'Motion JPEG AVI');
vobj=VideoWriter(fnavi,'Motion JPEG AVI');
vobj.FrameRate=fps;
% vobj.Quality=quality;
open(vobj);

for k=1:nF;
   %Load and prep images
   %load and subtract background intensity
    switch filetype
        case {'mmreader','VideoReader'}
            F=read(obj,k+1);
            f2=imsubtract(squeeze(F(:,:,1)),m);
        case 'seq'
            [~,F]=load_SEQ(obj,k);
            f2=imsubtract(F,m);
    end

   writeVideo(vobj,f2)
end %for k
close(vobj)

