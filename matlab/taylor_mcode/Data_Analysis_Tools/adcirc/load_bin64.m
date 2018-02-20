function adc=load_bin64(file,it,ftype,recl)
%LOAD_BIN64 function to read ADCIRC fort.63 binary.
%
%USAGE:  adc=load_bin64(file,it,ftype,recl)
%  where,
%       adc = structure array with the following fields:
%             .nt = number of fields written
%             .np = number of nodes
%             .dt = interval of output in timestamp
%             .u  = u component of velocity
%             .v  = v component of velocity
%      file = string filename (including path if necessary)
%        it = timestamp number to retrieve
%     ftype = the format of the file
%             'b' = big endian    (Unix, Linux, Alpha)
%             'L' = little endian (Windows)
%             'c' = cray
%      recl = record length in 4 byte words
%             4 = 4 byte (32bit) output
%             8 = 8 byte (64bit) output
%

% Jarrell Smith
% 28 Mar 2004

switch recl
    case 4,
        ilen='int32';
        flen='float32';
        vlen=4;
    case 8,
        ilen='int64';
        flen='float64';
        vlen=8;
    otherwise,
        error('Unsupported value of RECL, type help load_bin64');
end

switch lower(ftype),
    case 'b'
        ft='rb';
    case 'l'
        ft='rl';
    case 'c',
        ft='rc';
    otherwise,
        error('Unsupported value of FTYPE, type help load_bin64 for options');
end
fid64=fopen(file,ft);   

%skip text headers
fseek(fid64,1*(32+2*24),'bof');

%read settings
nt=fread(fid64,1,ilen);
fseek(fid64,0*vlen,'cof');
np=fread(fid64,1,ilen);
fseek(fid64,0*vlen,'cof');
dt=fread(fid64,1,flen);
fseek(fid64,0*vlen,'cof');
nspoolge=fread(fid64,1,ilen);
fseek(fid64,0*vlen,'cof');
kflag=fread(fid64,1,ilen);
fseek(fid64,0*vlen,'cof');

%check consistency
if it>nt | it<1,
    adc.nt=nt;
    adc.np=np;
    adc.dt=dt;
    return
end

%position file
% 1 values * vlen bytes/value * (it-1) fields to skip * 
%(np pts * 2 values/pt + 2 time values at beginning of each record
offset=1*vlen*(it-1)*(np*2+2);
fseek(fid64,offset,0);

%read data
adc.time=fread(fid64,1,flen);
fseek(fid64,0*vlen+1*vlen,0);  %skip empty records and iteration number.

fseek(fid64,0*8,'cof');
uv=fread(fid64,np*2,flen);
adc.u=uv(1:2:np*2);
adc.v=uv(2:2:np*2);
adc.dt=dt;
adc.nt=nt;
adc.np=np;

%close file
fclose(fid64);
