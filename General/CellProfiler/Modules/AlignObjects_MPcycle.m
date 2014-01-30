function handles = AlignObjects_MPcycle(handles)

% Help for the ALIGNOBJECTS_MPCYCLE module:
% Category: Other
%
% SHORT DESCRIPTION: 
% Loads shift descriptors (structure stored as .json file) from iBRAIN's
% ALIGNCYCLES directory and obtains intensity as well as segmentation image
% from the handles. Then it aligns the intensity and the segmentation
% images. To this end, both images are cropped according to the loaded
% shift descriptors.
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

%textVAR01 = What did you call the intensity image that you want to shift?
%infotypeVAR01 = imagegroup
IntImName = char(handles.Settings.VariableValues{CurrentModuleNum,1});
%inputtypeVAR01 = popupmenu

%textVAR02 = What did you call the objects that you want to measure later?
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

%textVAR08 = How do you want to call the shifted intensity image?
%defaultVAR08 = AlignedGreen
%infotypeVAR08 = imagegroup indep
IntImOutputName = char(handles.Settings.VariableValues{CurrentModuleNum,8});




%%%%%%%%%%%%%%%%%%
%%% PROCESSING %%%
%%%%%%%%%%%%%%%%%%

%%% retrieve shift descriptors from handles
shift = handles.shiftDescriptor;

%%% retrieve intensity image
IntensityImage = CPretrieveimage(handles,IntImName,ModuleName,'MustBeGray','CheckScale');

%%% load and shift/crop images

% get index of current image
strOrigImageName = char(handles.Measurements.Image.FileNames{handles.Current.SetBeingAnalyzed}{1,1});
strLookup = regexprep(strOrigImageName,'A\d{2}Z\d{2}C\d{2}','A\\d{2}Z\\d{2}C\\d{2}');
index = find(cell2mat(regexp(cellstr(shift.fileName),strLookup)));

% align and crop intensity image according to shift descriptor
if abs(shift.yShift(index))>shift.maxShift || abs(shift.xShift(index))>shift.maxShift % don't shift images if shift values are very high (reflects empty images)
    IntensityOutputImage = IntensityImage(1+shift.lowerOverlap : end-shift.upperOverlap, 1+shift.rightOverlap : end-shift.leftOverlap);
else
    IntensityOutputImage = IntensityImage(1+shift.lowerOverlap-shift.yShift(index) : end-(shift.upperOverlap+shift.yShift(index)), 1+shift.rightOverlap-shift.xShift(index) : end-(shift.leftOverlap+shift.xShift(index)));
end
% do the same for segmentation images
SegmentationImages = cell(1,length(ObjectNameList));
SegmentationOutputImages = cell(1,length(ObjectNameList));
for i = 1:length(ObjectNameList)
    ObjectName = ObjectNameList{i};
    if strcmpi(ObjectName,'Do not use')
        continue
    end
    % load segmentation image
    SegmentationImages{i} = CPretrieveimage(handles,['Segmented', ObjectName],ModuleName,'MustBeGray','DontCheckScale');
    % shift/crop segmenation image
    SegmentationOutputImages{i} = SegmentationImages{i}(1+shift.lowerOverlap : end-shift.upperOverlap, 1+shift.rightOverlap : end-shift.leftOverlap);

end



%%%%%%%%%%%%%%%
%%% DISPLAY %%%
%%%%%%%%%%%%%%%


drawnow

