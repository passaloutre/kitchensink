function a=caltrack(varargin)
%CALTRACK function to plot depth-averaged currents along ADCPtrack survey
%         against ADCIRC data
% SYNTAX: a=caltrack
%         a=caltrack(a)

%CONVERSIONS AND HARDCODED PARAMETERS
s2d=1/3600/24;  %conversion for seconds to days
zncon=0;        %conversion from local time to GMT +4hrs EDT to GMT
gclr=0.5*[.9,.9,1]; %gray color
plottype='m_map';  %either normal or m_map
%note1: see hardcoded parameters in map projection when loading ADCIRC grid
%      utm zone, lat/lon ranges

%check I/O
nargchk(0,1,nargin);
nargoutchk(0,1,nargout);
if nargin,
    a=varargin{1};
    if ~isa(a,'struct'),
        help('caltrack')
        error('Input argument must be a structure array.')
    end
else
    a=struct([]);
end


%if incomplete information given in a, use defaults
%% ADCIRC INFORMATION
if ~isfield(a,'AdcircGrid') || a.adcircnew,
    [fname,pname]=uigetfile('*.14;*.grd','Select the ADCIRC grid');
    fname=fullfile(pname,fname);
    if isnumeric(fname),return,end
    a(1).AdcircGrid=load14(fname);
    latlim=minmax(a.AdcircGrid.y);
    lonlim=minmax(a.AdcircGrid.x);
    a.adcircnew=true;
    %set projection.... requires M_MAP toolbox
    %(http://www2.ocgy.ubc.ca/~rich/map.html)
%     m_proj('Lambert','lon',lonlim,'lat',latlim,...
%        'rectbox','on')
end
if ~isfield(a,'fileDA')||a.adcircnew,
    [fname,pname]=uigetfile('*.da','Select the ADCIRC direct-access solution file');
    if isstr(fname),a.fileDA=fullfile(pname,fname);end
elseif ~exist(a.fileDA),
    uiwait(msgbox(['Could not find the file: ',a.fileDA,...
            '. Please select the ADCIRC direct-access solution file.'],'modal'));
    [fname,pname]=uigetfile('*.da','Select the ADCIRC direct-access solution file');
    if isstr(fname),a.fileDA=fullfile(pname,fname);end
end
if ~exist(a.fileDA),
    warning('Matlab:error',['Could not proceed without an ADCIRC direct-access file.%s\n',...
            'This file can be created from a fort.63 and fort.64 with%s\n',...
            'the function mk_adcda.m'],' ',' ')
    return
end
if ~isfield(a,'timestamp'),
    a.timestamp=1;
end

%% ADCP TRACK DATA
%if new flag set on adcp, then replace the ADCP data
if isfield(a,'adcp'),
    if a.adcpnew,
        a=rmfield(a,'adcp');
    end
end

if ~isfield(a,'adcp'), 
    [fname,pname]=uigetfile('*.mat','Select the ADCP data file.');
    if isnumeric(fname),
        warning('Matlab:error','Could not proceed without an ADCP data file.')
        return
    end
    load(fullfile(pname,fname),'-mat');
    a.adcp=adcp;
    %get time limits for adcp track data
    ntrans=length(a.adcp);
    a.adcptimelim=zeros(ntrans,2);
    for k=1:ntrans
       a.adcptimelim(k,:)=minmax(a.adcp(k).mtime);
    end
    a.adcpnew=true;
    clear adcp ntrans
end
if ~isfield(a,'dn'),   %sets default averaging interval for ADCP data
    a.dn=1;  %width of averaging window
end
        
%% FIGURE INFORMATION
if ~isfield(a,'ax'),   %if field doesn't exist, create figure and place dummy value in handle
   figure(10);clf
   a.ax=.01;
end
if ~ishandle(a.ax),   %create axis and background image
   a.ax=axes;
   a.adcpnew=true;
   latlim=minmax(a.AdcircGrid.y);
   lonlim=minmax(a.AdcircGrid.x);
   set(a.ax,'XTick',[],'YTick',[],'Position',[0.01,0.10,0.98,0.90],...
      'XLim',lonlim,'YLim',latlim,'NextPlot','add');
   a.hstxt=uicontrol(gcf,'Style','text',...
      'Units','points',...
      'Position',[0,0,400,50],...
      'String','Initializing . . . ',...
      'FontName','System',...
      'HorizontalAlignment','left',...
      'FontSize',10);
end
if a.adcircnew
   % get ADCIRC solution information
   adc=load_adcda_pt(a.fileDA,0);
   a.adcircnt=adc.nt;
   a.adcirctime=adc.time;
   if adc.np~=length(a.AdcircGrid.x)
      herr=errordlg('The DA file and grid do not match.');
      uiwait(herr)
      return
   end
   % plot ADCIRC boundaries
   axes(a.ax);
%    set(a.ax,'PlotBoxAspectRatio',[1,1,1])
   switch plottype
      case 'm_map'
         m_proj('mercator','lat',latlim,'lon',lonlim);
   end
   %plot open boundaries
   Nopen=length(a.AdcircGrid.bndopen);
   a.hbndopen=zeros(Nopen,1);
   for k=1:Nopen;
      I=a.AdcircGrid.bndopen{k};
      switch plottype
         case 'm_map'
            a.hbndopen(k)=m_line(a.AdcircGrid.x(I),a.AdcircGrid.y(I),'Color','b');
         otherwise
            a.hbndopen(k)=line(a.AdcircGrid.x(I),a.AdcircGrid.y(I),'Color','b');
%             axis equal
      end
   end
   %plot closed boundaries
   Nland=length(a.AdcircGrid.bndland);
   a.hbndland=zeros(Nland,1);
   for k=1:Nland;
      I=a.AdcircGrid.bndland{k};
      switch plottype
         case 'm_map'
            a.hbndland(k)=m_line(a.AdcircGrid.x(I),a.AdcircGrid.y(I),'Color','b');
         otherwise
            a.hbndland(k)=line(a.AdcircGrid.x(I),a.AdcircGrid.y(I),'Color','b');
      end
   end
   in=a.AdcircGrid.bndlandtype==0;
   set(a.hbndland(in),'Color','k')
   in=a.AdcircGrid.bndlandtype==1;
   set(a.hbndland(in),'Color','g')
   in=a.AdcircGrid.bndlandtype==2;
   set(a.hbndland(in),'Color','c')
   set([a.hbndland;a.hbndopen],'HandleVisibility','off')

   switch plottype
      case 'm_map'
         m_grid
      otherwise
%          set(a.ax,'XLim',lonlim,'YLim',latlim)
   end
   a.adcircnew=false;
end
%% ADCP data
if a.adcpnew,
    if isfield(a,'htrk')&& any(ishandle(a.htrk))
       delete(a.htrk)
    end
    ntrk=size(a.adcptimelim,1);
    a.htrk=zeros(ntrk,1);
    for k=1:ntrk,
      switch plottype
         case 'm_map'
            a.htrk(k)=m_line(a.adcp(k).nav_longitude,a.adcp(k).nav_latitude,...
               'Color',gclr,...
               'LineStyle','--',...
               'LineWidth',2,...
               'HandleVisibility','off');
         otherwise
            a.htrk(k)=line(a.adcp(k).nav_longitude,a.adcp(k).nav_latitude,...
               'Color',gclr,...
               'LineStyle','--',...
               'LineWidth',2,...
               'HandleVisibility','off');
      end
    end
    a.adcpnew=false;
end %adcpnew
if ~isfield(a,'vscale'),  %scaling factor for vectors
    a.vscale=1e-2;
    a.vlen=1.0;     %length of scale vector
end
%% check if running in gui mode
%if running through gui, get handles and plotting states
if ~isfield(a,'gui'),  %field for gui flag 0=standalone 1=gui
    a.gui=false; %default setting is standalone
    show.adcirc=true; %display adcirc vectors
    show.adcp=true;   %display adcp vectors
end
if a.gui,
   handles=guidata(a.ax);
   show.adcirc=get(handles.radiobuttonADCIRCvectors,'Value');
   show.adcp=get(handles.radiobuttonADCPvectors,'Value');
end
%% Decimate ADCIRC vector settings
if ~isfield(a,'decADCIRC'),  %field for gui flag 0=standalone 1=gui
    a.decADCIRC=1; %decimate ADCIRC vectors by this factor. default=1 (no reduction)
end


%% Plotting
%%%%%%%%%%%%%%%%%%%%%% BEGIN PLOTTING ROUTINE HERE  %%%%%%%%%%%%%%%%%%%%%%%%
%load data from ADCIRC timestamp
adc=load_adcda(a.fileDA,a.timestamp);
%select nodes within the plot limits
a.qlim.x=get(a.ax,'XLim');
a.qlim.y=get(a.ax,'YLim');
X=a.AdcircGrid.x;
Y=a.AdcircGrid.y;
switch plottype
   case 'm_map'
      [X,Y]=m_ll2xy(X,Y);      
   otherwise
      sy=sind(mean(a.qlim.y));
      set(a.ax,'DataAspectRatio',[1,sy,1])
end
in=X > a.qlim.x(1) & X < a.qlim.x(2) & ...
   Y > a.qlim.y(1) & Y < a.qlim.y(2) ;
%plot ADCIRC vectors
axes(a.ax);cla
indx=find(in);
indx=indx(1:a.decADCIRC:end);

a.hq=quiver(X(indx),Y(indx),...
   a.vscale*adc.u(indx),a.vscale*adc.v(indx),0,'r');
set(a.hq,'LineWidth',2,'MarkerSize',2);
if ~show.adcirc,
   set(a.hq,'Visible','off')
end
%vector for scale in upper right corner
dx=a.vscale*a.vlen;
dy=0.25*dx;
xo=a.qlim.x(2)-0.1*dx;
yo=a.qlim.y(2)-0.25*dy;
x=[xo, xo-1.2*dx, xo-1.2*dx, xo     , xo];
y=[yo, yo       , yo-3*dy  , yo-3*dy, yo];
hqpatch=patch(x,y,'w','EdgeColor','r','LineWidth',1);
hqtxt=text(xo-dx,yo-3*dy,sprintf('%g m/s',a.vlen));
x=get(gcf,'Position');
y=get(gca,'Position');
fsz=max(8,round(3*dy/diff(minmax(a.qlim.y))*y(4)*x(4)/2.5));
set(hqtxt,'Color','r','FontWeight','bold',...
    'VerticalAlignment','bottom','BackgroundColor','none',...
    'FontUnits','pixels','FontSize',fsz)
hqr=quiver(xo-1.1*dx,yo-.75*dy,dx,0,0,'r');
set(hqr,'LineWidth',2,'MarkerSize',2);

%find ADCP times within +/- DT/2 of ADCIRC snapshot
dt2=adc.dt/2*s2d;  %dt/2 [days]
tlim=adc.time+dt2*[-1,1];
%find appropriate trackline(s)
in1=(a.adcptimelim(:,1)>=tlim(1) & a.adcptimelim(:,1) <= tlim(2)) |...
    (a.adcptimelim(:,2)>=tlim(1) & a.adcptimelim(:,2) <= tlim(2)) |...
    (a.adcptimelim(:,1)<=tlim(1) & a.adcptimelim(:,2) >= tlim(2));
set(a.htrk(in1),'Color','c')
set(a.htrk(~in1),'Color',gclr)
I=find(in1);
for k=I'
   in2{k}=a.adcp(k).mtime>=tlim(1) & a.adcp(k).mtime<=tlim(2);
end

%plot ADCP vectors
[x,y,U,V,t]=deal([]);
for k=I'
   in22=in2{k};
   J=find(in22);
   nwin=ceil(length(J)/a.dn);
   [xtmp,ytmp,utmp,vtmp]=deal(zeros(1,nwin));
   t=[t,a.adcp(k).mtime(in22)];
   for kk=1:nwin,
      if kk==nwin
         i1=(kk-1)*a.dn+1:length(J);
      else
         i1=(kk-1)*a.dn+(1:a.dn);
      end
      xtmp(kk)=mean(a.adcp(k).nav_longitude(J(i1)));
      ytmp(kk)=mean(a.adcp(k).nav_latitude(J(i1)));
      utmp(kk)=mean(a.adcp(k).umean(J(i1)));
      vtmp(kk)=mean(a.adcp(k).vmean(J(i1)));      
   end
   x=[x,xtmp];
   y=[y,ytmp];
   U=[U,utmp];
   V=[V,vtmp];
end
   switch plottype
      case 'm_map'
         [x,y]=m_ll2xy(x,y);
   end
if ~isempty(x),
   a.hqm=quiver(x,y,a.vscale*U,a.vscale*V,0,'b');
   set(a.hqm,'LineWidth',2)
   %plot NaNs as empty bubbles
   in4=isnan(U) | isnan(V);
   a.hqmnan=plot(x(in4),y(in4),'bo','LineWidth',3);
   %toggle view depending on display settings
   if ~show.adcp
      set([a.hqm,a.hqmnan],'Visible','off')
   end
end
%update the status area
if isempty(I),
   adcpindx=zeros(4);
   t=zeros(1,2);
else
   adcpindx=[I(1),I(end);find(in2{I(1)},1,'first'),find(in2{I(end)},1,'last')];
end
update_statusbox(a.hstxt,minmax(t),adcpindx,a.adcptimelim,adc.time,a.timestamp,adc.nt);


%%%%%%%%%%%%%%%%%%%% SUB FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%

function update_statusbox(htxt,adcptlim,adcpindx,adcptime,adctime,adcindx,nt)
%htxt=handle to status textbox
%t0=min adcp time
%t2=max adcp time
%t1=adcirc time
%i0,i1,i2 = corresponding indices to times
%nt = number of ADCIRC snapshots
%dtwin= windowing intervals
t1=adctime;
i1=adcindx;
t0=adcptlim(1);
t2=adcptlim(2);
%place information into title
str1=['ADCIRC TIMESTAMP:',sprintf('%4.0f of %4.0f',i1,nt),...
            sprintf(', Time= %s GMT',datestr(t1,0))];
if t0==0,  %no matching ADCP data
    str2='NO MATCHING ADCP DATA';
    trng=minmax(adcptime);
    str3=sprintf('ADCP data: %s to %s',datestr(trng(1)),datestr(trng(2)));
else    %with matching ADCP data
    str2=[sprintf('ADCP INDEX RANGE: %g/%g to %g/%g',adcpindx)];
    if floor(t0)==floor(t2);
        str3=sprintf('ADCP TIME RANGE: %s  %s to %s GMT ',...
            datestr(t0,1),datestr(t0,13),datestr(t2,13));
    else
        str3=sprintf('TimeRange: %s to %s GMT ',...
            datestr(t0,0),datestr(t2,0));
    end
end
set(htxt,'String',{str1;str2;str3})
