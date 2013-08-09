function Gather_TotalCorrectedCellNumber_iBrain(strRootPath)

warning off MATLAB:divideByZero

if nargin==0
    strRootPath = 'Z:\Data\Users\VSV_DG\070330_VSV_DG_batch3_CP038-1ab\BATCH';
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

% Out of focus images
cellMeasurementFiles = SearchTargetFolders(strRootPath,'Measurements_Image_OutOfFocus_DG.mat');
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
for position=image_positions'
    Cell_Number_Normalization_Factors(position)=nanmedian(matObjectCount(matImagePositionNumber==position & handles0.Measurements.Image.OutOfFocus'));
end
Cell_Number_Normalization_Factors=Cell_Number_Normalization_Factors./sum(Cell_Number_Normalization_Factors);

for well=1:size(BASICDATA.WellRow,2)
    % get the image indices per well
    matImageIndicesPerWell=BASICDATA.ImageIndices{1,well};
    matImagePositions=matImagePositionNumber(matImageIndicesPerWell);
    
%     % removing images that do not have any objects (a quality control step to avoid crashes etc)
%     object_count=cat(1,handles0.Measurements.Image.ObjectCount{matImageIndicesPerWell});
%     if not(isempty(object_count))
%         object_count=object_count(:,1);
%         matImageIndicesPerWell(object_count==0)=[];
%     end
    
    % First checking which images might be out-of-focus or otherwise bad
    good_images=handles0.Measurements.Image.OutOfFocus(matImageIndicesPerWell);

    % Bad image normalized total cell number (Total_number)
    Total_number=length(cat(1,handles0.Measurements.Nuclei.Mitotic{matImageIndicesPerWell(good_images)}));
    Total_number=Total_number+round(sum(Total_number.*Cell_Number_Normalization_Factors(matImagePositions(not(good_images)))));
    
    for i=1:length(matImageIndicesPerWell)
        handles.Measurements.Image.TotalCorrectedCellNumber{matImageIndicesPerWell(i)}=Total_number;
    end
end
   
disp(sprintf('SAVING %s',fullfile(strRootPath,'Measurements_Image_CorrectedTotalCellNumberPerWell_DG.mat')))      
save(fullfile(strRootPath,'Measurements_Image_CorrectedTotalCellNumberPerWell_DG.mat'),'handles');

