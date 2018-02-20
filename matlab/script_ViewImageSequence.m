%% Load & Display an AVI or SEQ file
fig=102;
% Select file
if exist('prevDir','var')
    [fnseq,pnseq]=uigetfile({'*.avi;*.seq';'*.avi';'*.seq';'*.*'},'File Selector',prevDir);
else
    [fnseq,pnseq]=uigetfile({'*.avi;*.seq';'*.avi';'*.seq';'*.*'},'File Selector');
end
if isnumeric(fnseq),return,end % user canceled operation
prevDir=pnseq;
fnseq=fullfile(pnseq,fnseq);
[~,~,ext]=fileparts(fnseq);

% Prepare file for Reading & Load first frame
imageType='mono';
switch lower(ext)
    case '.avi'
        vobj=VideoReader(fnseq);
        F=read(vobj,1);
        if all(isequal(F(:,:,1),F(:,:,2),F(:,:,3)))
            f=squeeze(F(:,:,1));
        else
            f=F;
            imageType='color';
        end
    case '.seq' %only B/W SEQ files supported here.
        vobj=fnseq;
        [hdr,f]=load_SEQ(fnseq,1);
end
% Prompt user for Background Correction
ans=questdlg('Do you want to remove background intensity?');
switch lower(ans)
    case 'yes'
        ibackground=true;
        switch imageType
            case 'mono'
                m=im_background(vobj,'mode',25);
            case 'color'
                ibackground=false; %im_background doesn't support color images
                m=zeros(size(f),'uint8');
        end
    case 'no'
        ibackground=false;
        m=zeros(size(f),'uint8');
    otherwise
        return
end

%Check for existence of suitable figure & image handle
if exist('hshw','var') && ishandle(hshw)
    set(hshw,'CData',imsubtract(f,m));
else
    figure(fig);
    hshw=imshow(imsubtract(f,m),...
        'Border','tight',...
        'Parent',gca);
end
%% Display Frames from file
k=65;
switch lower(ext)
    case '.avi'
        F=read(vobj,k);
        switch imageType
            case 'mono'
                f=squeeze(F(:,:,1));
            case 'color'
                f=F;
        end
    case '.seq' %only B/W SEQ files supported here.
        [~,f]=load_SEQ(fnseq,k);
end
set(hshw,'CData',imsubtract(f,m));

%% Save current image to File
%Construct default ImageFile Name
fnout=regexprep(fnseq,{'.seq','.avi'},sprintf('_%g.png',k));
clm=get(gca,'CLim');
[fnout,pnout]=uiputfile('*.png','Specify Output File',fnout);
if isnumeric(fnout),return,end
imwrite(imadjust(imsubtract(f,m),clm/255,[0,1]),...
    fullfile(pnout,fnout));

%% Create AVI animation
klm=1+[0,240];
fnout=regexprep(fnseq,{'.avi','.seq'},sprintf('_%03.0f-%03.0f.avi',klm));
clm=get(gca,'CLim');
[fnout,pnout]=uiputfile('*.avi','Specify Output File',fnout);
if isnumeric(fnout),return,end
%Setup AVI file
vid=VideoWriter(fullfile(pnout,fnout),'Motion JPEG AVI');
switch lower(ext)
    case '.avi'
        vid.FrameRate=vobj.FrameRate;
    case '.seq'
        vid.FrameRate=hdr.FrameRate;
end
vid.Quality=75;  %affects video quality and filesize
open(vid);
%Read frames, write to AVI
for k=klm(1):klm(2);
    switch lower(ext)
        case '.avi'
            F=read(vobj,k);
            switch imageType
                case 'mono'
                    f=squeeze(F(:,:,1));
                case 'color'
                    f=F;
            end
        case '.seq' %only B/W SEQ files supported here.
            [~,f]=load_SEQ(fnseq,k);
    end
    writeVideo(vid,imadjust(imsubtract(f,m),clm/255,[0,1]));
end
%Cleanup
close(vid);
%% OTHER FUNCTIONS....
%To change Image contrast:  imcontrast
%To view pixel information: impixelregion
%To zoom/pan use toolbar from figure window
