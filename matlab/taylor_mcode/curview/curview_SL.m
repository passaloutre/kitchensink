function varargout = curview_SL(varargin)
%CURVIEW_SL M-file for curview_SL.fig
%      CURVIEW_SL, by itself, creates a new CURVIEW_SL or raises the existing
%      singleton*.
%
%      H = CURVIEW_SL returns the handle to a new CURVIEW_SL or the handle to
%      the existing singleton*.
%
%      CURVIEW_SL('Property','Value',...) creates a new CURVIEW_SL using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to curview_SL_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      CURVIEW_SL('CALLBACK') and CURVIEW_SL('CALLBACK',hObject,...) call the
%      local function named CALLBACK in CURVIEW_SL.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help curview_SL

% Last Modified by GUIDE v2.5 07-May-2007 17:01:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @curview_SL_OpeningFcn, ...
                   'gui_OutputFcn',  @curview_SL_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before curview_SL is made visible.
function curview_SL_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for curview_SL
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes curview_SL wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = curview_SL_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_SelectBins.
function pushbutton_SelectBins_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_SelectBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
indx=handles.adcp.bins';
R=handles.adcp.R';
Strs=cellstr(num2str([indx,R],'Bin%02.0f, range=%4.1f m'));
Def=handles.adcp.selected;
answer=radiodlg(Strs,'Select bins to display.',Def);
if isempty(answer),return,end
handles.adcp.selected=answer==1;
guidata(hObject,handles)
I=get(handles.slider_DateTime,'Value');
update_Velocity(handles,I);



function edit_CorrThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to edit_CorrThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_CorrThreshold as text
%        str2double(get(hObject,'String')) returns contents of edit_CorrThreshold as a double
%check that input is a valid number
if isnan(str2double(get(hObject,'String'))),%restore last good value
    set(hObject,'String',get(hObject,'UserData')) 
    errordlg('Invalid numeric entry. Reset to last valid entry.')
    return
else  %store entry in UserData
    set(hObject,'UserData',get(hObject,'String'))
end


% --- Executes during object creation, after setting all properties.
function edit_CorrThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_CorrThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'UserData',get(hObject,'String'))


% --- Executes on button press in radiobutton_vectors.
function radiobutton_vectors_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_vectors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobutton_vectors

%vectors and reference vector
if isfield(handles,'hvec')
    switch get(hObject,'Value')
        case 1 %selected on
            clr=get(hObject,'ForegroundColor');
            set(handles.hvec,'Visible','on')
            set(handles.hvec,'Color',clr)
            if isfield(handles,'hrvec') && get(handles.popupmenu_RefVecLocation,'Value')>1
                set(handles.hrvec,'Visible','on')
                set(handles.hrvec,'Color',clr)
                set(handles.hrveclabel,'Visible','on')
                set(handles.hrveclabel,'Color',clr)
            end
        otherwise %selected off
            set(handles.hvec,'Visible','off')
            if isfield(handles,'hrvec') && get(handles.popupmenu_RefVecLocation,'Value')>1
                set(handles.hrvec,'Visible','off')
                set(handles.hrveclabel,'Visible','off')
            end
    end
end

% --- Executes on button press in radiobutton_bins.
function radiobutton_bins_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_bins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobutton_bins
if isfield(handles,'hbins')
    if get(hObject,'Value'), %selected on
        set(handles.hbins,'Visible','on')
        set(handles.hbins,'Color',get(hObject,'ForegroundColor'))
    else
        set(handles.hbins,'Visible','off')
    end
end


% --- Executes on button press in radiobutton_beam.
function radiobutton_beam_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_beam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobutton_beam
if isfield(handles,'hbeam')
    if get(hObject,'Value'), %selected on
        set(handles.hbeam,'Visible','on')
        set(handles.hbeam,'Color',get(hObject,'ForegroundColor'))
    else
        set(handles.hbeam,'Visible','off')
    end
end


