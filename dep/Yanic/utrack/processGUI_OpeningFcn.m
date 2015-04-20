function processGUI_OpeningFcn(hObject, eventdata, handles, string,varargin)
% Common initialization of concrete process GUIs
%
% This function fills various fields of the userData 
%       userData.mainFig - handle to the main figure
%       userData.handles_main - 'handles' of main figure
%       userData.procID - The ID of process in the current package
%       userData.MD - current movieData object
%       userData.crtProc - current process
%       userData.crtPackage - current package
%       userData.crtProcClassName - current process class
%       (as defined by the package: can be superclass)
%       userData.procConstr - constructor of current process
%
%       userData.questIconData - help icon image information
%       userData.colormap - color map information
%
% Sebastien Besson May 2011

% Check input
% The mainFig and procID should always be present
% procCOnstr and procName should only be present if the concrete process
% initation is delegated from an abstract class. Else the constructor will
% be directly read from the package constructor list.
ip = inputParser;
ip.addRequired('hObject',@ishandle);
ip.addRequired('eventdata',@(x) isstruct(x) || isempty(x));
ip.addRequired('handles',@isstruct);
ip.addRequired('string',@(x) isequal(x,'mainFig'));
ip.addOptional('mainFig',[],@ishandle);
ip.addOptional('procID',[],@isscalar);
ip.addParamValue('procConstr',[],@(x) isa(x,'function_handle'));
ip.addParamValue('procClassName','',@ischar);
ip.addParamValue('initChannel',0,@isscalar);
ip.parse(hObject,eventdata,handles,string,varargin{:});

% Retrieve userData and read function input 
userData = get(handles.figure1, 'UserData');
userData.mainFig=ip.Results.mainFig;
userData.procID = ip.Results.procID;
userData.procConstr=ip.Results.procConstr;
userData.crtProcClassName = ip.Results.procClassName;
initChannel = ip.Results.initChannel;

% Set up copyright statement
[copyright openHelpFile] = userfcn_softwareConfig(handles);
set(handles.text_copyright, 'String', copyright)

% Get current package, movie data and process
userData.handles_main = guidata(userData.mainFig);
userData_main = get(userData.mainFig, 'UserData');
userData.MD = userData_main.MD(userData_main.id);
if isa(userData.MD,'MovieList'),userData.ML=userData.MD; end
userData.crtPackage = userData_main.crtPackage;

% If constructor is not inherited from abstract class, read it from package
if isempty(userData.procConstr)
    userData.procConstr = userData.crtPackage.getDefaultProcessConstructors{userData.procID};
    userData.crtProcClassName = userData.crtPackage.getProcessClassNames{userData.procID};
end

% Retrieve crtProc if procID step of the package is set up AND is the same
% class as the current process
crtProcName = eval([userData.crtProcClassName '.getName']);
if isa(userData.crtPackage.processes_{userData.procID},userData.crtProcClassName)    
    userData.crtProc = userData.crtPackage.processes_{userData.procID};
else
    userData.crtProc =[];
end

% Set process names in the text box and figure title
procString = [' Step ' num2str(userData.procID) ': ' crtProcName];
set(handles.text_processName,'String',procString);
figString = [' Setting - ' crtProcName];
set(handles.figure1,'Name',figString);

% Initialize help, preview figure
userData.helpFig=-1;
userData.previewFig=-1;

% Get icon infomation
userData.questIconData = userData_main.questIconData;
userData.colormap = userData_main.colormap;

% If process does not exist, create a default one in user data.
if isempty(userData.crtProc)
    try
        userData.crtProc = userData.procConstr(userData.MD, ...
            userData.crtPackage.outputDirectory_);
    catch ME
        if ~isequal(ME.identifier,'MATLAB:class:MethodRestricted')
            rethrow(ME);
        end
    end
end

% Check for multiple movies else
if isfield(handles,'checkbox_applytoall')
    if numel(userData_main.MD) ==1
        set(handles.checkbox_applytoall,'Value',0,'Visible','off');
    else
        set(handles.checkbox_applytoall, 'Value',...
            userData_main.applytoall(userData.procID));
    end
    uicontrol(handles.pushbutton_done);
