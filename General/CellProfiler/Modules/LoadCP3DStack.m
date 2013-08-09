function handles = LoadCP3DStack(handles)

% Help for the LoadCP3D module:
% Category: File Processing
%
% SHORT DESCRIPTION:
% Will load files into a 3D Image Matrix
% 
% *************************************************************************
%
% Website: http://www.cellprofiler.org
%
% $Revision: 1879 $

%%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%%


drawnow

[CurrentModule, CurrentModuleNum, ModuleName] = CPwhichmodule(handles);

%textVAR01 = Which images do you want to load into memory?
%infotypeVAR01 = imagegroup
StackName = char(handles.Settings.VariableValues{CurrentModuleNum,1});
%inputtypeVAR01 = popupmenu

%%%VariableRevisionNumber = 1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRELIMINARY ERROR CHECKING & FILE HANDLING %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try 
 % obtain full path to file, note that Path and Filename have been stored separately before to remain consistency with CP1 modules such as create Batchfiles      
ImagePathFile =  cellfun(@(x) fullfile(handles.Pipeline.(StackName).Pathname, char(x)), handles.Pipeline.(StackName).FileNames, 'UniformOutput', 0);

handles.Pipeline.(StackName) = imreadCP3D(ImagePathFile,'single');
catch NotLoaded
   error(['Image processing was canceled in the ', ModuleName, ' module because the specified files could not be loaded.'])
end


%%%%%%%%%%%%%
%%% DISPLAY
%%%%%%%%%%%%%

CombinedImage =  CombinePlanesCP3D(handles.Pipeline.(StackName),'Maximum');

drawnow
ThisModuleFigureNumber = handles.Current.(['FigureNumberForModule',CurrentModule]);
if any(findobj == ThisModuleFigureNumber)

    %%% Activates the appropriate figure window.
    CPfigure(handles,'Image',ThisModuleFigureNumber);

    if handles.Current.SetBeingAnalyzed == handles.Current.StartingImageSet
        CPresizefigure(CombinedImage,'TwoByTwo',ThisModuleFigureNumber);
    end
    
    %%% A subplot of the figure window is set to display the Combined Image
    %%% image.  Using CPimagesc or image instead of imshow doesn't work when
    %%% some of the pixels are saturated.

    CPimagesc(CombinedImage,handles);

    title(sprintf('Maximum intensity projection of loaded %s stack, cycle #%d', StackName ,num2str(handles.Current.SetBeingAnalyzed)));
end


end