% --- Executes on button press in pushbutton_VectorColor.
function pushbutton_VectorColor_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_VectorColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hbut=handles.radiobutton_vectors;
c=uisetcolor(get(hbut,'ForegroundColor'),'Select Color for Vectors.');
set(hbut,'ForeGroundColor',c)
%vectors
if isfield(handles,'hvec'), %change vector color
    set(handles.hvec,'Color',c);
end
%reference vector
if isfield(handles,'hrvec'), %change ref.vector color
    set(handles.hrvec,'Color',c);
    set(handles.hrveclabel,'Color',c);
end



% --- Executes on button press in pushbutton_BinColor.
function pushbutton_BinColor_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_BinColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hbut=handles.radiobutton_bins;
c=uisetcolor(get(hbut,'ForegroundColor'),'Select Color for Vectors.');
set(hbut,'ForeGroundColor',c)
if isfield(handles,'hbins'), %change bin color
    set(handles.hbins,'Color',c);
end


% --- Executes on button press in pushbutton_LineColor.
function pushbutton_LineColor_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_LineColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hbut=handles.radiobutton_beam;
c=uisetcolor(get(hbut,'ForegroundColor'),'Select Color for Vectors.');
set(hbut,'ForeGroundColor',c)
if isfield(handles,'hbeam'), %change beam color
    set(handles.hbeam,'Color',c);
end


% --- Executes on selection change in popupmenu_RefVecLocation.
function popupmenu_RefVecLocation_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_RefVecLocation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns popupmenu_RefVecLocation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_RefVecLocation
I=get(hObject,'Value');
switch I
    case 1
        if isfield(handles,'hrvec') && ishandle(handles.hrvec)
            set([handles.hrvec,handles.hrveclabel],'Visible','off')
        end
        return
    otherwise
        if isfield(handles,'hrvec') && ishandle(handles.hrvec)
            set([handles.hrvec,handles.hrveclabel],'Visible','on')
        else
            return
        end
        update_ReferenceVector(handles)
end

% --- Executes during object creation, after setting all properties.
function popupmenu_RefVecLocation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_RefVecLocation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_RefVecLength_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RefVecLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_RefVecLength as text
%        str2double(get(hObject,'String')) returns contents of edit_RefVecLength as a double

%check that input is a valid number
if isnan(str2double(get(hObject,'String'))),%restore last good value
    set(hObject,'String',get(hObject,'UserData')) 
    errordlg('Invalid numeric entry. Reset to last valid entry.')
    return
else  %store entry in UserData
    set(hObject,'UserData',get(hObject,'String'))
end
%check reference vector information
I=get(handles.popupmenu_RefVecLocation,'Value');
switch I
    case 1
        return
    otherwise
        if ~isfield(handles,'hrvec') || ~ishandle(handles.hrvec)
            return
        end
        update_ReferenceVector(handles)
end


% --- Executes during object creation, after setting all properties.
function edit_RefVecLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_RefVecLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'UserData',get(hObject,'String'))

function edit_RefVecScale_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RefVecScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_RefVecScale as text
%        str2double(get(hObject,'String')) returns contents of edit_RefVecScale as a double

%check that input is a valid number
if isnan(str2double(get(hObject,'String'))),%restore last good value
    set(hObject,'String',get(hObject,'UserData')) 
    errordlg('Invalid numeric entry. Reset to last valid entry.')
    return
else  %store entry in UserData
    set(hObject,'UserData',get(hObject,'String'))
end
%check reference vector information
I=get(handles.popupmenu_RefVecLocation,'Value');
switch I
    case 1
        return
    otherwise
        if ~isfield(handles,'hrvec') || ~ishandle(handles.hrvec)
            return
        end
        update_ReferenceVector(handles)
end


% --- Executes during object creation, after setting all properties.
function edit_RefVecScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_RefVecScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'UserData',get(hObject,'String'))


% --- Executes on button press in togglebutton_Zoom.
function togglebutton_Zoom_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_Zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value'), %zoom on
    hPan=handles.togglebutton_Pan;
    if get(hPan,'Value'),
        set(hPan,'Value',0)
        pan off
    end
    zoom on
    hZoom=zoom(gcf);
    set(hZoom,...
        'RightClickAction','InverseZoom',...
        'ActionPostCallback',@zoompan_postcallback);
    setAxesZoomMotion(hZoom,handles.axes_Tide,'horizontal')
    setAxesZoomMotion(hZoom,handles.axes_Velocity,'both')
