function correctTrainingData4(strDataPath, settings, strModelPath)
%%% USES GLMFIT TO CALCULATE MODEL PREDICTED VALUES
%%% 080307 VERSION

if nargin == 0
    strDataPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\';
end


%%% WHICH COLUMNS TO USE FOR EACH MEASUREMENT, TRANSPOSE DATA, RAW
%%% MEASUREMENT FILE NAMES, NUMBER OF BINS, ETC... 
if nargin < 2
    [structDataColumnsToUse, structMiscSettings] = initStructDataColumnsToUse();
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
            disp('   old settings do not match new settings. redoing training data correction')
        else 
            disp('   old settings match new settings. skipping training data correction')            
            return
        end

    else
        disp('   old file did not contain settings field. redoing training data correction')            
    end
else
%     disp('   no file present yet')                
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
matTensorExpectedInfectedCells = NaN(intNumOfFolders,384);

matOligoNumbers = NaN(intNumOfFolders,384);
matWellColumnNumbers = NaN(intNumOfFolders,384);
matWellRowNumbers = NaN(intNumOfFolders,384);

cellstrDataLabels = cell(intNumOfFolders,384);
cellstrWellNames = cell(intNumOfFolders,384);

cellstrPaths = cell(intNumOfFolders,1);

for i = 1:intNumOfFolders
    
    disp(sprintf('  processing %s',getlastdir(cellstrTargetFolderList{i})))
    
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
                X = PlateTensor{i}.TrainingData(matCurWellCellIndices,2:end);
                X = X - 1;
                X = [ones(size(X,1),1),X];
                
                YHAT = glmval(double(MasterTensor.Model.Params),double(X),'identity','constant','off');
                YHAT(YHAT<0)=0;
                YHAT(YHAT>1)=1;
                matModelExpectedInfectedCells(i,wellcounter) = round(sum(YHAT));
                
