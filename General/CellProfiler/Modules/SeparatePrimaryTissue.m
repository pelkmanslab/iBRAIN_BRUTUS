function handles = SeparatePrimaryTissue(handles)

% Help for SeparatePrimaryTissue
% Category: Object Processing
%
%
% DESCRIPTION:
% Separation of clumped nuclei based on shape and intensity parameters.
% Cuts are made between concave regions of clumped nuclei.
%
% PARAMETERS:
% Shape/cutting passes: Each pass only one cut per concave region is
% allowed, possibly making it neccesary to perform additional cutting
% passes.
%
% Shape/window size: Sliding window for calculating the curvature of objects.
% large = more continuous, smoother but maybe less precise regions,
% small = more precise but smaller and less continuous regions.
%
% Shape/max equivalent radius: Maximum equivalent radius of a concave region
% to be eligible for cutting. Determine via test mode.
% Higher values result in more cuts.
%
% Shape/min equivalent angle: Minimum equivalent circular fragment (degree)
% of a concave region to be eligible for cutting. Determine via test mode.
% Lower values result in more cuts.
%
% Watershed line straightness: Degree of watershed line straightness.
% Selection of watershed lines for cutting is made based on straightness,
% amoung others. 
% Lower values make selection more strict, i.e. selection of less lines as
% potential cutting lines.
%
% Watershed line intensity: Correction factor for intensity threshold
% (relative to mean object intensity).
%
% Shape/Test mode: Displays curvature, convex/concave, equivalent radius
% and segment for each cutting pass. Pick values from images to fine tune
% settings.



%%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%%

%drawnow
[CurrentModule, CurrentModuleNum, ModuleName] = CPwhichmodule(handles);

%textVAR01 = What did you call the primary objects you want to process?
%infotypeVAR01 = objectgroup
NucleiName = char(handles.Settings.VariableValues{CurrentModuleNum,1});
%inputtypeVAR01 = popupmenu

%textVAR02 = What do you want to call the objects identified by this module?
%defaultVAR02 = SeparatedNuclei
%infotypeVAR02 = objectgroup indep
ObjectName = char(handles.Settings.VariableValues{CurrentModuleNum,2});

%textVAR03 = What did you call the original intensity image?
%infotypeVAR03 = imagegroup
IntImageName = char(handles.Settings.VariableValues{CurrentModuleNum,3});
%inputtypeVAR03 = popupmenu

%textVAR04 = Watershed analysis: Cutting passes (0 = no cutting)
%defaultVAR04 = 0
CuttingPasses1 = str2double(char(handles.Settings.VariableValues{CurrentModuleNum,4}));

%textVAR05 = Watershed analysis: line straightness threshold
%defaultVAR05 = 6
ThreStraight = str2double(char(handles.Settings.VariableValues{CurrentModuleNum,5}));

%textVAR06 = Watershed analysis: correction factor for intensity threshold
%defaultVAR06 = 0.2
ThreIntensitycorrectionFactor = str2double(char(handles.Settings.VariableValues{CurrentModuleNum,6}));

%textVAR07 = Watershed analysis: threshold for angle between vectors of concave regions
%defaultVAR07 = 120
ThreAngle = str2double(char(handles.Settings.VariableValues{CurrentModuleNum,7}));

%textVAR08 = Watershed analysis: threshold for fraction of cut objects
%defaultVAR08 = 0.2
ThreFraction = str2double(char(handles.Settings.VariableValues{CurrentModuleNum,8}));

%textVAR09 = Shape analysis: Cutting passes (0 = no cutting)
%defaultVAR09 = 0
CuttingPasses2 = str2double(char(handles.Settings.VariableValues{CurrentModuleNum,9}));

%textVAR10 = Shape analysis: Sliding window size for curvature calculation
%defaultVAR10 = 8
WindowSize = str2double(char(handles.Settings.VariableValues{CurrentModuleNum,10}));

%textVAR11 = Shape analysis: Maximum concave region equivalent radius
%defaultVAR11 = 20
PerimSegEqRadius = str2double(char(handles.Settings.VariableValues{CurrentModuleNum,11}));

