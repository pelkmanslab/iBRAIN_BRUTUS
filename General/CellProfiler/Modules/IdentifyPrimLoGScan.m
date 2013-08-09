function handles = IdentifyPrimLoGScan(handles)
% Help for the IdentifyPrimLoGPScan module:
% Category: Object Processing
%
% SHORT DESCRIPTION:
% Will Determine Spots in 2D Image stacks by Laplacian Of Gaussian
% Filtering at different thresholds.
%
% Spot detection by Laplacian of Gaussian with global boundaries for
% individual thresholds and one global threshold for spot detection. Also
% see SCRIPTIDENTIFYPARAMETERSFORSPOTDETECTION
% *************************************************************************


drawnow

[CurrentModule, CurrentModuleNum, ModuleName] = CPwhichmodule(handles);

%textVAR01 = What did you call the images you want to process?
%infotypeVAR01 = imagegroup
ImageName = char(handles.Settings.VariableValues{CurrentModuleNum,1});
%inputtypeVAR01 = popupmenu

%textVAR02 = How do you want to call the objects identified PRIOR to deblending?
%defaultVAR02 = PreSpots
%infotypeVAR02 = objectgroup indep
iPreObjectName = char(handles.Settings.VariableValues{CurrentModuleNum,2});

%textVAR03 = Deactivated
%defaultVAR03 = /
%infotypeVAR03 = objectgroup indep
iPostObjectName = [];

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

%textVAR07 = Range Spot Detection 
%defaultVAR07 = [0.04:0.001:0.05]
iDetectionThr = char(handles.Settings.VariableValues{CurrentModuleNum,7});


%textVAR08 =  Deactivated
%defaultVAR08 = 0
iDeblendSteps = [];

%textVAR09 = What is the minimal intensity of a pixel within a spot?
%defaultVAR09 = /
iObjIntensityThr = char(handles.Settings.VariableValues{CurrentModuleNum,9});

%textVAR10 = Do you want to perform spot bias correction?
%choiceVAR10 = No
%choiceVAR10 = Yes
iDoBiasCorrection = char(handles.Settings.VariableValues{CurrentModuleNum,10});
%inputtypeVAR10 = popupmenu

%textVAR11 = Which image do you want to use as a reference for spot bias correction?
%infotypeVAR11 = imagegroup
iCorrectionName = char(handles.Settings.VariableValues{CurrentModuleNum,11});
%inputtypeVAR11 = popupmenu

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
[isSafe iDetectionThr]= inputVectorsForEvalCP3D(iDetectionThr,true);
if isSafe ==false
    error(['Image processing was canceled in the ', ModuleName, ' module because the Detection Threshold could not be converted to a number.'])
end


% Deblend Threshold
try
    iDeblendSteps = str2double(iDeblendSteps);
catch errDeblendDetection
    error(['Image processing was canceled in the ', ModuleName, ' module because the Stepsize for deblending could not be converted to a number.'])
end


if iPostObjectName == '/'
    if iDeblendSteps > 0
        error(['Image processing was canceled in the ', ModuleName, ' module because no Name for the Objects after deblending were defined.'])
    end
else
    if iDeblendSteps <0
        error(['Image processing was canceled in the ', ModuleName, ' module because the amount of deblending steps were not defined.'])
    end
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

% Bias correction
if strcmp(iDoBiasCorrection,'Yes')
    bnDoBiasCorrection = true;
else
    bnDoBiasCorrection = false;
end


% Initiate Bias Correction
if bnDoBiasCorrection == true
    DetectionBias =  handles.Pipeline.(iCorrectionName);
else
    DetectionBias = [];
end

% Initiate Settings for deblending
% Options.ObSize = iHsize;
% Options.limQuant = eval(iImgLimes);
% Options.RescaleThr = eval(iRescaleThr);
% Options.ObjIntensityThr = [];
% Options.closeHoles = false;
% Options.ObjSizeThr = [];
% Options.ObjThr = iDetectionThr;
% Options.StepNumber = iDeblendSteps;
% Options.numRatio = 0.20;
% Options.doLog = 0;
% Options.DetectBias = DetectionBias;

%%%%%%%%%%%%%%%%%%%%%%
%%% IMAGE ANALYSIS %%%
%%%%%%%%%%%%%%%%%%%%%%
Image = double(CPretrieveimage(handles,ImageName,ModuleName,'DontCheckColor','DontCheckScale')).*65535;     % convert to scale used for spotdetection
op = fspecialCP3D('2D LoG',iHsize);         % force 2D filter