%    set(hObject,'UserData',hZoom)
else %zoom off
    zoom off
end

% --- Executes on button press in togglebutton_Pan.
function togglebutton_Pan_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_Pan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value'), %pan on
    hZoom=handles.togglebutton_Zoom;
    if get(hZoom,'Value'),
        set(hZoom,'Value',0)
        zoom off
    end
    pan on
    hPan=pan(gcf);
    set(hPan,'ActionPostCallback',@zoompan_postcallback)
    setAxesPanMotion(hPan,handles.axes_Tide,'horizontal')
    setAxesPanMotion(hPan,handles.axes_Velocity,'both')
else %pan off
    pan off
end


% --- Executes on slider movement.
function slider_DateTime_Callback(hObject, eventdata, handles)
% hObject    handle to slider_DateTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
I=round(get(hObject,'Value'));
set(hObject,'Value',I)
%update tide bubble
update_TideBubble(handles.htide,handles.adcp.time(I),handles.adcp.tide(I))
%update edit text window
set(handles.edit_DateTime,'String',datestr(handles.adcp.time(I),0))
%update Velocity Vectors
update_Velocity(handles,I)


% --- Executes during object creation, after setting all properties.
function slider_DateTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_DateTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit_DateTime_Callback(hObject, eventdata, handles)
% hObject    handle to edit_DateTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_DateTime as text
%        str2double(get(hObject,'String')) returns contents of edit_DateTime as a double

% parse string & check for errors
datstr=get(hObject,'String');
try
    time=datenum(datstr);
catch
    I=get(handles.slider_DateTime,'Value');
    set(hObject,'String',datestr(handles.adcp.time(I),0))
    errordlg({sprintf('Invalid date specifier: %s',datstr);...
        'Try again.'})
    return
end
% restrict limits of time
tlim=handles.adcp.time([1,end]);
time=max(min(time,tlim(2)),tlim(1));
% interpolate to closest ensemble
I=interp1(handles.adcp.time,1:length(handles.adcp.time),time,'nearest');
% set value of slider
set(handles.slider_DateTime,'Value',I)
% set value of text box to nearest ensemble
set(hObject,'String',datestr(handles.adcp.time(I),0))
% update tide bubble
update_TideBubble(handles.htide,handles.adcp.time(I),handles.adcp.tide(I))
%update velocity axis
update_Velocity(handles,I)

% --- Executes during object creation, after setting all properties.
function edit_DateTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_DateTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Menu_OpenFile_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_OpenFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%get file
[fn,pn]=uigetfile('*.mat','Select side-looking ADCP file.');
if isnumeric(fn),
    return
end
fn=fullfile(pn,fn);
load(fn);
%check file
if ~exist('adcp','var') || ~strcmp('horizontal',adcp.type),
    errordlg('Not a valid side-looking ADCP.mat file.  Try again.');
    return
end
%Store adcp struct in GUIDATA struct handles.adcp
handles.adcp=adcp;
handles.adcp.selected=true(size(adcp.bins));
nt=size(adcp.time,1);
%update date/time slider
set(handles.slider_DateTime,...
    'Enable','on',...
    'Min',1,...
    'Max',nt,...
    'SliderStep',[1,10]/(nt-1),...
    'Value',1)
%update date/time text edit object
set(handles.edit_DateTime,...
    'Enable','on',...
    'String',datestr(adcp.time(1),0));
%plot tide
axes(handles.axes_Tide)
cla
plot(adcp.time,adcp.tide,'b');
xlm=get(gca,'XLim');
ylm=get(gca,'YLim');
handles.nametxt=text(xlm(2),ylm(2),adcp.name,...
    'HorizontalAlignment','right',...
    'VerticalAlignment','top',...
    'FontWeight','bold');
