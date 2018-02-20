function [out,I] = mesh_stats(adc,varargin)
%MESH_STATS produces statistical measures of FE meshes
%
% [out,I] = mesh_stats(mesh_struct,'option')
% where,
%  out = output range of quantity specified by option
%        in form [min,max]
%  mesh_struct = Struct array with following fields
%       .x = longitude or cartesian x
%       .y = latitude or cartesian y
%     .dep = depth (not required)
%  option = string option specifier giving analysis option
%          {'area','length'}.  Default = 'length'
%
% NOTE: If abs(max(mesh_struct.y)))>90, coordinates assumed to
%       be Cartesian, otherwise, Lat/Lon.  In case of Cartesian
%       coorinates, units of out = units of .x^2.  If Lat/Lon
%       units of out = m^2.

%% Input checking
nargchk(1,2,nargin);  %check for correct number of input args
switch nargin,  % assign optional arguments to option
    case 0,
        help mesh_stats
        error('Must have at least one input arg.')
    case 1, %if no optional args option=length
        option='length';
    case 2, %if optional arg provided assign to option
        tmp=varargin{1};
        switch lower(tmp),
            case 'area',
                option='area';
            case 'length',
                option='length';
            otherwise,
                error('Valid options are ''area'' and ''length''')
        end
end
fields={'x','y','tri'};  %required fields in struct adc for code
for k=1:length(fields),  %check for required fields
    if ~isfield(adc,fields(k)),
        error(['Field: ',fields(k),' required and not found in first argument.'])
    end
end
%% Calculations
%no units given in ADCIRC .14 file, so use magnitude of units to decide
%whether input is lat/lon or Cartesian
if max(abs(range(adc.y)))>90,
    type='cartesian';
else
    type='latlon';
    R=6367650; %earth radius [m]
end
switch option
    case 'area'
        switch type
            case 'cartesian'
                A=polyarea(adc.x(adc.tri),adc.y(adc.tri),2);
            case 'latlon'
                A=triarea_sph(adc.x(adc.tri),adc.y(adc.tri),R);
        end
        out=minmax(A); %compute limits of element areas
        I(1)=find(A==out(1),1,'first'); %find elem.num for min area
        I(2)=find(A==out(2),1,'first'); %find elem.num for max area
    case 'length'
        switch type
            case 'cartesian'
                x=adc.x(adc.tri);
                y=adc.y(adc.tri);
                dx=[x(:,2)-x(:,1),x(:,3)-x(:,2),x(:,1)-x(:,3)];
                dy=[y(:,2)-y(:,1),y(:,3)-y(:,2),y(:,1)-y(:,3)];
                L=sqrt(dx.^2+dy.^2); %compute element edge lengths.
                out=minmax(L); %get min and max of lengths
                [I(1),J]=find(L==out(1),1,'first'); %find element with min length
                [I(2),J]=find(L==out(2),1,'first'); %find element with max length
            case 'latlon'
                %convert lat,lon to 3d cartesian space
                [x,y,z]=sph2cart(pi/180*adc.x(adc.tri),pi/180*adc.y(adc.tri),R);
                L=zeros(length(x),3); %preallocate
                %Determine chord lengths for each side of element
                c1=1;c2=2;
                L(:,1)=sqrt((x(:,c1)-x(:,c2)).^2+...
                    (y(:,c1)-y(:,c2)).^2+...
                    (z(:,c1)-z(:,c2)).^2);
                c1=2;c2=3;
                L(:,2)=sqrt((x(:,c1)-x(:,c2)).^2+...
                    (y(:,c1)-y(:,c2)).^2+...
                    (z(:,c1)-z(:,c2)).^2);
                c1=3;c2=1;
                L(:,3)=sqrt((x(:,c1)-x(:,c2)).^2+...
                    (y(:,c1)-y(:,c2)).^2+...
                    (z(:,c1)-z(:,c2)).^2);
                %compute arc length of each element edge
                S=2*R*asin(L./2./R);
                out=minmax(S); %min & max arc length               
                [I(1),J]=find(S==out(1),1,'first'); %element associated with minval
                [I(2),J]=find(S==out(2),1,'first'); %element associated with maxval
        end
end


function lim=minmax(a)
%function to determine range of values in matrix A
%USAGE:  lim=minmax(A)
%  lim= two element vector containing min and max values of A
%see also MIN, MAX
n=ndims(a);
a1=min(a);
a2=max(a);
for k=2:n,
    a1=min(a1);
    a2=max(a2);
end
lim=[a1,a2];

function A=triarea_sph(lon,lat,R)
%POLYAREA_SPH is a fuction to estmate the surface area included within a polygon
%located on the surface of a sphere.
%USAGE:  A=polyarea_sph(lon,lat,R);
%     A = area within polygon in units of R^2
%   lon = vector of polygon longitudes
%   lat = vector of polygon latitudes
%     R = radius of sphere 
%     R=mean([6378388,6356912])=6367650  %mean earth radius, m

%% Chord lengths
[x,y,z]=sph2cart(pi/180*lon,pi/180*lat,R);
c1=1;c2=2;
L1=(x(:,c1)-x(:,c2)).^2+...
   (y(:,c1)-y(:,c2)).^2+...
   (z(:,c1)-z(:,c2)).^2;
c1=2;c2=3;
L2=(x(:,c1)-x(:,c2)).^2+...
   (y(:,c1)-y(:,c2)).^2+...
   (z(:,c1)-z(:,c2)).^2;
c1=3;c2=1;
L3=(x(:,c1)-x(:,c2)).^2+...
   (y(:,c1)-y(:,c2)).^2+...
   (z(:,c1)-z(:,c2)).^2;
%% Spherical triangle area
a=acos(1-L1/2/R^2);
b=acos(1-L2/2/R^2);
c=acos(1-L3/2/R^2);
s=(a+b+c)/2;
arg1=sqrt(tan(s/2).*tan((s-a)/2).*tan((s-b)/2).*tan((s-c)/2));
E=4*atan(arg1);
A=R.^2*E;