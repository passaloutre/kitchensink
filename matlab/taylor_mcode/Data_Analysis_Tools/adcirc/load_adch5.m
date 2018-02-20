function s=load_adch5(h5file,n,t0)
%LOAD_ADCH5 loads ADCIRC velocity fields from SMS-generated H5 files
%
%SYNTAX:  s = load_adch5(h5file,n,start_time)
%where,
%       s = struct variable with following fields
%           .nt = number of snapshots in h5 file
%           .np = number of ADCIRC nodes
%           .time = date/time associated with the requested snapshot
%                   in Matlab's datenum format
%           .dt = snapshot interval (in sec)
%           .eta = water surface elevation for each node
%           .u = eastward-directed velocity component at each node
%           .v = northward-directed velocity component at each node
%
%   h5file = filename of h5 file (specify full path if file is not local)
%        n = snapshot index to retrieve
% start_time = date/time associated with beginning of ADCIRC simulation
%
% Required functions: h5varget (from Mathworks Central)
%
% SEE ALSO: mk_adcda, load_adcda, mk_adch5

% Jarrell Smith
% US Army Engineer Research & Development Center
% Coastal and Hydraulics Laboratory
% Vicksburg, MS
%% Check Input
narginchk(3,3)
nargoutchk(0,1)
%check for file existence
if ~exist(h5file,'file')
   error('File %s is not found.',h5file)
end
%check date specification
if ischar(t0)
   try
      t0=datenum(t0);
   catch ME
      fprintf(1,'The date string entered cannot be converted.\n')
      fprintf(1,'Try mm/dd/yyyy HH:MM:SS.\n\n')
      rethrow(ME)
   end
end

%% Retrieve Data
%retrieve storage addresses and general parameters
h5=h5info(h5file);
s.np=h5.np; %number of nodes
s.nt=h5.nt; %number of timesteps
time_all=h5varget(h5file,[h5.var.eta,'/Times']);
s.dt=time_all(2)-time_all(1);
s.time=t0+time_all(n)/86400;
%extract specified hyperslab from h5 file
%ETA  H5 indexing: [nodes,time]
s.eta=h5varget(h5file,[h5.var.eta,'/Values'],[0,n-1],[h5.np,1]);
%UV  H5 indexing: [u/v index,nodes,time]
s.u=h5varget(h5file,[h5.var.uv,'/Values'],[0,0,n-1],[1,h5.np,1])';
s.v=h5varget(h5file,[h5.var.uv,'/Values'],[1,0,n-1],[1,h5.np,1])';

%%% SUBFUNCTIONS %%%
function h5=h5info(h5file)
%H5INFO reads appropriate file information for 
%       h5 variable addresses
%% Get File Info
fileinfo=hdf5info(h5file);
file_version=h5varget(h5file,'/File Version');
toplevel=fileinfo.GroupHierarchy;
if file_version ==1
   lev1=toplevel.Groups.Name; %Name for level_1
   attnames={toplevel.Groups.Groups.Name}; %Attribute Names
   %dimensions
   fi=strcmp([lev1,'/Water Surface Elevation (63)'],attnames);
   I=find(fi);
   datnames={toplevel.Groups.Groups(I).Datasets.Name};
   fi=strfind(datnames,'Values');
   J=~cellfun(@isempty,fi);
   dims=toplevel.Groups.Groups(I).Datasets(J).Dims;
elseif file_version >1
   lev1_names={toplevel.Groups.Name};
   I=find(cell2mat(strfind(lev1_names,'MeshModule')));
   lev3_names={toplevel.Groups(I).Groups.Groups.Name};
   J=find(cell2mat(strfind(lev3_names,'Datasets')));   
   lev1=toplevel.Groups(I).Groups.Groups(J).Name; %Name for level_1
   attnames={toplevel.Groups(I).Groups.Groups(J).Groups.Name}; %Attribute Names
   %dimensions
   datnames={toplevel.Groups(I).Groups.Groups(J).Groups(3).Datasets.Name};
   fi=strfind(datnames,'Values');
   K=~cellfun(@isempty,fi);
   dims=toplevel.Groups(I).Groups.Groups(J).Groups(3).Datasets(K).Dims;
end
%Velocity vectors (u,v) Variable
fi=strcmp([lev1,'/Velocity (64)'],attnames);
I=find(fi);
h5.var.uv=attnames{I};
%Elevation Variable
fi=strcmp([lev1,'/Water Surface Elevation (63)'],attnames);
I=find(fi);
h5.var.eta=attnames{I};
%get dimensions
h5.np=dims(1);
h5.nt=dims(2);
