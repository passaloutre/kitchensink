function ch3=load_ch3dda(file,k)
%LOAD_CH3DDA. function to load CH3D direct access (binary) file.
%  DA files are produced by the function MK_CH3DDA
%USAGE: ch3=load_adcda(file,itime)
%  ch3 = structure array containing fields
%        .time (time [sec] from start of simulation)
%        .u    (east component of velocity [m/s])
%        .v    (north component of velocity [m/s])
%        .eta  (water surface elevation [m])
% file = filename (with path if not in current directory)
% itime= index of timestamps saved
%
%see also: MK_CH3DDA, MK_ADCDA, LOAD_ADCDA, MK_STWDA, LOAD_STWDA

%Author Info:
%Jarrell Smith
%USACE ERDC
%Coastal and Hydraulics Laboratory
%8/30/2009

%open the file
fid=fopen(file,'rb','ieee-le');
%read header information
nt=fread(fid,1,'integer*4');
ni=fread(fid,1,'integer*4');
nj=fread(fid,1,'integer*4');
nc=ni*nj; %number of cells
tform=fread(fid,1,'integer*4');
ch3.nt=nt;
ch3.ni=ni;
ch3.nj=nj;
ch3.tform=tform;
if tform
    ch3.timeformat='datenum';
else
    ch3.timeformat='elapsed';
end

%check consistency
if k>nt || k<1,
    fprintf(1,'NT= %4.0f, NI= %6.0f, NJ= %5.0f\n',[nt,ni,nj]);
    warning('load_ch3dda:InvalidTimestep','Requested timestep out of range');
    return
end

%position file
% hdr bytes + (preceeding timestamps)* 4 bytes/rec * (np*3+2) recs
offset=4*4 + (k-1)*4*(nc*3+2);
status=fseek(fid,offset,-1);
%check for errors
if status<0,
   msg=ferror(fid);
   error(msg);
end

%read data
ch3.time=fread(fid,1,'float64');
ch3.eta=reshape(fread(fid,nc,'float32'),ni,nj);
ch3.u=reshape(fread(fid,nc,'float32'),ni,nj);
ch3.v=reshape(fread(fid,nc,'float32'),ni,nj);
%check again for errors during read
if numel(ch3.v)<nc
   error('Reached end of file during read')
end
%Reshape output
%TODO: unit conversions?
fclose(fid);
