function correctTrainingData4_probit(strDataPath, settings, strModelPath)
%%% USES GLMFIT TO CALCULATE MODEL PREDICTED VALUES
%%% 080307 VERSION

if nargin == 0
    strDataPath = 'Y:\Data\Users\50K_final_reanalysis\Ad3_KY_NEW\070606_Ad3_50k_Ky_1_1_CP071-1aa\BATCH\';
    strModelPath = 'Y:\Data\Users\50K_final_reanalysis\Ad3_KY_NEW\';
end


%%% WHICH COLUMNS TO USE FOR EACH MEASUREMENT, TRANSPOSE DATA, RAW
%%% MEASUREMENT FILE NAMES, NUMBER OF BINS, ETC... 
if nargin < 2
    [structDataColumnsToUse, structMiscSettings] = initStructDataColumnsToUse('Y:\Data\Users\50K_final_reanalysis\ProbModel_Settings.txt');
else
    structDataColumnsToUse = settings.structDataColumnsToUse;
    structMiscSettings = settings.structMiscSettings;        
end

%%% IF PRESENT LOAD THE TRAININGDATA STRUCT. FROM THE CURRENT FOLDER
% strOutputFile = fullfile(strDataPath,'ProbModel_TensorCorrectedData.mat');
[boolTrainingDataFileExists] =  fileattrib(fullfile(strDataPath,'ProbModel_TensorCorrectedData.mat'));
if boolTrainingDataFileExists
    oldTensorCorrectedData = load(fullfile(strDataPath,'ProbModel_TensorCorrectedData.mat'));
    oldTensorCorrectedData = oldTensorCorrectedData.TensorCorrectedData;

    if isfield(oldTensorCorrectedData, 'settings')
        oldSettings = oldTensorCorrectedData.settings;

        newSettings = struct();
        newSettings.structMiscSettings = structMiscSettings;
        newSettings.structDataColumnsToUse = structDataColumnsToUse;

        if ~isequal(oldSettings, newSettings)
            disp(sprintf('%s: old settings do not match new settings. redoing training data correction',mfilename))
        else 
            disp(sprintf('%s: old settings match new settings. skipping training data correction',mfilename))            
%             if ~(nargin==0)
%                 return
%             end
        end

    else
        disp(sprintf('%s: old file did not contain settings field. redoing training data correction',mfilename))            
    end
