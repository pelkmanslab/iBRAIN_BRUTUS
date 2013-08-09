% function correctTrainingData_with_tensor(strRootPath)
%%% USE THE TENSOR ITSELF RATHER THAN THE MODEL TO CORRECT FOR EFFECTS
%%% 080815 VERSION

% if nargin == 0
    strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\RV_MZ\';
% end

MasterTensor = load(fullfile(strRootPath,'ProbModel_Tensor.mat'));
MasterTensor = MasterTensor.Tensor;

%%% Recalculate tensor without the dimension of 'total cell
%%% number' or 'population size'
% % % intTCNColumn = ~cellfun(@isempty,strfind(MasterTensor.Features,'TotalCellNumber'));
% % % if ~isempty(find(intTCNColumn,1))
% % %     disp('recalculating tensor without total cell number column')
% % %     [tensor_X, tensor_Y, tensor_TotalCells] = recalculateTensorFromTrainingData(MasterTensor.TrainingData(:,~intTCNColumn));
% % %     cellstrNewMasterTensorFeatures = MasterTensor.Features(~intTCNColumn);
% % %     if size(MasterTensor.TrainingData,1) ~= sum(tensor_TotalCells)
% % %         error('reconstructed tensor does not have the right amount of cells (%d ~= %d)',size(MasterTensor.TrainingData,1),sum(tensor_TotalCells))
% % %     else
% % %         disp(sprintf('tensor correctly reconstructed with %d cells',sum(tensor_TotalCells)))
% % %     end
% % % 
% % %     matTensorIndices = tensor_X;
% % %     matTensorInfectionIndices = tensor_Y;
% % %     
% % %     %%% recalculating model parameters, without TCN dimension
% % %     W = tensor_TotalCells.^(1/3);
% % %     W(W<8) = 0;
% % %     [b,dev,stats] = glmfit(tensor_X,tensor_Y,'normal','weights',W,'link','identity');
% % %     matModelParameters = b;
% % % else
    matTensorIndices = (MasterTensor.Indices-1);
    matTensorInfectionIndices = MasterTensor.InfectionIndex;    
    matModelParameters = MasterTensor.Model.Params;    
    %%% BS HACK
    intTCNColumn = zeros(1,size(MasterTensor.TrainingData,2));
% % % end

matTrainingData = MasterTensor.TrainingData(:,~intTCNColumn)-1;
matMeasuredInfection = MasterTensor.TrainingData(:,1)-1;
matTrainingData(:,1) = [];

%%% Create a vector matrix with the infection index of the tensor-bin
%%% corresponding to each cell in TrainingData
[c, ia] = ismember(matTrainingData,matTensorIndices,'rows');
matTensorExpectedInfection = matTensorInfectionIndices(ia);


%%% Look up which columns of MetaData contain resp. the plate number, the
%%% oligo number, the row number and the column number corresponding to
%%% each well 
intPlateNumberIndx = strcmpi(MasterTensor.MetaDataFeatures,'PlateNumber');
intOligoNumberIndx = strcmpi(MasterTensor.MetaDataFeatures,'OligoNumber');
intRowIndx = strcmpi(MasterTensor.MetaDataFeatures,'PlateRow');
intColIndx = strcmpi(MasterTensor.MetaDataFeatures,'PlateCol');


%%% Loop over all plates and wells, and calculate tensor - not model -
%%% predicted and measured infection indices

