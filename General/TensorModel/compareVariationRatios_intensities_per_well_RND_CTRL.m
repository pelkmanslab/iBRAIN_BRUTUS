% strDataPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\50K_Tfn\';
strDataPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ2\philip_071006_Tfn_MZ_AWaa\';
% strDataPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Lilli\070716_ChTxB_A431\';

if ~exist('Tensor','var') || ~exist('strLoadedDataPath','var')
    strLoadedDataPath = strDataPath;
    disp(sprintf('LOADING %s',fullfile(strDataPath,'ProbModel_Tensor.mat')))
    load(fullfile(strDataPath,'ProbModel_Tensor.mat'))
else
    if ~strcmpi(strLoadedDataPath,strDataPath)
        strLoadedDataPath = strDataPath;
        disp(sprintf('LOADING %s',fullfile(strDataPath,'ProbModel_Tensor.mat')))
        load(fullfile(strDataPath,'ProbModel_Tensor.mat'))
    else
        disp(sprintf('ALREADY LOADED %s',fullfile(strDataPath,'ProbModel_Tensor.mat')))        
    end
end

% disp(sprintf('*** RANDOMIZING'))
% matRndIndices = randperm(size(Tensor.TrainingData,1));
% Tensor.TrainingData(:,1)=Tensor.TrainingData(matRndIndices,1);
% disp(sprintf('*** COMPLETED RANDOMIZATION'))

intMinimalBinSize = 50;

intNumOfPlates = max(Tensor.MetaData(:,find(strcmpi(Tensor.MetaDataFeatures,'PlateNumber'))));

%lookup corresponding data columns
intTCNColumn = find(strcmpi(Tensor.Features,'Image_CorrectedTotalCellNumberPerWell_1'));
intReadoutColumn = find(strcmpi(Tensor.Features,'Nuclei_VirusScreen_ClassicalInfection_1'));
intWellRowColumn = find(strcmpi(Tensor.MetaDataFeatures,'PlateRow'));
intWellColColumn = find(strcmpi(Tensor.MetaDataFeatures,'PlateCol'));
intPlateColumn = find(strcmpi(Tensor.MetaDataFeatures,'PlateNumber'));

