function handles = IdentifyPrimLoGCP3D(handles)
% Help for the IdentifyPrimLGCP3D module:
% Category: Object Processing
%
% SHORT DESCRIPTION:
% Will Determine Spots in 3D Image stacks by Laplacian Of Gaussian
% Filtering.
%
% Filtering can either be done in 2D or in 3D according to Raj et al.; In
% addition security thresholds are included to add limits of the rescaling
% of individual images prior to application of the filtering. This can
% prevent the identification of true positive, but biological false
% positive, spots in dim images, e.g. if autofluorescence is grainy 
%
% *************************************************************************


drawnow

[CurrentModule, CurrentModuleNum, ModuleName] = CPwhichmodule(handles);

%textVAR01 = What did you call the images you want to process?
%infotypeVAR01 = imagegroup
StackName = char(handles.Settings.VariableValues{CurrentModuleNum,1});
%inputtypeVAR01 = popupmenu

%textVAR02 = What do you want to call the objects identified by this module?
%defaultVAR02 = Spots
%infotypeVAR02 = objectgroup indep
ObjectName = char(handles.Settings.VariableValues{CurrentModuleNum,2});

%textVAR03 = Which Spot amplification do you want to use?
%choiceVAR03 = 3D LoG, Raj
%choiceVAR03 = 2D LoG
iFilterType = char(handles.Settings.VariableValues{CurrentModuleNum,3});
%inputtypeVAR03 = popupmenu

%textVAR04 = ObjectSize
%defaultVAR04 = 6
iHsize = char(handles.Settings.VariableValues{CurrentModuleNum,4});

%textVAR05 = Intensity Quanta Per Image
%defaultVAR05 = [0.01 0.99]
iImgLimes = char(handles.Settings.VariableValues{CurrentModuleNum,5});

%textVAR06 = Intensity borders for intensity rescaling of images
%[MinOfMinintens MaxOfMinintens MinOfMaxintens MaxOfMaxintens]
%defaultVAR06 = [NaN 120 500 NaN]
iRescaleThr = char(handles.Settings.VariableValues{CurrentModuleNum,6});

%textVAR07 = Threshold of Spot Detection
%defaultVAR07 = 0.01
iDetectionThr = char(handles.Settings.VariableValues{CurrentModuleNum,7});

%textVAR08 = What is the minimal intensity of a pixel within a spot?
%defaultVAR08 = /
iObjIntensityThr = char(handles.Settings.VariableValues{CurrentModuleNum,8});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  CHECK INPUT   %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Filter Size
try
    iHsize = str2double(iHsize);
catch errFilterSize
    error(['Image processing was canceled in the ', ModuleName, ' module because the object size could not be converted to a number.'])
end

if iHsize<=2
    error(['Image processing was canceled in the ', ModuleName, ' module because the object size was too small. Has to be at least 3'])
end

% Intensity Quanta Of Image
[isSafe iImgLimes]= inputVectorsForEvalCP3D(iImgLimes,true);
if isSafe ==false
    error(['Image processing was canceled in the ', ModuleName, ' module because Intensity Quanta per Image contain forbidden characters.'])
end

% Rescale Thresholds
[isSafe iRescaleThr]= inputVectorsForEvalCP3D(iRescaleThr,true);
if isSafe ==false
    error(['Image processing was canceled in the ', ModuleName, ' module because Rescaling Boundaries contain forbidden characters.'])
end

% Detection Threshold
try
    iDetectionThr = str2double(iDetectionThr);
catch errDetectionThr
    error(['Image processing was canceled in the ', ModuleName, ' module because the Detection Threshold could not be converted to a number.'])
end

% Object intensity Threshold
if iObjIntensityThr == '/'
    iObjIntensityThr = [];
else
    try
        iObjIntensityThr = str2double(iObjIntensityThr);
    catch errObjIntensityThr
        error(['Image processing was canceled in the ', ModuleName, ' module because the Stepsize for deblending could not be converted to a number.'])
    end
