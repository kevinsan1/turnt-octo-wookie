function varargout = mainGUI(varargin)
% MAINGUI MATLAB code for mainGUI.fig
%      MAINGUI, by itself, creates a new MAINGUI or raises the
%      existing singleton*.
%
%      H = MAINGUI returns the handle to a new MAINGUI or the
%      handle to the existing singleton*.
%
%      MAINGUI('CALLBACK',hObject,eventData,handles,...) calls
%      the local function named CALLBACK in MAINGUI.M with the
%      given input arguments.
%
%      MAINGUI('Property','Value',...) creates a new MAINGUI or
%      raises the existing singleton*.  Starting from the left,
%      property value pairs are applied to the GUI before
%      mainGUI_OpeningFcn gets called.  An unrecognized property
%      name or invalid value makes property application stop. All
%      inputs are passed to mainGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI
%      allows only one instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mainGUI

% Last Modified by GUIDE v2.5 15-Jul-2014 19:07:38

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @mainGUI_OpeningFcn, ...
  'gui_OutputFcn',  @mainGUI_OutputFcn, ...
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


% --- Executes just before mainGUI is made visible.
function mainGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn. hObject handle
% to figure eventdata  reserved - to be defined in a future
% version of MATLAB handles    structure with handles and user
% data (see GUIDATA) varargin   command line arguments to mainGUI
% (see VARARGIN) Choose default command line output for mainGUI
handles.output = hObject;
handles.comsAvailable = getAvailableComPort;
set(handles.arduinoPort, 'String', handles.comsAvailable);
set(handles.azimuthPort, 'String', handles.comsAvailable);
[handles.chan, handles.flagSatPC] = satpc32_com;
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes mainGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command
% line.
function varargout = mainGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see
% VARARGOUT); hObject    handle to figure eventdata  reserved -
% to be defined in a future version of MATLAB handles structure
% with handles and user data (see GUIDATA) Get default command
% line output from handles structure

varargout{1} = handles.output;

% --- Executes on button press in connectToInstruments.
function connectToInstruments_Callback(hObject, eventdata, handles)
% hObject    handle to connectToInstruments (see GCBO) eventdata
% reserved - to be defined in a future version of MATLAB handles
% structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.arduinoPort,'String'));
arduinoPortName = contents{get(handles.arduinoPort,'Value')};
azimuthPortName = contents{get(handles.azimuthPort,'Value')};
[handles.arduinoCom, handles.arduinoFlag] = initializeArduino(arduinoPortName);
[handles.azimuthCom, handles.azimuthFlag] = initializeAzimuthRotor(azimuthPortName);
% handles.arduinoFlag = 1 if we are connected to the arduino
% rotor and 2 if we are not.
switch (handles.arduinoFlag)
  case 1
    set(handles.myDisplay, 'String', strvcat('Connected to Arduino', get(handles.myDisplay,'String')));
    assignin('base', 'arduinoSerialPort', handles.arduinoCom);
  case 0
    set(handles.myDisplay, 'String', strvcat('Not Connected to Arduino', get(handles.myDisplay,'String')));
end
% handles.azimuthFlag = 1 if we are connected to the azimuth
% rotor and 2 if we are not.
switch (handles.azimuthFlag)
  case 1
    set(handles.myDisplay, 'String', strvcat('Connected to Azimuth', get(handles.myDisplay,'String')));
    varargout{1} = 'azimuth';
    assignin('base', 'azimuthSerialPort', handles.azimuthCom);
  case 0
    set(handles.myDisplay, 'String', strvcat('Not connected to Azimuth', get(handles.myDisplay,'String')));
end
% Update handles structure
guidata(hObject, handles);

function clearInstrumentConnections_Callback(hObject,  eventdata, handles)
% hObject    handle to clearInstrumentConnections (see GCBO)
% eventdata  reserved - to be defined in a future version of
% MATLAB handles    structure with handles and user data (see
% GUIDATA)
delete(instrfind); clc;
set(handles.myDisplay, 'String', '');
handles.comsAvailable = getAvailableComPort;
set(handles.arduinoPort, 'String', handles.comsAvailable);
set(handles.azimuthPort, 'String', handles.comsAvailable);
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in startSatPC32.
function startSatPC32_Callback(hObject, eventdata, handles)
% hObject    handle to startSatPC32 (see GCBO) eventdata reserved
% - to be defined in a future version of MATLAB handles structure
% with handles and user data (see GUIDATA)
toggleStartSatPC = get(hObject,'Value');
lastString = get(handles.myDisplay, 'String');
% if arduino, azimuth rotor, and satpc are connected

