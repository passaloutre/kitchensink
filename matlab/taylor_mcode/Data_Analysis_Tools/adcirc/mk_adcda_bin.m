function mk_adcda_bin(basename,t0,varargin)
% MK_ADCDA_BIN Function to create ADCIRC direct access binary file
%          from binary fort.63 and fort.64 files
% SYNTAX:  mk_adcda_bin(basename,t0)
%          mk_adcda_bin(basename,t0,machformat)
%          mk_adcda_bin(basename,t0,machformat,nbyte)
%    basename = string argument containing filename (without
%               extension for *.63 and *.64 file).  Note basename
%               must be the same for both files.
%         t0  = time of simulation start 
%               format of start time(either Matlab datenum format or string)
%               e.g. datenum(2007,6,18,16,5,0) or '6/18/2007 16:05'
% machformat  = binary endianness. 
%               'ieee-le' = little endian
%               'ieee-be' = big endian (default)
%      nbyte  = bytelength (bytes) default = 4, double prec=8
%
%  MK_ADCDA_BIN creates a file in the local directory containing
%           water surface, u, v in a single file, compressing
%           filesize and speeding access of ADCIRC data.
%
% See also: LOAD_ADCDA, MK_STWDA, LOAD_STWDA
%
% Note: change made 27 July 2004 to write adc.time as
% float64 to accomodate Matlab datenum format.

%% Parameters
machformat='ieee-be';  %default bit ordering
nbyte=4; %default bytelength
tconv=1/3600/24;  %convert seconds to days
ieof=false;
valid.machformat={'ieee-le','ieee-be'};
valid.nbyte=[4,8];
%% Input checking
nargchk(2,4,nargin);
if ischar(t0),
   try
      t0=datenum(t0);
   catch ME
      fprintf(1,'The date string entered cannot be converted.\n')
      fprintf(1,'Try mm/dd/yyyy HH:MM:SS.\n\n')
      rethrow(ME)
   end
end
%check date and issue warning if necessary
if abs(now-t0)>100*365.25
   warning('Date entered is more than 100 years from today. Is this correct?')
end
% process optional input args
% machformat
if nargin>2
   machformat=varargin{1};
end
if ~any(strcmp(machformat,{'ieee-le','ieee-be'}))
   error('Machine format: %s not supported.  Valid options are: ''%s'' ''%s''.',...
      machformat,valid.machformat{:})
end
% machformat
if nargin>3,
   nbyte=varargin{2};
   if ischar(nbyte),nbyte=str2num(nbyte);end  %for compiled command-line compatibility
end
if ~any(valid.nbyte==nbyte)
   error('Byte length %g not supported.  Valid options are: 4,8.',...
      nbyte)
end
% set read formats
switch nbyte
   case 4
      itype='int32';
      ftype='*float32';
      ftype2='float32=>float64';
   case 8
      itype='int64';
      ftype='float64';
      ftype2='float64';
end
% do files exist?
fn63=[basename,'.63'];
fn64=[basename,'.64'];
if ~exist(fn63,'file')
   error('%s does not exist.  Check input.',fn63)
end
if ~exist(fn64,'file')
   error('%s does not exist.  Check input.',fn64)
end
%% open ADCIRC binary files
f63=fopen(fn63,'rb',machformat);
f64=fopen(fn64,'rb',machformat);
fseek(f63,0,'eof');
fseek(f64,0,'eof');
p63=ftell(f63); %eof position
p64=ftell(f64); %eof position
%% read header information
% elevation file
fseek(f63,80,'bof'); %skip text header
nt=fread(f63,1,itype);
np=fread(f63,1,itype);
dt=fread(f63,1,ftype);
fseek(f63,2*nbyte,'cof'); %skip 2 records
%velocity file
fseek(f64,80,'bof'); %skip text header
nt2=fread(f64,1,itype);
np2=fread(f64,1,itype);
dt2=fread(f64,1,ftype);
fseek(f64,2*nbyte,'cof'); %skip 2 records
%check for consistency
if ~all([nt==nt2,np==np2,dt==dt2])
    error('Mismatched elevation and velocity files.')
end
% byte offsets
nbyte63=np*nbyte;
nbyte64=np*2*nbyte;
%create da file and file header
fid=fopen([basename,'.da'],'wb','n');
fwrite(fid,[nt,np],'int32');
fwrite(fid,dt,'float32');

%% step through each file and get one timestep at a time
%read the water-surface info
fprintf(1,'Total Timesteps: %g\nLoading Timestep: %s',nt,'     ');
for k = 1:nt,
    fprintf(1,'\b\b\b\b\b%5.0f',k);
    %read 63
    t=fread(f63,1,ftype2,1*nbyte);
    %check for impending eof (63)
    pos=ftell(f63);
    if pos+nbyte63>p63
       nt=k-1;
       ieof=true;
       fprintf(1,'\n');
       warning('Impending EOF in 63. Ending .da creation...');
       break
    end
    eta=fread(f63,np,ftype);
    %read 64
    t2=fread(f64,1,ftype2,1*nbyte);
    %check for impending eof (64)
    pos=ftell(f64);
    if pos+nbyte64>p64
       nt=k-1;
       ieof=true;
       fprintf(1,'\n');
       warning('Impending EOF in 64. Ending .da creation...');
       break
    end
    u=fread(f64,np,ftype,nbyte);
    fseek(f64,pos+nbyte,'bof');
    v=fread(f64,np,ftype,nbyte);
    fseek(f64,-nbyte,'cof');
    % check for mismatched times in f63/f64
    if t~=t2
       nt=k-1;
       ieof=true;
       warning('Mismatched time in .63 and .64 files. Ending .da creation...');
       break
    end
    %dump data to da file
    fwrite(fid,t*tconv+t0,'float64'); %time
    fwrite(fid,eta,'float32'); %all etas
    fwrite(fid,u,'float32'); %all u
    fwrite(fid,v,'float32'); %all v
end %for k
fprintf(1,'\n')
fclose(f63);
fclose(f64);
%replace nt with correct value if file ends before expected
if ieof,
   frewind(fid);
   fwrite(fid,nt,'int32');
end
fclose(fid);