% Detect objects, note that input vectors are eval'ed
[ObjCount SegmentationCC] = ObjByFilter(Image,op,eval(iDetectionThr),eval(iImgLimes),eval(iRescaleThr),iObjIntensityThr,true,[],DetectionBias);

numThresholds = length(ObjCount);
for k=1:numThresholds
%     
%     % Convert to CP1 standard: labelmatrix
%     MatrixLabel = double(labelmatrix(SegmentationCC{k}));
    
    % Security check, if conversion is correct
%     if max(MatrixLabel(:)) ~= ObjCount(k)
%         error(['Image processing was canceled in the ', ModuleName, ' module because conversion of format of segmentation was wrong. Contact Thomas.'])
%     end
%     
    % % Deblend objects
    % if iDeblendSteps > 0        % Only do deblending, if number of iterations was defined
    %     MatrixLabel{2} = SourceExtractorDeblend(Image,SegmentationCC{1},FiltImage,Options);
    %     ObjCount{2} = max(MatrixLabel{2}(:));
    % end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% MEASUREMENTS and SAVE DATA TO HANDLES STRUCTURE %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ObjectName = [iPreObjectName num2str(k)];
            
%         %%% Save Segmentation to Pipeline
%         fieldname = ['Segmented', ObjectName];
%         handles.Pipeline.(fieldname) = MatrixLabel;
%         
%         fieldname = ['SmallRemovedSegmented', ObjectName];
%         handles.Pipeline.(fieldname) = MatrixLabel;
%         
%         fieldname = ['UneditedSegmented', ObjectName];
%         handles.Pipeline.(fieldname) = MatrixLabel;
        
        %%% Saves the ObjectCount, i.e. the number of segmented objects:
        if ~isfield(handles.Measurements.Image,'ObjectCountFeatures')
            handles.Measurements.Image.ObjectCountFeatures = {};
            handles.Measurements.Image.ObjectCount = {};
        end
        column = find(strcmp(handles.Measurements.Image.ObjectCountFeatures,ObjectName));
        if isempty(column)
            handles.Measurements.Image.ObjectCountFeatures(end+1) = {ObjectName};
            column = length(handles.Measurements.Image.ObjectCountFeatures);
        end
        handles.Measurements.Image.ObjectCount{handles.Current.SetBeingAnalyzed}(1,column) = ObjCount(k);
        
        % Save Centroid
        handles.Measurements.(ObjectName).LocationFeatures = {'CenterX','CenterY'};
        
        Centroid = [0 0];
        if ObjCount(k) ~= 0 % determine centroid, if at least one object
            tmp = regionprops(SegmentationCC{k},'Centroid');
            Centroid = cat(1,tmp.Centroid);
        end
        handles.Measurements.(ObjectName).Location(handles.Current.SetBeingAnalyzed) = {Centroid};
        
end


%%%%%%%%%%%%%%%%%%%
%%% DISPLAY %%%%%%%
% %%%%%%%%%%%%%%%%%%%
%
% drawnow
% ThisModuleFigureNumber = handles.Current.(['FigureNumberForModule',CurrentModule]);
% if any(findobj == ThisModuleFigureNumber)
%
%     % Activates the appropriate figure window.
%     CPfigure(handles,'Image',ThisModuleFigureNumber);
%
%     subplot(2,1,1)      % Subplot with input image
%     CPimagesc(Image,handles);
%     title([ImageName, ' cycle # ',num2str(handles.Current.SetBeingAnalyzed)]);
%
%
%     subplot(2,1,2)
%     switch numObjects
%         case 1
%             bwImage = MatrixLabel{1}>0;
%         case 2  % in case that deblending was done, dilate by 2 pixels to help visualization
%             bwImage = imdilate(MatrixLabel{2}>0, strel('disk', 2));
%     end
%
%     r = (Image - min(Image(:))) / quantile(Image(:),0.995);
%     g = (Image - min(Image(:))) / quantile(Image(:),0.995);
%     b = (Image - min(Image(:))) / quantile(Image(:),0.995);
%
%     r(bwImage) = max(r(:));
%     g(bwImage) = 0;
%     b(bwImage) = 0;
%     visRGB = cat(3, r, g, b);
%     f = visRGB <0;
%     visRGB(f)=0;
%     f = visRGB >1;
%     visRGB(f)=1;
%
%
%     CPimagesc(visRGB, handles);
%     switch numObjects
%         case 1
%             title([ObjectName{1} ' (no deblending) Total count' num2str(ObjCount{1})]);
%
%         case 2
%             title([ObjectName{2} ' Total count' num2str(ObjCount{2}) ' (after deblending) ' num2str(ObjCount{1}) ' (before deblending)']);
%     end
%
% end



end