handles.htide=line(adcp.time(1),adcp.tide(1),...
    'Color','b',...
    'Marker','o',...
    'MarkerFaceColor','b',...
    'LineStyle','none');
xlabel('time')
datetick('x','keeplimits')
ylabel('depth [m]')
%Plot velocity vectors...
if isfield(handles,'hvec')
    delete([handles.hsta,handles.hvec,handles.hbins,handles.hbeam,...
        handles.hrvec,handles.hrveclabel])
    handles=rmfield(handles,{'hsta','hvec','hbins','hbeam','hrvec','hrveclabel'});
end
update_Velocity(handles,1);
handles=guidata(hObject);
%FIXME: Set station name in velocity axis
% set(handles.hvname,'String',{'Station';handles.adcp.name})
% Enable Select Bins button
set([handles.pushbutton_SelectBins,handles.text_SelectBins],...
    'Enable','on')

% --------------------------------------------------------------------
function Cmenu_SliderProperties_Callback(hObject, eventdata, handles)
% hObject    handle to Cmenu_SliderProperties (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%check to see if data has been loaded
if ~isfield(handles,'adcp'),
    errordlg('Must have a dataset loaded before changing Slider Properties.')
end
smin=get(handles.slider_DateTime,'Min');
smax=get(handles.slider_DateTime,'Max');
sstep=get(handles.slider_DateTime,'SliderStep');
srng=smax-smin;
ensint=median(diff(handles.adcp.time));
prompt={sprintf('Ensemble Interval is %s (min:sec)\nSpecify number of ensembles to advance per arrow-click.',datestr(ensint,'MM:SS'));...
    'Specify number of ensembles to advance per trough-click.'};
default={num2str(sstep(1)*srng),num2str(sstep(2)*srng)};
answer=inputdlg(prompt,'Slider Properties',1,default);
if isempty(answer),return,end
sstep=[str2double(answer{1}),str2double(answer{2})]/srng;
% reset slider properties
set(handles.slider_DateTime,'SliderStep',sstep);
   

% --- Executes on button press in pushbutton_VelAxisBounds.
function pushbutton_VelAxisBounds_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_VelAxisBounds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
card=lower(get(hObject,'String'));
f=str2double(get(handles.edit_BoundsFactor,'String'));
switch card
    case 'decrease'
        f=1/f;
end
ax=handles.axes_Velocity;
xlm=get(ax,'XLim');
ylm=get(ax,'YLim');
xc=mean(xlm);
yc=mean(ylm);
xrng=diff(xlm);
yrng=diff(ylm);
a.XLim=xc+0.5*f*xrng*[-1,1];
a.YLim=yc+0.5*f*yrng*[-1,1];
set(ax,a)


function edit_BoundsFactor_Callback(hObject, eventdata, handles)
% hObject    handle to edit_BoundsFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_BoundsFactor as text
%        str2double(get(hObject,'String')) returns contents of edit_BoundsFactor as a double

%check that input is a valid number
if isnan(str2double(get(hObject,'String'))),%restore last good value
    set(hObject,'String',get(hObject,'UserData')) 
    errordlg('Invalid numeric entry. Reset to last valid entry.')
    return
else  %store entry in UserData
    set(hObject,'UserData',get(hObject,'String'))
end


% --- Executes during object creation, after setting all properties.
function edit_BoundsFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_BoundsFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'UserData',get(hObject,'String'))

% --- Executes when selected object is changed in uipanel_IncreaseDecrease.
function uipanel_IncreaseDecrease_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_IncreaseDecrease 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=get(hObject,'String');
set(handles.pushbutton_VelAxisBounds,...
    'String',[upper(str(1)),str(2:end)])


% --- Executes on button press in pushbutton_Reset.
function pushbutton_Reset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% zoom reset


%%%%%%%%%  Internal Functions %%%%%%%%%%%
function update_TideBubble(h,time,tide)
% internal function to update tide bubble position
set(h,...
    'XData',time,...
    'YData',tide)

