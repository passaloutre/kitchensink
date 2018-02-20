function PICS_imageProcessing(PathFile)
%% Parameters and defaults
fnpaths='Paths_PICS_imageProcessing.txt'; %default filename
%required cards for the PATHS file...
reqcards={'PNSEQ','PNRESULTS','PNQUEUE','PNLOG','PNSEQ2'}; 
iavi=false; %flag for creating AVI
iptv=false;  %flag for PTV analysis
ipiv=true; %flag for PIV analysis
ipiv2=false; %flag for loading previous PIV results from file
%% Process inputs
narginchk(0,1)
if nargin
    fnpaths=PathFile;
end
%% Read the PATHS file to set storage locations
fid0=fopen(fnpaths,'rt');
fgetl(fid0); %skip the header
while ~feof(fid0)
    str=fgetl(fid0);
    [card,tok]=strtok(str);
    s.(card)=strtrim(tok);
end
%check for required fields
flds=fieldnames(s);
if(~all(ismember(reqcards,flds)))
    fprintf(2,'A field is missing from the PATHS file.\n');
    fprintf(2,' REQFLDS are:/n');
    fprintf(2,'%s\n',reqcards{:});
    error('Missing File.')
end

%path checks
%check input paths
if ~exist(s.PNSEQ,'file')
    error('Path for SEQ files does not exist.\nPath specified: %s\n',...
        s.PNSEQ);
end
%check output paths
%SendQueue
if ~exist(s.PNQUEUE,'file')
    error('Path for SendQueue files does not exist.\nPath specified: %s\n',...
        s.PNQUEUE);
end
%the RESULTS and LOG dirs will be created as needed
pnseq=s.PNSEQ;
pnout=s.PNRESULTS;
%Results directory
if ~exist(pnout,'file')
    mkdir(pnout);
end
%Log directory
if ~exist(s.PNLOG,'file')
    mkdir(s.PNLOG);
end
%SEQarchive directory
if ~exist(s.PNSEQ2,'file')
    mkdir(s.PNSEQ2);
end

%% Run Analysis
files=dir(fullfile(pnseq,'*.seq'));
nf=length(files);
nstart=1;
% logging
fnlog=sprintf('runlog_%s.txt',datestr(now,'yyyymmdd_HHMMSS'));
fidlog=fopen(fullfile(s.PNLOG,fnlog),'wt');
%set opts
opts.fps=1; %prealloc

for k=nstart:nf
   fnseq=fullfile(pnseq,files(k).name);
   tic;
   try
       hdr=load_SEQ(fnseq);
       fps=hdr.FrameRate;
       opts.fps=fps;
       m=im_background(fnseq,'mode',50);
   catch
          fprintf(fidlog,'There was a problem reading \nFile: %s\n',files(k).name);
          m=0;
   end
   %create low-res video of SEQ file
   if iavi
   [~,fntmp]=fileparts(fnseq);
   video_seq(fnseq,m,fullfile(s.PNRESULTS,[fntmp,'.avi']),opts)
   end

   %PTV
   if iptv
   fprintf(fidlog,'File: %s\nStartPTV %s\n',files(k).name,datestr(now));
   fnout=fullfile(pnout,['ptv_',strrep(files(k).name,'.seq','.mat')]);
   try
       ptv=im_ptv(fnseq,fps);
       save(fnout,'ptv','-v7')
       if ~strcmpi(s.PNQUEUE,s.PNRESULTS)
           dos(sprintf('copy "%s" "%s"\n',fnout,s.PNQUEUE));
       end
   catch
       fprintf(fidlog,'There was an error in the PTV analysis.\n');
   end
   fprintf(fidlog,'EndPTV %s\n',datestr(now));
   end

   %PIV
   if ipiv
   fprintf(fidlog,'StartPIV %s\n',datestr(now));
   fnout=fullfile(pnout,['piv_',strrep(files(k).name,'.seq','.mat')]);
   if ipiv2
       load(fnout); %loads struct: piv
   else
       try
           piv=im_piv(fnseq,m,[8,10],'bwrep');
           save(fnout,'piv','-v7')
           if ~strcmpi(s.PNQUEUE,s.PNRESULTS)
               dos(sprintf('copy "%s" "%s"\n',fnout,s.PNQUEUE));
           end
       catch
           fprintf(fidlog,'There was an error in the PIV analysis.\n');
       end
   end
   fprintf(fidlog,'EndPIV %s\n',datestr(now));
   
   %create video of PIV results
   fprintf(fidlog,'StartVideoPIV %s\n',datestr(now));
   try
       video_piv(fnseq,m,piv,strrep(fnout,'.mat','.avi'),opts)
       if ~strcmpi(s.PNQUEUE,s.PNRESULTS)
           dos(sprintf('copy "%s" "%s"\n',strrep(fnout,'.mat','.avi'),s.PNQUEUE));
       end

   catch
       fprintf(fidlog,'There was an error with VideoPIV.\n');
   end
   fprintf(fidlog,'EndVideoPIV %s\n',datestr(now));
   et=toc;
   fprintf(fidlog,'FileTime: %g sec (%s)\n\n',et,...
       datestr(floor(now)+et/86400,'HH:MM:SS'));
   
   %move SEQ file to SEQarchive directory
   dos(sprintf('move "%s" "%s"\n',fnseq,s.PNSEQ2));
   end
end
fclose(fidlog);
