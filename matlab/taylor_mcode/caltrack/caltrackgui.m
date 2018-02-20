function varargout = caltrackgui(varargin)
% CALTRACKGUI M-file for caltrackgui.fig
%      CALTRACKGUI, by itself, creates a new CALTRACKGUI or raises the existing
%      singleton*.
%
%      H = CALTRACKGUI returns the handle to a new CALTRACKGUI or the handle to
%      the existing singleton*.
%
%      CALTRACKGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALTRACKGUI.M with the given input arguments.
%
%      CALTRACKGUI('Property','Value',...) creates a new CALTRACKGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before caltrackgui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to caltrackgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help caltrackgui

% Last Modified by GUIDE v2.5 13-Nov-2007 08:31:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @caltrackgui_OpeningFcn, ...
                   'gui_OutputFcn',  @caltrackgui_OutputFcn, ...
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


% --- Executes just before caltrackgui is made visible.
function caltrackgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to caltrackgui (see VARARGIN)

% Choose default command line output for caltrackgui
handles.output = hObject;

% Assign appdata
a.gui=true;
a.ax=handles.axes1;
set(a.ax,'XTick',[],...
   'YTick',[],...
   'ActivePositionProperty','outerposition',...   
   'PlotBoxAspectRatioMode','manual',...
   'DataAspectRatioMode','manual',...
   'NextPlot','add');
a.hstxt=handles.text_Status;
set(a.hstxt,...
   'FontName','System',...
   'HorizontalAlignment','left',...
   'FontSize',10);
a.dn=str2double(get(handles.edit_ADCPavg,'String'));
a.vscale=str2double(get(handles.edit_RefVecScale,'String'));
a.vlen=str2double(get(handles.edit_RefVecMag,'String'));
a.adcircnew=true;
a=caltrack(a);
setappdata(handles.figure1,'a',a)
set(handles.pushbuttonADCIRC,'Enable','on')
set(handles.edit_DateTime,'String',datestr(a.adcirctime(1),0))
set(handles.slider_DateTime,...
   'Value',1,...
   'Min',1,...
   'Max',a.adcircnt,...
   'SliderStep',1/(a.adcircnt-1)*[1,4])

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes caltrackgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = caltrackgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in radiobuttonADCIRCvectors.
function radiobuttonADCIRCvectors_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonADCIRCvectors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobuttonADCIRCvectors
a=getappdata(handles.figure1,'a');
if get(hObject,'Value')
   set(a.hq,'Visible','on')
else
   set(a.hq,'Visible','off')
end

% --- Executes on button press in radiobuttonADCIRCbnds.
function radiobuttonADCIRCbnds_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonADCIRCbnds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobuttonADCIRCbnds
a=getappdata(handles.figure1,'a');
if get(hObject,'Value')
   set([a.hbndopen;a.hbndland],'Visible','on')
else
   set([a.hbndopen;a.hbndland],'Visible','off')
end

% --- Executes on button press in radiobuttonADCPvectors.
function radiobuttonADCPvectors_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonADCPvectors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobuttonADCPvectors
a=getappdata(handles.figure1,'a');
if get(hObject,'Value')
   set(a.hqm,'Visible','on')
else
   set(a.hqm,'Visible','off')
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
%call caltrack
a=getappdata(handles.figure1,'a');
a.timestamp=I;
a=caltrack(a);
setappdata(handles.figure1,'a',a);
%update edit text window
set(handles.edit_DateTime,'String',datestr(a.adcirctime(I),0))

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
datstr=get(hObject,'String');
a=getappdata(handles.figure1,'a');
try
    time=datenum(datstr);
catch
    I=get(handles.slider_DateTime,'Value');
    set(hObject,'String',datestr(a.adcirctime(I),0))
    errordlg({sprintf('Invalid date specifier: %s',datstr);...
        'Try again.'})
    return
end
% restrict limits of time
tlim=a.adcirctime([1,end]);
time=max(min(time,tlim(2)),tlim(1));
% interpolate to closest ensemble
I=interp1(a.adcirctime,1:a.adcircnt,time,'nearest');
% set value of slider
set(handles.slider_DateTime,'Value',I)
% set value of text box to nearest ensemble
set(hObject,'String',datestr(a.adcirctime(I),0))
% call caltrack
a.timestamp=I;
a=caltrack(a);
setappdata(handles.figure1,'a',a)

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



