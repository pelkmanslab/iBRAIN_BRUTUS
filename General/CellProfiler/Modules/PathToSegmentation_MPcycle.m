function handles = PathToSegmentation_MPcycle(handles)

% Help for the PATHTOSEGMENTATION module:
% Category: Other
%
% SHORT DESCRIPTION: 
% Provides path to SEGMENTATION directory, where segmentation images are
% stored. This is necessary in a multiplexing setting, where only one set
% of segmentation images exists for multiple iterative cycles. This works
% only on unix systems. If you have a Windows machine, you shouldn't be
% doing this anyways. However, you can get a Mac instead next time (or
% install ubuntu from http://www.ubuntu.com)!
% *************************************************************************
%
% Author:
%    Markus Herrmann <markus.herrmann@imls.uzh.ch>
%


%%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%%
drawnow

[CurrentModule, CurrentModuleNum, ModuleName] = CPwhichmodule(handles);

%textVAR01 = Please provide relative path to SEGMENTATION directory, which contains segmented images:
%defaultVAR01 = ../
SegmentationDirectory = char(handles.Settings.VariableValues{CurrentModuleNum,1});

%textVAR02 = Please provide filename trunk of segmented images (e.g. trunk_C03_T0001F001L01A01Z01C01.png):
%defaultVAR02 = /
SegmentationFilenameTrunk = char(handles.Settings.VariableValues{CurrentModuleNum,2});


%%%%%%%%%%%%%%%%%%
%%% PROCESSING %%%
%%%%%%%%%%%%%%%%%%

% get default output directory from handles
DefaultOutputDir = handles.Current.DefaultOutputDirectory;

% built full path from default output directory and provided relative path
if strcmp(getlastdir(DefaultOutputDir),'BATCH')
    Path = [strrep(DefaultOutputDir, [filesep,'BATCH'], filesep), SegmentationDirectory];
end

Filename = SegmentationFilenameTrunk;


%%%%%%%%%%%%%%%
%%% DISPLAY %%%
%%%%%%%%%%%%%%%
drawnow

ThisModuleFigureNumber = handles.Current.(['FigureNumberForModule',CurrentModule]);
if any(findobj == ThisModuleFigureNumber)
    if handles.Current.SetBeingAnalyzed == handles.Current.StartingImageSet
        CPresizefigure('','NarrowText',ThisModuleFigureNumber)
    end
    %%% print path
    currentfig = CPfigure(handles,'Text',ThisModuleFigureNumber);
    TextString = ['Path to SEGMENTATION directory: ',Path];
    uicontrol(currentfig,'style','text','units','normalized','fontsize',handles.Preferences.FontSize,'HorizontalAlignment','left','string',TextString,'position',[.05 .85-0*.15 .95 .1],'BackgroundColor',[.7 .7 .9])
    %%% print filename trunk
    currentfig = CPfigure(handles,'Text',ThisModuleFigureNumber);
    TextString = ['Filename trunk of segmented image: ',Filename];
    uicontrol(currentfig,'style','text','units','normalized','fontsize',handles.Preferences.FontSize,'HorizontalAlignment','left','string',TextString,'position',[.05 .85-1*.15 .95 .1],'BackgroundColor',[.7 .7 .9])
end



%%%%%%%%%%%%%%
%%% OUTPUT %%%
%%%%%%%%%%%%%%

%%% save path to handles
handles.Pipeline.SegmentationDirectory = Path;
handles.Pipeline.SegmentationFilenameTrunk = Filename;



end
