function varargout = curview_bm(varargin)
% CURVIEW_BM M-file for curview_bm.fig
%      CURVIEW_BM, by itself, creates a new CURVIEW_BM or raises the existing
%      singleton*.
%
%      H = CURVIEW_BM returns the handle to a new CURVIEW_BM or the handle to
%      the existing singleton*.
%
%      CURVIEW_BM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CURVIEW_BM.M with the given input arguments.
%
%      CURVIEW_BM('Property','Value',...) creates a new CURVIEW_BM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before curview_bm_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to curview_bm_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help curview_bm

% Last Modified by GUIDE v2.5 23-Sep-2008 20:48:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @curview_bm_OpeningFcn, ...
                   'gui_OutputFcn',  @curview_bm_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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


% --- Executes just before curview_bm is made visible.
function curview_bm_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to curview_bm (see VARARGIN)

% Choose default command line output for curview_bm
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
%initialize velocity grid
create_VelocityGrid(hObject,handles)

% UIWAIT makes curview_bm wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = curview_bm_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


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


% --- Executes on button press in pushbutton_SelectBins.
function pushbutton_SelectBins_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_SelectBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
indx=handles.adcp.bins';
z=handles.adcp.z';
Strs=cellstr(num2str([indx,z],'Bin%02.0f, depth=%4.1f m'));
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
if isfield(handles,'adcp'), %if velocity data exists
    I=get(handles.slider_DateTime,'Value');
    update_Velocity(handles,I);
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
%store default value in UserData
set(hObject,'UserData',get(hObject,'String'))


% --- Executes on button press in checkbox_SurfaceCheck.
function checkbox_SurfaceCheck_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_SurfaceCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_SurfaceCheck
if isfield(handles,'adcp'), %if velocity data exists
    I=get(handles.slider_DateTime,'Value');
    update_Velocity(handles,I);
end

% --- Executes on button press in radiobutton_vectors.
function radiobutton_vectors_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_vectors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_vectors
if isfield(handles,'hvec')
    if get(hObject,'Value'), %selected on
        set(handles.hvec,'Visible','on')
        set(handles.hvec,'Color',get(hObject,'ForegroundColor'))
    else
        set(handles.hvec,'Visible','off')
    end
