function grd=load_ch3dgrid(varargin)
%LOAD_CH3DGRID function to load CH3D grid
%
%SYNTAX:grd=load_ch3dgrid  
%       grd=load_ch3dgrid(file)
%where, 
%  grd = struct containing following fields
%       .header = descriptive information from the grid file
%       .ni = number of I cells
%       .nj = number of J cells
%       .x = x coordinates (corners)
%       .y = y coordinates (corners)
%       .z = depths (corners)
%       .xc = x coordinates (cell centers)
%       .yc = y coordinates (cell centers)
%       .zc = depths (cell centers)
%
% file = input filename
%        Include full or relative path as necessary.
%        Optional input.  If not given, user will be prompted to select.
%
%NOTE: Land cells determined by cells with values > 10^9 and
%      are indicated in grd struct as NaN.
%

%Author Info
%Jarrell Smith
%USACE ERDC
%Coastal and Hydraulics Laboratory
%8/30/2009

%% Parameters
vland=1e9;
h=0.25*[1,1;1,1]; %filter shape for corner averaging;
%% Check input
error(nargchk(0,1,nargin))
error(nargoutchk(0,1,nargout))

%% Process Input
if nargin==1
    %get filename
    fn=varargin{1};
    %check for existence
    if ~exist(fn,'file')
        error('File: %s not found.',fn);
    end
elseif nargin==2
    %prompt user for filename
    [fn,pn]=uigetfile('*.*','Select CH3D grid.');
    if isnumeric(fn),return,end
    %construct filename
    fn=fullfile(pn,fn);
end
%% Read file
fid=fopen(fn,'rt');
%read header info
grd.header=fgetl(fid);
grd.ni=fscanf(fid,'%f',1);
grd.nj=fscanf(fid,'%f',1);
%read data
% dat=textscan(fid,'%f %f %f %f %f');
dat=textscan(fid,'%f %f %f %*f %*f');
fclose(fid);
%parse data
grd.x=reshape(dat{:,1},grd.ni,grd.nj);
grd.y=reshape(dat{:,2},grd.ni,grd.nj);
grd.z=reshape(dat{:,3},grd.ni,grd.nj);
% grd.i=reshape(dat{:,4},grd.ni,grd.nj);
% grd.j=reshape(dat{:,5},grd.ni,grd.nj);
%set land cells to NaN
in=grd.z>vland;
grd.x(in)=nan;
grd.y(in)=nan;
grd.z(in)=nan;
%determine cell center positions
grd.xc=filter2(h,grd.x,'valid');
grd.yc=filter2(h,grd.y,'valid');
grd.zc=filter2(h,grd.z,'valid');