%textVAR12 = Shape analysis: Minimum concave region equivalent circular segment (degree)
%defaultVAR12 = 40
PerimSegEqSegment = degtorad(str2double(char(handles.Settings.VariableValues{CurrentModuleNum,12})));

%textVAR13 = Shape analysis: Distance metric method distance between regions
%choiceVAR13 = best
%choiceVAR13 = center
%choiceVAR13 = curvature
PerimSegDistMethod = handles.Settings.VariableValues{CurrentModuleNum,13};
%inputtypeVAR13 = popupmenu

%textVAR14 = Shape analysis: Maximum distance between opposing concave regions
%defaultVAR14 = 50
PerimSegDistance = str2double(char(handles.Settings.VariableValues{CurrentModuleNum,14}));

%textVAR15 = Shape analysis: Angle metric method angle between regions
%choiceVAR15 = best_inline
%choiceVAR15 = best
%choiceVAR15 = center
%choiceVAR15 = curvature
PerimSegAngMethod = handles.Settings.VariableValues{CurrentModuleNum,15};
%inputtypeVAR15 = popupmenu

%textVAR16 = Shape analysis: Maximum angle deviation of opposing concave regions from ideal 180 degree geometry (degree)
%defaultVAR16 = 36
PerimSegAngDeviation = degtorad(str2double(char(handles.Settings.VariableValues{CurrentModuleNum,16})));

%textVAR17 = Shape analysis: Score weight: 1=angle only 0=distance only
%defaultVAR17 = 0.5
PerimSegAngDistRatio = str2double(char(handles.Settings.VariableValues{CurrentModuleNum,17}));

%textVAR18 = Shape analysis: Cut method between opposing regions: depends on distance/angle method!
%choiceVAR18 = angle
%choiceVAR18 = distance
PerimSegCutMethod = handles.Settings.VariableValues{CurrentModuleNum,18};
%inputtypeVAR18 = popupmenu

%textVAR19 = Shape analysis: Minimum resulting area to permit a cut
%defaultVAR19 = 500
MinCutArea = str2double(char(handles.Settings.VariableValues{CurrentModuleNum,19}));

%textVAR20 = Discard border objects
%choiceVAR20 = No
%choiceVAR20 = Yes
DiscardBorder = char(handles.Settings.VariableValues{CurrentModuleNum,20});
%inputtypeVAR20 = popupmenu

%textVAR21 = Discard objects with intensity lower than (0=off)
%defaultVAR21 = 0
MinFilterIntensity = str2double(char(handles.Settings.VariableValues{CurrentModuleNum,21}));

%textVAR22 = Intensity method
%choiceVAR22 = mean
%choiceVAR22 = median
IntensityMethod = str2func(char(handles.Settings.VariableValues{CurrentModuleNum,22}));
%inputtypeVAR22 = popupmenu

%textVAR23 = Test mode for intensity exclusion
%choiceVAR23 = No
%choiceVAR23 = Yes
FilterTestMode = char(handles.Settings.VariableValues{CurrentModuleNum,23});
%inputtypeVAR23 = popupmenu

%textVAR24 = Test mode for shape analysis: overlay curvature etc. on objects
%choiceVAR24 = No
%choiceVAR24 = Yes
TestMode = char(handles.Settings.VariableValues{CurrentModuleNum,24});
%inputtypeVAR24 = popupmenu



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRELIMINARY ERROR CHECKING & FILE HANDLING %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

OrigImage = handles.Pipeline.(IntImageName);
imObjects = CPretrieveimage(handles,['Segmented', NucleiName],ModuleName,'DontCheckColor','DontCheckScale',size(OrigImage));
imObjects = imObjects>0;

%imDapi = imDapi .* 65535;%reverse rescaling done by CP!



%%%%%%%%%%%%%%%%%%%%%%
%%% IMAGE ANALYSIS %%%
%%%%%%%%%%%%%%%%%%%%%%

%% Seperate clumped objects based on shape and intensity using perimeter and watershed analysis, respectively %%

% Parts of the code are derived from IdentifyPrimLoGShape.m   