intLcdColumn = find(strcmpi(Tensor.Features','Nuclei_GridNucleiCountCorrected_1'));
intEdgeColumn = find(strcmpi(Tensor.Features','Nuclei_GridNucleiEdges_1'));
intSizeColumn = find(strcmpi(Tensor.Features','Nuclei_AreaShape_1'));
% intTcnColumn = find(strcmpi(Tensor.Features','Image_CorrectedTotalCellNumberPerWell_1'));


%%% MAIN LOOP OVER RANDOMIZED CONTROL ITERATIONS
matRatio = nan(20,1);
matRatioVars = nan(20,1);
for iCtrlLoop = 1:20

matSTDs = [];
matCount = [];
matMeans = [];
matVars = [];

matWellVars = [];
matWellCount = [];

matWellCount = nan(8,12);
matPerWellVarRatios = nan(8,12);
matWellYHatStd = nan(8,12);

for iPlate = 1:intNumOfPlates
    for iRow = 1:8
        for iCol = 1:12
%             disp(sprintf('processing plate %d, row %d, col %d',iPlate,iRow,iCol))            
            matCellIndices = find(Tensor.MetaData(:,intWellRowColumn)==iRow & Tensor.MetaData(:,intWellColColumn)==iCol & Tensor.MetaData(:,intPlateColumn)==iPlate);

            matCurrentWellTrainingData = Tensor.TrainingData(matCellIndices,:);
            
%             disp('randomizing data within well')
            matCurrentWellTrainingData(:,1) = matCurrentWellTrainingData(randperm(size(matCurrentWellTrainingData,1)),1);

            
            matWellMeans = [];
            matWellVars = [];            
            matWellCountsPerBin = [];
            
            matWellCount(iRow,iCol) = size(matCurrentWellTrainingData,1);

            for iEdgeBin = unique(matCurrentWellTrainingData(:,intEdgeColumn))'            
                for iSizeBin = unique(matCurrentWellTrainingData(:,intSizeColumn))'
                    for iDensityBin = unique(matCurrentWellTrainingData(:,intLcdColumn))'

                        matCurWellCellIndices = (matCurrentWellTrainingData(:,intLcdColumn) == iDensityBin) & ...
                                        (matCurrentWellTrainingData(:,intSizeColumn) == iSizeBin) & ...
                                        (matCurrentWellTrainingData(:,intEdgeColumn) == iEdgeBin);

%                         matCurWellCellIndices = (matCurrentWellTrainingData(:,intSizeColumn) == iSizeBin) & ...
%                                         (matCurrentWellTrainingData(:,intEdgeColumn) == iEdgeBin);
%                         matCurWellCellIndices = (matCurrentWellTrainingData(:,intLcdColumn) == iDensityBin);
%                         matCurWellCellIndices = (matCurrentWellTrainingData(:,intEdgeColumn) == iEdgeBin);

                        %%%%
                        matVars = [matVars; nanvar(single(matCurrentWellTrainingData(matCurWellCellIndices,1)-1))];%nanvar

                        matSTDs = [matSTDs; nanstd(single(matCurrentWellTrainingData(matCurWellCellIndices,1)-1))];
                        matMeans = [matMeans; nanmean(single(matCurrentWellTrainingData(matCurWellCellIndices,1)-1))];                
                        matCount = [matCount; sum(matCurWellCellIndices)];

                        %%%%                        
                        matWellVars = [matWellVars; nanvar(single(matCurrentWellTrainingData(matCurWellCellIndices,1)-1))];%nanvar
                        matWellMeans = [matWellMeans; nanmean(single(matCurrentWellTrainingData(matCurWellCellIndices,1)-1))];
                        matWellCountsPerBin = [matWellCountsPerBin; sum(matCurWellCellIndices)];

                    end
                end
            end
            
            %%%%
            matPerWellVarRatios(iRow,iCol)=nanvar(matWellMeans(matWellCountsPerBin>intMinimalBinSize))/nanmean(matWellVars(matWellCountsPerBin>intMinimalBinSize));%nanvar

        end
    end    
end

% nanstd(matMeans(matCount>intMinimalBinSize))
% nanmean(matVars(matCount>intMinimalBinSize))


% nanmax(matPerWellVarRatios(:))
% nanmean(matPerWellVarRatios(:))

% return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PLOT THE PER WELL PER BIN VARIANCE %%%
    
% figure();
% subplot(2,5,[1:4,6:9])
% hold on
% imagesc(flipud(matPerWellVarRatios))
% axis off
% title(sprintf('Plate heatmap with per well variance ratio\n average ( variance of mean values per bin / mean variance within bins) : %.3f',nanmean(matPerWellVarRatios(:))),'fontsize',10)
% colorbar('location','southoutside','fontsize',8)
% hold off
% 
% subplot(2,5,5)
% hold on
% hist(matPerWellVarRatios(:))
% title('histogram of variance ratio''s','fontsize',10)
% hold off
% 
% subplot(2,5,10)
% hold on
% S = repmat(3,size(matCount));
% C = ones(size(matCount));
% C(matCount<intMinimalBinSize)=2;
% scatter(matCount,matVars,S,C,'o','filled')
% vline(intMinimalBinSize,':r',sprintf('minimum (%d)',intMinimalBinSize))
% x=matCount(matCount>0);
% [x,nx]=sort(x);
% y=matVars(matCount>0);
% y=y(nx);
% yLowess = malowess(x,y);
% plot(x,yLowess,'k','linewidth',2)
% title('scatter of bin-variance and bin-cellcount','fontsize',10)
% xlabel('number of cells per bin','fontsize',8)
% ylabel('variance per bin','fontsize',8)
% hold off
% drawnow




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CHECK THE WITHIN BIN VARIANCES OF THE ENTIRE MODEL %%%

matTrainingData = Tensor.TrainingData;

disp(sprintf('*** RANDOMIZING matTrainingData'))
matRndIndices = randperm(size(matTrainingData,1));
matTrainingData(:,1)=matTrainingData(matRndIndices,1);
disp(sprintf('*** COMPLETED RANDOMIZATION matTrainingData'))

intMinBinSize = 50;
matOkBinIndices = find(Tensor.Model.TotalCells>intMinBinSize);
intNumOfOkBins = length(matOkBinIndices);
matBinVariance = nan(1,intNumOfOkBins);
matBinStdev = nan(1,intNumOfOkBins);
matBinMean = nan(1,intNumOfOkBins);

iBinCounter = 0;

% search algorithm optimization, break down the entire dataset according to
% the biggest varying dimension, and process all underlying dimensions/bins
% of those subsets individually.
matBiggestVaryingDim = find(Tensor.BinSizes(2:end)==max(Tensor.BinSizes(2:end)),1,'first')+1;
for i = 1:Tensor.BinSizes(matBiggestVaryingDim)

    matCurrentXTrainingData = matTrainingData(matTrainingData(:,matBiggestVaryingDim)==i,:);
    matCurrentXIndices = find(Tensor.Model.TotalCells>intMinBinSize & Tensor.Model.X(:,matBiggestVaryingDim)==(i-1));    
    matCurrentX = Tensor.Model.X(matCurrentXIndices,:);
    
    for iBin = 1:length(matCurrentXIndices)
        iBinCounter=iBinCounter+1;
%         disp(sprintf('bin %d of %d',iBinCounter,intNumOfOkBins))
        matBinDims = matCurrentX(iBin,2:end)+1;
        matCellsInCurrentBin=ismember(matCurrentXTrainingData(:,2:end),matBinDims,'rows');
        matCellsInCurrentBinIndices = find(matCellsInCurrentBin);

        %%%%        
        matBinVariance(iBinCounter) = nanvar(single(matCurrentXTrainingData(matCellsInCurrentBinIndices,1)-1));%nanvar
        matBinStdev(iBinCounter) = nanstd(single(matCurrentXTrainingData(matCellsInCurrentBinIndices,1)-1));%nanvar
        matBinMean(iBinCounter) = nanmean(single(matCurrentXTrainingData(matCellsInCurrentBinIndices,1)-1));%nanvar        
    end
    
    % remove processed cells from trainingdata
    matTrainingData(matTrainingData(:,matBiggestVaryingDim)==i,:) = [];
end

% hist(matBinVariance)
% nanmean(matBinVariance)

%%% CHECK THE VARIANCE OF ALL BIN MEANS OF THE DATA
% matYs = Tensor.Model.Y(Tensor.Model.TotalCells>50);
% nanvar(matYs);%nanvar

%%% CHECK THE VARIANCE OF THE ENTIRE PREDICTIONS OF THE MODEL
% matYHats = glmval(Tensor.Model.Params, Tensor.Model.X((Tensor.Model.TotalCells>50),2:end),'identity');
% nanvar(matYHats);%nanvar


% nanvar(matYs) / nanmean(matBinVariance)
% nanstd(matYs) / nanmean(matBinStdev)

% matRatio(iCtrlLoop) = nanstd(matBinMean) / nanmean(matVars(matCount>intMinimalBinSize))
matRatioVars(iCtrlLoop) = nanvar(matBinMean) / nanmean(matVars(matCount>intMinimalBinSize))

end % iCtrlLoop