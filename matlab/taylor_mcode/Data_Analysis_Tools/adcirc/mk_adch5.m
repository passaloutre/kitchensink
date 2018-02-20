function mk_adch5(dafile,h5file)
%MK_ADCH5 function to create SMS h5 file from ADCIRC DA file
%
%SYNTAX:  mk_adch5(dafile,h5file)
% where
%   dafile = Matlab DA style file (from mk_adcda)
%   h5file = SMS readable h5 file
%
%SEE ALSO: MK_ADCDA, LOAD_ADCDA
%

%% Parameters
% %input files (for testing)
% dafile='D:\activejobs\POA\adcirc\production\bathy_j5_w_k5c_base_fort63bin_06.da';
% h5file='D:\activejobs\POA\adcirc\production\base_test13.h5';
%% Access DA file.  Get dimension sizes
adc=load_adcda(dafile,0);
nt=adc.nt;
np=adc.np;
dt=adc.dt;
% nt=20; %for testing purposes
%% Load snapshot from DA, place in H5
fprintf(1,'Converting: \n DAfile: %s\n H5file: %s\n',dafile,h5file);
fprintf(1,'Preparing H5 file...\n');
%Create File Type and File Version Info
hdf5write(h5file,'/File Type','Xmdf')
hdf5write(h5file,'/File Version',single(1.0),'WriteMode','append');
%Write data
%create data holding structures
%GUID
hdf5write(h5file,'/Datasets/Guid',CreateGuid,...
   'WriteMode','append');
%Velocity (64)
dumval=single(1:nt);
dumval2=(0:nt-1)*dt;
hdf5write(h5file,'/Datasets/Velocity (64)/Maxs',...
   dumval,'WriteMode','append');
hdf5write(h5file,'/Datasets/Velocity (64)/Mins',...
   dumval,'WriteMode','append');
hdf5write(h5file,'/Datasets/Velocity (64)/Times',...
   dumval2,'WriteMode','append');
hdf5write(h5file,'/Datasets/Velocity (64)/Values',...
   single(zeros(2,np,3)),'WriteMode','append');
%Velocity (64) mag
hdf5write(h5file,'/Datasets/Velocity (64) mag/Maxs',...
   dumval,'WriteMode','append');
hdf5write(h5file,'/Datasets/Velocity (64) mag/Mins',...
   dumval,'WriteMode','append');
hdf5write(h5file,'/Datasets/Velocity (64) mag/Times',...
   dumval2,'WriteMode','append');
hdf5write(h5file,'/Datasets/Velocity (64) mag/Values',...
   single(zeros(np,2)),'WriteMode','append');
%Water Surface Elevation (63)
hdf5write(h5file,'/Datasets/Water Surface Elevation (63)/Maxs',...
   dumval,'WriteMode','append');
hdf5write(h5file,'/Datasets/Water Surface Elevation (63)/Mins',...
   dumval,'WriteMode','append');
hdf5write(h5file,'/Datasets/Water Surface Elevation (63)/Times',...
   dumval2,'WriteMode','append');
hdf5write(h5file,'/Datasets/Water Surface Elevation (63)/Values',...
   single(zeros(np,2)),'WriteMode','append');
hdf5write(h5file,'/Datasets/Water Surface Elevation (63)/PROPERTIES/nullvalue',...
   single(-99999),'WriteMode','append');

%add dataset attributes
h5attput(h5file,'/Datasets','Grouptype','MULTI DATASETS');
h5attput(h5file,'/Datasets/Velocity (64)',...
   'Grouptype','DATASET VECTOR');
h5attput(h5file,'/Datasets/Velocity (64)',...
   'TimeUnits','Seconds');
h5attput(h5file,'/Datasets/Velocity (64)',...
   'DatasetUnits','m/s');
h5attput(h5file,'/Datasets/Velocity (64)',...
   'DatasetCompression',int32(-1));