function update_Velocity(handles,I)
% internal function to update velocity information in velocity axis
% I = ensemble index to plot
%create velocity filters
in1=handles.adcp.selected(:); %Bins selected
% corrTH=str2double(get(handles.edit_CorrThreshold,'String'));
% in2=handles.adcp.corr(I,:)'>=corrTH; %meets correlation threshold
% in3=true(size(in1));
% if get(handles.checkbox_SurfaceCheck,'Value'),
%     sindx=find(diff(handles.adcp.ss(I,:))>=0,1,'first');
%     if ~isempty(sindx)
%         in3(sindx+1:end)=false;
%     end
% end
% in=all([in1,in2,in3],2);
in=in1;
%get velocity scaling
s=1e-2*str2double(get(handles.edit_RefVecScale,'String'));
%retrieve velocities
u=handles.adcp.u(I,:);
v=handles.adcp.v(I,:);
%assign bins not meeting filters to NaN
u(~in)=NaN;
v(~in)=NaN;
axes(handles.axes_Velocity)
%if velocity object doesn't exist, create all
if ~isfield(handles,'hvec'), 
    set(gca,'XLimMode','auto','YLimMode','auto',...
        'NextPlot','replacechildren')
    nbins=length(handles.adcp.bins);
    R=handles.adcp.blank+(handles.adcp.bins-0.5)*handles.adcp.dx;
    handles.adcp.R=R;
    TH=mean(handles.adcp.heading)+handles.adcp.hdgcorr;
    [y,x]=pol2cart(TH*pi/180,R);
    handles.hsta=plot(0,0,'rp',...
        'Clipping','off',...
        'HandleVisibility','off'); %adcp location
    handles.hvec=quiver(x,y,u,v,0,...
        'LineWidth',2,...
        'HandleVisibility','off');
    %determine bin positions and plot
    bvec=[x(end),y(end)]/R(end); %beam vector
    bvec2=repmat(bvec'*handles.adcp.dx/2,1,nbins+1);
    bvec2(:,end)=-bvec2(:,end); %end bin boundary
    nvec=repmat((bvec*[0,1;-1,0])',1,nbins+1); %normal vector
    xbin=zeros(2,3*(nbins+1));
    xbin(:,1:3:3*(nbins+1))=[x,x(end);y,y(end)]-bvec2-nvec;
    xbin(:,2:3:3*(nbins+1))=[x,x(end);y,y(end)]-bvec2+nvec;
    xbin(:,3:3:3*(nbins+1))=NaN;    
    handles.hbins=line(xbin(1,:),xbin(2,:),...
        'Marker','none',...
        'LineStyle',':',...
        'HandleVisibility','off');
    %plot beam line
    handles.hbeam=line([0,x],[0,y],...
        'LineStyle','--',...
        'Marker','.',...
        'HandleVisibility','off');
    axis equal
    set(gca,'XLimMode','manual',...
        'YLimMode','manual',...
        'ActivePositionProperty','outerposition',...
        'DataAspectRatio',[1,1,1],...
        'PlotBoxAspectRatio',[50,60,1])
    xlabel('east distance [m]')
    ylabel('north distance [m]')
    %set visibile parameter based on GUI settings
    radiobutton_vectors_Callback(handles.radiobutton_vectors,[],handles)
    radiobutton_bins_Callback(handles.radiobutton_bins,[],handles)
    radiobutton_beam_Callback(handles.radiobutton_beam,[],handles)
    %create reference vector
    update_ReferenceVector(handles)
    handles=guidata(handles.axes_Velocity);
    %save GUIDATA
    guidata(handles.axes_Velocity, handles);
end
%replace data with appropriate scale
set(handles.hvec,'UData',s*u,'VData',s*v)

% --- Creates/Updates Reference Vector ---
function update_ReferenceVector(handles)
rmag=str2double(get(handles.edit_RefVecLength,'String'));
rscale=str2double(get(handles.edit_RefVecScale,'String'));
I=get(handles.popupmenu_RefVecLocation,'Value');
str=get(handles.popupmenu_RefVecLocation,'String');
card=str{I};
ax=handles.axes_Velocity;
xlm=get(ax,'XLim');
ylm=get(ax,'YLim');
vlen=rmag*1e-2*rscale;
switch card
    case 'upper-left'
        a.x=xlm(1)+0.02*diff(xlm);
        a.y=ylm(2)-0.02*diff(ylm);
        a.HorizontalAlignment='left';
        a.VerticalAlignment='top';
        v.x=a.x;
        v.y=a.y-0.02*diff(ylm);
    case 'upper-right'
        a.x=xlm(2)-0.02*diff(xlm)-vlen;
        a.y=ylm(2)-0.02*diff(ylm);
        a.HorizontalAlignment='left';
        a.VerticalAlignment='top';
        v.x=a.x;
        v.y=a.y-0.02*diff(ylm);
    case 'lower-left'
        a.x=xlm(1)+0.02*diff(xlm);
        a.y=ylm(1)+0.02*diff(ylm);
        a.HorizontalAlignment='left';
        a.VerticalAlignment='bottom';
        v.x=a.x;
        v.y=a.y+0.02*diff(ylm);
    case 'lower-right'
        a.x=xlm(2)-0.02*diff(xlm)-vlen;
        a.y=ylm(1)+0.02*diff(ylm);
        a.HorizontalAlignment='left';
        a.VerticalAlignment='bottom';
        v.x=a.x;
        v.y=a.y+0.02*diff(ylm);
end
if ~isfield(handles,'hrvec') || ~ishandle(handles.hrvec),
    %draw ref.vec and label
    handles.hrvec=quiver(v.x,v.y,vlen,0,0,...
        'Color',get(handles.hvec,'Color'),...
        'LineWidth',get(handles.hvec,'LineWidth'));
    handles.hrveclabel=text(a.x,a.y,sprintf('%g cms',rmag),...
        'Color',get(handles.hvec,'Color'),...
        'FontSize',9,...
        'FontWeight','bold');
    guidata(handles.axes_Velocity,handles)
else
    set(handles.hrvec,'XData',v.x,...
        'YData',v.y,...
        'UData',vlen)
    set(handles.hrveclabel,'Position',[a.x,a.y],...
        'String',sprintf('%g cms',rmag))
end
    
    


% --- Executes on button press in togglebutton_TideGrid.
function togglebutton_TideGrid_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_TideGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of togglebutton_TideGrid
if get(hObject,'Value')
    set(handles.axes_Tide,'XGrid','on','YGrid','on')
else
    set(handles.axes_Tide,'XGrid','off','YGrid','off')
end

% --- Executes on button press in togglebutton_VelocityGrid.
function togglebutton_VelocityGrid_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_VelocityGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(handles.axes_Velocity,'XGrid','on','YGrid','on')
else
    set(handles.axes_Velocity,'XGrid','off','YGrid','off')
end

% Hint: get(hObject,'Value') returns toggle state of togglebutton_VelocityGrid

function zoompan_postcallback(obj,evd)
% function to reset time-axis limits after zoom or pan action
handles=guidata(get(evd.Axes,'Parent'));
xlm=get(evd.Axes,'XLim');
ylm=get(evd.Axes,'YLim');
switch evd.Axes
    case handles.axes_Tide
        datetick('x','keeplimits')
        set(handles.nametxt,'Position',[xlm(2),ylm(2),0]);
    case handles.axes_Velocity
        update_ReferenceVector(handles)
end


% --------------------------------------------------------------------
function menu_Print_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Print (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

printpreview


% --------------------------------------------------------------------
function menu_Export_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exportsetupdlg

% --------------------------------------------------------------------
function menu_PageSetup_Callback(hObject, eventdata, handles)
% hObject    handle to menu_PageSetup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pagesetupdlg


% --------------------------------------------------------------------
function menu_CreateAVI_Callback(hObject, eventdata, handles)
% hObject    handle to menu_CreateAVI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tlim=get(handles.axes_Tide,'XLim');
Prompt={'Start Date/Time',...
    'End Date/Time',...
    'Ensemble Interval',...
    'Quality (1-100)',...
    'Frame Rate (fps)'};
defAns={datestr(tlim(1),0),datestr(tlim(2),0),'1','75','10'};
ierr=true;
opts.WindowStyle='modal';
opts.Interpreter='none';
while ierr
    Ans=inputdlg(Prompt,'Create AVI.',1,defAns);
    if isempty(Ans),return,end
    ierr=false;
    %check inputs
    try
        t1=datenum(Ans{1});
        t2=datenum(Ans{2});
        ensint=str2double(Ans{3});
        quality=str2double(Ans{4});
        framerate=str2double(Ans{5});
    catch
        ierr=true;
        s=lasterror;
        switch s.identifier
            case 'MATLAB:datenum:ConvertDateString'
                h=errordlg({'Invalid Date Specifier.',...
                    'Check format of starting and ending date/time.'},...
                    ' ',...
                    opts);
                uiwait(h)
                defAns=Ans;
                continue
            otherwise
                h=errordlg({'Unclassified error...',...
                    s.identifier},...
                    ' ',opts);
                uiwait(h)
                continue
        end %switch
    end  %try
    %find ensembles between specified times
    I=find(handles.adcp.time>=t1 & handles.adcp.time<=t2);
    %finish error checking...
    if ensint~=round(ensint) || ensint<1,
        ierr=true;
        h=errordlg({'Ensemble interval must be integer >= 1.',...
            'Check ensemble interval.'},...
            ' ',opts);
        uiwait(h)
        defAns=Ans;
        continue
    elseif t1>t2,
        ierr=true;
        h=errordlg({'Ending date before starting date.',...
            'Check specified times.'},...
            ' ',opts);
        uiwait(h)
        defAns=Ans;
        continue
    elseif length(I)<2,
        ierr=true;
        h=errordlg({'Not enough ensembles found to create movie.',...
            sprintf('%g ensembles found between %s and %s.',length(I),datestr(t1),datestr(t2))},...
            ' ',opts);
        uiwait(h)
        defAns=Ans;
        continue
    elseif quality>100 || quality <1
        ierr=true;
        h=errordlg({'Quality must be between 1 and 100',...
            'Check specified quality.'},...
            ' ',opts);
        uiwait(h)
        defAns=Ans;
        continue
    end

end %while
[fn,pn]=uiputfile('*.avi','Specify filename to save movie loop.');
if isnumeric(fn),return,end

%create avifile
aviobj=avifile(fullfile(pn,fn),...
    'fps',framerate,...
    'quality',quality);
NI=length(I);
titlestr=get(handles.figure1,'Name');
fprev=-1;
for k=1:ensint:NI,
    f=round(k/NI*100);
    if f>fprev,
        str=sprintf('Creating AVI. %g%% complete.',f);
        set(handles.figure1,'Name',str)
    end
    set(handles.slider_DateTime,'Value',I(k))
    %update tide bubble
    update_TideBubble(handles.htide,handles.adcp.time(I(k)),handles.adcp.tide(I(k)))
    %update edit text window
    set(handles.edit_DateTime,'String',datestr(handles.adcp.time(I(k)),0))
    %update Velocity Vectors
    update_Velocity(handles,I(k))
    F=getframe(handles.figure1);
    aviobj=addframe(aviobj,F);
end
set(handles.figure1,'Name',titlestr);
aviobj=close(aviobj);



% --------------------------------------------------------------------
function menu_ExportPNG_Callback(hObject, eventdata, handles)
% hObject    handle to menu_ExportPNG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tvec=datevec(get(handles.edit_DateTime,'String'));
isp=isspace(handles.adcp.name);
tname=sprintf('%s_%02.0f%02.0f%02.0f_%02.0f%02.0f%02.0f.png',handles.adcp.name(~isp),tvec);
[fn,pn]=uiputfile('*.png','Specify filename of exported graphic.',tname);
if isnumeric(fn)
    return
else
    print('-dpng',fullfile(pn,fn))
end


% --------------------------------------------------------------------
function menu_CopyClipboard_Callback(hObject, eventdata, handles)
% hObject    handle to menu_CopyClipboard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

print('-dmeta')
