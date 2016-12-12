function varargout = Fir_Interface(varargin)
% FIR_INTERFACE MATLAB code for Fir_Interface.fig
%      FIR_INTERFACE, by itself, creates a new FIR_INTERFACE or raises the existing
%      singleton*.
%
%      H = FIR_INTERFACE returns the handle to a new FIR_INTERFACE or the handle to
%      the existing singleton*.
%
%      FIR_INTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIR_INTERFACE.M with the given input arguments.
%
%      FIR_INTERFACE('Property','Value',...) creates a new FIR_INTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Fir_Interface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Fir_Interface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Fir_Interface

% Last Modified by GUIDE v2.5 05-Jun-2016 17:28:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Fir_Interface_OpeningFcn, ...
                   'gui_OutputFcn',  @Fir_Interface_OutputFcn, ...
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


% --- Executes just before Fir_Interface is made visible.
function Fir_Interface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Fir_Interface (see VARARGIN)

% Choose default command line output for Fir_Interface
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);
% UIWAIT makes Fir_Interface wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Fir_Interface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in projetar.
function projetar_Callback(hObject, eventdata, handles)
% hObject    handle to projetar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

janela = get(handles.janela, 'Value')-2;
switch(get(handles.bits, 'Value'));
    case(2) 
        bits = 8;
    case(3)
        bits = 10;
    case(4)
        bits = 16;
end
[handles.metricdata.ideal_order, handles.metricdata.wc_ideal,...
 handles.metricdata.wc_nlinear, handles.metricdata.ordem_nlinear,...
 handles.metricdata.correct_flag, handles.metricdata.thd] = FIR_Filter(bits, janela);

set(handles.thd, 'String', handles.metricdata.thd);
if(handles.metricdata.correct_flag == 3)
set(handles.correct_flag,  'String', 'Sim');
end
set(handles.ideal_order, 'String', handles.metricdata.ideal_order);
set(handles.wc_ideal, 'String', handles.metricdata.wc_ideal);
set(handles.wc_nlinear, 'String', handles.metricdata.wc_nlinear);
set(handles.ordem_nlinear, 'String', handles.metricdata.ordem_nlinear);

% --- Executes on selection change in bits.
function bits_Callback(hObject, eventdata, handles)
% hObject    handle to bits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns bits contents as cell array
%        contents{get(hObject,'Value')} returns selected item from bits


% --- Executes during object creation, after setting all properties.
function bits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in janela.
function janela_Callback(hObject, eventdata, handles)
% hObject    handle to janela (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns janela contents as cell array
%        contents{get(hObject,'Value')} returns selected item from janela


% --- Executes during object creation, after setting all properties.
function janela_CreateFcn(hObject, eventdata, handles)
% hObject    handle to janela (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function thd_Callback(hObject, eventdata, handles)
% hObject    handle to thd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thd as text
%        str2double(get(hObject,'String')) returns contents of thd as a double


% --- Executes during object creation, after setting all properties.
function thd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function correct_flag_Callback(hObject, eventdata, handles)
% hObject    handle to correct_flag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of correct_flag as text
%        str2double(get(hObject,'String')) returns contents of correct_flag as a double


% --- Executes during object creation, after setting all properties.
function correct_flag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to correct_flag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
initialize_gui(gcbf, handles, true);





function ideal_order_Callback(hObject, eventdata, handles)
% hObject    handle to ideal_order (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ideal_order as text
%        str2double(get(hObject,'String')) returns contents of ideal_order as a double


% --- Executes during object creation, after setting all properties.
function ideal_order_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ideal_order (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wc_ideal_Callback(hObject, eventdata, handles)
% hObject    handle to wc_ideal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wc_ideal as text
%        str2double(get(hObject,'String')) returns contents of wc_ideal as a double


% --- Executes during object creation, after setting all properties.
function wc_ideal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wc_ideal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ordem_nlinear_Callback(hObject, eventdata, handles)
% hObject    handle to ordem_nlinear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ordem_nlinear as text
%        str2double(get(hObject,'String')) returns contents of ordem_nlinear as a double


% --- Executes during object creation, after setting all properties.
function ordem_nlinear_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ordem_nlinear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wc_nlinear_Callback(hObject, eventdata, handles)
% hObject    handle to wc_nlinear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wc_nlinear as text
%        str2double(get(hObject,'String')) returns contents of wc_nlinear as a double


% --- Executes during object creation, after setting all properties.
function wc_nlinear_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wc_nlinear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function initialize_gui(fig_handle, handles, isreset)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
if isfield(handles, 'metricdata') && ~isreset
    return;
end

handles.metricdata.thd = 0;
handles.metricdata.correct_flag  = 0;
handles.metricdata.ideal_order = 0;
handles.metricdata.ordem_nlinear = 0;
handles.metricdata.wc_ideal = 0;
handles.metricdata.wc_nlinear = 0;

set(handles.thd, 'String', handles.metricdata.thd);
set(handles.correct_flag,  'String', 'Não');
set(handles.ideal_order, 'String', handles.metricdata.ideal_order);
set(handles.wc_ideal, 'String', handles.metricdata.wc_ideal);
set(handles.wc_nlinear, 'String', handles.metricdata.wc_nlinear);
set(handles.ordem_nlinear, 'String', handles.metricdata.ordem_nlinear);

% Update handles structure
guidata(handles.figure1, handles);
