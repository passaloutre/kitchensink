function mk_cmswaveda(varargin)
%MK_CMSWAVEDA function to create direct-access file with information from
%CMS-WAVE wavfield file.
%
% USAGE:  mk_cmswaveda(simfile);
%         mk_cmswaveda(simfile,...,'index');
%         mk_cmswaveda(simfile,...,'rstress');
%   simfile = optional path/file information if not given, the function
%      prompts the user for file information
%   'index' = indicates to write integer index instead of time
%   'rstress' = indicates to load radiation stress gradients
%
% see also: LOAD_CMSWAVEDA, LOAD_STWDA, MK_ADCDA, LOAD_ADCDA

%Check Input
error(nargchk(0,3,nargin))
%defaults
index=false;
rads=false;
%process input
switch nargin
   case 0
      [fname,pname]=uigetfile('*.sim','Select the CMSWAVE SIM file to convert');
      fsim=fullfile(pname,fname);
      index=false;
   case 1
      fsim=varargin{1};
      index=false;
      rads=false;
   case {2,3}
      fsim=varargin{1};
      for k=2:length(varargin);
         switch lower(varargin{k})
            case 'index'
               index=true;
            case 'rads'
               rads=true;
         end
      end
end

%Open Simfile and get Wavfile name
fids=fopen(fsim,'rt');
a=fscanf(fids,'%*s %f %f %f');
b=fgetl(fids);
xo=a(1);
yo=a(2);
xaz=a(3);
while ischar(b),
    CARD=sscanf(b,'%s',1);
    name=sscanf(b,'%*s %s',1);
    switch lower(CARD),
        case 'wave',
            pname=fileparts(fsim);
            fname=fullfile(pname,name);
       case 'rads'
          pname=fileparts(fsim);
          fnrads=fullfile(pname,name);
    end
    b=fgetl(fids);
end


%open files....
%ascii files
fidw=fopen(fname,'rt');
fnbin=regexprep(fname,'.wav','.da');
if rads
   fid_rads=fopen(fnrads,'rt');
end
%binary DA file
fid=fopen(fnbin,'wb','n');

% read header info from ascii wav file
a=fscanf(fidw,'%f %f %f',3);
nx=a(1);
ny=a(2);
dx=a(3);
tn=fscanf(fidw,'%f',1);
nt=99;
% read header info from ascii rads file
if rads
   a=fscanf(fid_rads,'%f %f %f',3);
   tn2=fscanf(fid_rads,'%f',1);
end

% write header info to binary wav file
fwrite(fid,[xo,yo,xaz],'float32'); %grid origin, rotation
fwrite(fid,[nx,ny,nt],'int32'); %grid size and nt
fwrite(fid,dx,'float32'); %grid spacing (mean?)
fwrite(fid,rads,'uint8'); %radiation stress flag

nt=0;
fprintf(1,'Processing Timestep: ')
nbyte=fprintf(1,'%s',' ');
while ~isempty(tn),
    nt=nt+1;
    if index
       wave.time=tn;
       fmt=[repmat('\b',1,nbyte),'%g %10.0f'];
       nbyte=fprintf(1,fmt,nt,wave.time)-nbyte;
    else %convert int string tn to datenum
       yy=floor(tn/1e6);
       if yy<=50,
          yy=2000+yy;
       elseif yy>50 && yy<100,
          yy=1900+yy;
       end
       mm=mod(floor(tn/1e4),100);
       dd=mod(floor(tn/1e2),100);
       HH=mod(tn,100);
       wave.time=datenum(yy,mm,dd,HH,0,0);
       fmt=[repmat('\b',1,nbyte),'%g %s'];
       nbyte=fprintf(1,fmt,nt,datestr(wave.time,0))-nbyte;
    end
    
    %read output from ascii file
    wave.height=fliplr(fscanf(fidw,'%f',[nx,ny]));
    wave.period=fliplr(fscanf(fidw,'%f',[nx,ny]));
    wave.dir=fliplr(fscanf(fidw,'%f',[nx,ny]));
    if rads
       dat=fscanf(fid_rads,'%f',[2*nx,ny]);
       wave.radsx=fliplr(dat(1:2:end,:));
       wave.radsy=fliplr(dat(2:2:end,:));
    end
    
    %write data from timestep to binary da file
    fwrite(fid,wave.time,'float64');
    fwrite(fid,wave.height,'float32');
    fwrite(fid,wave.period,'float32');
    fwrite(fid,wave.dir,'float32');
    %write rads
    if rads
       fwrite(fid,wave.radsx,'float32');
       fwrite(fid,wave.radsy,'float32');
    end
    %read next timestep
    tn=fscanf(fidw,'%f',1);
    if rads,tn2=fscanf(fid_rads,'%f',1);end
end
fprintf(1,'%s\n',' ');
fseek(fid,5*4,'bof');
fwrite(fid,nt,'int32');
fclose(fidw);
fclose(fid);
if rads
   fclose(fid_rads);
end

