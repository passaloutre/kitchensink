function adc=load_adcda(file,it)
%Note... this version is obsolete.  For reading da files with float32
%timestamps.  mk_adcda and load_adcda were modified 27 July 2004 to
%accomodate the placement of Matlab datenum dates into the field adc.time
%
%LOAD_ADCDA. function to load ADCIRC direct access (binary) file.
%  DA files are produced by the function MK_ADCDA
%USAGE: adc=load_adcda(file,itime)
%  adc = structure array containing fields
%        .time (time [sec] from start of simulation)
%        .u    (east component of velocity [m/s])
%        .v    (north component of velocity [m/s])
%        .eta  (water surface elevation [m])
% file = filename (with path if not in current directory)
% itime= index of timestamps saved
%        note if number of nodes, timestamps, or DT is returned if 
%        itime is specified as 0.
%
%see also: MK_ADCDA

%open the file
fid=fopen(file,'rb','n');
%read header information
nt=fread(fid,1,'integer*4');
np=fread(fid,1,'integer*4');
dt=fread(fid,1,'real*4');

%check consistency
if it>nt | it<1,
    fprintf(1,'NT= %4.0f, NP= %6.0f, DT= %5.0f\n',[nt,np,dt]);
    warning('Requested timestep out of range'),
    adc.nt=nt;
    adc.np=np;
    adc.dt=dt;
    return
end

%position file
% hdr bytes + 4*(preceeding timestamps)*(np*3+1) bytes
offset=4*3 + 4*(it-1)*(np*3+1);
fseek(fid,offset,-1);

%read data
adc.time=fread(fid,1,'real*4');
adc.eta=fread(fid,np,'real*4');
adc.u=fread(fid,np,'real*4');
adc.v=fread(fid,np,'real*4');
adc.dt=dt;
adc.nt=nt;
adc.np=np;

fclose(fid);