%% script for developing h5 particle reader.

%% Parameters
datflds={'Locations','Times'};
attflds={'source','state'};
%% Get File Info
h5file='v2_particles.h5';
fileinfo=hdf5info(h5file);
toplevel=fileinfo.GroupHierarchy;
lev1=toplevel.Groups.Name;
datnames={toplevel.Groups.Datasets.Name};
attnames={toplevel.Groups.Groups.Name};
%Location Variable
fi=strfind(datnames,'Locations');
I=find(~cellfun(@isempty,fi));
var.location=datnames{I};
szloc=toplevel.Groups.Datasets(I).Dims;
np=szloc(2); %number of particles
nt=szloc(3); %number of times
FillValue=toplevel.Groups.Datasets(I).FillValue; %dummy value
%Time Variable
fi=strfind(datnames,'Times');
I=find(~cellfun(@isempty,fi));
var.time=datnames{I};
%Source Variable
fi=strfind(attnames,'source');
I=find(~cellfun(@isempty,fi));
var.source=attnames{I};
%State Variable
fi=strfind(attnames,'state');
I=find(~cellfun(@isempty,fi));
var.state=attnames{I};
%Get Reftime
reftime=h5attget(h5file,[lev1,'/Reftime']); %Julian Day (noon start)
%% Step through time to extract positional data
k=7; %time index
%get position and time
x=h5varget(h5file,var.location,[0,0,k],[1,np,1]);
y=h5varget(h5file,var.location,[1,0,k],[1,np,1]);
z=h5varget(h5file,var.location,[2,0,k],[1,np,1]);
t=h5varget(h5file,var.time,k,1);
dn=julian2datenum(reftime+0.5+t/86400);
%set all dummy data to nan instead of FillValue
in= x==FillValue & y==FillValue;
x(in)=nan;
y(in)=nan;
z(in)=nan;
%get particle attributes
state=h5varget(h5file,[var.state,'/Values'],[0,k],[np,1]);
state(in)=0;
state=logical(state);  %convert state variable to logical
src=h5varget(h5file,[var.source,'/Values'],[0,0],[np,1]);

% %display particle positions
% figure(1)
% plot(x(in),y(in),'o')
% text(x(in),y(in),num2str(find(in(:))),...
%    'HorizontalAlignment','left',...
%    'VerticalAlignment','bottom')
% set(gca,'XLim',[2500,5000],'YLim',[0,2000])
% axis equal
% title(sprintf('t = %g',t))

% %plot mobility
% figure(2)
% plot(mob)
% title(sprintf('t = %g',t))

%plot x,z
figure(3)
h3=plot(x(state),z(state),'bo',...
   x(~state),z(~state),'bo');
set(h3(2),'MarkerFaceColor','b')
text(x(~in),z(~in),num2str(find(~in(:))),...
   'HorizontalAlignment','left',...
   'VerticalAlignment','bottom')
set(gca,'XLim',[2500,5000],'YLim',[-2,0])
title(sprintf('t = %g (%s)',t,datestr(dn)))
