function adc=load_adcda_pt(file,node)
%LOAD_ADCDA. function to load ADCIRC direct access (binary) file.
%  This function loads all data at a single node.
%  DA files are produced by the function MK_ADCDA
%USAGE: adc=load_adcda_pt(file,node)
%  adc = structure array containing fields
%        .time (time [sec] from start of simulation
%        .u    (east component of velocity [m/s])
%        .v    (north component of velocity [m/s])
%        .eta  (water surface elevation [m])
% file = filename (with path if not in current directory)
% node = node to extract data from
%        NOTE: If node = 0, only time returned, otherwise
%              all parameters returned from selected node
%
%see also: MK_ADCDA, LOAD_ADCDA, LOAD_STWDA, MK_STWDA
%% Parameters
flen=4;
flen2=8;
ftype='float32';
ftype2='float64';
itype='int32';
%% open the file
fid=fopen(file,'rb','n');
%read header information
nt=fread(fid,1,itype);
np=fread(fid,1,itype);
dt=fread(fid,1,ftype);
adc.nt=nt;
adc.np=np;
adc.dt=dt;
adc.node=node;

%check consistency
if node>np || node<0,
    fprintf(1,'NT= %4.0f, NP= %6.0f, DT= %5.0f\n',[nt,np,dt]);
    warning('Requested node out of range');
    fclose(fid);
    return
end

%position file
pos=ftell(fid);
skip1=flen*np*3; %for time read
skip2=flen2+flen*(np*3-1); %for eta,u,v read

%read data
%TODO: May be more efficient with a loop, grabbing t,eta,u,v for each
%timestep instead of cycling through file 4 times with skip strides as
%in Method2.  Findings so far are inconclusive.
%METHOD1
% skip00=3*flen;
% skip01=flen2+flen*(np*3); %for eta,u,v read
% skip02=flen*(np-1); %for individual fields
% if node>0
%    [adc.time,adc.eta,adc.u,adc.v]=deal(zeros(nt,1));
%    for k=1:nt,
%       fseek(fid,skip00+(k-1)*skip01,'bof');
%       adc.time(k)=fread(fid,1,ftype2);
%       fseek(fid,flen*(node-1),'cof');
%       dat=fread(fid,3,ftype,skip02);
%       adc.eta(k)=dat(1);
%       adc.u(k)=dat(2);
%       adc.v(k)=dat(3);
%    end
% else
%    adc.time=fread(fid,nt,ftype2,skip01-flen);
% end
   
%METHOD2   
adc.time=fread(fid,nt,ftype2,skip1);
if node>0
  fseek(fid,pos+flen2+(0*np+node-1)*flen,'bof');
  adc.eta=fread(fid,nt,ftype,skip2);
  fseek(fid,pos+flen2+(1*np+node-1)*flen,'bof');
  adc.u=fread(fid,nt,ftype,skip2);
  fseek(fid,pos+flen2+(2*np+node-1)*flen,'bof');
  adc.v=fread(fid,nt,ftype,skip2);
end
fclose(fid);