%%% ( NOTE: this is preferred over MasterTensor.NumberOfPlates, since there
%%% seems to be a bug in the mainTensorModel_glmfit code that omits a plate
%%% of  RV_KY/RV_MZ but adds it to the NumberOfPlates variable... check!
matUniquePlateNumbers = unique(MasterTensor.MetaData(:,intPlateNumberIndx));
intNumOfPlates = length(matUniquePlateNumbers);
% intNumOfPlates = MasterTensor.NumberOfPlates;

%%% Initialise output matrices
matRawIIs = NaN(intNumOfPlates,384);
matRawTotalCells = NaN(intNumOfPlates,384);
matRawInfectedCells = NaN(intNumOfPlates,384);
matModelExpectedInfectedCells = NaN(intNumOfPlates,384);
matTensorExpectedInfectedCells = NaN(intNumOfPlates,384);
matOligoNumbers = NaN(intNumOfPlates,384);
matWellColumnNumbers = NaN(intNumOfPlates,384);
matWellRowNumbers = NaN(intNumOfPlates,384);

for iPlate = 1:intNumOfPlates
    iPlateNumber = matUniquePlateNumbers(iPlate);
    % only include data of current plate
    matPlateTrainingDataIndices = MasterTensor.MetaData(:,intPlateNumberIndx)==iPlateNumber;
    matPlateTrainingData = matTrainingData(matPlateTrainingDataIndices,:);
    matPlateMetaData = MasterTensor.MetaData(matPlateTrainingDataIndices,:);
    matPlateMeasuredInfection = matMeasuredInfection(matPlateTrainingDataIndices,:);
    matPlateTensorExpectedInfection = matTensorExpectedInfection(matPlateTrainingDataIndices,:);
    
    intPlateOligoNumber = unique(matPlateMetaData(:,intOligoNumberIndx));
        
    iWellCounter = 0;
    for iRow = 1:16
        
        % only include data of current plate-row
        matRowIndices = (matPlateMetaData(:,intRowIndx)==iRow);
        matRowTrainingData = matPlateTrainingData(matRowIndices,:);
        matRowMetaData = matPlateMetaData(matRowIndices,:);
        matRowMeasuredInfection = matPlateMeasuredInfection(matRowIndices,:);
        matRowTensorExpectedInfection = matPlateTensorExpectedInfection(matRowIndices,:);        
        
        for iCol = 1:24
            
            iWellCounter = iWellCounter + 1;
            
            % find current well
            matWellIndices = matRowMetaData(:,intColIndx)==iCol;
            
            if ~isempty(find(matWellIndices, 1))
                disp(sprintf('plate %02d well row %02d col %02d: processing',iPlate,iRow,iCol));
                matWellTrainingData = matRowTrainingData(matWellIndices,:);
%                 matWellMetaData = matRowMetaData(matWellIndices,:);            
                matWellMeasuredInfection = matRowMeasuredInfection(matWellIndices,:);
                matWellTensorExpectedInfection = matRowTensorExpectedInfection(matWellIndices,:);


                %%% Fill in output matrices
                matRawIIs(iPlate,iWellCounter) = mean(matWellMeasuredInfection);
                matRawTotalCells(iPlate,iWellCounter) = sum(matWellIndices);
                matRawInfectedCells(iPlate,iWellCounter) = sum(matWellMeasuredInfection);
                matTensorExpectedInfectedCells(iPlate,iWellCounter) = sum(matWellTensorExpectedInfection);
                
                %%% Let's also calculate model correction here
                %%% MODEL EXPECTED INFECTION INDEX            
                matYHAT = glmval(double(matModelParameters),double(matWellTrainingData),'identity');
                matYHAT(matYHAT<0)=0;matYHAT(matYHAT>1)=1;
                matModelExpectedInfectedCells(iPlate,iWellCounter) = sum(matYHAT);
            end

            %%% fill in these values for all wells
            matOligoNumbers(iPlate,iWellCounter) = intPlateOligoNumber;                            
            matWellColumnNumbers(iPlate,iWellCounter) = iCol;
            matWellRowNumbers(iPlate,iWellCounter) = iRow;
            
        end
    end
end

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CALCULATING PARAMS WITHOUT NANZSCORE %%%

% SET ALL TensorEDINFECTEDCELLS <0 TO 0
matTensorExpectedInfectedCells(matTensorExpectedInfectedCells<0)=0;

%%% RAW 
matRawRIIs = matRawIIs ./ repmat(nanmedian(matRawIIs,2),1,size(matRawIIs,2));
matRawRIIs(matRawRIIs==0) = NaN;
matRawLog2RIIs = log2( matRawRIIs );
matRawLog2RIIs(isinf(matRawLog2RIIs)) = NaN;

dataMean=nanmean(matRawLog2RIIs,2);
dataSigma=nanstd(matRawLog2RIIs,0,2);
matRawZScoreLog2RIIs=(matRawLog2RIIs-repmat(dataMean,1,size(matRawLog2RIIs,2))) ./repmat(dataSigma,1,size(matRawLog2RIIs,2));

%%% TENSOR EXPECTED/CORRECTED
matTensorExpectedIIs = matTensorExpectedInfectedCells ./ matRawTotalCells;
matTensorExpectedRIIs = matTensorExpectedIIs ./ repmat(nanmedian(matTensorExpectedIIs,2),1,size(matTensorExpectedIIs,2));
matTensorExpectedRIIs(matTensorExpectedRIIs<0)=0;
matTensorExpectedLog2RIIs = log2( matTensorExpectedRIIs );
matTensorExpectedLog2RIIs(isinf(matTensorExpectedLog2RIIs)) = NaN;

dataMean=nanmean(matTensorExpectedLog2RIIs,2);
dataSigma=nanstd(matTensorExpectedLog2RIIs,0,2);
matTensorExpectedZScoreLog2RIIs=(matTensorExpectedLog2RIIs-repmat(dataMean,1,size(matTensorExpectedLog2RIIs,2))) ./repmat(dataSigma,1,size(matTensorExpectedLog2RIIs,2));

matTensorCorrectedLog2RIIs = log2(matRawInfectedCells ./ matTensorExpectedInfectedCells);
matTensorCorrectedLog2RIIs(isinf(matTensorCorrectedLog2RIIs)) = NaN;

% matTensorCorrectedZScoreLog2RIIs = nanzscore(matTensorCorrectedLog2RIIs')';
dataMean=nanmean(matTensorCorrectedLog2RIIs,2);
dataSigma=nanstd(matTensorCorrectedLog2RIIs,0,2);
matTensorCorrectedZScoreLog2RIIs=(matTensorCorrectedLog2RIIs-repmat(dataMean,1,size(matTensorCorrectedLog2RIIs,2))) ./repmat(dataSigma,1,size(matTensorCorrectedLog2RIIs,2));


%%% MODEL EXPECTED/CORRECTED
matModelExpectedIIs = matModelExpectedInfectedCells ./ matRawTotalCells;
matModelExpectedRIIs = matModelExpectedIIs ./ repmat(nanmedian(matModelExpectedIIs,2),1,size(matModelExpectedIIs,2));
matModelExpectedRIIs(matModelExpectedRIIs<0)=0;
matModelExpectedLog2RIIs = log2( matModelExpectedRIIs );
matModelExpectedLog2RIIs(isinf(matModelExpectedLog2RIIs)) = NaN;

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

%%% RAW
TensorCorrectedData.Raw.TotalCellNumber = matRawTotalCells;
TensorCorrectedData.Raw.Infected = matRawInfectedCells;
TensorCorrectedData.Raw.II = matRawIIs;
TensorCorrectedData.Raw.RII = matRawRIIs;
TensorCorrectedData.Raw.LOG2RII = matRawLog2RIIs;
TensorCorrectedData.Raw.ZSCORELOG2RII = matRawZScoreLog2RIIs;

%%% TENSOR
TensorCorrectedData.TensorPredicted.Infected = matTensorExpectedInfectedCells;
TensorCorrectedData.TensorPredicted.II = matTensorExpectedIIs;
TensorCorrectedData.TensorPredicted.RII = matTensorExpectedRIIs;
TensorCorrectedData.TensorPredicted.LOG2RII = matTensorExpectedLog2RIIs;
TensorCorrectedData.TensorPredicted.ZSCORELOG2RII = matTensorExpectedZScoreLog2RIIs;
TensorCorrectedData.TensorCorrected.LOG2RII = matTensorCorrectedLog2RIIs;
TensorCorrectedData.TensorCorrected.ZSCORELOG2RII = matTensorCorrectedZScoreLog2RIIs;
TensorCorrectedData.Delta.IIraw_minus_IITensor = matRawIIs - matTensorExpectedIIs;
TensorCorrectedData.Delta.Log2IIraw_minus_Log2IITensor = matRawLog2RIIs - matTensorExpectedLog2RIIs;

%%% MODEL
TensorCorrectedData.ModelPredicted.Infected = matModelExpectedInfectedCells;
TensorCorrectedData.ModelPredicted.II = matModelExpectedIIs;
TensorCorrectedData.ModelPredicted.RII = matModelExpectedRIIs;
TensorCorrectedData.ModelPredicted.LOG2RII = matModelExpectedLog2RIIs;
TensorCorrectedData.ModelPredicted.ZSCORELOG2RII = matModelExpectedZScoreLog2RIIs;
TensorCorrectedData.ModelCorrected.LOG2RII = matModelCorrectedLog2RIIs;
TensorCorrectedData.ModelCorrected.ZSCORELOG2RII = matModelCorrectedZScoreLog2RIIs;
TensorCorrectedData.Delta.IIraw_minus_IIModel = matRawIIs - matModelExpectedIIs;
TensorCorrectedData.Delta.Log2IIraw_minus_Log2IIModel = matRawLog2RIIs - matModelExpectedLog2RIIs;

%%% GENERAL
TensorCorrectedData.OligoNumber = matOligoNumbers;
% TensorCorrectedData.WellName = cellstrWellNames;
TensorCorrectedData.WellRowNumber = matWellRowNumbers;
TensorCorrectedData.WellColNumber = matWellColumnNumbers;

TensorCorrectedData.Path = {};%cellstrPaths

TensorCorrectedData.settings.structMiscSettings = MasterTensor.settings.structMiscSettings;
TensorCorrectedData.settings.structDataColumnsToUse = MasterTensor.settings.structDataColumnsToUse;

strOutputFile = fullfile(strRootPath,'ProbModel_TensorCorrectedData2.mat');
save(strOutputFile,'TensorCorrectedData');
disp(sprintf(' STORED %s',strOutputFile))

