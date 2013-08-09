function handles = GrayToColor(handles)
  
% Help for the Gray To Color module:
% Category: Image Processing
%
% SHORT DESCRIPTION:
% Takes 1 to 3 images and assigns them to colors in a final red, green,
% blue (RGB) image. Each color's brightness can be adjusted independently.
% *************************************************************************
%
% This module takes up to three grayscale images as inputs, and produces a
% new color (RGB) image which results from assigning each of the input
% images the colors red, green, and blue in the color image, respectively.
% In addition, each color's intensity can be adjusted independently by
% using adjustment factors (see below).
%
% Settings:
%
% Choose the input images: You must select at least one image which you
% would like to use to create the color image. Also, all images must be the
% same size, since they will combined pixel by pixel.
%
% Adjustment factors: Leaving the adjustment factors set to 1 will balance
% all three colors equally in the final image, and they will use the same
% range of intensities as each individual incoming image. Using factors
% less than 1 will decrease the intensity of that color in the final image,
% and values greater than 1 will increase it. Setting the adjustment factor
% to zero will cause that color to be entirely blank.
%
% See also ColorToGray.

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
% $Revision: 4428 $

%%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%%
drawnow

[CurrentModule, CurrentModuleNum, ModuleName] = CPwhichmodule(handles);

%textVAR01 = What did you call the image to be colored red?
%choiceVAR01 = Leave this black
%infotypeVAR01 = imagegroup
RedImageName = char(handles.Settings.VariableValues{CurrentModuleNum,1});
%inputtypeVAR01 = popupmenu custom

%textVAR02 = What did you call the image to be colored green?
%choiceVAR02 = Leave this black
%infotypeVAR02 = imagegroup
GreenImageName = char(handles.Settings.VariableValues{CurrentModuleNum,2});
%inputtypeVAR02 = popupmenu custom

%textVAR03 = What did you call the image to be colored blue?
%choiceVAR03 = Leave this black
%infotypeVAR03 = imagegroup
BlueImageName = char(handles.Settings.VariableValues{CurrentModuleNum,3});
%inputtypeVAR03 = popupmenu custom

%textVAR04 = What do you want to call the resulting image?
%defaultVAR04 = ColorImage
%infotypeVAR04 = imagegroup indep
RGBImageName = char(handles.Settings.VariableValues{CurrentModuleNum,4});

%textVAR05 = Enter the adjustment factor for the red image
%defaultVAR05 = 1
RedAdjustmentFactor = char(handles.Settings.VariableValues{CurrentModuleNum,5});

%textVAR06 = Enter the adjustment factor for the green image
%defaultVAR06 = 1
GreenAdjustmentFactor = char(handles.Settings.VariableValues{CurrentModuleNum,6});

%textVAR07 = Enter the adjustment factor for the blue image
%defaultVAR07 = 1
BlueAdjustmentFactor = char(handles.Settings.VariableValues{CurrentModuleNum,7});

%%%VariableRevisionNumber = 2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRELIMINARY CALCULATIONS & FILE HANDLING %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

%%% Determines whether the user has specified an image to be loaded in
%%% blue.
if ~strcmp(BlueImageName, 'Leave this black')
    %%% Read (open) the images and assign them to variables.
    BlueImage = CPretrieveimage(handles,BlueImageName,ModuleName,'MustBeGray','CheckScale');
    BlueImageExists = 1;
else
    BlueImageExists = 0;
end

%%% Repeat for Green and Red.
if ~strcmp(GreenImageName, 'Leave this black')
    GreenImage = CPretrieveimage(handles,GreenImageName,ModuleName,'MustBeGray','CheckScale');
    GreenImageExists = 1;
else GreenImageExists = 0;
end

if ~strcmp(RedImageName, 'Leave this black')
    RedImage = CPretrieveimage(handles,RedImageName,ModuleName,'MustBeGray','CheckScale');
    RedImageExists = 1;
else RedImageExists = 0;
end
drawnow

%%% If any of the colors are to be left black, creates the appropriate
%%% image.
if ~BlueImageExists && ~RedImageExists && ~GreenImageExists
    error(['Image processing was canceled in the ', ModuleName, ' module because you have not selected any images to be merged.'])
end
if ~BlueImageExists && ~RedImageExists && GreenImageExists
    BlueImage = zeros(size(GreenImage));
    RedImage = zeros(size(GreenImage));
end
if ~BlueImageExists && RedImageExists && ~GreenImageExists
    BlueImage = zeros(size(RedImage));
    GreenImage = zeros(size(RedImage));
end
if BlueImageExists && ~RedImageExists && ~GreenImageExists
    RedImage = zeros(size(BlueImage));
    GreenImage = zeros(size(BlueImage));
end
if BlueImageExists && RedImageExists && ~GreenImageExists
    GreenImage = zeros(size(BlueImage));
