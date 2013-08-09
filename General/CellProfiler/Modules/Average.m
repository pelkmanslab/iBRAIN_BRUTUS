function handles = Average(handles)

% Help for the Average module:
% Category: Image Processing
%
% SHORT DESCRIPTION:
% Averages images together (makes a projection).
% *************************************************************************
%
% This module averages a set of images by averaging the pixel intensities
% at each pixel position. When this module is used to average a Z-stack
% (3-D image stack), this process is known as making a projection.
%
% Settings:
%
% * What did you call the images to be averaged (made into a projection)?:
%   Choose an image from among those loaded by a module or created by the
% pipeline, which will be averaged with the corresponding images of every
% image set.
%
% * What do you want to call the averaged image?:
%   Give a name to the resulting image, which could be used in subsequent
% modules. See the next setting for restrictions.
%
% * Are the images you want to use to be loaded straight from a Load Images
% module, or are they being produced by the pipeline?:
%   If you choose Load Images Module, the module will calculate the single,
% averaged image the first time through the pipeline (i.e. for cycle 1) by
% loading the image of the type specified above of every image set and
% averaging them together. It is then acceptable to use the resulting image
% later in the pipeline. Subsequent runs through the pipeline (i.e. for
% cycle 2 through the end) produce no new results. The averaged image
% calculated during the first cycle is still available to other modules
% during subsequent cycles.
%   If you choose Pipeline, the module will calculate the single, averaged
% image during the last cycle of the pipeline. This is because it must wait
% for preceding modules in the pipeline to produce their results before it
% can calculate an averaged image. For example, you cannot calculate the
% average of all Cropped images until after the last image cycle completes
% and the last cropped image is produced. Note that in this mode, the
% resulting averaged image will not be available until the last cycle has
% been processed, so the averaged image it produces cannot be used in
% subsequent modules unless they are instructed to wait until the last
% cycle.
%
% See also CorrectIllumination_Calculate.

% CellProfiler is distributed under the GNU General Public License.
% See the accompanying file LICENSE for details.
%
% Developed by the Whitehead Institute for Biomedical Research.
% Copyright 2003,2004,2005.
%
% Authors:
%   Anne E. Carpenter
%   Thouis Ray Jones
%   In Han Kang
%   Ola Friman
%   Steve Lowe
%   Joo Han Chang
%   Colin Clarke
%   Mike Lamprecht
%   Peter Swire
%   Rodrigo Ipince
%   Vicky Lay
%   Jun Liu
%   Chris Gang
%
% Website: http://www.cellprofiler.org
%
% $Revision: 4102 $

%%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%%
drawnow

[CurrentModule, CurrentModuleNum, ModuleName] = CPwhichmodule(handles);

%textVAR01 = What did you call the images to be averaged (made into a projection)?
%infotypeVAR01 = imagegroup
ImageName = char(handles.Settings.VariableValues{CurrentModuleNum,1});
%inputtypeVAR01 = popupmenu

%textVAR02 = What do you want to call the averaged image?
%defaultVAR02 = AveragedBlue
%infotypeVAR02 = imagegroup indep
AveragedImageName = char(handles.Settings.VariableValues{CurrentModuleNum,2});

%textVAR03 = Are the images you want to use to be loaded straight from a Load Images module, or are they being produced by the pipeline?
%choiceVAR03 = Load Images module
%choiceVAR03 = Pipeline
SourceIsLoadedOrPipeline = char(handles.Settings.VariableValues{CurrentModuleNum,3});
SourceIsLoadedOrPipeline = SourceIsLoadedOrPipeline(1);
%inputtypeVAR03 = popupmenu

%%%VariableRevisionNumber = 1

%%%%%%%%%%%%%%%%%%%%%%
%%% IMAGE ANALYSIS %%%
%%%%%%%%%%%%%%%%%%%%%%
drawnow

%%% If running in non-cycling mode (straight from the hard drive using a
%%% Load Images module), the averaged image and its flag need only be
%%% calculated and saved to the handles structure after the first cycle is
%%% processed. If running in cycling mode (Pipeline mode), the averaged
%%% image and its flag are saved to the handles structure after every cycle
%%% is processed.
if strncmpi(SourceIsLoadedOrPipeline, 'L',1) && handles.Current.SetBeingAnalyzed ~= 1
    return
end

ReadyFlag = 'Not Ready';
try
    if strncmpi(SourceIsLoadedOrPipeline, 'L',1)
        %%% If we are in Load Images mode, the averaged image is calculated
        %%% the first time the module is run.
        if  isfield(handles.Pipeline,['Pathname', ImageName]);
            [handles, AveragedImage, ReadyFlag] = CPaverageimages(handles, 'DoNow', ImageName, 'ignore');
        else
            error(['Image processing was canceled in the ', ModuleName, ' module because CellProfiler could not look up the name of the folder where the ' ImageName ' images were loaded from.  This is most likely because this module is not using images that were loaded directly from the load images module. See help for more details.']);
        end
    elseif strncmpi(SourceIsLoadedOrPipeline, 'P',1)
        [handles, AveragedImage, ReadyFlag] = CPaverageimages(handles, 'Accumulate', ImageName, AveragedImageName);
    else
        error(['Image processing was canceled in the ', ModuleName, ' module because you must choose either "Load images" or "Pipeline".']);
    end
catch [ErrorMessage, ErrorMessage2] = lasterr;
    error(['An error occurred in the ', ModuleName, ' module. Matlab says the problem is: ', ErrorMessage, ErrorMessage2])
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% DISPLAY RESULTS %%%
%%%%%%%%%%%%%%%%%%%%%%%
drawnow

ThisModuleFigureNumber = handles.Current.(['FigureNumberForModule',CurrentModule]);
if any(findobj == ThisModuleFigureNumber)
    %%% Activates the appropriate figure window.
    CPfigure(handles,'Image',ThisModuleFigureNumber);
    if handles.Current.SetBeingAnalyzed == handles.Current.StartingImageSet
        CPresizefigure(AveragedImage,'OneByOne',ThisModuleFigureNumber)
    end
    CPimagesc(AveragedImage,handles);
    if strncmpi(SourceIsLoadedOrPipeline, 'L',1)
        %%% The averaged image is displayed the first time through the set.
        %%% For subsequent cycles, this figure is not updated at all, to
        %%% prevent the need to load the averaged image from the handles
        %%% structure.
        title(['Final Averaged Image, based on all ', num2str(handles.Current.NumberOfImageSets), ' images']);
    elseif strncmpi(SourceIsLoadedOrPipeline, 'P',1)
        %%% The accumulated averaged image so far is displayed each time
        %%% through the pipeline.
        title(['Averaged Image so far, based on image # 1 - ', num2str(handles.Current.SetBeingAnalyzed)]);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SAVE DATA TO HANDLES STRUCTURE %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

%%% Saves the averaged image to the handles structure so it can be used by
%%% subsequent modules.
handles.Pipeline.(AveragedImageName) = AveragedImage;
%%% Saves the ready flag to the handles structure so it can be used by
%%% subsequent modules.
fieldname = [AveragedImageName,'ReadyFlag'];
handles.Pipeline.(fieldname) = ReadyFlag;