ThisModuleFigureNumber = handles.Current.(['FigureNumberForModule',CurrentModule]);
if any(findobj == ThisModuleFigureNumber)
       
    CPfigure(handles,'Image',ThisModuleFigureNumber);
    
    %%% Calculates the object outlines, which are overlaid on the intensity
    %%% image.
    %%% Creates the structuring element that will be used for dilation.
    StructuringElement = strel('square',3);
    %%% Converts the FinalLabelMatrixImage to binary.
    FinalBinaryImage = im2bw(SegmentationImages{1},.5);
    %%% Dilates the FinalBinaryImage by one pixel (8 neighborhood).
    DilatedBinaryImage = imdilate(FinalBinaryImage, StructuringElement);
    %%% Subtracts the FinalBinaryImage from the DilatedBinaryImage,
    %%% which leaves the PrimaryObjectOutlines.
    PrimaryObjectOutlines = DilatedBinaryImage - FinalBinaryImage;
    %%% Overlays the object outlines on the original image.
    ObjectOutlinesOnIntImage = IntensityImage;
    %%% Determines the grayscale intensity to use for the cell outlines.
    LineIntensity = max(IntensityOutputImage(:));
    ObjectOutlinesOnIntImage(PrimaryObjectOutlines == 1) = LineIntensity;
    %%% display original images
    subplot(1,2,1); 
    CPimagesc(ObjectOutlinesOnIntImage,handles);
    title([ObjectNameList{1}, ' Outlines on Original Intensity Image']);
    
    %%% Calculates the object outlines, which are overlaid on the intensity
    %%% image.
    %%% Creates the structuring element that will be used for dilation.
    StructuringElement2 = strel('square',3);
    %%% Converts the FinalLabelMatrixImage to binary.
    FinalBinaryImage2 = im2bw(SegmentationOutputImages{1},.5);
    %%% Dilates the FinalBinaryImage by one pixel (8 neighborhood).
    DilatedBinaryImage2 = imdilate(FinalBinaryImage2, StructuringElement2);
    %%% Subtracts the FinalBinaryImage from the DilatedBinaryImage,
    %%% which leaves the PrimaryObjectOutlines.
    PrimaryObjectOutlines2 = DilatedBinaryImage2 - FinalBinaryImage2;
    %%% Overlays the object outlines on the original image.
    ObjectOutlinesOnIntImage2 = IntensityOutputImage;
    %%% Determines the grayscale intensity to use for the cell outlines.
    LineIntensity2 = max(IntensityOutputImage(:));
    ObjectOutlinesOnIntImage2(PrimaryObjectOutlines2 == 1) = LineIntensity2;
    %%% display aligned images
    subplot(1,2,2); 
    CPimagesc(ObjectOutlinesOnIntImage2,handles);
    title([ObjectNameList{1}, ' Outlines on Aligned Intensity Image']);     
    
    drawnow
end



%%%%%%%%%%%%%%
%%% OUTPUT %%%
%%%%%%%%%%%%%%


%%% save shifted images to handles
handles.Pipeline.(IntImOutputName) = IntensityOutputImage;

for i = 1:length(ObjectNameList)
    ObjectName = ObjectNameList{i};
    if strcmpi(ObjectName,'Do not use')
        continue
    end
    
    %%% Saves the segmented image, not edited for objects along the edges or
    %%% for size, to the handles structure.
    fieldname = ['UneditedSegmented',ObjectName];
    handles.Pipeline.(fieldname) = SegmentationOutputImages{i};
    
    %%% Saves the segmented image, only edited for small objects, to the
    %%% handles structure.
    fieldname = ['SmallRemovedSegmented',ObjectName];
    handles.Pipeline.(fieldname) = SegmentationOutputImages{i};
    
    %%% Saves the final segmented label matrix image to the handles structure.
    fieldname = ['Segmented',ObjectName];
    handles.Pipeline.(fieldname) = SegmentationOutputImages{i};
    
    %%% Saves the ObjectCount, i.e., the number of segmented objects.
    %%% See comments for the Threshold saving above
    if ~isfield(handles.Measurements.Image,'ObjectCountFeatures')
        handles.Measurements.Image.ObjectCountFeatures = {};
        handles.Measurements.Image.ObjectCount = {};
    end
    column = find(~cellfun('isempty',strfind(handles.Measurements.Image.ObjectCountFeatures,ObjectName)));
    if isempty(column)
        handles.Measurements.Image.ObjectCountFeatures(end+1) = {ObjectName};
        column = length(handles.Measurements.Image.ObjectCountFeatures);
    end
    handles.Measurements.Image.ObjectCount{handles.Current.SetBeingAnalyzed}(1,column) = max(SegmentationOutputImages{i}(:));
    
    %%% Saves the location of each segmented object
    handles.Measurements.(ObjectName).LocationFeatures = {'CenterX','CenterY'};
    tmp = regionprops(SegmentationOutputImages{i},'Centroid');
    Centroid = cat(1,tmp.Centroid);
    handles.Measurements.(ObjectName).Location(handles.Current.SetBeingAnalyzed) = {Centroid};
    
end

end
