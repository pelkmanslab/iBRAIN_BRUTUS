function handles = MeasureAdditionalObjectIntensities(handles)

% Help for the Measure Object Intensity module:
% Category: Measurement
%
% SHORT DESCRIPTION:
% MeasuresAdditionalObject
% *************************************************************************
%
% Given an image with objects identified (e.g. nuclei or cells), this
% module extracts intensity features for each object based on a
% corresponding grayscale image. Measurements are recorded for each object.
%
% Measurement:             Feature Number:
% WeightedCentroidX        |       1
% WeightedCentroidY        |       2
%
% How it works:
% Retrieves objects in label matrix format and a corresponding original
% grayscale image and makes measurements of the objects. The label matrix
% image should be "compacted": that is, each number should correspond to an
% object, with no numbers skipped. So, if some objects were discarded from
% the label matrix image, the image should be converted to binary and
% re-made into a label matrix image before feeding it to this module.
%
% See also MeasureAdditionalObjectIntensities.

% CellProfiler is distributed under the GNU General Public License.
% See the accompanying file LICENSE for details.
%
% Developed by the Whitehead Institute for Biomedical Research.
% Copyright 2003,2004,2005.
%
% Authors:
%   TS
%
% $Revision: 4526 $

%%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%%
drawnow

[CurrentModule, CurrentModuleNum, ModuleName] = CPwhichmodule(handles);

%textVAR01 = What did you call the greyscale images you want to measure?
%infotypeVAR01 = imagegroup
ImageName = char(handles.Settings.VariableValues{CurrentModuleNum,1});
%inputtypeVAR01 = popupmenu

%textVAR02 = What did you call the objects that you want to measure?
%choiceVAR02 = Do not use
%infotypeVAR02 = objectgroup
ObjectNameList{1} = char(handles.Settings.VariableValues{CurrentModuleNum,2});
%inputtypeVAR02 = popupmenu

%textVAR03 = Type "Do not use" in unused boxes.
%choiceVAR03 = Do not use
%infotypeVAR03 = objectgroup
ObjectNameList{2} = char(handles.Settings.VariableValues{CurrentModuleNum,3});
%inputtypeVAR03 = popupmenu

%textVAR04 =
%choiceVAR04 = Do not use
%infotypeVAR04 = objectgroup
ObjectNameList{3} = char(handles.Settings.VariableValues{CurrentModuleNum,4});
%inputtypeVAR04 = popupmenu

%textVAR05 =
%choiceVAR05 = Do not use
%infotypeVAR05 = objectgroup
ObjectNameList{4} = char(handles.Settings.VariableValues{CurrentModuleNum,5});
%inputtypeVAR05 = popupmenu

%textVAR06 =
%choiceVAR06 = Do not use
%infotypeVAR06 = objectgroup
ObjectNameList{5} = char(handles.Settings.VariableValues{CurrentModuleNum,6});
%inputtypeVAR06 = popupmenu

%textVAR07 =
%choiceVAR07 = Do not use
%infotypeVAR07 = objectgroup
ObjectNameList{6} = char(handles.Settings.VariableValues{CurrentModuleNum,7});
%inputtypeVAR07 = popupmenu

%%%VariableRevisionNumber = 2

%%% Set up the window for displaying the results
ThisModuleFigureNumber = handles.Current.(['FigureNumberForModule',CurrentModule]);
if any(findobj == ThisModuleFigureNumber);
    CPfigure(handles,'Text',ThisModuleFigureNumber);
    columns = 1;
end