h5attput(h5file,'/Datasets/Velocity (64) mag',...
   'Grouptype','DATASET SCALAR');
h5attput(h5file,'/Datasets/Velocity (64) mag',...
   'TimeUnits','Seconds');
h5attput(h5file,'/Datasets/Velocity (64) mag',...
   'DatasetUnits','m/s');
h5attput(h5file,'/Datasets/Velocity (64) mag',...
   'DatasetCompression',int32(-1));
h5attput(h5file,'/Datasets/Water Surface Elevation (63)',...
   'Grouptype','DATASET SCALAR');
h5attput(h5file,'/Datasets/Water Surface Elevation (63)',...
   'TimeUnits','Seconds');
h5attput(h5file,'/Datasets/Water Surface Elevation (63)',...
   'DatasetUnits','m');
h5attput(h5file,'/Datasets/Water Surface Elevation (63)',...
   'DatasetCompression',int32(-1));
h5attput(h5file,'/Datasets/Water Surface Elevation (63)/PROPERTIES',...
   'Grouptype','PROPERTIES');


%modify sizes of storage space for large datasets
fid=H5F.open(h5file,'H5F_ACC_RDWR','H5P_DEFAULT');
did=H5D.open(fid,'/Datasets/Velocity (64)/Values');
H5D.extend(did,[nt,np,2])
did=H5D.open(fid,'/Datasets/Velocity (64) mag/Values');
H5D.extend(did,[nt,np])
did=H5D.open(fid,'/Datasets/Water Surface Elevation (63)/Values');
H5D.extend(did,[nt,np])
H5F.close(fid);
%populate file with data
fprintf(1,'Converting %g timesteps.\nTimestep: ',nt);
nbyte=fprintf(1,'%g (%4.1f%%)',0,0);
for k=1:nt;
   nbyte=fprintf(1,[repmat('\b',1,nbyte),'%g (%4.1f%%)'],k,(k-1)/nt*100)-nbyte;
   adc=load_adcda(dafile,k);
   time=(k-1)*dt; %stored as double
   v3=single([adc.u,adc.v]');
   v3mag=single(hypot(adc.u,adc.v));
   eta=single(adc.eta);
   %Velocity (64)
   h5varput(h5file,'/Datasets/Velocity (64)/Maxs',...
      k-1,1,max(v3(:)));
   h5varput(h5file,'/Datasets/Velocity (64)/Mins',...
      k-1,1,single(0));
%    h5varput(h5file,'/Datasets/Velocity (64)/Times',...
%       k-1,1,time);
   h5varput(h5file,'/Datasets/Velocity (64)/Values',...
      [0,0,k-1],[2,np,1],v3);      
   %Velocity (64) mag
   h5varput(h5file,'/Datasets/Velocity (64) mag/Maxs',...
      k-1,1,max(v3mag(:)));
   h5varput(h5file,'/Datasets/Velocity (64) mag/Mins',...
      k-1,1,min(v3mag(:)));
%    h5varput(h5file,'/Datasets/Velocity (64) mag/Times',...
%       k-1,1,time);
   h5varput(h5file,'/Datasets/Velocity (64) mag/Values',...
      [0,k-1],[np,1],v3mag);
   %Water Surface Elevation (63)   
   h5varput(h5file,'/Datasets/Water Surface Elevation (63)/Maxs',...
      k-1,1,max(eta));
   h5varput(h5file,'/Datasets/Water Surface Elevation (63)/Mins',...
      k-1,1,min(eta));
%    h5varput(h5file,'/Datasets/Water Surface Elevation (63)/Times',...
%       k-1,1,time);
   h5varput(h5file,'/Datasets/Water Surface Elevation (63)/Values',...
      [0,k-1],[np,1],eta);
end
fprintf(1,'\nJob Complete.\n')
fid=H5F.open(h5file,'H5F_ACC_RDWR','H5P_DEFAULT');
H5F.close(fid);