end

%%%%%%%%%%%%%%%%%%%%%%
%%% IMAGE ANALYSIS %%%
%%%%%%%%%%%%%%%%%%%%%%

Image = handles.Pipeline.(StackName);


op = fspecialCP3D(iFilterType,iHsize);
% Detect objects, note that input vectors are eval'ed
[ObjCount SegmentationCC] = ObjByFilter(Image,op,iDetectionThr,eval(iImgLimes),eval(iRescaleThr),iObjIntensityThr,false,[],[]);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SAVE DATA TO HANDLES STRUCTURE %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Save Segmentation to Pipeline and define format
fieldname = ['Segmented', ObjectName];
handles.Pipeline.(fieldname).Label = SegmentationCC;
handles.Pipeline.(fieldname).Format = 'SegmentationCC';

%%% Saves the ObjectCount, i.e. the number of segmented objects:
% This is saved in the .Image measurement so that different objects are
% stored together independend of whether they were initially derived
% from a 2D image or a 3D stack
if ~isfield(handles.Measurements.Image,'ObjectCountFeatures')
    handles.Measurements.Image.ObjectCountFeatures = {};
    handles.Measurements.Image.ObjectCount = {};
end
column = find(~cellfun('isempty',strfind(handles.Measurements.Image.ObjectCountFeatures,ObjectName)));
if isempty(column)
    handles.Measurements.Image.ObjectCountFeatures(end+1) = {ObjectName};
    column = length(handles.Measurements.Image.ObjectCountFeatures);
end
handles.Measurements.Image.ObjectCount{handles.Current.SetBeingAnalyzed}(1,column) = ObjCount;


%%% Saves the location of each segmented object
switch size(SegmentationCC.ImageSize,2)
    case 2
        handles.Measurements.(ObjectName).LocationFeatures = {'CenterX','CenterY'};
    case 3
        handles.Measurements.(ObjectName).LocationFeatures = {'CenterX','CenterY','CenterZ'};
    otherwise
        error(['Image processing was canceled in the ', ModuleName, ' module. Currently only centroids of 2D and 3D are supported. '])
        % note that it would be very easy to add more dimensions by removing this induced error.
        % The only reason for inducing this crash is to prevent
        % amiguity resulting from not having the dimensions not named
        % clearly. Thus if someone wants to add more, one should
        % conciously make a simple adaptation (or ask TS to do so)
end

if SegmentationCC.NumObjects ~= 0 % determine centroid, if at least one object
    tmp = regionprops(SegmentationCC,'Centroid');
    Centroid = cat(1,tmp.Centroid);
    if isempty(Centroid)   % keep the resettign to 0 0 found in other modules to remain consistent
        Centroid = [0 0];
    end
    handles.Measurements.(ObjectName).Location(handles.Current.SetBeingAnalyzed) = {Centroid};
end


%%%%%%%%%%%%%%%%%%%
%%% DISPLAY %%%%%%%
%%%%%%%%%%%%%%%%%%%

% Display centroid might be more informative!




% Create Occupancy image, which shows how manz Z planes have an object
occImg = createOccupancyImage(SegmentationCC,'XY');
    

drawnow
ThisModuleFigureNumber = handles.Current.(['FigureNumberForModule',CurrentModule]);
if any(findobj == ThisModuleFigureNumber)
    
    % Activates the appropriate figure window.
    CPfigure(handles,'Image',ThisModuleFigureNumber);
    
    if handles.Current.SetBeingAnalyzed == handles.Current.StartingImageSet
                CPresizefigure(handles.Pipeline.(StackName),'TwoByTwo',ThisModuleFigureNumber);
    end
    
    % Make heatmap showing occupancy of individual pixels with objects
    imagesc(occImg);
    colormap('JET')
    colorbar
    
    %CPimagesc(occImg,handles);
    title(sprintf('Z planes with object. Total Amount of Objects is %d', ObjCount))
end



end