end
if ~BlueImageExists && RedImageExists && GreenImageExists
    BlueImage = zeros(size(GreenImage));
end
if BlueImageExists && ~RedImageExists && GreenImageExists
    RedImage = zeros(size(BlueImage));
end

%%% Checks whether the three images are the same size.
if any(size(BlueImage) ~= size(GreenImage)) || any(size(RedImage) ~= size(GreenImage))
    error(['Image processing was canceled in the ', ModuleName, ' module because the three images selected are not the same size.  The pixel dimensions must be identical. Most likely one of the images is not in the same format as the others - for example, one of the images might already be in color (RGB) format.'])
end
%%% Check to see if all adjustment factors are in the correct range of 0 to
%%% 1
if (str2double(RedAdjustmentFactor) < 0.0) || isnan(str2double(RedAdjustmentFactor))
    if isempty(findobj('Tag',['Msgbox_' ModuleName ', ModuleNumber ' num2str(CurrentModuleNum) ': Red adjustment factor invalid']))
        CPwarndlg(['The red adjustment factor you have entered in the ' ModuleName ' module is invalid or less than 0. It is being set to the default value of 1.'],[ModuleName ', ModuleNumber ' num2str(CurrentModuleNum) ': Red adjustment factor invalid']);
    end
    RedAdjustmentFactor = '1';
end
if (str2double(GreenAdjustmentFactor) < 0.0) || isnan(str2double(GreenAdjustmentFactor))
    if isempty(findobj('Tag',['Msgbox_' ModuleName ', ModuleNumber ' num2str(CurrentModuleNum) ': Green adjustment factor invalid']))
        CPwarndlg(['The green adjustment factor you have entered in the ' ModuleName ' module is invalid or less than 0. It is being set to the default value of 1.'],[ModuleName ', ModuleNumber ' num2str(CurrentModuleNum) ': Green adjustment factor invalid']);
    end
    GreenAdjustmentFactor = '1';
end
if (str2double(BlueAdjustmentFactor) < 0.0) || isnan(str2double(BlueAdjustmentFactor))
    if isempty(findobj('Tag',['Msgbox_' ModuleName ', ModuleNumber ' num2str(CurrentModuleNum) ': Blue adjustment factor invalid']))
        CPwarndlg(['The blue adjustment factor you have entered in the ' ModuleName ' module is invalid or less than 0. It is being set to the default value of 1.'],[ModuleName ', ModuleNumber ' num2str(CurrentModuleNum) ': Blue adjustment factor invalid']);
    end
    BlueAdjustmentFactor = '1';
end
%%%%%%%%%%%%%%%%%%%%%%
%%% IMAGE ANALYSIS %%%
%%%%%%%%%%%%%%%%%%%%%%
drawnow

%%% If any of the images are binary/logical format, they must be
%%% converted to a double first before immultiply.
RGBImage(:,:,1) = immultiply(double(RedImage),str2double(RedAdjustmentFactor));
RGBImage(:,:,2) = immultiply(double(GreenImage),str2double(GreenAdjustmentFactor));
RGBImage(:,:,3) = immultiply(double(BlueImage),str2double(BlueAdjustmentFactor));

%%%%%%%%%%%%%%%%%%%%%%%
%%% DISPLAY RESULTS %%%
%%%%%%%%%%%%%%%%%%%%%%%
drawnow

ThisModuleFigureNumber = handles.Current.(['FigureNumberForModule',CurrentModule]);
if any(findobj == ThisModuleFigureNumber)
    %%% Activates the appropriate figure window.
    CPfigure(handles,'Image',ThisModuleFigureNumber);
    if handles.Current.SetBeingAnalyzed == handles.Current.StartingImageSet
        CPresizefigure(RGBImage,'TwoByTwo',ThisModuleFigureNumber);
    end
    %%% A subplot of the figure window is set to display the Merged RGB
    %%% image.  Using CPimagesc or image instead of imshow doesn't work when
    %%% some of the pixels are saturated.
    subplot(2,2,1); 
    CPimagesc(RGBImage,handles);
    title(['Merged Color Image, cycle # ',num2str(handles.Current.SetBeingAnalyzed)]);
    %%% A subplot of the figure window is set to display the blue image.
    subplot(2,2,2); 
    CPimagesc(BlueImage,handles); 
    title('Blue Image');
    %%% A subplot of the figure window is set to display the green image.
    subplot(2,2,3); 
    CPimagesc(GreenImage,handles); 
    title('Green Image');
    %%% A subplot of the figure window is set to display the red image.
    subplot(2,2,4); 
    CPimagesc(RedImage,handles); 
    title('Red Image');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SAVE DATA TO HANDLES STRUCTURE %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

%%% Saves the adjusted image to the handles structure so it can be used by
%%% subsequent modules.
handles.Pipeline.(RGBImageName) = RGBImage;