%%% Define input image for cutting
% Measure solidity
propsCutShapeObj = regionprops(logical(imObjects),'Solidity');
SolidityPerObject = cat(1,propsCutShapeObj.Solidity);
% Create label image for solidity
imShapeLabel = bwlabel(imObjects);
Index = unique(imShapeLabel);
Index(Index==0) = [];
for t = 1:length(Index)
    imShapeLabel(imShapeLabel==Index(t)) = SolidityPerObject(t);
end
%figure,imagesc(ShapeLabelImage)
% Only subject objects with low solidity to shape cutting
imCutShapeObjects = imShapeLabel;
imCutShapeObjects(imShapeLabel>=0.9) = 0;
imSelectedForCutting = imCutShapeObjects;%for later visualization only

imCutShapeObjects(:,:,1) = bwlabel(imCutShapeObjects);

%%% Store objects that are omitted from shape cutting
imNotCut = imShapeLabel>0.9;

%%% Cut objects
% Separate clumped objects along watershed lines
WindowSizeHoles = 4;
cellPerimeterProps = cell(CuttingPasses1,1);
if CuttingPasses1>0
    imCutMask = zeros([size(OrigImage),CuttingPasses1]);
else 
    imCutMask = zeros(size(OrigImage));
end
for i = 1:CuttingPasses1
cellPerimeterProps{i} = PerimeterAnalysis(imCutShapeObjects(:,:,i),WindowSize,WindowSizeHoles);
imCutMask(:,:,i) = PerimeterWatershedSegmentation(imCutShapeObjects(:,:,i),OrigImage,cellPerimeterProps{i},PerimSegEqRadius,PerimSegEqSegment,PerimSegAngMethod,ThreAngle,ThreStraight,ThreIntensitycorrectionFactor,ThreFraction);
imCutShapeObjects(:,:,i+1) = bwlabel(imCutShapeObjects(:,:,i).*~imCutMask(:,:,i));
end
imCutShapeObjects = imCutShapeObjects(:,:,CuttingPasses1+1);%labels are continuous at this point
% Separate remaining clumps via simple cutting (straight line between concave regions)
cellPerimeterProps2 = cell(CuttingPasses2,1);
if CuttingPasses2>0
    imCutMask2 = zeros([size(OrigImage),CuttingPasses2]);
else
    imCutMask2 = zeros(size(OrigImage));
end
for i = 1:CuttingPasses2
cellPerimeterProps2{i} = PerimeterAnalysis(imCutShapeObjects(:,:,i),WindowSize,WindowSizeHoles);
imCutMask2(:,:,i) = PerimeterSegmentation(imCutShapeObjects(:,:,i),cellPerimeterProps2{i},PerimSegEqRadius,PerimSegEqSegment,PerimSegAngDeviation,PerimSegDistance,PerimSegAngDistRatio,PerimSegDistMethod,PerimSegAngMethod,PerimSegCutMethod,MinCutArea);
imCutShapeObjects(:,:,i+1) = bwlabel(imCutShapeObjects(:,:,i).*~imCutMask2(:,:,i));
end
imCutShapeObjects = imCutShapeObjects(:,:,CuttingPasses2+1);%labels are continuous at this point

%%% Retrieve objects that were not cut
imFinalObjects = imCutShapeObjects + imNotCut;


%% Final clean-up

%%% Size filter: discard small objects
ObjectAreas = cell2mat(struct2cell(regionprops(imFinalObjects,'Area')))';
ValidObjectIndices = find(ObjectAreas>100);
imFinalObjectsArea = bwlabel(ismember(imFinalObjects,ValidObjectIndices));%relabel to get continuous indices
%%% Intensity filter: discard very low intensity objects
if MinFilterIntensity>0 || strcmp(FilterTestMode,'Yes')
    PixelProps = regionprops(imFinalObjectsArea,'PixelIdxList');
    ObjectCount = length(PixelProps);
    ObjectMeanIntensities = zeros(ObjectCount,1,'double');
    for i=1:ObjectCount
         ObjectMeanIntensities(i) = IntensityMethod(OrigImage(PixelProps(i).PixelIdxList));
    end
    ValidObjectIndices = find(ObjectMeanIntensities>MinFilterIntensity);
    imFinalObjectsIntensity = bwlabel(ismember(imFinalObjectsArea,ValidObjectIndices));%relabel to get continuous indices
