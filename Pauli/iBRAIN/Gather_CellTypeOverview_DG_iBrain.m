function Gather_CellTypeOverview_DG_iBRAIN(strRootPath)

% default input options (works nice for testing)
if nargin==0
    strRootPath = 'X:\Data\Users\YF_DG\20080425085857_M2_080424_YF_DG_batch2_CP066-1df\BATCH';

    strRootPath = npc(strRootPath);
end

% checks on input parameters
boolInputPathExists = fileattrib(strRootPath);
if not(boolInputPathExists)
    error('%s: could not read input strRootPath %s',mfilename,strRootPath)
else
    disp(sprintf('%s: starting on %s',mfilename,strRootPath))
end


%-------------------------------------------------------------------------------------------------------------------------------------------------
% CellType Gathering
% finding and load/parse the latest classifications for the following svm
% classes
classes{1}='interphase'; %Interphase
classes{2}='mitotic'; %Mitotic
classes{3}='apoptotic'; %Apoptotic
classes{4}='blob'; %Blob
classes{5}='infection'; %SVM infected

% load plate BASICDATA
load(char(SearchTargetFolders(strRootPath,'BASICDATA_*.mat')));

% standard cell type SVM results
handles0 = struct;
handles0 = LoadMeasurements(handles0,fullfile(strRootPath,'Measurements_Nuclei_CellTypeClassificationPerColumn.mat'));

% loop over all latest infection screen classes, and load data
% Needed for uncorrected results
disp(sprintf('%s: parsing latest svm files ',mfilename))
class_list = cell(1,length(classes));
numPositiveClassNumbers = nan(1,length(classes));
for i = 1:length(classes)
    [handles0, class_list{i}, numPositiveClassNumbers(i)] = load_latest_svm_file(handles0, strRootPath, classes{i},'newest');
end

% nucleus size information
cellMeasurementFiles = SearchTargetFolders(strRootPath,'Measurements_*Nuclei_AreaShape.mat');
strAreaSizeObject = regexp(cellMeasurementFiles{1},'.*_(.*Nuclei)','tokens');
strAreaSizeObject = char(strAreaSizeObject{1});
if ~isempty(cellMeasurementFiles)
    handles0 = LoadMeasurements(handles0,cellMeasurementFiles{1});
else
    error('Nuclei_AreaShape NOT AVAILABLE!')
end

% EDGE
cellMeasurementFiles = SearchTargetFolders(strRootPath,'Measurements_*Nuclei_Edge.mat');
if ~isempty(cellMeasurementFiles)
    handles0 = LoadMeasurements(handles0,cellMeasurementFiles{1});
    strDensityEdgeObject = regexp(cellMeasurementFiles{1},'.*_(.*Nuclei)_Edge','tokens');
    strDensityEdgeObject = char(strDensityEdgeObject{1});
else
    error('Nuclei_AreaShape NOT AVAILABLE!')
end

% LCD
cellMeasurementFiles = SearchTargetFolders(strRootPath,'Measurements_*Nuclei_LocalCellDensity.mat');
if ~isempty(cellMeasurementFiles)
    handles0 = LoadMeasurements(handles0,cellMeasurementFiles{1});
else
    error('Nuclei_LocalCellDensity NOT AVAILABLE!')
end

% SINGLE CELL
cellMeasurementFiles = SearchTargetFolders(strRootPath,'Measurements_*Nuclei_SingleCell.mat');
if ~isempty(cellMeasurementFiles)
    handles0 = LoadMeasurements(handles0,cellMeasurementFiles{1});
else
    error('Nuclei_SingleCell NOT AVAILABLE!')
end

% OBJECT COUNT
cellMeasurementFiles = SearchTargetFolders(strRootPath,'Measurements_*Image_ObjectCount.mat');
if ~isempty(cellMeasurementFiles)
    handles0 = LoadMeasurements(handles0,cellMeasurementFiles{1});
else
    error('Image_ObjectCount NOT AVAILABLE!')
