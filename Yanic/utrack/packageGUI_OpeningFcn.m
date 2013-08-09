function packageGUI_OpeningFcn(hObject,eventdata,handles,packageName,varargin)
% Callback called at the opening of packageGUI
%
% packageGUI_OpeningFcn(packageName,MD)   MD: MovieData object
%
% Useful tools
%
% User Data:
%
%       userData.MD - array of MovieData object
%       userData.package - array of package (same length with userData.MD)
%       userData.crtPackage - the package of current MD
%       userData.id - the id of current MD on board
%
%       userData.dependM - dependency matrix
%       userdata.statusM - GUI status matrix
%       userData.optProcID - optional process ID
%       userData.applytoall - array of boolean for batch movie set up
%
%       userData.passIconData - pass icon image data
%       userData.errorIconData - error icon image data
%       userData.warnIconData - warning icon image data
%       userData.questIconData - help icon image data
%       userData.colormap - color map
%
%       userData.setFig - array of handles of (multiple) setting figures (may not exist)
%       userData.resultFig - array of handles of (multiple) result figures (may not exist)
%       userData.packageHelpFig - handle of (single) help figure (may not exist)
%       userData.iconHelpFig - handle of (single) help figures (may not exist)
%       userData.statusFig - handle of (multiple) status figures (may not exist)
%       userData.processHelpFig - handle of (multiple) help figures (may not exist) 
%       
%
% NOTE:
%   
%   userData.statusM - 1 x m stucture array, m is the number of Movie Data 
%                      this user data is used to save the status of movies
%                      when GUI is switching between different movie(s)
%                   
%   	fields: IconType - the type of status icons, 'pass', 'warn', 'error'
%               Msg - the message displayed when clicking status icons
%               Checked - 1 x n logical array, n is the number of processes
%                         used to save value of check box of each process
%               Visited - logical true or false, if the movie has been
%                         loaded to GUI before 