%%% START LOOP THROUGH ALL THE OBJECTS
for i = 1:length(ObjectNameList)
    ObjectName = ObjectNameList{i};
    if strcmpi(ObjectName,'Do not use')
        continue
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% PRELIMINARY CALCULATIONS & FILE HANDLING %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    drawnow
    
    %%% Reads (opens) the image you want to analyze and assigns it to a variable,
    %%% "OrigImage".
    OrigImage = CPretrieveimage(handles,ImageName,ModuleName);
    
    %%% If the image is three dimensional (i.e. color), the three channels
    %%% are added together in order to measure object intensity.
    if ndims(OrigImage) ~= 2
        s = size(OrigImage);
        if (length(s) == 3 && s(3) == 3)
            OrigImage = OrigImage(:,:,1)+OrigImage(:,:,2)+OrigImage(:,:,3);
        else
            error(['Image processing was canceled in the ', ModuleName, ' module. There was a problem with the dimensions. The image must be grayscale or RGB color.'])
        end
    end
    
    %%% Retrieves the label matrix image that contains the segmented objects which
    %%% will be measured with this module.
    LabelMatrixImage = CPretrieveimage(handles,['Segmented', ObjectName],ModuleName,'MustBeGray','DontCheckScale');
    
    %%% For the cases where the label matrix was produced from a cropped
    %%% image, the sizes of the images will not be equal. So, we crop the
    %%% LabelMatrix and try again to see if the matrices are then the
    %%% proper size. Removes Rows and Columns that are completely blank.
    if any(size(OrigImage) < size(LabelMatrixImage))
        ColumnTotals = sum(LabelMatrixImage,1);
        RowTotals = sum(LabelMatrixImage,2)';
        warning off all
        ColumnsToDelete = ~logical(ColumnTotals);
        RowsToDelete = ~logical(RowTotals);
        warning on all
        drawnow
        CroppedLabelMatrix = LabelMatrixImage;
        CroppedLabelMatrix(:,ColumnsToDelete,:) = [];
        CroppedLabelMatrix(RowsToDelete,:,:) = [];
        clear LabelMatrixImage
        LabelMatrixImage = CroppedLabelMatrix;
        %%% In case the entire image has been cropped away, we store a single
        %%% zero pixel for the variable.
        if isempty(LabelMatrixImage)
            LabelMatrixImage = 0;
        end
    end
    
    if any(size(OrigImage) ~= size(LabelMatrixImage))
        error(['Image processing was canceled in the ', ModuleName, ' module. The size of the image you want to measure is not the same as the size of the image from which the ',ObjectName,' objects were identified.'])
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% MAKE MEASUREMENTS & SAVE TO HANDLES STRUCTURE %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    drawnow
    
    %%% Initialize measurement structure
    Basic = [];
    BasicFeatures    = {'WeightedCentroidX',...
        'WeightedCentroidY'};
    
    %%% Get pixel indexes (fastest way), and count objects
    props = regionprops(LabelMatrixImage,OrigImage,'WeightedCentroid');
    
    ObjectCount = length(props);
    if ObjectCount > 0
        
        Basic = zeros(ObjectCount,2);
        
        %[sr sc] = size(LabelMatrixImage);
        for Object = 1:ObjectCount
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% [bs081112] TEMP BEREND DEBUGGING %%% [TS 120509 adjusted for different props]
            if isempty(props(Object).WeightedCentroid)
                disp(sprintf('%s: BEREND BUGFIX: DETECTED EMPTY OBJECT, SKIPPING MEASUREMENT.',mfilename))
                continue
            end
            
            
            try
                %%% Measure basic set of Intensity features
                %                 if isempty(props(Object).PixelIdxList)
                Basic(Object,1) = props(Object).WeightedCentroid(1);
                Basic(Object,2) = props(Object).WeightedCentroid(2);
            catch caughtError
                disp('BEREND HACK: DETECTED ERROR, START DISPLAYING VARIABLE VALUES.')
                
                ImageName
                handles.Current.SetBeingAnalyzed
                ObjectName
                ObjectCount
                Basic
                Object
                props
                
                try
                    props(Object)
                end
                try
                    props(Object).PixelIdxList
                end
                
                disp('BEREND HACK: RETHROW THE ORIGINAL ERROR. WE ARE GONNA CRASH NOW...')
                rethrow(caughtError)
            end
            %%%   [bs081112] END OF DEBUGGING    %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        end
    else
        Basic(1,1:2) = 0;
    end
    %%% Save measurements
    handles.Measurements.(ObjectName).(['AdditionalIntensity_',ImageName,'Features']) = BasicFeatures;
    handles.Measurements.(ObjectName).(['AdditionalIntensity_',ImageName])(handles.Current.SetBeingAnalyzed) = {Basic};
    
    %%% Report measurements
    if any(findobj == ThisModuleFigureNumber);
        FontSize = handles.Preferences.FontSize;
        if handles.Current.SetBeingAnalyzed == handles.Current.StartingImageSet
            delete(findobj('parent',ThisModuleFigureNumber,'string','R'));
            delete(findobj('parent',ThisModuleFigureNumber,'string','G'));
            delete(findobj('parent',ThisModuleFigureNumber,'string','B'));
        end
        %%%% This first block writes the same text several times
        %%% Header
        
        uicontrol(ThisModuleFigureNumber,'style','text','units','normalized', 'position', [0 0.95 1 0.04],...
            'HorizontalAlignment','center','BackgroundColor',[.7 .7 .9],'fontname','Helvetica',...
            'fontsize',FontSize,'fontweight','bold','string',sprintf(['Average intensity features for ', ImageName,', cycle #%d'],handles.Current.SetBeingAnalyzed));
        
        %%% Number of objects
        uicontrol(ThisModuleFigureNumber,'style','text','units','normalized', 'position', [0.05 0.85 0.3 0.03],...
            'HorizontalAlignment','left','BackgroundColor',[.7 .7 .9],'fontname','Helvetica',...
            'fontsize',FontSize,'fontweight','bold','string','Number of objects:');
        
        %%% Text for Basic features
        uicontrol(ThisModuleFigureNumber,'style','text','units','normalized', 'position', [0.05 0.8 0.3 0.03],...
            'HorizontalAlignment','left','BackgroundColor',[.7 .7 .9],'fontname','Helvetica',...
            'fontsize',FontSize,'fontweight','bold','string','Intensity feature:');
        for k = 1:2
            uicontrol(ThisModuleFigureNumber,'style','text','units','normalized', 'position', [0.05 0.8-0.04*k 0.3 0.03],...
                'HorizontalAlignment','left','BackgroundColor',[.7 .7 .9],'fontname','Helvetica',...
                'fontsize',FontSize,'string',BasicFeatures{k});
        end
        
        %%% The name of the object image
        uicontrol(ThisModuleFigureNumber,'style','text','units','normalized', 'position', [0.35+0.1*(columns-1) 0.9 0.1 0.03],...
            'HorizontalAlignment','center','BackgroundColor',[.7 .7 .9],'fontname','Helvetica',...
            'fontsize',FontSize,'fontweight','bold','string',ObjectName);
        
        %%% Number of objects
        uicontrol(ThisModuleFigureNumber,'style','text','units','normalized', 'position', [0.35+0.1*(columns-1) 0.85 0.1 0.03],...
            'HorizontalAlignment','center','BackgroundColor',[.7 .7 .9],'fontname','Helvetica',...
            'fontsize',FontSize,'string',num2str(ObjectCount));
        
        if ObjectCount > 0
            %%% Basic features
            for k = 1:2
                uicontrol(ThisModuleFigureNumber,'style','text','units','normalized', 'position', [0.35+0.1*(columns-1) 0.8-0.04*k 0.1 0.03],...
                    'HorizontalAlignment','center','BackgroundColor',[.7 .7 .9],'fontname','Helvetica',...
                    'fontsize',FontSize,'string',sprintf('%0.2f',mean(Basic(:,k))));
            end
        end
        %%% This variable is used to write results in the correct column
        %%% and to determine the correct window size
        columns = columns + 1;
    end
end