else
    imFinalObjectsIntensity = imFinalObjectsArea;
end
%%% Border filter: disard border objects
if strcmp(DiscardBorder,'Yes')
    BorderIndices = setdiff(unique([imFinalObjectsIntensity(1,1:end),imFinalObjectsIntensity(end,1:end),imFinalObjectsIntensity(1:end,1)',imFinalObjectsIntensity(1:end,end)']),0);
    BorderObjectmask = ismember(imFinalObjectsIntensity,BorderIndices);
    imFinalObjectsIntensityBorder = bwlabel(imFinalObjectsIntensity.*~BorderObjectmask);%relabel to get continuous indices
else
    imFinalObjectsIntensityBorder = imFinalObjectsIntensity;
end



%%%%%%%%%%%%%%%%%%%%%%%
%%% DISPLAY RESULTS %%%
%%%%%%%%%%%%%%%%%%%%%%%

%drawnow

% Create overlay images
imOutlineShapeSeparatedOverlay = OrigImage;
B = bwboundaries(imFinalObjectsIntensityBorder,'holes');
imCutShapeObjectsLabel = label2rgb(bwlabel(imFinalObjectsIntensityBorder),'jet',[1 1 1],'shuffle');

% GUI
imSelectedForCutting = imSelectedForCutting>0;
imCuts = imCutMask + imCutMask2;
imCuts = logical(sum(imCuts,3));
ThisModuleFigureNumber = handles.Current.(['FigureNumberForModule',CurrentModule]);
if any(findobj == ThisModuleFigureNumber)
    CPfigure(handles,'PrimObj: Perimeter segmentation');
    subplot(2,2,1), CPimagesc(imSelectedForCutting,handles),
    title(['Objects selected for cutting, cycle # ',num2str(handles.Current.SetBeingAnalyzed)]);
    hold on
    red = cat(3, ones(size(imSelectedForCutting)), zeros(size(imSelectedForCutting)), zeros(size(imSelectedForCutting)));
    h = imagesc(red);
    set(h, 'AlphaData', imCuts)
    hold off
    freezeColors
    subplot(2,2,2), CPimagesc(imShapeLabel,handles), colormap('jet'),
    title(['Solidity of objects, cycle # ',num2str(handles.Current.SetBeingAnalyzed)]);
    freezeColors
    subplot(2,2,3), CPimagesc(imOutlineShapeSeparatedOverlay,handles),
    title(['Outlines of final objects, cycle # ',num2str(handles.Current.SetBeingAnalyzed)]);
    hold on
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 1)
    end
    hold off
    freezeColors
    subplot(2,2,4), CPimagesc(imCutShapeObjectsLabel,handles),
    title(['Final objects, cycle # ',num2str(handles.Current.SetBeingAnalyzed)]); 
    freezeColors
end

