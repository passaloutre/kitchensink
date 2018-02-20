function adc=load_adcda(file,it)
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
%see also: MK_ADCDA, LOAD_STWDA, MK_STWDA

%open the file
fid=fopen(file,'r','n');
%read header information
nt=fread(fid,1,'integer*4');
np=fread(fid,1,'integer*4');
dt=fread(fid,1,'real*4');

%check consistency
if it>nt || it<1,
    fprintf(1,'NT= %4.0f, NP= %6.0f, DT= %5.0f\n',[nt,np,dt]);
    warning('Requested timestep out of range'),
    adc.nt=nt;
    adc.np=np;
    adc.dt=dt;
    fclose(fid);
    return
end

%position file
% hdr bytes + (preceeding timestamps)* 4 bytes/rec * (np*3+2) recs
offset=4*3 + (it-1)*4*(np*3+2);
status=fseek(fid,offset,-1);
%check for errors
if status<0,
   msg=ferror(fid);
   error(msg);
end

%read data
adc.time=fread(fid,1,'float64');
adc.eta=fread(fid,np,'float32');
adc.u=fread(fid,np,'float32');
adc.v=fread(fid,np,'float32');
adc.dt=dt;
adc.nt=nt;
adc.np=np;
%check again for errors during read
if numel(adc.v)<np
   error('Reached end of file during read')
end

fclose(fid);
