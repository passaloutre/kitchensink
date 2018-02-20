function adcirc_struc=load14(varargin)
% LOAD14 function to load ADCIRC mesh
% 
% SYNTAX:  adc_struc=load14(filename)
%   adc_struc is a structure variable with the following fields
%             .x    the longitude coordinates of each node
%             .y    the latitude coordinates of each node
%             .dep  the depth of each node
%             .tri  the connectivity table for each element
%   filename  = optional input of the mesh filename
%
%  Jarrell Smith
%  21 November 2003
%

%check input
error(nargchk(0,1,nargin))

%specify the input file
switch nargin
    case 0,
        [fname,pname]=uigetfile('*.14; *.grd','Select the ADCIRC mesh file');
        if isa(fname,'numeric'),error('load14 aborted by user');end
        file=fullfile(pname,fname);
    case 1,
        file=varargin{1};
end
if ~exist(file,'file'),error('Invalid filename. '),end

%load the fort.14 file
fid14=fopen(file,'r');
id = fgetl(fid14);
dum = str2num(fgetl(fid14));
ne = dum(1);
np = dum(2);
%load points
fprintf(1,'Loading Fort.14 file... points\n')
xy=fscanf(fid14,'%*f %f %f %f',[3,np]);
xy=xy';
adcirc_struc.x=xy(:,1);
adcirc_struc.y=xy(:,2);
adcirc_struc.dep=xy(:,3);
%load connectivity table
fprintf(1,'Loading Fort.14 file... connectivity table\n')
tri=fscanf(fid14,'%*f %*f %f %f %f',[3,ne]);
adcirc_struc.tri=tri';
%load open boundaries
fprintf(1,'Loading Fort.14 file... open boundaries\n')
nopen=fscanf(fid14,'%f',1); %number of open boundaries
fgetl(fid14);
fgetl(fid14);
for k=1:nopen
   npts=fscanf(fid14,'%f',1); %number of points on boundary k
   fgetl(fid14);
   adcirc_struc.bndopen{k}=fscanf(fid14,'%f',npts);
end
%load land boundaries
fprintf(1,'Loading Fort.14 file... land boundaries\n')
nland=fscanf(fid14,'%f',1); %number of open boundaries
fgetl(fid14);
fgetl(fid14);
adcirc_struc.bndlandtype=zeros(1,nland);
for k=1:nland
   npts=fscanf(fid14,'%f',1); %number of points on boundary k
   adcirc_struc.bndlandtype(k)=fscanf(fid14,'%f',1); %boundary type
   fgetl(fid14);
   adcirc_struc.bndland{k}=fscanf(fid14,'%f',npts);
end
%close file
fclose(fid14);
