function varargout = PlantModelDemo(varargin)
% PLANTMODELDEMO MATLAB code for PlantModelDemo.fig
%      PLANTMODELDEMO, by itself, creates a new PLANTMODELDEMO or raises the existing
%      singleton*.
%
%      H = PLANTMODELDEMO returns the handle to a new PLANTMODELDEMO or the handle to
%      the existing singleton*.
%
%      PLANTMODELDEMO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLANTMODELDEMO.M with the given input arguments.
%
%      PLANTMODELDEMO('Property','Value',...) creates a new PLANTMODELDEMO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlantModelDemo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlantModelDemo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PlantModelDemo

% Last Modified by GUIDE v2.5 05-Apr-2016 22:41:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlantModelDemo_OpeningFcn, ...
                   'gui_OutputFcn',  @PlantModelDemo_OutputFcn, ...
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


% --- Executes just before PlantModelDemo is made visible.
function PlantModelDemo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlantModelDemo (see VARARGIN)

% Choose default command line output for PlantModelDemo
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%Set initial values for plant profit
vInitProfit = [6 7];

%Hide the axis
handles.axes1.Visible = 'off';
handles.axes3.Visible = 'off';

% UIWAIT makes PlantModelDemo wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PlantModelDemo_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% CODE EXECUTES WHEN RUN GAMS BUTTON is PUSHED

% First read data from the input table
vData = cell2mat(handles.uitable1.Data(1,:));

% Create a GDX structure to hold the data
sProfit.name='c_inp'; %The name of the parameter in GAMS
sProfit.val= vData;
sProfit.form = 'full'; % Sparse is for integer and full is for decimal
sProfit.type ='parameter';
sProfit.uels={'Eggplant' 'Tomatoes'}; %Index values in GAMS

% Write the GDX structure to a file
wgdx('PlantProfit',sProfit); 

%msgbox('Data written to PlantProfit.gdx')
%return %break here after writing data but before running gams

% Run the GAMS model
gams('Ex2-1-parametric');

% Read Results back into GAMS (Tomato Water Requirement, Objective function value, and decision variables) 
    cParams = {'TomWatReq' 'ObjFunc' 'DecVars'}; %Parameter names in GAMS GDX file
    sResRead = cell(3,1); %Cell array to hold structures returned from GAMS GDX file
    
  %Create the structure to hold the gdx data
    sRes.form = 'full';
    sRes.compress = true;
    
    for i=1:length(cParams) %Loop through parameters
        sRes.name = cParams{i};  %Specify the parameter name
        %Read in the result
        sResRead{i} = rgdx('Ex2-1-parametric',sRes);
    end
    
    TomWatReq = sResRead{1}.val;
    ObjFun = sResRead{2}.val;
    DecVars = sResRead{3}.val;

%Plot the results
cla(handles.axes1,'reset') % clear prior plots
cla(handles.axes3,'reset') % clear prior plots

lTrace = plot(handles.axes1,TomWatReq,ObjFun);
hold on
set(handles.axes1,'Fontsize',16,'xTickLabels',[]);
set(lTrace,'color',[0 0 1],'marker','x','markersize',10,'linestyle','-');
ylabel(handles.axes1,'Profit ($)','FontSize',18);
hold off

rTrace1 = plot(handles.axes3,TomWatReq,DecVars(:,1));
hold on
set(rTrace1,'color',[1 0 0],'marker','o','markersize',10,'linestyle','-.');
rTrace2 = plot(handles.axes3,TomWatReq,DecVars(:,2),'marker','^','markersize',10,'linestyle',':');
set(handles.axes3,'FontSize',16);
ylabel('Number of Plants');

xlabel('Tomato Water Requirement (gal/plant)','FontSize',18);
hLeg = legend({'Eggplants','Tomatoes'});
set(hLeg,'Fontsize',14);






% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});