%Plot shape analysis data
if strcmp(TestMode,'Yes')
    for h = 1:CuttingPasses2%plot for all cutting passes!
        imCurvature = zeros(size(OrigImage),'double');
        imConvexConcave = zeros(size(OrigImage),'double');
        imAngle = zeros(size(OrigImage),'double');
        imRadius = zeros(size(OrigImage),'double');
        for i = 1:length(cellPerimeterProps{h})
            matCurrentObjectProps = cellPerimeterProps{h}{i};%get current object
            imConcaveRegions = bwlabel(matCurrentObjectProps(:,11)==-1);
            imConvexRegions = bwlabel(matCurrentObjectProps(:,11)==1);
            AllRegions = imConcaveRegions+(max(imConcaveRegions)+imConvexRegions).*(imConvexRegions>0);%bwlabel only works binary, therefore label convex, concave seperately, then merger labels
            NumRegions = length(setdiff(unique(AllRegions),0));
            for j = 1:size(matCurrentObjectProps,1)%loop over all pixels of object to plot general properties
                imCurvature(matCurrentObjectProps(j,1),matCurrentObjectProps(j,2)) = matCurrentObjectProps(j,9);
                imConvexConcave(matCurrentObjectProps(j,1),matCurrentObjectProps(j,2)) = matCurrentObjectProps(j,11);
            end
            for k = 1:NumRegions%loop over all regions to plot region specific properties
                matCurrentRegionProps = matCurrentObjectProps(AllRegions==k,:);%get current region
                NormCurvature = matCurrentRegionProps(:,9);
                CurrentEqAngle = sum(NormCurvature);
                CurrentEqRadius = length(NormCurvature)/sum(NormCurvature);
                for l = 1:size(matCurrentRegionProps,1)%loop over all pixels in region
                    imRadius(matCurrentRegionProps(l,1),matCurrentRegionProps(l,2)) = CurrentEqRadius;
                    imAngle(matCurrentRegionProps(l,1),matCurrentRegionProps(l,2)) = radtodeg(CurrentEqAngle);
                end
            end
        end
        CPfigure('Tag',strcat('ShapeAnalysisPass',num2str(h)));
        
        subplot(2,2,1);
        CPimagesc(imCurvature,handles);
        title(['Curvature image, cycle # ',num2str(handles.Current.SetBeingAnalyzed),' Pass ',num2str(h)]);
        
        subplot(2,2,2);
        %problem with the CP image range scaling hack: while CPimagesc would
        %accept the range as an argument, 'Open in new window' will ignore
        %it. therefore the function has to be tricked somehow! solution:
        %make rgb image with each channel binary
        RGBConvexConcaveImage = cat(3,(imConvexConcave==1),(imConvexConcave==-1),zeros(size(imConvexConcave)));
        CPimagesc(RGBConvexConcaveImage,handles);
        title(['Convex concave image, cycle # ',num2str(handles.Current.SetBeingAnalyzed),' Pass ',num2str(h)]);
        
        subplot(2,2,3);
        CPimagesc(imAngle,handles);
        title(['Equivalent angle (degree) image, cycle # ',num2str(handles.Current.SetBeingAnalyzed),' Pass ',num2str(h)]);
        
        subplot(2,2,4);
        CPimagesc(imRadius,handles);
        title(['Equivalent radius, cycle # ',num2str(handles.Current.SetBeingAnalyzed),' Pass ',num2str(h)]);
    end
end

%Plot object filter data
if strcmp(FilterTestMode,'Yes')
    IntensityImage=zeros(size(FinalObjects));
    for i=1:size(ObjectMeanIntensities,1)
        IntensityImage(FinalObjects==i) = ObjectMeanIntensities(i);
    end
    CPfigure('Tag','Filter');
    CPimagesc(IntensityImage,handles);
    title('Object intensities');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SAVE DATA TO HANDLES STRUCTURE %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%todo:
%-consider saving more data to handle structure as done in IdentifyPrimAutormatic.m

fieldname = ['UneditedSegmented',ObjectName];%not edited for size or edge
handles.Pipeline.(fieldname) = imFinalObjects;

fieldname = ['SmallRemovedSegmented',ObjectName];%for IdentifySecondary.m
handles.Pipeline.(fieldname) = imFinalObjects;

fieldname = ['Segmented',ObjectName];%final label image
handles.Pipeline.(fieldname) = imFinalObjectsIntensityBorder;

%%% Saves location of each segmented object
handles.Measurements.(ObjectName).LocationFeatures = {'CenterX','CenterY'};
tmp = regionprops(imFinalObjectsIntensityBorder,'Centroid');
Centroid = cat(1,tmp.Centroid);
handles.Measurements.(ObjectName).Location(handles.Current.SetBeingAnalyzed) = {Centroid};

%%% Saves ObjectCount, i.e. number of segmented objects.
if ~isfield(handles.Measurements.Image,'ObjectCountFeatures')
    handles.Measurements.Image.ObjectCountFeatures = {};
    handles.Measurements.Image.ObjectCount = {};
end
column = find(~cellfun('isempty',strfind(handles.Measurements.Image.ObjectCountFeatures,ObjectName)));
if isempty(column)
    handles.Measurements.Image.ObjectCountFeatures(end+1) = {ObjectName};
    column = length(handles.Measurements.Image.ObjectCountFeatures);
end
handles.Measurements.Image.ObjectCount{handles.Current.SetBeingAnalyzed}(1,column) = max(imFinalObjectsIntensityBorder(:));


end