if handles.arduinoFlag && handles.azimuthFlag && handles.flagSatPC && toggleStartSatPC
  [Az, El, Sat] = satpc32( handles.chan ); % Get coordinates from SatPC32
  currentElevation = getCurrentElevation(handles.arduinoCom) % in degrees
  currentAzimuth = 0;
  while toggleStartSatPC == 1 && 1i < 10 % while button is pressed run
    [Az, El, Sat] = satpc32(chan);
    set(handles.myDisplay, 'String', strvcat(strcat(num2str(Az),num2str(El)), lastString));
%     [El_mode, El_rotor] = rotorDirection(abs(El),
%     handles.arduinoCom); % with youtubeSerialCommunication
%     arduino code
    
    orbit(Az, handles.azimuthCom);
    pause(0.7);
    toggleStartSatPC = get(hObject,'Value');
  end
  % when button isn't pressed, stop both rotors
  fprintf(handles.azimuthCom, 'H<'); % tell azimuth rotor to stop
  fprintf(handles.arduinoCom, 's'); % tell arduino to stop
elseif not(toggleStartSatPC) % if toggle is not pressed, do nothing
elseif handles.arduinoFlag && handles.azimuthFlag && not(handles.flagSatPC)
elseif handles.arduinoFlag && not(handles.azimuthFlag) && not(handles.flagSatPC)
  set(handles.myDisplay, 'String', strvcat('Only the Arduino is connected', lastString));
elseif not(handles.arduinoFlag) && not(handles.azimuthFlag) && not(handles.flagSatPC)
  set(handles.myDisplay, 'String', strvcat('Nothing is connected', lastString));
  
end

% --- Executes on button press in stopSatPC32.
function stopSatPC32_Callback(hObject, eventdata, handles)
% hObject    handle to stopSatPC32 (see GCBO) eventdata  reserved
% - to be defined in a future version of MATLAB handles structure
% with handles and user data (see GUIDATA)
% index% returns toggle state of stopSatPC32
% --- Executes on button press in clearInstrumentConnections.

% --- Executes on selection change in arduinoPort.
function arduinoPort_Callback(hObject, eventdata, handles)
% hObject    handle to arduinoPort (see GCBO) eventdata  reserved
% - to be defined in a future version of MATLAB handles structure
% with handles and user data (see GUIDATA)
% set(handles.arduinoPort, 'String', handles.comsAvailable);

% --- Executes on selection change in azimuthPort.
function azimuthPort_Callback(hObject, eventdata, handles)
% hObject    handle to azimuthPort (see GCBO) eventdata  reserved
% - to be defined in a future version of MATLAB handles structure
% with handles and user data (see GUIDATA)

function myDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to myDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of myDisplay as text
%        str2double(get(hObject,'String')) returns contents of myDisplay as a double

% --- Executes on button press in elevationUp.
function elevationUp_Callback(hObject, eventdata, handles)
% hObject    handle to elevationUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

toggleElevationUp = get(hObject,'Value'); % returns toggle state of elevationUp
if toggleElevationUp == 1
  fprintf(handles.arduinoCom, 'u');
  bot = 1;
else
  fprintf(handles.arduinoCom, 's');
end
i = 1;

while toggleElevationUp == 1 && bot ~= 962
  fprintf(handles.arduinoCom, 'r');
  pause(0.1);
  bot(:,i) = str2num(fgets(handles.arduinoCom))
  %     handles.voltageUp(:,i) = str2num(fgets(handles.arduinoCom));
  i = i + 1;
  toggleElevationUp = get(hObject,'Value');
end
guidata(hObject, handles);

% --- Executes on button press in elevationDown.
function elevationDown_Callback(hObject, eventdata, handles)
% hObject    handle to elevationDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of elevationDown
toggleElevationDown = get(hObject,'Value'); % returns toggle state of elevationUp
switch toggleElevationDown
  case 1
    fprintf(handles.arduinoCom, 'd');
    fprintf(handles.arduinoCom, 'r');
    pause(0.1);
    voltage = fgets(handles.arduinoCom)
  otherwise
    fprintf(handles.arduinoCom, 's');
end

% --- Executes on button press in elevationStop.
function elevationStop_Callback(hObject, eventdata, handles)
% hObject    handle to elevationStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fprintf(handles.arduinoCom, 's');
fprintf(handles.azimuthCom, 'H<');

% --- Executes on button press in clearDisplay.
function clearDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to clearDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.myDisplay, 'String', '');

% --- Executes during object creation, after setting all
% properties.
function azimuthPort_CreateFcn(hObject, eventdata, handles)
% hObject    handle to azimuthPort (see GCBO) eventdata  reserved
% - to be defined in a future version of MATLAB handles    empty
% - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on
% Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all
% properties.
function arduinoPort_CreateFcn(hObject, eventdata, handles)
% hObject    handle to arduinoPort (see GCBO) eventdata  reserved
% - to be defined in a future version of MATLAB handles    empty
% - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on
% Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function myDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to myDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end
