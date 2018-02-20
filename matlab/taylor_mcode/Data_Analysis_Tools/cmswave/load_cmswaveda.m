function stw=load_cmswaveda(file,it)
%LOAD_CMSWAVEDA. function to load CMS-WAVE direct access (binary) file.
%  DA files are produced by the function MK_CMSWAVEDA
%
%USAGE: adc=load_cmswaveda(file,itime)
%  stw = structure array containing fields
%        .time (time Matlab datenum format or integer index)
%        .h    (wave height [m])
%        .t    (wave period [sec])
%        .dir  (wave direction [deg, local-polar to model orientation])
% file = filename (with path if not in current directory)
% itime= index of timestamps saved
%        note number of nodes, timestamps, or DT is returned if 
%        itime is specified as 0.
%
%see also: MK_STWDA, MK_ADCDA, LOAD_ADCDA

%open the file
fid=fopen(file,'rb','n');
%read header information
xo=fread(fid,1,'float32');
yo=fread(fid,1,'float32');
xaz=fread(fid,1,'float32');
nx=fread(fid,1,'int32');
ny=fread(fid,1,'int32');
nt=fread(fid,1,'int32');
dx=fread(fid,1,'float32');
rads=fread(fid,1,'uint8');

%check consistency
if it>nt || it<1,
    fprintf(1,'NT= %4.0f, NX= %6.0f, NY= %5.0f\n',[nt,nx,ny]);
    warning('Load_CMSWAVEDA:BadIndex','Requested timestep out of range.')
    stw.nt=nt;
    stw.xo=xo;
    stw.yo=yo;
    stw.xaz=xaz;
    stw.nx=nx;
    stw.ny=ny;
    stw.dx=dx;
    return
end

%position file
% hdr bytes + (preceeding timestamps)* 4 bytes/rec * (np*3+2) recs
offset=4*7+1 + (it-1)*(8+4*(nx*ny*(3+rads*2)));
fseek(fid,offset,-1);

%read data and set fields in structure array
stw.nt=nt;
stw.xo=xo;
stw.yo=yo;
stw.xaz=xaz;
stw.nx=nx;
stw.ny=ny;
stw.dx=dx;
stw.time=fread(fid,1,'float64');
stw.h=fread(fid,[nx,ny],'float32');
stw.t=fread(fid,[nx,ny],'float32');
stw.dir=fread(fid,[nx,ny],'float32');
if rads
   stw.radsx=fread(fid,[nx,ny],'float32');
   stw.radsy=fread(fid,[nx,ny],'float32');
end

fclose(fid);