end

% OUT OF FOCUS IMAGES
cellMeasurementFiles = SearchTargetFolders(strRootPath,'Measurements_Image_OutOfFocus_DG.mat');
if ~isempty(cellMeasurementFiles)
    handles0 = LoadMeasurements(handles0,cellMeasurementFiles{1});
else
    error('Image_OutOfFocus_DG NOT AVAILABLE!')
end

% CORRECTED TOTAL CELL NUMBER
cellMeasurementFiles = SearchTargetFolders(strRootPath,'Measurements_Image_CorrectedTotalCellNumberPerWell_DG.mat');
if ~isempty(cellMeasurementFiles)
    handles0 = LoadMeasurements(handles0,cellMeasurementFiles{1});
else
    error('CorrectedTotalCellNumberPerWell_DG NOT AVAILABLE!')
end

% CORRECTED CellSize
cellMeasurementFiles = SearchTargetFolders(strRootPath,'Measurements_BIN_corrected_CellSize.mat');
if ~isempty(cellMeasurementFiles)
    handles0 = LoadMeasurements(handles0,cellMeasurementFiles{1});
else
    error('BIN_corrected_CellSize NOT AVAILABLE!')
end

% CORRECTED Edge
cellMeasurementFiles = SearchTargetFolders(strRootPath,'Measurements_BIN_corrected_Edge.mat');
if ~isempty(cellMeasurementFiles)
    handles0 = LoadMeasurements(handles0,cellMeasurementFiles{1});
else
    error('BIN_corrected_Edge NOT AVAILABLE!')
end

% CORRECTED Mitotic
cellMeasurementFiles = SearchTargetFolders(strRootPath,'Measurements_BIN_corrected_Mitotic.mat');
if ~isempty(cellMeasurementFiles)
    handles0 = LoadMeasurements(handles0,cellMeasurementFiles{1});
else
    error('BIN_corrected_Mitotic NOT AVAILABLE!')
end

% CORRECTED Apoptotic
cellMeasurementFiles = SearchTargetFolders(strRootPath,'Measurements_BIN_corrected_Apoptotic.mat');
if ~isempty(cellMeasurementFiles)
    handles0 = LoadMeasurements(handles0,cellMeasurementFiles{1});
else
    error('BIN_corrected_Apoptotic NOT AVAILABLE!')
end

% CORRECTED LCD
cellMeasurementFiles = SearchTargetFolders(strRootPath,'Measurements_BIN_corrected_LCD.mat');
if ~isempty(cellMeasurementFiles)
    handles0 = LoadMeasurements(handles0,cellMeasurementFiles{1});
else
    error('BIN_corrected_LCD NOT AVAILABLE!')
end

% CORRECTED SingleCell
cellMeasurementFiles = SearchTargetFolders(strRootPath,'Measurements_BIN_corrected_SingleCell.mat');
if ~isempty(cellMeasurementFiles)
    handles0 = LoadMeasurements(handles0,cellMeasurementFiles{1});
else
    error('BIN_corrected_SingleCell NOT AVAILABLE!')
end

% CORRECTED SVMInfection
cellMeasurementFiles = SearchTargetFolders(strRootPath,'Measurements_BIN_corrected_SVMinfection.mat');
if ~isempty(cellMeasurementFiles)
    handles0 = LoadMeasurements(handles0,cellMeasurementFiles{1});
else
    error('BIN_corrected_SVMinfection NOT AVAILABLE!')
end

% well row and column information
BASICDATA_CellType.WellRow=BASICDATA.WellRow;
BASICDATA_CellType.WellCol=BASICDATA.WellCol;

% % precalculating cell number correction factors for each image position
% for image=1:size(handles0.Measurements.Image.ObjectCount,2)
%    matObjectCount(image)=handles0.Measurements.Image.ObjectCount{image}(1);
% end

[foo1,foo2,foo3, matImagePositionNumber] = LoadStandardData(strRootPath);
matImagePositionNumber=matImagePositionNumber(:,1);
image_positions=unique(matImagePositionNumber);

