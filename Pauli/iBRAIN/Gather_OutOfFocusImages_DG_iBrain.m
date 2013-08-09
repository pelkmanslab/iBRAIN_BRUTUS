function Gather_OutOfFocusImages_DG_iBrain(strRootPath)

if nargin==0
    strRootPath = 'Z:\Data\Users\VSV_DG\070309_VSV_DG_batch1_CP017-1ab\BATCH';
end

% load plate BASICDATA
load(char(SearchTargetFolders(strRootPath,'BASICDATA_*.mat')));

% standard cell type SVM results
handles0 = struct;
handles0 = LoadMeasurements(handles0,fullfile(strRootPath,'Measurements_Nuclei_CellTypeClassificationPerColumn.mat'));

% OBJECT COUNT
cellMeasurementFiles = SearchTargetFolders(strRootPath,'Measurements_*Image_ObjectCount.mat');
if ~isempty(cellMeasurementFiles)
    handles0 = LoadMeasurements(handles0,cellMeasurementFiles{1});
end

% precalculating cell number correction factors for each image position
for image=1:size(handles0.Measurements.Image.ObjectCount,2)
    matObjectCount(image)=handles0.Measurements.Image.ObjectCount{image}(1);
end
[foo1,foo2,foo3, matImagePositionNumber] = LoadStandardData(strRootPath);
matImagePositionNumber=matImagePositionNumber(:,1);
image_positions=unique(matImagePositionNumber);
for image=1:length(matImagePositionNumber)
    handles.Measurements.Image.OutOfFocus(image)=mean(handles0.Measurements.Nuclei.Others{image})<0.3;
end
handles.Measurements.Image.OutOfFocus_Features={'Out of focus', 'In focus'};

disp(sprintf('SAVING %s',fullfile(strRootPath,'Measurements_Image_OutOfFocus_DG.mat')))      
save(fullfile(strRootPath,'Measurements_Image_OutOfFocus_DG.mat'),'handles');