end
% --- Executes on button press in radiobutton_stems.
function radiobutton_stems_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_stems (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_stems
if isfield(handles,'hstem')
    if get(hObject,'Value'), %selected on
        set(handles.hstem,'Visible','on')
        set(handles.hstem,'Color',get(hObject,'ForegroundColor'))
    else
        set(handles.hstem,'Visible','off')
    end
end


% --- Executes on button press in radiobutton_lines.
function radiobutton_lines_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_lines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_lines
if isfield(handles,'hline')
    if get(hObject,'Value'), %selected on
        set(handles.hline,'Visible','on')
        set(handles.hline,'Color',get(hObject,'ForegroundColor'))
    else
        set(handles.hline,'Visible','off')
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
if isfield(handles,'hvec'), %change vector color
    set(handles.hvec,'Color',c);
end

% --- Executes on button press in pushbutton_StemColor.
function pushbutton_StemColor_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_StemColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hbut=handles.radiobutton_stems;
c=uisetcolor(get(hbut,'ForegroundColor'),'Select Color for Vectors.');
set(hbut,'ForeGroundColor',c)
if isfield(handles,'hstem'), %change stem color
    set(handles.hstem,'Color',c);
end


% --- Executes on button press in pushbutton_LineColor.
function pushbutton_LineColor_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_LineColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hbut=handles.radiobutton_lines;
c=uisetcolor(get(hbut,'ForegroundColor'),'Select Color for Vectors.');
set(hbut,'ForeGroundColor',c)
if isfield(handles,'hline'), %change line color
    set(handles.hline,'Color',c);
end

% --- Executes on button press in pushbutton_viewLeft.
function pushbutton_viewLeft_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_viewLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[az,el]=view(handles.axes_Velocity);
view(handles.axes_Velocity,az-10,el);

% --- Executes on button press in pushbutton_viewRight.
function pushbutton_viewRight_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_viewRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[az,el]=view(handles.axes_Velocity);
view(handles.axes_Velocity,az+10,el);


% --- Executes on button press in pushbutton_viewDefault.
function pushbutton_viewDefault_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_viewDefault (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
view(handles.axes_Velocity,3)


% --- Executes on button press in pushbutton_viewDown.
function pushbutton_viewDown_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_viewDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[az,el]=view(handles.axes_Velocity);
view(handles.axes_Velocity,az,el-10);


% --- Executes on button press in pushbutton_viewUp.
function pushbutton_viewUp_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_viewUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[az,el]=view(handles.axes_Velocity);
view(handles.axes_Velocity,az,el+10);


function edit_MaxCurrent_Callback(hObject, eventdata, handles)
% hObject    handle to edit_MaxCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_MaxCurrent as text
%        str2double(get(hObject,'String')) returns contents of edit_MaxCurrent as a double

%check that input is a valid number
if isnan(str2double(get(hObject,'String'))),%restore last good value
    set(hObject,'String',get(hObject,'UserData')) 
    errordlg('Invalid numeric entry. Reset to last valid entry.')
    return
else  %store entry in UserData
    set(hObject,'UserData',get(hObject,'String'))
end

create_VelocityGrid(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit_MaxCurrent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_MaxCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%store default value in UserData
set(hObject,'UserData',get(hObject,'String'))


function edit_TickSpacing_Callback(hObject, eventdata, handles)
% hObject    handle to edit_TickSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_TickSpacing as text
%        str2double(get(hObject,'String')) returns contents of edit_TickSpacing as a double

%check that input is a valid number
if isnan(str2double(get(hObject,'String'))),%restore last good value
    set(hObject,'String',get(hObject,'UserData')) 
    errordlg('Invalid numeric entry. Reset to last valid entry.')
    return
else  %store entry in UserData
    set(hObject,'UserData',get(hObject,'String'))
end

create_VelocityGrid(hObject,handles)


% --- Executes during object creation, after setting all properties.
function edit_TickSpacing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_TickSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%store default value in UserData
set(hObject,'UserData',get(hObject,'String'))



function edit_AngleSpacing_Callback(hObject, eventdata, handles)
% hObject    handle to edit_AngleSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_AngleSpacing as text
%        str2double(get(hObject,'String')) returns contents of edit_AngleSpacing as a double

%check that input is a valid number
if isnan(str2double(get(hObject,'String'))),%restore last good value
    set(hObject,'String',get(hObject,'UserData')) 
    errordlg('Invalid numeric entry. Reset to last valid entry.')
    return
else  %store entry in UserData
    set(hObject,'UserData',get(hObject,'String'))
end

create_VelocityGrid(hObject,handles)


% --- Executes during object creation, after setting all properties.
function edit_AngleSpacing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_AngleSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%store default value in UserData
set(hObject,'UserData',get(hObject,'String'))

function edit_Depth_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Depth as text
%        str2double(get(hObject,'String')) returns contents of edit_Depth as a double

%check that input is a valid number
if isnan(str2double(get(hObject,'String'))),%restore last good value
    set(hObject,'String',get(hObject,'UserData')) 
    errordlg('Invalid numeric entry. Reset to last valid entry.')
    return
else  %store entry in UserData
    set(hObject,'UserData',get(hObject,'String'))
end

create_VelocityGrid(hObject,handles)


% --- Executes during object creation, after setting all properties.
function edit_Depth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%store default value in UserData
set(hObject,'UserData',get(hObject,'String'))





% --- Executes on button press in checkbox_MaxDepth.
function checkbox_MaxDepth_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_MaxDepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_MaxDepth
if get(hObject,'Value'), %use max elevation from adcp data
    set([handles.edit_Depth,handles.text_Depth],'Enable','off')
    if isfield(handles,'adcp'), 
        %store old value in userdata
        set(handles.edit_Depth,'UserData',get(handles.edit_Depth,'String'))
        %retrieve new value from adcp struct
        set(handles.edit_Depth,'String',sprintf('%g',max(handles.adcp.z)))
    end
else %use user-specified depth
    set([handles.edit_Depth,handles.text_Depth],'Enable','on')
    if ~isempty(get(handles.edit_Depth,'UserData')),
        %restore previous value
        set(handles.edit_Depth,'String',get(handles.edit_Depth,'UserData'))
    end
end    
%reset the z-limits on velocity axis
create_VelocityGrid(hObject,handles)

% --------------------------------------------------------------------
function Menu_OpenFile_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_OpenFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get file
[fn,pn]=uigetfile('*.mat','Select Bottom- or Surface-mounted ADCP file.');
if isnumeric(fn),
    return
end
fn=fullfile(pn,fn);
load(fn);
%check file
if ~exist('adcp','var') || ...
      ~(strcmp('bottom',adcp.type) || strcmp('surface',adcp.type)),
    errordlg('Not a valid ADCP.mat file.  Try again.');
    return
end
%Store adcp struct in GUIDATA struct handles.adcp
handles.adcp=adcp;
handles.adcp.selected=true(size(adcp.z));
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
    'Interpreter','none',...
    'FontWeight','bold');
handles.htide=line(adcp.time(1),adcp.tide(1),...
    'Color','b',...
    'Marker','o',...
    'MarkerFaceColor','b',...
    'LineStyle','none');
xlabel('time')
datetick('x','keepticks')
ylabel('tide (m)')
%Plot velocity vectors...
if isfield(handles,'hvec')
    delete([handles.hvec,handles.hstem,handles.hline])
    handles=rmfield(handles,{'hvec','hstem','hline'});
end
update_Velocity(handles,1);
handles=guidata(hObject);
%Set station name in velocity axis
set(handles.hvname,'String',{'Station';handles.adcp.name})
%Set depth to max bin depth
if get(handles.checkbox_MaxDepth,'Value'),
    set(handles.edit_Depth,'String',sprintf('%g',max(adcp.z)))
    create_VelocityGrid(handles.axes_Velocity,handles)
end
% Enable Select Bins button
set([handles.pushbutton_SelectBins,handles.text_SelectBins],...
    'Enable','on')




% --------------------------------------------------------------------
function Menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function menu_Print_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Print (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printpreview

% --------------------------------------------------------------------
function menu_PageSetup_Callback(hObject, eventdata, handles)
% hObject    handle to menu_PageSetup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pagesetupdlg

% --------------------------------------------------------------------
function menu_Export_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exportsetupdlg

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
    %more error checking...
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
function Cmenu_slider_Callback(hObject, eventdata, handles)
% hObject    handle to Cmenu_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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

% --- Executes on button press in togglebutton_Zoom.
function togglebutton_Zoom_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_Zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of togglebutton_Zoom
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
    setAllowAxesZoom(hZoom,handles.axes_Velocity,0)
    setAxesZoomMotion(hZoom,handles.axes_Tide,'horizontal')
%    set(hObject,'UserData',hZoom)
else %zoom off
    zoom off
end



% --- Executes on button press in togglebutton_Pan.
function togglebutton_Pan_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_Pan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of togglebutton_Pan
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
    setAllowAxesPan(hPan,handles.axes_Velocity,0)
else %pan off
    pan off
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


%%%%%%%%%  Internal Functions %%%%%%%%%%%
function update_TideBubble(h,time,tide)
% internal function to update tide bubble position
set(h,...
    'XData',time,...
    'YData',tide)

function create_VelocityGrid(hObject,handles)
% internal function to create velocity grid and
% set initial settings for plotting 3-D currents
if isfield(handles,'hm') && ishandle(handles.hm),
    delete([handles.hm,handles.hh])
end
uvlim=str2double(get(handles.edit_MaxCurrent,'String'));
uvstep=str2double(get(handles.edit_TickSpacing,'String'));
angstep=str2double(get(handles.edit_AngleSpacing,'String'));
depth=str2double(get(handles.edit_Depth,'String'));
angtic=(0:angstep:360)*pi/180;
veltic=unique([0:uvstep:uvlim,uvlim]);
[a,b]=meshgrid(angtic,veltic);
[x,y]=pol2cart(a,b);
axes(handles.axes_Velocity)  %set current axes to velocity axis
[az,el]=view(handles.axes_Velocity); %get current viewing properties
set(gca,'ActivePositionProperty','outerposition',...
    'NextPlot','ReplaceChildren')
if ~isfield(handles,'hvname'),
    handles.hvname=text(1,1,' ',...
        'Units','normalized',...
        'Interpreter','none',...
        'HorizontalAlignment','right',...
        'VerticalAlignment','top',...
        'FontWeight','bold',...
        'HandleVisibility','off');
end
hm=mesh(x,y,zeros(size(x)));
set(hm,'EdgeColor',0.4*[1,1,1],'HandleVisibility','off');
axis([-uvlim uvlim -uvlim uvlim 0 depth])
axis square
axis vis3d
view(handles.axes_Velocity,az,el)
set(gca,'Projection','perspective','Box','off')
%draw vertical axis at instrument
hh(1)=line([0 0],[0 0],[0 depth],...
    'Color','k',...
    'LineWidth',1.5,...
    'HandleVisibility','off');
%draw lines defining quadrants and add North Indicator
hh(2)=line([0 0],[-uvlim uvlim],0.01*[1,1],...
    'Color','k',...
    'LineWidth',2.0,...
    'HandleVisibility','off');
hh(3)=line([-uvlim uvlim],[0 0],0.01*[1,1],...
    'Color','k',...
    'LineWidth',2.0,...
    'HandleVisibility','off');
hh(4)=text(0,uvlim,depth*.05,'N',...
    'FontSize',18,...
    'FontWeight','bold',...
    'HandleVisibility','off');
%create tick marks on vertical axis corresponding to axis ticks
ztic=get(gca,'ZTick');
zz=zeros(size(ztic));
hh(5)=line(zz,zz,ztic,...
    'LineStyle','none',...
    'Marker','+',...
    'LineWidth',1.5,...
    'Color','k',...
    'HandleVisibility','off');
%figure Title,axes labels, etc...
%title(['Site: ' site ', Deployment: ' deploy],'FontSize',30,'FontWeight','bold','HandleVisibility','off')
xlabel('u (cms)',...
    'Position',[0,-1.3*uvlim,0],...
    'HorizontalAlignment','Center',...
    'VerticalAlignment','Top',...
    'HandleVisibility','off');
ylabel('v (cms)',...
    'Position',[-1.3*uvlim,0,0],...
    'HorizontalAlignment','Center',...
    'VerticalAlignment','Top',...
    'HandleVisibility','off');
zlabel('Distance above bed (m)','HandleVisibility','off');
%store handles in handles struct and save guidata
handles.hm=hm;
handles.hh=hh;
guidata(hObject, handles);

function update_Velocity(handles,I)
% internal function to update velocity information in velocity axis
% I = ensemble index to plot
%create velocity filters
in1=handles.adcp.selected(:); %Bins selected
corrTH=str2double(get(handles.edit_CorrThreshold,'String'));
in2=handles.adcp.corr(I,:)'>=corrTH; %meets correlation threshold
in3=true(size(in1));
if get(handles.checkbox_SurfaceCheck,'Value'),
   switch lower(handles.adcp.type)
      case 'bottom'
         sindx=find(diff(handles.adcp.ss(I,:))>=0,1,'first');
         if ~isempty(sindx)
            in3(sindx+1:end)=false;
         end
      case 'surface'
         btdep=handles.adcp.bt_range(I);
         in3(btdep-handles.adcp.z<0)=false;
   end
end
in=all([in1,in2,in3],2);
%retrieve velocities
u=handles.adcp.u(I,:);
v=handles.adcp.v(I,:);
%assign bins not meeting filters to NaN
u(~in)=NaN;
v(~in)=NaN;
switch lower(handles.adcp.type)
   case 'bottom'
      z=handles.adcp.z;
   case 'surface'
      z=handles.adcp.bt_range(I)-handles.adcp.z;
end
zz=zeros(size(u));
axes(handles.axes_Velocity)
%if velocity object doesn't exist, create all
if ~isfield(handles,'hvec'), 
    handles.hvec=quiver3(zz,zz,z,u,v,zz,0,...
        'LineWidth',2,...
        'HandleVisibility','off');
    handles.hstem=stem3(u,v,z,'Marker','none','HandleVisibility','off');
    handles.hline=line(u,v,z,'LineStyle','--','HandleVisibility','off');
    %set visibile parameter based on GUI settings
    radiobutton_vectors_Callback(handles.radiobutton_vectors,[],handles)
    radiobutton_stems_Callback(handles.radiobutton_stems,[],handles)
    radiobutton_lines_Callback(handles.radiobutton_lines,[],handles)    
else %replace data
    set(handles.hvec,'UData',u,'VData',v,'ZData',z)
    set(handles.hstem,'XData',u,'YData',v,'ZData',z)
    set(handles.hline,'XData',u,'YData',v,'ZData',z)
end
set(gca,'Projection','perspective','Box','off')
%save GUIDATA
guidata(handles.axes_Velocity, handles);


function zoompan_postcallback(obj,evd)
% function to reset time-axis limits after zoom or pan action
handles=guidata(get(evd.Axes,'Parent'));
xlm=get(evd.Axes,'XLim');
ylm=get(evd.Axes,'YLim');
switch evd.Axes
    case handles.axes_Tide
        datetick('x','keeplimits')
        set(handles.nametxt,'Position',[xlm(2),ylm(2),0]);
end