end

% ----------------------Set up help icon------------------------

% Set up help icon
set(hObject,'colormap',userData.colormap);
% Set up package help. Package icon is tagged as '0'
set(handles.figure1,'CurrentAxes',handles.axes_help);
Img = image(userData.questIconData);
set(gca, 'XLim',get(Img,'XData'),'YLim',get(Img,'YData'),...
    'visible','off','YDir','reverse');
set(Img,'ButtonDownFcn',@icon_ButtonDownFcn);
if openHelpFile
    set(Img, 'UserData', struct('class',userData.crtProcClassName))
end

% Update user data and GUI data
set(hObject, 'UserData', userData);
% ----------------------------------------------------------------
if ~initChannel, return; end

funParams = userData.crtProc.funParams_;

% Set up available input channels
set(handles.listbox_availableChannels,'String',userData.MD.getChannelPaths(), ...
    'UserData',1:numel(userData.MD.channels_));

channelIndex = funParams.ChannelIndex;

% Find any parent process
parentProc = userData.crtPackage.getParent(userData.procID);
if isempty(userData.crtPackage.processes_{userData.procID}) && ~isempty(parentProc)
    % Check existence of all parent processes
    emptyParentProc = any(cellfun(@isempty,userData.crtPackage.processes_(parentProc)));
    if ~emptyParentProc
        % Intersect channel index with channel index of parent processes
        parentChannelIndex = @(x) userData.crtPackage.processes_{x}.funParams_.ChannelIndex;
        for i = parentProc
            channelIndex = intersect(channelIndex,parentChannelIndex(i));
        end
    end
end

if ~isempty(channelIndex)
    channelString = userData.MD.getChannelPaths(channelIndex);
else
    channelString = {};
end

set(handles.listbox_selectedChannels,'String',channelString,...
    'UserData',channelIndex);

% Set default channels callback function
set(handles.checkbox_all,'Callback',@(hObject,eventdata)...
    checkallChannels(hObject,eventdata,guidata(hObject)));
set(handles.pushbutton_select,'Callback',@(hObject,eventdata)...
    selectChannel(hObject,eventdata,guidata(hObject)));
set(handles.pushbutton_delete,'Callback',@(hObject,eventdata)...
    deleteChannel(hObject,eventdata,guidata(hObject)));

% --- Executes on button press in checkbox_all.
function checkallChannels(hObject, eventdata, handles)

% Retrieve available channels properties
availableProps = get(handles.listbox_availableChannels, {'String','UserData'});
if isempty(availableProps{1}), return; end

% Update selected channels
if get(hObject,'Value')
    set(handles.listbox_selectedChannels, 'String', availableProps{1},...
        'UserData',availableProps{2});
else
    set(handles.listbox_selectedChannels, 'String', {}, 'UserData',[], 'Value',1);
end

% --- Executes on button press in pushbutton_select.
function selectChannel(hObject, eventdata, handles)

% Retrieve  channels properties
availableProps = get(handles.listbox_availableChannels, {'String','UserData','Value'});
selectedProps = get(handles.listbox_selectedChannels, {'String','UserData'});

% Find new elements and set them to the selected listbox
newID = availableProps{3}(~ismember(availableProps{1}(availableProps{3}),selectedProps{1}));
selectedChannels = horzcat(selectedProps{1}',availableProps{1}(newID)');
selectedData = horzcat(selectedProps{2}, availableProps{2}(newID));
set(handles.listbox_selectedChannels, 'String', selectedChannels, 'UserData', selectedData);

% --- Executes on button press in pushbutton_delete.
function deleteChannel(hObject, eventdata, handles)

% Get selected properties and returin if empty
selectedProps = get(handles.listbox_selectedChannels, {'String','UserData','Value'});
if isempty(selectedProps{1}) || isempty(selectedProps{3}),return; end

% Delete selected item
selectedProps{1}(selectedProps{3}) = [ ];
selectedProps{2}(selectedProps{3}) = [ ];
set(handles.listbox_selectedChannels, 'String', selectedProps{1},'UserData',selectedProps{2},...
    'Value',max(1,min(selectedProps{3},numel(selectedProps{1}))));
