function R=im_partrack(obj,time,post,m)
%IM_PARTRACK function to perform particle tracking from
%            Particle Imaging Camera System (PICS)
%SYNTAX:  R=im_partrack(obj,post,time,m)
% where,
%    R = cell array containing particle structs for each frame
%  obj = mmreader object or Norpix SEQ filename
% time = time [sec] associated with each frame
% post = struct containing post-processing parameters
%        .A transformation matrix for images
%           Y=X*A
%           where Y = Cartesian coords [mm], [Nx3]
%                 X = image coords [pixels], [Nx3]
%                 inverse transform: X=Y/A
%    m = mean image intensity (NI,NJ)
%
%NOTE: klim removed as an option.  Analyze all frames.
%NOTE: This file contains potentially patentable material.  The author
%requests that you do not distribute without prior consent.

%TODO: Add support for Matrix image.  Only AVI obj supported now.

% Jarrell Smith
% US Army Engineer Research and Development Center
% Coastal and Hydraulics Laboratory
% Vicksburg, MS 39180
% Jarrell.Smith@usace.army.mil

%% Parameters     % bwthold was 13 for york. 7 for currituck 2015 and set to 4 for currituck CS151015
%TODO: Make bwthold an input option
bwthold=40/255; %LowerMiss2016_SaltWedge
%bwthold=4/255;  %Curritcuk Sound
%TODO: Reevaluate im_autothreshold. Consider adding as option.

%% Image processing and PTV
args.A=post.A;
switch class(obj)
    case 'mmreader'
        NF=obj.NumberOfFrames;
        filetype='mmreader';
    case 'char'
        hdr=load_SEQ(obj);
        NF=hdr.AllocatedFrames;
        filetype='seq';
end
R=cell(NF,1); %create cell array to store all regprops
for k=1:NF-1;
    args.dt=diff(time(k:k+1));
    %first frame
    if k==1,
        switch filetype
            case 'mmreader'
                f=read(obj,k);
            case 'seq'
                [~,f]=load_SEQ(obj,k);
        end
        Ig1=imsubtract(squeeze(f(:,:,1)),m); %gs image (single frame)
%         bwthold=im_autothreshold(Ig1,0.25);
        I1=im_morph(Ig1,bwthold); %bw image (single frame)
        [R1,L1]=im_props(I1,post.A,k);
        for j1=1:length(R1),
            R1(j1).xVelocity=[NaN,NaN];
            R1(j1).xIDprev=NaN;
            R1(j1).xIDnext=NaN;
        end
    else
        R1=R2;
        L1=L2;
    end
    %%second frame
        switch filetype
            case 'mmreader'
                f=read(obj,k+1);
            case 'seq'
                [~,f]=load_SEQ(obj,k+1);
        end
    Ig2=imsubtract(squeeze(f(:,:,1)),m); %gs image (single frame)
    I2=im_morph(Ig2,bwthold); %bw image (single frame)
    [R2,L2]=im_props(I2,post.A,k+1);
    for j1=1:length(R2), %initialize fields for matching
        R2(j1).xVelocity=[NaN,NaN];
        R2(j1).xIDprev=NaN;
        R2(j1).xIDnext=NaN;
    end
    %%Find matching pixel in next frame and estimate velocity
    j2=zeros(length(R1),1);
    dt=diff(time(k:k+1));
    fprintf(1,'Matching Particles, Frame: %g...\n',k);
    fprintf(1,'Particle:    ')
    for j1=1:length(R1)
        if ~mod(j1,10) 
           fprintf(1,'\b\b\b%03.0f',j1);
        end
        j2(j1)=im_findobj(L1,L2,R1,R2,j1,args); %binary cross-correlation
        %%estimate velocities
        if j2(j1)>0 %match occurred store data in Rs
            x=[R1(j1).xCentroid;R2(j2(j1)).xCentroid];
            dx=diff(x);
            v=dx/dt;
            %[vth,vmag]=cart2pol(v(1),v(2));
            R2(j2(j1)).xVelocity=v;
            R2(j2(j1)).xIDprev=j1;
            R1(j1).xIDnext=j2(j1);
        else %no match
            R1(j1).xIDnext=NaN;
        end
    end %for j1=1:length(R1)
    fprintf(1,'\b\b\b%03.0f\n',j1)
    R{k}=R1;
end %for k=1:NF-1
R{k+1}=R2;
fprintf(1,'\n');