%                 Y = repmat(MasterTensor.Model.Params',size(X,1),1) .* double(X);
%                 matModelExpectedInfectedCells(i,wellcounter) = round(sum(Y(:)));                
                
            else 
                matRawIIs(i,wellcounter) = NaN;
                matRawInfectedCells(i,wellcounter) = NaN;
                matRawTotalCells(i,wellcounter) = NaN;                
                matModelExpectedInfectedCells(i,wellcounter) = NaN; 
                matTensorExpectedInfectedCells(i,wellcounter) = NaN;
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

matModelExpectedIIs = matModelExpectedInfectedCells ./ matRawTotalCells;
matModelExpectedRIIs = matModelExpectedIIs ./ repmat(nanmedian(matModelExpectedIIs,2),1,size(matModelExpectedIIs,2));
matModelExpectedRIIs(matModelExpectedRIIs<0)=0;
matModelExpectedLog2RIIs = log2( matModelExpectedRIIs );
matModelExpectedLog2RIIs(isinf(matModelExpectedLog2RIIs)) = NaN;

% matModelExpectedZScoreLog2RIIs = nanzscore(matModelExpectedLog2RIIs')';
dataMean=nanmean(matModelExpectedLog2RIIs,2);
dataSigma=nanstd(matModelExpectedLog2RIIs,0,2);
matModelExpectedZScoreLog2RIIs=(matModelExpectedLog2RIIs-repmat(dataMean,1,size(matModelExpectedLog2RIIs,2))) ./repmat(dataSigma,1,size(matModelExpectedLog2RIIs,2));

matModelCorrectedLog2RIIs = log2(matRawInfectedCells ./ matModelExpectedInfectedCells);
matModelCorrectedLog2RIIs(isinf(matModelCorrectedLog2RIIs)) = NaN;

% matModelCorrectedZScoreLog2RIIs = nanzscore(matModelCorrectedLog2RIIs')';
dataMean=nanmean(matModelCorrectedLog2RIIs,2);
dataSigma=nanstd(matModelCorrectedLog2RIIs,0,2);
matModelCorrectedZScoreLog2RIIs=(matModelCorrectedLog2RIIs-repmat(dataMean,1,size(matModelCorrectedLog2RIIs,2))) ./repmat(dataSigma,1,size(matModelCorrectedLog2RIIs,2));




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

TensorCorrectedData.Delta.IIraw_minus_IImodel = matRawIIs - matModelExpectedIIs;
TensorCorrectedData.Delta.Log2IIraw_minus_Log2IImodel = matRawLog2RIIs - matModelExpectedLog2RIIs;

TensorCorrectedData.OligoNumber = matOligoNumbers;
TensorCorrectedData.WellName = cellstrWellNames;
TensorCorrectedData.WellRowNumber = matWellRowNumbers;
TensorCorrectedData.WellColNumber = matWellColumnNumbers;

TensorCorrectedData.Path = cellstrPaths;

TensorCorrectedData.settings.structMiscSettings = structMiscSettings;
TensorCorrectedData.settings.structDataColumnsToUse = structDataColumnsToUse;



strOutputFile = fullfile(strDataPath,'ProbModel_TensorCorrectedData.mat');
save(strOutputFile,'TensorCorrectedData');
disp(sprintf(' STORED %s',strOutputFile))


if nargin == 0

    matModelExpectedIIs = matModelExpectedInfectedCells ./ matRawTotalCells;

    matModelExpectedIIs(matModelExpectedIIs<0) = 0;

    for i = 1:3

        rowIndices = ([1:3]+(3*(i-1)));

        matRawLog2RIIs = log2( matRawIIs(rowIndices,:) ./ repmat(nanmedian(matRawIIs(rowIndices,:),2),1,size(matRawIIs(rowIndices,:),2)) );
        matRawLog2RIIs(isinf(matRawLog2RIIs)) = NaN;

        matModelExpectedRIIs = matModelExpectedIIs(rowIndices,:) ./ repmat(nanmedian(matModelExpectedIIs(rowIndices,:),2),1,size(matModelExpectedIIs(rowIndices,:),2));
        matModelExpectedRIIs(matModelExpectedRIIs<0)=0;
        matModelExpectedLog2RIIs = log2( matModelExpectedRIIs );
        matModelExpectedLog2RIIs(isinf(matModelExpectedLog2RIIs)) = NaN;

        matModelCorrectedLog2RII = log2(matRawInfectedCells(rowIndices,:) ./ matModelExpectedInfectedCells(rowIndices,:));
        matModelCorrectedLog2RII(isinf(matModelCorrectedLog2RII)) = NaN;

        figure()

        
        matDataPointsPresent = nanmedian(matRawLog2RIIs);
        matDataPointsPresent = find(~isnan(matDataPointsPresent));

        matYLim = [nanmin([matRawLog2RIIs(:);matModelExpectedLog2RIIs(:);matModelCorrectedLog2RII(:)]), nanmax([matRawLog2RIIs(:);matModelExpectedLog2RIIs(:);matModelCorrectedLog2RII(:)])];
        
        subplot(3,1,1)
        hold on
        boxplot(matRawLog2RIIs(:,matDataPointsPresent))
        title(['Raw Log2 IIs: std = ',num2str(nanmedian(nanstd(matRawLog2RIIs,0,1)))])
        
        ylabel('Raw Log2 IIs')
        ylim(matYLim)
        hline(0)
        hold off

        subplot(3,1,2)
        hold on
        boxplot(matModelExpectedLog2RIIs(:,matDataPointsPresent))
        title(['Model Expected Log2 IIs: std = ',num2str(nanmedian(nanstd(matModelExpectedLog2RIIs,0,1)))])
        ylabel('Model Expected Log2 IIs')
        ylim(matYLim)
        hline(0)
        hold off


        subplot(3,1,3)
        hold on
        boxplot(matModelCorrectedLog2RII(:,matDataPointsPresent))
        title(['Model Corrected Log2 IIs: std = ',num2str(nanmedian(nanstd(matModelCorrectedLog2RII,0,1)))])
        ylabel('Model Corrected Log2 IIs')
        ylim(matYLim)
        hline(0)
        hold off

        drawnow

    end

end