function edit_RefVecMag_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RefVecMag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_RefVecMag as text
%        str2double(get(hObject,'String')) returns contents of edit_RefVecMag as a double
if isnan(str2double(get(hObject,'String'))),%restore last good value
    set(hObject,'String',get(hObject,'UserData')) 
    errordlg('Invalid numeric entry. Reset to last valid entry.')
    return
else  %store entry in UserData
    set(hObject,'UserData',get(hObject,'String'))
end
a=getappdata(handles.figure1,'a');
a.vlen=str2double(get(hObject,'String'));
a=caltrack(a);
setappdata(handles.figure1,'a',a);


% --- Executes during object creation, after setting all properties.
function edit_RefVecMag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_RefVecMag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%store default value in UserData
set(hObject,'UserData',get(hObject,'String'))



function edit_RefVecScale_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RefVecScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_RefVecScale as text
%        str2double(get(hObject,'String')) returns contents of edit_RefVecScale as a double
if isnan(str2double(get(hObject,'String'))),%restore last good value
    set(hObject,'String',get(hObject,'UserData')) 
    errordlg('Invalid numeric entry. Reset to last valid entry.')
    return
else  %store entry in UserData
    set(hObject,'UserData',get(hObject,'String'))
end
a=getappdata(handles.figure1,'a');
a.vscale=str2double(get(hObject,'String'));
a=caltrack(a);
setappdata(handles.figure1,'a',a);


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
%store default value in UserData
set(hObject,'UserData',get(hObject,'String'))



function edit_ADCPavg_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ADCPavg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_ADCPavg as text
%        str2double(get(hObject,'String')) returns contents of edit_ADCPavg as a double
if isnan(str2double(get(hObject,'String'))),%restore last good value
    set(hObject,'String',get(hObject,'UserData')) 
    errordlg('Invalid numeric entry. Reset to last valid entry.')
    return
else  %store entry in UserData
    set(hObject,'UserData',get(hObject,'String'))
end
a=getappdata(handles.figure1,'a');
a.dn=str2double(get(hObject,'String'));
a=caltrack(a);
setappdata(handles.figure1,'a',a);

% --- Executes during object creation, after setting all properties.
function edit_ADCPavg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ADCPavg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%store default value in UserData
set(hObject,'UserData',get(hObject,'String'))

function edit_DecimateADCIRC_Callback(hObject, eventdata, handles)
% hObject    handle to edit_DecimateADCIRC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_DecimateADCIRC as text
%        str2double(get(hObject,'String')) returns contents of edit_DecimateADCIRC as a double
if isnan(str2double(get(hObject,'String'))),%restore last good value
    set(hObject,'String',get(hObject,'UserData')) 
    errordlg('Invalid numeric entry. Reset to last valid entry.')
    return
else  %store entry in UserData
    set(hObject,'UserData',get(hObject,'String'))
end
a=getappdata(handles.figure1,'a');
a.decADCIRC=str2double(get(hObject,'String'));
a=caltrack(a);
setappdata(handles.figure1,'a',a);


% --- Executes during object creation, after setting all properties.
function edit_DecimateADCIRC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_DecimateADCIRC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%store default value in UserData
set(hObject,'UserData',get(hObject,'String'))


% --- Executes on button press in pushbuttonADCIRC.
function pushbuttonADCIRC_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonADCIRC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=getappdata(handles.figure1,'a');
a.adcircnew=true;
a=caltrack(a);
setappdata(handles.figure1,'a',a)

% --- Executes on button press in pushbuttonADCP.
function pushbuttonADCP_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonADCP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=getappdata(handles.figure1,'a');
a.adcpnew=true;
a=caltrack(a);
setappdata(handles.figure1,'a',a)


% --- Executes on button press in togglebuttonZoom.
function togglebuttonZoom_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of togglebuttonZoom
if get(hObject,'Value'), %zoom on
    hPan=handles.togglebuttonPan;
    set(hPan,'Value',0)
    zoom on
else %zoom off
    zoom off
end


% --- Executes on button press in togglebuttonPan.
function togglebuttonPan_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonPan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of togglebuttonPan
if get(hObject,'Value'), %pan on
    hZoom=handles.togglebuttonZoom;
    set(hZoom,'Value',0)
    pan on
else %pan off
    pan off
end




