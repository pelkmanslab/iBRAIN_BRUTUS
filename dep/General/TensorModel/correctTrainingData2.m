function correctTrainingData2(strRootPath)

if nargin == 0
    strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\HPV16_MZ_2\';
end

cellstrTargetFolderList = SearchTargetFolders(strRootPath,'Measurements_Image_FileNames.mat');
intNumOfFolders = length(cellstrTargetFolderList);

PlateTensor = cell(intNumOfFolders,1);

MasterTensor = load(fullfile(strRootPath,'ProbModel_Tensor.mat'));
MasterTensor = MasterTensor.Tensor;

matRows = cellstr(regexp(char(65:80),'\w','match'));
matCols = regexp(sprintf('%.2d',1:24),'\d\d','match');

matRawIIs = NaN(intNumOfFolders,50);
matRawTotalCells = NaN(intNumOfFolders,50);
matRawInfectedCells = NaN(intNumOfFolders,50);
matModelExpectedInfectedCells = NaN(intNumOfFolders,50);
matTensorExpectedInfectedCells = NaN(intNumOfFolders,50);

matOligoNumbers = NaN(intNumOfFolders,50);
matWellColumnNumbers = NaN(intNumOfFolders,50);
matWellRowNumbers = NaN(intNumOfFolders,50);

cellstrDataLabels = cell(intNumOfFolders,50);
cellstrWellNames = cell(intNumOfFolders,50);

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
    
    
    
    for iRows = 3:7
        for iCols = 2:11
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
                Y = repmat(MasterTensor.Model.Params',size(X,1),1) .* double(X);
                matModelExpectedInfectedCells(i,wellcounter) = round(sum(Y(:)));                
                
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

dataMean=nanmean(matRawLog2RIIs);
dataSigma=nanstd(matRawLog2RIIs);
matRawZScoreLog2RIIs=(matRawLog2RIIs-repmat(dataMean,size(matRawLog2RIIs,1),1)) ./repmat(dataSigma,size(matRawLog2RIIs,1),1) ;


% matRawZScoreLog2RIIs = nanzscore(matRawLog2RIIs')';

matModelExpectedIIs = matModelExpectedInfectedCells ./ matRawTotalCells;
matModelExpectedRIIs = matModelExpectedIIs ./ repmat(nanmedian(matModelExpectedIIs,2),1,size(matModelExpectedIIs,2));
matModelExpectedRIIs(matModelExpectedRIIs<0)=0;
matModelExpectedLog2RIIs = log2( matModelExpectedRIIs );
matModelExpectedLog2RIIs(isinf(matModelExpectedLog2RIIs)) = NaN;

% matModelExpectedZScoreLog2RIIs = nanzscore(matModelExpectedLog2RIIs')';

dataMean=nanmean(matModelExpectedLog2RIIs);
dataSigma=nanstd(matModelExpectedLog2RIIs);
matModelExpectedZScoreLog2RIIs=(matModelExpectedLog2RIIs-repmat(dataMean,size(matModelExpectedLog2RIIs,1),1)) ./repmat(dataSigma,size(matModelExpectedLog2RIIs,1),1) ;


matModelCorrectedLog2RIIs = log2(matRawInfectedCells ./ matModelExpectedInfectedCells);
matModelCorrectedLog2RIIs(isinf(matModelCorrectedLog2RIIs)) = NaN;
% matModelCorrectedZScoreLog2RIIs = nanzscore(matModelCorrectedLog2RIIs')';

dataMean=nanmean(matModelCorrectedLog2RIIs);
dataSigma=nanstd(matModelCorrectedLog2RIIs);
matModelCorrectedZScoreLog2RIIs=(matModelCorrectedLog2RIIs-repmat(dataMean,size(matModelCorrectedLog2RIIs,1),1)) ./repmat(dataSigma,size(matModelCorrectedLog2RIIs,1),1) ;







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



strOutputFile = fullfile(strRootPath,'ProbModel_TensorCorrectedData.mat');
save(strOutputFile,'TensorCorrectedData');
disp(sprintf(' STORED %s',strOutputFile))



% % % matModelExpectedIIs = matModelExpectedInfectedCells ./ matRawTotalCells;
% % % 
% % % matModelExpectedIIs(matModelExpectedIIs<0) == 0;
% % % 
% % % for i = 1:3
% % % 
% % % rowIndices = ([1:3]+(3*(i-1)));
% % % 
% % % matRawLog2RIIs = log2( matRawIIs(rowIndices,:) ./ repmat(nanmedian(matRawIIs(rowIndices,:),2),1,size(matRawIIs(rowIndices,:),2)) );
% % % matRawLog2RIIs(isinf(matRawLog2RIIs)) = NaN;
% % % 
% % % matModelExpectedRIIs = matModelExpectedIIs(rowIndices,:) ./ repmat(nanmedian(matModelExpectedIIs(rowIndices,:),2),1,size(matModelExpectedIIs(rowIndices,:),2));
% % % matModelExpectedRIIs(matModelExpectedRIIs<0)=0;
% % % matModelExpectedLog2RIIs = log2( matModelExpectedRIIs );
% % % matModelExpectedLog2RIIs(isinf(matModelExpectedLog2RIIs)) = NaN;
% % % 
% % % matModelCorrectedLog2RII = log2(matRawInfectedCells(rowIndices,:) ./ matModelExpectedInfectedCells(rowIndices,:));
% % % matModelCorrectedLog2RII(isinf(matModelCorrectedLog2RII)) = NaN;
% % % 
% % % figure()
% % % 
% % % subplot(3,1,1)
% % % hold on
% % % boxplot(matRawLog2RIIs)
% % % title(['Raw Log2 IIs: std = ',num2str(nanstd(nanmedian(matRawLog2RIIs)))])
% % % ylabel('Raw Log2 IIs')
% % % ylim([-3 3])
% % % hline(0)
% % % hold off
% % % 
% % % subplot(3,1,2)
% % % hold on
% % % boxplot(matModelExpectedLog2RIIs)
% % % title(['Model Expected Log2 IIs: std = ',num2str(nanstd(nanmedian(matModelExpectedLog2RIIs)))])
% % % ylabel('Model Expected Log2 IIs')
% % % ylim([-3 3])
% % % hline(0)
% % % hold off
% % % 
% % % 
% % % subplot(3,1,3)
% % % hold on
% % % boxplot(matModelCorrectedLog2RII)
% % % title(['Model Corrected Log2 IIs: std = ',num2str(nanstd(nanmedian(matModelCorrectedLog2RII)))])
% % % ylabel('Model Corrected Log2 IIs')
% % % ylim([-3 3])
% % % hline(0)
% % % hold off
% % % 
% % % drawnow

% end


