function w=load_cmswavedep(varargin)
%LOAD_CMSWAVEDEP is a function to load data from a CMS-WAVE grid file.
%
%SYNTAX:   w = load_cmswavedep
%          w = load_cmswavedep(simfile)
% where,
%    w = struct holding fields
%        .xp = Easting
%        .yp = Northing
%        .z  = 2-D array of gridded depths
% simfile = filename for simfile
%
%

%CHECK I/O ARGUMENTS
error(nargchk(0,1,nargin));
error(nargoutchk(1,1,nargout));

%READ SIM FILE
%get simfile name
switch nargin
   case 0
[fname,pname]=uigetfile('*.sim','Select SIM file STWAVE grid:');
   case 1
      fn=varargin{1};
      %check for existence
      if ~exist(fn,'file')
         error('File not found.')
      end
      [pname,fname,ext]=fileparts(fn);
      fname=[fname,ext];
end
%open and read simfile
fidp=fopen(fullfile(pname,fname),'rt');
a=fgetl(fidp);
b=sscanf(a,'%*s %f %f %f');
xop=b(1);yop=b(2);xazp=b(3);
%get DEP filename
while ~feof(fidp),
    a=fgetl(fidp);
    [card,tok]=strtok(a);
    switch lower(card)
    case 'dep'
        fnd=strtrim(tok);
        break
    end
end
fclose(fidp);

%READ GRID HEADER FOR NX,NY,DX
fid=fopen(fullfile(pname,fnd),'rt');
a=fgetl(fid);
b=sscanf(a,'%f');
ni=b(1);nj=b(2);
if numel(b)==3,
   dmesh=b(3); dindex=b(3);
else
   dmesh=b(3);dindex=b(4);
end
%Populate fields in output struct
w.ni=ni;
w.nj=nj;
w.xo=xop;
w.yo=yop;
w.dx=0;
w.dy=0;
w.A=0;
w.x=0;
w.y=0;
w.z=0;
w.xp=0;
w.yp=0;
%read depths
w.z=fscanf(fid,'%f',[ni,nj]);
w.z=fliplr(w.z);
%read dx dy
if dindex~=999
   dx=dmesh*ones(ni,1);
   dy=dindex*ones(nj,1);
else
   dx=fscanf(fid,'%f',ni);
   dy=fscanf(fid,'%f',nj);
end
fclose(fid);
w.dx=dx;
w.dy=dy;

%CREATE MATRIX OF CELL CENTER REAL-WORLD COORDINATES
ct=cos(xazp/180*pi);
st=sin(xazp/180*pi);
A=[ct st;-st ct]; %transformation matrix (rotation only)
x=cumsum(dx)-dx(1)/2;
y=cumsum(dy)-dy(1)/2;
[Y,X]=meshgrid(y,x);
Xp=[X(:),Y(:)]*A;
w.xp=reshape(xop+Xp(:,1),size(w.z));
w.yp=reshape(yop+Xp(:,2),size(w.z));
w.x=x;
w.y=y;
w.A=A;