% --- Executes on button press in pushbutton_Refresh.
function pushbutton_Refresh_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=getappdata(handles.figure1,'a');
a=caltrack(a);
setappdata(handles.figure1,'a',a);



% --- Executes when uipanel2 is resized.
function uipanel2_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles),
   set(handles.axes1,...
      'Position',[0,0.116,1.0,0.714],...
      'PlotBoxAspectRatio',[1,.714,1]) 
end


% --------------------------------------------------------------------
function menu_Copy_meta_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Copy_meta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
print('-dmeta');

% --------------------------------------------------------------------
function menu_Copy_bitmap_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Copy_bitmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
print('-dbitmap');

% --------------------------------------------------------------------
function menu_CreateAVI_Callback(hObject, eventdata, handles)
% hObject    handle to menu_CreateAVI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
titlestr=get(handles.figure1,'Name');
tlim=get(handles.edit_DateTime,'String');
Prompt={'Start Date/Time',...
    'End Date/Time',...
    'Snapshot Interval',...
    'Compression: (Indeo5,none)',...
    'Quality (1-100)',...
    'Frame Rate (fps)'};
defAns={tlim,datestr(datenum(tlim)+1),'1','Indeo5','75','10'};
ierr=true;
opts.WindowStyle='modal';
opts.Interpreter='none';
app=getappdata(handles.figure1,'a');
while ierr
    Ans=inputdlg(Prompt,'Create AVI.',1,defAns);
    if isempty(Ans),return,end
    ierr=false;
    %check inputs
    try
        t1=datenum(Ans{1});
        t2=datenum(Ans{2});
        ensint=str2double(Ans{3});
        compression=Ans{4};
        quality=str2double(Ans{5});
        framerate=str2double(Ans{6});
        if t2<=t1,
           error('CALTRACKGUI:AVIinput:TimeLimit','Stop Time less than start.');
        end
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
            case 'CALTRACKGUI:AVIinput:TimeLimit'
                h=errordlg({'Invalid Date Specification.',...
                    'End time before start time.'},...
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
    I=find(app.adcirctime>=t1 & app.adcirctime<=t2);
    %finish error checking...
    if ensint~=round(ensint) || ensint<1,
        ierr=true;
        h=errordlg({'Ensemble interval must be integer >= 1.',...
            'Check ensemble interval.'},...
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
    elseif ~any(strcmpi(compression,{'none','Indeo5'}))
        ierr=true;
        h=errordlg({'Compression must be Indeo5 or none',...
            'Check specified compression setting.'},...
            ' ',opts);
        uiwait(h)
        defAns=Ans;
        continue
    end

end %while ierr
[fn,pn]=uiputfile('*.avi','Specify filename to save movie loop.');
if isnumeric(fn),return,end

%create avifile
aviobj=avifile(fullfile(pn,fn),...
    'fps',framerate,...
    'compression',compression,...
    'quality',quality);
 
NI=length(I);
fprev=-1;
for k=1:ensint:NI,
    f=round(k/NI*100);
    if f>fprev,
        str=sprintf('Creating AVI. %g%% complete.',f);
        set(handles.figure1,'Name',str)
    end
    %advance date/time with slider
    set(handles.slider_DateTime,'Value',I(k))
    %update window
    slider_DateTime_Callback(handles.slider_DateTime,[],handles)
    %grab graphics and add to AVI
    F=getframe(handles.figure1);
    aviobj=addframe(aviobj,F);
end
set(handles.figure1,'Name',titlestr);
aviobj=close(aviobj);




% --------------------------------------------------------------------
function menu_PrintPreview_Callback(hObject, eventdata, handles)
% hObject    handle to menu_PrintPreview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printpreview

% --------------------------------------------------------------------
function menu_ExportPNG_Callback(hObject, eventdata, handles)
% hObject    handle to menu_ExportPNG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA
tvec=datevec(get(handles.edit_DateTime,'String'));
app=getappdata(handles.figure1,'a');
[pnda,fnda]=fileparts(app.fileDA);
tname=fullfile(pnda,sprintf('%s_%02.0f%02.0f%02.0f_%02.0f%02.0f%02.0f.png',fnda,tvec));
[fn,pn]=uiputfile('*.png','Specify filename of exported graphic.',tname);
if isnumeric(fn)
    return
else
    print('-dpng',fullfile(pn,fn))
end