for well=1:size(BASICDATA.WellRow,2)
    % get the image indices per well
    matImageIndicesPerWell=BASICDATA.ImageIndices{1,well};
    matImagePositions=matImagePositionNumber(matImageIndicesPerWell);
    
    % removing images that do not have any objects (a quality control step to avoid crashes etc)
    % CHECK IF THIS CAUSES PROBLEMS?!?!?!?!?!?!?!!?
    object_count=cat(1,handles0.Measurements.Image.ObjectCount{matImageIndicesPerWell});
    if not(isempty(object_count))
        object_count=object_count(:,1);
        matImageIndicesPerWell(object_count==0)=[];
    end
    
    good_images=handles0.Measurements.Image.OutOfFocus(matImageIndicesPerWell);
    
    % gathering non SVM data first
    CellSizeData=cat(1,handles0.Measurements.(strAreaSizeObject).AreaShape{matImageIndicesPerWell});
    LocalCellDensityData=cat(1,handles0.Measurements.(strDensityEdgeObject).LocalCellDensity{matImageIndicesPerWell});
    EdgeData=cat(1,handles0.Measurements.(strDensityEdgeObject).Edge{matImageIndicesPerWell});
    SingleCellData=cat(1,handles0.Measurements.(strDensityEdgeObject).SingleCell{matImageIndicesPerWell});
    
    % Tensor corrected single cell data
    foo=cat(1,handles0.Measurements.BIN.corrected_CellSize{matImageIndicesPerWell});if isempty(foo);foo=zeros(0,3);end;
    CellSizeData_BIN=foo(:,1).*(foo(:,1)./foo(:,2)); % normalized to non others!!
    foo=cat(1,handles0.Measurements.BIN.corrected_LCD{matImageIndicesPerWell});if isempty(foo);foo=zeros(0,3);end;
    LocalCellDensityData_BIN=foo(:,1).*(foo(:,1)./foo(:,2));
    foo=cat(1,handles0.Measurements.BIN.corrected_Edge{matImageIndicesPerWell});if isempty(foo);foo=zeros(0,3);end;
    EdgeData_BIN=foo(:,1).*(foo(:,1)./foo(:,2));
    foo=cat(1,handles0.Measurements.BIN.corrected_SingleCell{matImageIndicesPerWell});if isempty(foo);foo=zeros(0,3);end;
    SingleCellData_BIN=foo(:,1).*(foo(:,1)./foo(:,2));
    
    good_cells=not(cat(1,handles0.Measurements.Nuclei.Others{matImageIndicesPerWell}));
    interphase_cells=cat(1,handles0.Measurements.Nuclei.Interphase{matImageIndicesPerWell});
    
    % no cells in well
    if isempty(CellSizeData)
        CellSizeData=NaN;
        LocalCellDensityData=NaN;
        EdgeData=NaN;
        SingleCellData=NaN;
    end
    
    % Gathering Mitotic, Apoptotic, Interphase & Others numbers per well
    % All images are used, even if they are out-of-focus: normalization is done with total good cell number.
    Mitotic_number=nansum(cat(1,handles0.Measurements.Nuclei.Mitotic{matImageIndicesPerWell}));
    foo=cat(1,handles0.Measurements.BIN.corrected_Mitotic{matImageIndicesPerWell});if isempty(foo);foo=zeros(0,3);end;
    Mitotic_number_BIN=nansum(foo(:,1)./foo(:,2));
    
    Apoptotic_number=nansum(cat(1,handles0.Measurements.Nuclei.Apoptotic{matImageIndicesPerWell}));
    foo=cat(1,handles0.Measurements.BIN.corrected_Apoptotic{matImageIndicesPerWell});if isempty(foo);foo=zeros(0,3);end;
    Apoptotic_number_BIN=nansum(foo(:,1)./foo(:,2));
    
    InfectedSVM_number=nansum(cat(1,handles0.Measurements.Nuclei.InfectedSVM{matImageIndicesPerWell}));
    foo=cat(1,handles0.Measurements.BIN.corrected_SVMinfection{matImageIndicesPerWell});if isempty(foo);foo=zeros(0,3);end;
    InfectedSVM_number_BIN=nansum(foo(:,1)./foo(:,2));
    
    Interphase_number=nansum(cat(1,handles0.Measurements.Nuclei.Interphase{matImageIndicesPerWell}));
    Others_number=nansum(cat(1,handles0.Measurements.Nuclei.Others{matImageIndicesPerWell}));
    
    Mitotic_Infected_number=nansum(cat(1,handles0.Measurements.Nuclei.Mitotic{matImageIndicesPerWell}) & cat(1,handles0.Measurements.Nuclei.InfectedSVM{matImageIndicesPerWell}));
    Apoptotic_Infected_number=nansum(cat(1,handles0.Measurements.Nuclei.Apoptotic{matImageIndicesPerWell}) & cat(1,handles0.Measurements.Nuclei.InfectedSVM{matImageIndicesPerWell}));
    
    % all good cells (Cell_number)
    Cell_number=Mitotic_number+Apoptotic_number+Interphase_number;
   
    % Bad image normalized total cell number (Total_number)
    try
        Total_number=handles0.Measurements.Image.TotalCorrectedCellNumber{matImageIndicesPerWell(1)}; %all images have the same corrected cell number: taking value from the first image
    catch
        Total_number=NaN;
    end
    
    % Total detected objects (including all crap cells)
    Total_number2=length(cat(1,handles0.Measurements.Nuclei.Mitotic{matImageIndicesPerWell}));
   
    % Mean of interphase nucleus size (total area)
    try % REMOVE THE TRY-CATCH WHEN THE "EDGE 1-Cell bug has been fixed"
        CellSizeMean=nanmean(CellSizeData(interphase_cells,1));
    catch
        CellSizeMean=NaN;
    end
    try 
        CellSizeMean_BIN=nanmean(CellSizeData_BIN(interphase_cells,1));
    catch
        CellSizeMean_BIN=NaN;
    end
    
    % Mean local cell density. Using all images and only good nuclei.
    try
        LocalCellDensityMean=nanmean(LocalCellDensityData(good_cells));
    catch
        LocalCellDensityMean=NaN;
    end
    try
        LocalCellDensityMean_BIN=nanmean(LocalCellDensityData_BIN(good_cells));
    catch
        LocalCellDensityMean_BIN=NaN;
    end
    
    % Edge-index. Using all images and only good nuclei.
    try
        EdgeIndex=nanmean(EdgeData(good_cells));
    catch
        EdgeIndex=NaN;
    end
    try
        EdgeIndex_BIN=nanmean(EdgeData_BIN(good_cells));
    catch
        EdgeIndex_BIN=NaN;
    end
    
    % SingleCell-index. Using all images and only good nuclei.
    try
        SingleCellIndex=nanmean(SingleCellData(good_cells));
    catch
        SingleCellIndex=NaN;
    end
    try
        SingleCellIndex_BIN=nanmean(SingleCellData_BIN(good_cells));
    catch
        SingleCellIndex_BIN=NaN;
    end
    
    % Population features
    BASICDATA_CellType.CellSize_Mean(1,well) = CellSizeMean;
    BASICDATA_CellType.LocalCellDensity_Mean(1,well) = LocalCellDensityMean;
    BASICDATA_CellType.Edge_index(1,well) = EdgeIndex;
    BASICDATA_CellType.SingleCell_index(1,well) = SingleCellIndex;
    
    BASICDATA_CellType.CellSize_Mean_BIN(1,well) = CellSizeMean_BIN;
    BASICDATA_CellType.LocalCellDensity_Mean_BIN(1,well) = LocalCellDensityMean_BIN;
    BASICDATA_CellType.Edge_index_BIN(1,well) = EdgeIndex_BIN;
    BASICDATA_CellType.SingleCell_index_BIN(1,well) = SingleCellIndex_BIN;
    
    % Out-of-focus
    BASICDATA_CellType.Out_of_focus_images(1,well) = 9-sum(good_images);
    
    % Standard SVM celltype numbers
    BASICDATA_CellType.Mitotic_number(1,well)=Mitotic_number;
    BASICDATA_CellType.Apoptotic_number(1,well)=Apoptotic_number;
    BASICDATA_CellType.Interphase_number(1,well)=Interphase_number;
    BASICDATA_CellType.InfectedSVM_number(1,well)=InfectedSVM_number;
    BASICDATA_CellType.Others_number(1,well)=Others_number;
    BASICDATA_CellType.Cells_good(1,well)=Cell_number;
    BASICDATA_CellType.Cells_normalized(1,well)=Total_number;
    BASICDATA_CellType.Cells_allobjects(1,well)=Total_number2;
    
    % Standard SVM celltype indices
    BASICDATA_CellType.Others_index(1,well) = Others_number / Total_number2;
    BASICDATA_CellType.Mitotic_index(1,well) = Mitotic_number / Cell_number;
    BASICDATA_CellType.Mitotic_index_BIN(1,well) = Mitotic_number_BIN / Cell_number;
    BASICDATA_CellType.Apoptotic_index(1,well) = Apoptotic_number / Cell_number;
    BASICDATA_CellType.Apoptotic_index_BIN(1,well) = Apoptotic_number_BIN / Cell_number;
    BASICDATA_CellType.Interphase_index(1,well) = Interphase_number / Cell_number;
    BASICDATA_CellType.InfectedSVM_index(1,well) = InfectedSVM_number / Cell_number;
    BASICDATA_CellType.InfectedSVM_index_BIN(1,well) = InfectedSVM_number_BIN / Cell_number;
    BASICDATA_CellType.Mitotic_Infected_index(1,well) = Mitotic_Infected_number / Mitotic_number;       %special readout without corrections etc.
    BASICDATA_CellType.Apoptotic_Infected_index(1,well) = Apoptotic_Infected_number / Apoptotic_number; %special readout without corrections etc.
       
    % celltype indices without any clean-up steps (Absolute numbers can be get by multiplying with Cells_allobjects)
    BASICDATA_CellType.LocalCellDensity_Mean_unclean(1,well) = nanmean(LocalCellDensityData);
    BASICDATA_CellType.Edge_index_unclean(1,well) = nanmean(EdgeData);
    BASICDATA_CellType.SingleCell_index_unclean(1,well) = nanmean(SingleCellData);
    BASICDATA_CellType.CellSize_Mean_unclean(1,well) = nanmean(CellSizeData(:,1));
    
    BASICDATA_CellType.Interphase_index_unclean(1,well) = sum(cat(1,handles0.Measurements.SVM.(class_list{1}){matImageIndicesPerWell}) == numPositiveClassNumbers(1))./Total_number2;
    BASICDATA_CellType.Mitotic_index_unclean(1,well) = sum(cat(1,handles0.Measurements.SVM.(class_list{2}){matImageIndicesPerWell}) == numPositiveClassNumbers(2))./Total_number2;
    BASICDATA_CellType.Apoptotic_index_unclean(1,well) = sum(cat(1,handles0.Measurements.SVM.(class_list{3}){matImageIndicesPerWell}) == numPositiveClassNumbers(3))./Total_number2;
    BASICDATA_CellType.InfectedSVM_index_unclean(1,well) = sum(cat(1,handles0.Measurements.SVM.(class_list{5}){matImageIndicesPerWell}) == numPositiveClassNumbers(5))./Total_number2;
  
end

% saving data
disp(sprintf('SAVING %s',fullfile(strRootPath,'Measurements_CellType_Overview_DG.mat')))
save(fullfile(strRootPath,'Measurements_Nuclei_CellType_Overview_DG.mat'),'BASICDATA_CellType')