% Sebastien Besson May 2011 (last modified Sep 2011()

% Input check
ip = inputParser;
ip.addRequired('hObject',@ishandle);
ip.addRequired('eventdata',@(x) isstruct(x) || isempty(x));
ip.addRequired('handles',@isstruct);
ip.addRequired('packageName',@(x) isa(x,'char') || isa(x,'function_handle'));
ip.addOptional('MD',[],@(x) isa(x,'MovieObject'));
ip.parse(hObject,eventdata,handles,packageName,varargin{:});


% Generate the package constructor
if isa(packageName,'function_handle')
    packageConstr=packageName;
    packageName=func2str(packageName);
elseif isa(packageName,'char')
    packageConstr=str2func(packageName);
end

assert(any(strcmp(superclasses(packageName),'Package')),...
    sprintf('%s is not a valid Package',packageName));
      
handles.output = hObject;
userData = get(handles.figure1,'UserData');
userData.packageName = packageName;
userData.MD=ip.Results.MD;

% Call package GUI error
[copyright openHelpFile] = userfcn_softwareConfig(handles);
set(handles.text_copyright, 'String', copyright);

%If package GUI supplied without argument, saves a boolean which will be
%read by packageNameGUI_OutputFcn
if isempty(userData.MD)
    userData.startMovieSelectorGUI=true;
    set(handles.figure1,'UserData',userData);
    guidata(hObject, handles);
    return
end

% Singleton control
try assert(~userData.init)
catch ME
    if strcmpi(ME.identifier,'MATLAB:nonExistentField');
        userData.init=true;
    else
        return
    end
end


% ----------------------------- Load MovieData ----------------------------
nMovies = numel(userData.MD);
packageIndx = cell(1, nMovies);

% I. Before loading MovieData, firstly check if the current package exists
for i = 1:nMovies
    % Check for existing packages and create them if false
    packageIndx{i} = find(cellfun(@(x) isa(x,packageName),...
        userData.MD(i).packages_),1);
    if packageIndx{i}
        userData.package(i) = userData.MD(i).packages_{packageIndx{i}};
    else
        userData.MD(i).addPackage(packageConstr(userData.MD(i),...
            userData.MD(i).outputDirectory_));
        userData.package(i) = userData.MD(i).packages_{end};
    end
    
    % Run sanity check to check basic dependencies are satisfied
    try
        userData.package(i).sanityCheck(true,'all');
    catch ME
        errordlg(ME.message,'Package initialization','modal');
        userData.startMovieSelectorGUI=true;
        set(handles.figure1,'UserData',userData);
        guidata(hObject, handles);
        return
    end
end

% ------------- Check if existing processes can be recycled ---------------
recyclableProc = cell(1, nMovies);
processClassNames = userData.package(1).getProcessClassNames;

% Multiple movies loop
for i = 1:nMovies
    if isempty(packageIndx{i}) && ~isempty(userData.MD(i).processes_)
        recyclableProcIndx = cellfun(@(x) cellfun(@(y)isa(y,x),...
            userData.MD(i).processes_),processClassNames,'UniformOutput',false);
        recyclableProc{i}=userData.MD(i).processes_(any(vertcat(recyclableProcIndx{:}),1));
    end
end

recyclableProcMovie = find(~cellfun(@isempty, recyclableProc));

if ~isempty(recyclableProcMovie)
                      
    % Ask user if to recycle
    msg = ['Record indicates that existing processes are recyclable for %s package:'...
        '\n\nDo you want to load and re-use these steps?'];
    user_response = questdlg(sprintf(msg,userData.package(1).getName),...
        'Recycle Existing Steps','No','Yes','Yes');
    
    if strcmpi(user_response,'Yes')
        for i = recyclableProcMovie           
            recycleProcessGUI(recyclableProc{i}, userData.package(i),'mainFig', handles.figure1)
        end
    end      
end

% Initialize userdata
userData.id = 1;
userData.crtPackage = userData.package(userData.id);
userData.dependM = userData.package(userData.id).getDependencyMatrix;
userData.optProcID =find(sum(userData.dependM==2,1));
nProc = size(userData.dependM, 1);
userData.statusM = repmat( struct('IconType', {cell(1,nProc)}, 'Msg', {cell(1,nProc)}, 'Checked', zeros(1,nProc), 'Visited', false), 1, nMovies);

% -----------------------Load and set up icons----------------------------

% Load icon images from dialogicons.mat
load lccbGuiIcons.mat

% Save Icon data to GUI data
userData.passIconData = passIconData;
userData.errorIconData = errorIconData;
userData.warnIconData = warnIconData;
userData.questIconData = questIconData;

% Set figure colormap
supermap(1,:) = get(hObject,'color');
set(hObject,'colormap',supermap);

userData.colormap = supermap;

% Set up package help. 
set(handles.figure1,'CurrentAxes',handles.axes_help);
Img = image(questIconData); 
set(gca, 'XLim',get(Img,'XData'),'YLim',get(Img,'YData'),...
    'visible','off','YDir','reverse');
set(Img,'ButtonDownFcn',@icon_ButtonDownFcn);

if openHelpFile
    set(Img, 'UserData', struct('class', packageName))
end
% --------------------------Set up processes------------------------------

% List of template process uicontrols to expand
templateTag{1} = 'checkbox';
templateTag{2} = 'axes_icon';
templateTag{3} = 'pushbutton_show';
templateTag{4} = 'pushbutton_set';
templateTag{5} = 'axes_prochelp';
% templateTag{6} = 'pushbutton_clear'; To be implemented someday?
procTag=templateTag;
set(handles.figure1,'Position',...
    get(handles.figure1,'Position')+(nProc-1)*[0 0 0 40])
set(handles.panel_movie,'Position',...
    get(handles.panel_movie,'Position')+(nProc-1)*[0 40 0 0])
set(handles.panel_proc,'Position',...
    get(handles.panel_proc,'Position')+(nProc-1)*[0 0 0 40])
set(handles.text_status, 'Position',...
    get(handles.text_status,'Position')+(nProc-1)*[0 40 0 0])      

for i = 1:nProc
    for j=1:length(templateTag)
        procTag{j}=[templateTag{j} '_' num2str(i)];
        handles.(procTag{j}) = copyobj(handles.(templateTag{j}),handles.panel_proc);
        set(handles.(procTag{j}),'Tag',procTag{j},'Position',...
            get(handles.(templateTag{j}),'Position')+(nProc-i)*[0 40 0 0]);
    end
  
    processClassName = userData.crtPackage.getProcessClassNames{i};
    processName=eval([processClassName '.getName']);
    checkboxString = [' Step ' num2str(i) ': ' processName];
    set(handles.(procTag{1}),'String',checkboxString)
    
    set(handles.figure1,'CurrentAxes',handles.(procTag{5}));
    Img = image(questIconData);
    set(gca, 'XLim',get(Img,'XData'),'YLim',get(Img,'YData'),...
        'visible','off','YDir','reverse');  
    set(Img,'ButtonDownFcn',@icon_ButtonDownFcn);
        
    if openHelpFile
        set(Img, 'UserData', struct('class', processClassName))
    end
end

cellfun(@(x)delete(handles.(x)),templateTag)
handles = rmfield(handles,templateTag);

optTag = 'text_optional';
for i = userData.optProcID
    procOptTag=[optTag '_' num2str(i)];
    handles.(procOptTag) = copyobj(handles.(optTag),handles.panel_proc);
    set(handles.(procOptTag),'Tag',procOptTag,'Position',...
        get(handles.(optTag),'Position')+(nProc-i)*[0 40 0 0]);
end

delete(handles.(optTag));
handles = rmfield(handles,optTag);


% --------------------------Create tools menu-----------------------------

if ~isempty(userData.crtPackage.getTools)
    handles.menu_tools = uimenu(handles.figure1,'Label','Tools','Position',2);
    for i=1:length(userData.crtPackage.getTools)
        toolMenuTag=['menu_tools_' num2str(i)];
        handles.(toolMenuTag) = uimenu(handles.menu_tools,...
            'Label',userData.crtPackage.getTools(i).name,...
            'Callback',@(h,event)menu_tools_Callback(h),'Tag',toolMenuTag);
    end
end

% --------------------------Other GUI settings-----------------------------

% set titles
set(handles.figure1, 'Name',['Control Panel - ' userData.crtPackage.getName]);
set(handles.text_packageName,'String',userData.crtPackage.getName);

% Set movie explorer
msg = {};
for i = 1: length(userData.MD)
    msg = cat(2, msg, {sprintf('  Movie %d of %d', i, length(userData.MD))});
end
set(handles.popupmenu_movie, 'String', msg, 'Value', userData.id);

% Set option depen
if length(userData.MD) == 1
    set(handles.checkbox_runall, 'Visible', 'off')
    set(handles.pushbutton_left, 'Enable', 'off')
    set(handles.pushbutton_right, 'Enable', 'off')   
    set(handles.checkbox_all, 'Visible', 'off', 'Value', 0)
    userData.applytoall=zeros(nProc,1);
else
    set(handles.checkbox_runall, 'Visible', 'on')
    userData.applytoall=ones(nProc,1);
end


set(handles.pushbutton_run, 'Callback', @(hObject,eventdata)packageGUI_RunFcn(hObject,eventdata,guidata(hObject)));
% Set web links in menu
set(handles.menu_about_gpl,'UserData','http://www.gnu.org/licenses/gpl.html')
set(handles.menu_about_lccb,'UserData','http://lccb.hms.harvard.edu/')
set(handles.menu_about_lccbsoftware,'UserData','http://lccb.hms.harvard.edu/software.html')
 
% Update handles structure
set(handles.figure1,'UserData',userData);
guidata(hObject, handles);
set(Img,'ButtonDownFcn',@icon_ButtonDownFcn);

packageGUI_RefreshFcn(handles, 'initialize')
end


% --------------------------------------------------------------------
function menu_tools_Callback(hObject)

handles =guidata(hObject);
userData = get(handles.figure1, 'UserData');
prop=get(hObject,'Tag');
toolID = str2double(prop(length('menu_tools_')+1:end));

toolHandle=userData.crtPackage.getTools(toolID).funHandle;
userData.toolFig(toolID) = toolHandle('mainFig',handles.figure1);

set(handles.figure1, 'UserData', userData);
end