else
%     disp(sprintf('%s:    no file present yet')                
end


cellstrTargetFolderList = SearchTargetFolders(strDataPath,'Measurements_Image_FileNames.mat');
cellstrTargetFolderList = cellfun(@getbasedir,cellstrTargetFolderList,'UniformOutput',0);

intNumOfFolders = length(cellstrTargetFolderList);

PlateTensor = cell(intNumOfFolders,1);

MasterTensor = load(fullfile(strModelPath,'ProbModel_Tensor.mat'));
MasterTensor = MasterTensor.Tensor;

matRows = cellstr(regexp(char(65:80),'\w','match'));
matCols = regexp(sprintf('%.2d',1:24),'\d\d','match');

matRawIIs = NaN(intNumOfFolders,384);
matRawTotalCells = NaN(intNumOfFolders,384);
matRawInfectedCells = NaN(intNumOfFolders,384);
matModelExpectedInfectedCells = NaN(intNumOfFolders,384);
matPlateTensorExpectedInfectedCells = NaN(intNumOfFolders,384);
matProjectTensorExpectedInfectedCells = NaN(intNumOfFolders,384);

matOligoNumbers = NaN(intNumOfFolders,384);
matWellColumnNumbers = NaN(intNumOfFolders,384);
matWellRowNumbers = NaN(intNumOfFolders,384);

cellstrDataLabels = cell(intNumOfFolders,384);
cellstrWellNames = cell(intNumOfFolders,384);

cellstrPaths = cell(intNumOfFolders,1);

for i = 1:intNumOfFolders
    
    disp(sprintf('%s: processing %s',mfilename,cellstrTargetFolderList{i}))
    
    cellstrPaths{i,1} = char(cellstrTargetFolderList{i});
    
    PlateTensor{i} = load(fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat'));
    PlateTensor{i} = PlateTensor{i}.Tensor;
    
    if isempty(PlateTensor{i}.TrainingData)
        continue
    end
    
    wellcounter = 0;

    
    for iRows = 1:16
        for iCols = 1:24
            wellcounter = wellcounter + 1;
            matCurWellCellIndices = find(PlateTensor{i}.MetaData(:,1) == iRows & PlateTensor{i}.MetaData(:,2) == iCols);
            
            %%% DATA LABELS: OLIGO NUMBER AND WELL NAME
            cellstrDataLabels{i,wellcounter} = [num2str(PlateTensor{i}.Oligo),'_',matRows{iRows},matCols{iCols}];
            cellstrWellNames{i,wellcounter} = [matRows{iRows},matCols{iCols}];            
            matOligoNumbers(i,wellcounter) = PlateTensor{i}.Oligo;
            matWellColumnNumbers(i,wellcounter) = iCols;
            matWellRowNumbers(i,wellcounter) = iRows;            
            
            if ~isempty(matCurWellCellIndices)
                
                %%% ORIGINAL INFECTION INDEX                
                intInfectedCells = sum(PlateTensor{i}.TrainingData(matCurWellCellIndices,1)-1);
                intTotalCells = length(matCurWellCellIndices);
                matRawInfectedCells(i,wellcounter) = intInfectedCells;
                matRawTotalCells(i,wellcounter) = intTotalCells;
                matRawIIs(i,wellcounter) = intInfectedCells./intTotalCells;

                %%% MODEL EXPECTED INFECTION INDEX            
%                 X = PlateTensor{i}.TrainingData(matCurWellCellIndices,2:end);
%                 X = X - 1;
%                 X = [ones(size(X,1),1),X];

                % probit regression expected infected cells for current well (let glmfit add the constant)
                YHAT = glmval(double(MasterTensor.Model.Params),double(PlateTensor{i}.TrainingData(matCurWellCellIndices,2:end)-1),'probit');
                matModelExpectedInfectedCells(i,wellcounter) = round(nansum(YHAT));
                
                % Project BIN/Tensor expexted infected cells for current well
                [foo,matCorrespondingTensorIndices]=ismember(PlateTensor{i}.TrainingData(matCurWellCellIndices,2:end)-1,MasterTensor.Model.X(:,2:end),'rows');
                matProjectTensorExpectedInfectedCells(i,wellcounter) = round(nansum(MasterTensor.InfectionIndex(matCorrespondingTensorIndices)));
                
                % Plate BIN/Tensor expexted infected cells for current well
                [foo,matCorrespondingTensorIndices]=ismember(PlateTensor{i}.TrainingData(matCurWellCellIndices,2:end),PlateTensor{i}.Indices,'rows');
                matPlateTensorExpectedInfectedCells(i,wellcounter) = round(nansum(PlateTensor{i}.InfectionIndex(matCorrespondingTensorIndices)));
                
            else 
                matRawIIs(i,wellcounter) = NaN;
                matRawInfectedCells(i,wellcounter) = NaN;
                matRawTotalCells(i,wellcounter) = NaN;                
                matModelExpectedInfectedCells(i,wellcounter) = NaN; 
                matProjectTensorExpectedInfectedCells(i,wellcounter) = NaN;
                matPlateTensorExpectedInfectedCells(i,wellcounter) = NaN;
            end

        end
    end
    
end


% % % %%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %%% CALCULATING PARAMS %%%
% % % 
% % % % SET ALL MODELEDINFECTEDCELLS <0 TO 0
% % % matModelExpectedInfectedCells(matModelExpectedInfectedCells<0)=0;
% % % 
% % % matRawRIIs = matRawIIs ./ repmat(nanmedian(matRawIIs,2),1,size(matRawIIs,2));
% % % matRawLog2RIIs = log2( matRawRIIs );
% % % matRawLog2RIIs(isinf(matRawLog2RIIs)) = NaN;
% % % matRawZScoreLog2RIIs = nanzscore(matRawLog2RIIs')';
% % % 
% % % 
% % % matModelExpectedIIs = matModelExpectedInfectedCells ./ matRawTotalCells;
% % % matModelExpectedRIIs = matModelExpectedIIs ./ repmat(nanmedian(matModelExpectedIIs,2),1,size(matModelExpectedIIs,2));
% % % matModelExpectedRIIs(matModelExpectedRIIs<0)=0;
% % % matModelExpectedLog2RIIs = log2( matModelExpectedRIIs );
% % % matModelExpectedLog2RIIs(isinf(matModelExpectedLog2RIIs)) = NaN;
% % % matModelExpectedZScoreLog2RIIs = nanzscore(matModelExpectedLog2RIIs')';
% % % 
% % % matModelCorrectedLog2RIIs = log2(matRawInfectedCells ./ matModelExpectedInfectedCells);
% % % matModelCorrectedLog2RIIs(isinf(matModelCorrectedLog2RIIs)) = NaN;
% % % matModelCorrectedZScoreLog2RIIs = nanzscore(matModelCorrectedLog2RIIs')';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CALCULATING PARAMS WITHOUT NANZSCORE %%%

% SET ALL MODELEDINFECTEDCELLS <0 TO 0
matModelExpectedInfectedCells(matModelExpectedInfectedCells<0)=0;

matRawRIIs = matRawIIs ./ repmat(nanmedian(matRawIIs,2),1,size(matRawIIs,2));
matRawRIIs(matRawRIIs==0) = NaN;
matRawLog2RIIs = log2( matRawRIIs );
matRawLog2RIIs(isinf(matRawLog2RIIs)) = NaN;

% matRawZScoreLog2RIIs2 = nanzscore(matRawLog2RIIs')';
dataMean=nanmean(matRawLog2RIIs,2);
dataSigma=nanstd(matRawLog2RIIs,0,2);
matRawZScoreLog2RIIs=(matRawLog2RIIs-repmat(dataMean,1,size(matRawLog2RIIs,2))) ./repmat(dataSigma,1,size(matRawLog2RIIs,2));

% Model expected data
matModelExpectedIIs = matModelExpectedInfectedCells ./ matRawTotalCells;
matModelExpectedRIIs = matModelExpectedIIs ./ repmat(nanmedian(matModelExpectedIIs,2),1,size(matModelExpectedIIs,2));
matModelExpectedRIIs(matModelExpectedRIIs<0)=0;
matModelExpectedLog2RIIs = log2( matModelExpectedRIIs );
matModelExpectedLog2RIIs(isinf(matModelExpectedLog2RIIs)) = NaN;

% matModelExpectedZScoreLog2RIIs = nanzscore(matModelExpectedLog2RIIs')';
dataMean=nanmean(matModelExpectedLog2RIIs,2);
dataSigma=nanstd(matModelExpectedLog2RIIs,0,2);
matModelExpectedZScoreLog2RIIs=(matModelExpectedLog2RIIs-repmat(dataMean,1,size(matModelExpectedLog2RIIs,2))) ./repmat(dataSigma,1,size(matModelExpectedLog2RIIs,2));

% Model corrected data
matModelCorrectedLog2RIIs = log2(matRawInfectedCells ./ matModelExpectedInfectedCells);
matModelCorrectedLog2RIIs(isinf(matModelCorrectedLog2RIIs)) = NaN;
dataMean=nanmean(matModelCorrectedLog2RIIs,2);
dataSigma=nanstd(matModelCorrectedLog2RIIs,0,2);
matModelCorrectedZScoreLog2RIIs=(matModelCorrectedLog2RIIs-repmat(dataMean,1,size(matModelCorrectedLog2RIIs,2))) ./repmat(dataSigma,1,size(matModelCorrectedLog2RIIs,2));

% Project Tensor/Bin corrected data
matProjectTensorCorrectedLog2RIIs = log2(matRawInfectedCells ./ matProjectTensorExpectedInfectedCells);
matProjectTensorCorrectedLog2RIIs(isinf(matProjectTensorCorrectedLog2RIIs)) = NaN;
dataMean=nanmean(matProjectTensorCorrectedLog2RIIs,2);
dataSigma=nanstd(matProjectTensorCorrectedLog2RIIs,0,2);
matProjectTensorCorrectedZScoreLog2RIIs=(matProjectTensorCorrectedLog2RIIs-repmat(dataMean,1,size(matProjectTensorCorrectedLog2RIIs,2))) ./repmat(dataSigma,1,size(matProjectTensorCorrectedLog2RIIs,2));

% Plate Tensor/Bin corrected data
matPlateTensorCorrectedLog2RIIs = log2(matRawInfectedCells ./ matPlateTensorExpectedInfectedCells);
matPlateTensorCorrectedLog2RIIs(isinf(matPlateTensorCorrectedLog2RIIs)) = NaN;
dataMean=nanmean(matPlateTensorCorrectedLog2RIIs,2);
dataSigma=nanstd(matPlateTensorCorrectedLog2RIIs,0,2);
matPlateTensorCorrectedZScoreLog2RIIs=(matPlateTensorCorrectedLog2RIIs-repmat(dataMean,1,size(matPlateTensorCorrectedLog2RIIs,2))) ./repmat(dataSigma,1,size(matPlateTensorCorrectedLog2RIIs,2));

% PROJECT tensor expected data
matProjectTensorExpectedIIs = matProjectTensorExpectedInfectedCells ./ matRawTotalCells;
matProjectTensorExpectedRIIs = matProjectTensorExpectedIIs ./ repmat(nanmedian(matProjectTensorExpectedIIs,2),1,size(matProjectTensorExpectedIIs,2));
matProjectTensorExpectedRIIs(matProjectTensorExpectedRIIs<0)=0;
matProjectTensorExpectedLog2RIIs = log2( matProjectTensorExpectedRIIs );
matProjectTensorExpectedLog2RIIs(isinf(matProjectTensorExpectedLog2RIIs)) = NaN;
dataMean=nanmean(matProjectTensorExpectedLog2RIIs,2);
dataSigma=nanstd(matProjectTensorExpectedLog2RIIs,0,2);
matProjectTensorExpectedZscoreLog2RIIs=(matProjectTensorExpectedLog2RIIs-repmat(dataMean,1,size(matProjectTensorExpectedLog2RIIs,2))) ./repmat(dataSigma,1,size(matProjectTensorExpectedLog2RIIs,2));


% PLATE tensor expected data
matPlateTensorExpectedIIs = matPlateTensorExpectedInfectedCells ./ matRawTotalCells;
matPlateTensorExpectedRIIs = matPlateTensorExpectedIIs ./ repmat(nanmedian(matPlateTensorExpectedIIs,2),1,size(matPlateTensorExpectedIIs,2));
matPlateTensorExpectedRIIs(matPlateTensorExpectedRIIs<0)=0;
matPlateTensorExpectedLog2RIIs = log2( matPlateTensorExpectedRIIs );
matPlateTensorExpectedLog2RIIs(isinf(matPlateTensorExpectedLog2RIIs)) = NaN;
dataMean=nanmean(matPlateTensorExpectedLog2RIIs,2);
dataSigma=nanstd(matPlateTensorExpectedLog2RIIs,0,2);
matPlateTensorExpectedZscoreLog2RIIs=(matPlateTensorExpectedLog2RIIs-repmat(dataMean,1,size(matPlateTensorExpectedLog2RIIs,2))) ./repmat(dataSigma,1,size(matPlateTensorExpectedLog2RIIs,2));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PREPARE OUTPUT STRUCTURE %%%

TensorCorrectedData = struct();

TensorCorrectedData.Raw.TotalCellNumber = matRawTotalCells;
TensorCorrectedData.Raw.Infected = matRawInfectedCells;
TensorCorrectedData.Raw.II = matRawIIs;
TensorCorrectedData.Raw.RII = matRawRIIs;
TensorCorrectedData.Raw.LOG2RII = matRawLog2RIIs;
TensorCorrectedData.Raw.ZSCORELOG2RII = matRawZScoreLog2RIIs;

TensorCorrectedData.ModelPredicted.Infected = matModelExpectedInfectedCells;
TensorCorrectedData.ModelPredicted.II = matModelExpectedIIs;
TensorCorrectedData.ModelPredicted.RII = matModelExpectedRIIs;
TensorCorrectedData.ModelPredicted.LOG2RII = matModelExpectedLog2RIIs;
TensorCorrectedData.ModelPredicted.ZSCORELOG2RII = matModelExpectedZScoreLog2RIIs;

TensorCorrectedData.ModelCorrected.LOG2RII = matModelCorrectedLog2RIIs;
TensorCorrectedData.ModelCorrected.ZSCORELOG2RII = matModelCorrectedZScoreLog2RIIs;

% Tensor corrected
% Project Tensor
TensorCorrectedData.ProjectTensorCorrected.LOG2RII = matProjectTensorCorrectedLog2RIIs;
TensorCorrectedData.ProjectTensorCorrected.ZSCORELOG2RII = matProjectTensorCorrectedZScoreLog2RIIs;
% Plate Tensor
TensorCorrectedData.PlateTensorCorrected.LOG2RII = matPlateTensorCorrectedLog2RIIs;
TensorCorrectedData.PlateTensorCorrected.ZSCORELOG2RII = matPlateTensorCorrectedZScoreLog2RIIs;

% Tensor expected
% PROJECT tensor expected data
TensorCorrectedData.ProjectTensorExpected.Infected = matProjectTensorExpectedInfectedCells;
TensorCorrectedData.ProjectTensorExpected.II = matProjectTensorExpectedIIs;
TensorCorrectedData.ProjectTensorExpected.RII = matProjectTensorExpectedRIIs;
TensorCorrectedData.ProjectTensorExpected.LOG2RII = matProjectTensorExpectedLog2RIIs;
TensorCorrectedData.ProjectTensorExpected.ZSCORELOG2RII = matProjectTensorExpectedZscoreLog2RIIs;

% PLATE tensor expected data
TensorCorrectedData.PlateTensorExpected.Infected = matPlateTensorExpectedInfectedCells;
TensorCorrectedData.PlateTensorExpected.II = matPlateTensorExpectedIIs;
TensorCorrectedData.PlateTensorExpected.RII = matPlateTensorExpectedRIIs;
TensorCorrectedData.PlateTensorExpected.LOG2RII = matPlateTensorExpectedLog2RIIs;
TensorCorrectedData.PlateTensorExpected.ZSCORELOG2RII = matPlateTensorExpectedZscoreLog2RIIs;

% Delta = difference between measured and model
TensorCorrectedData.Delta.IIraw_minus_IImodel = matRawIIs - matModelExpectedIIs;
TensorCorrectedData.Delta.Log2IIraw_minus_Log2IImodel = matRawLog2RIIs - matModelExpectedLog2RIIs;

% Meta data
TensorCorrectedData.OligoNumber = matOligoNumbers;
TensorCorrectedData.WellName = cellstrWellNames;
TensorCorrectedData.WellRowNumber = matWellRowNumbers;
TensorCorrectedData.WellColNumber = matWellColumnNumbers;
TensorCorrectedData.Path = cellstrPaths;
% settings
TensorCorrectedData.settings.structMiscSettings = structMiscSettings;
TensorCorrectedData.settings.structDataColumnsToUse = structDataColumnsToUse;



strOutputFile = fullfile(strDataPath,'ProbModel_TensorCorrectedData.mat');
save(strOutputFile,'TensorCorrectedData');
disp(sprintf('%s: stored %s',mfilename,strOutputFile))
