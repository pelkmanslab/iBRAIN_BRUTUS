% strDataPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\50K_Tfn\';
% strDataPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ2\philip_071006_Tfn_MZ_AWaa\';
strDataPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Lilli\070716_ChTxB_A431\';

if ~exist('Tensor','var') || ~exist('strLoadedDataPath','var')
    strLoadedDataPath = strDataPath;
    disp(sprintf('LOADING %s',fullfile(strDataPath,'ProbModel_Tensor.mat')))
    load(fullfile(strDataPath,'ProbModel_Tensor.mat'))
else
    if ~strcmpi(strLoadedDataPath,strDataPath)
        strLoadedDataPath = strDataPath;
        disp(sprintf('LOADING %s',fullfile(strDataPath,'ProbModel_Tensor.mat')))
        load(fullfile(strDataPath,'ProbModel_Tensor.mat'))
    end
end

disp(sprintf('*** RANDOMIZING'))
matRndIndices = randperm(size(Tensor.TrainingData,1));
Tensor.TrainingData(:,1)=Tensor.TrainingData(matRndIndices,1);
disp(sprintf('*** COMPLETED RANDOMIZATION'))

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
            disp(sprintf('processing plate %d, row %d, col %d',iPlate,iRow,iCol))            
            matCellIndices = find(Tensor.MetaData(:,intWellRowColumn)==iRow & Tensor.MetaData(:,intWellColColumn)==iCol & Tensor.MetaData(:,intPlateColumn)==iPlate);

            matCurrentWellTrainingData = Tensor.TrainingData(matCellIndices,:);

            
            matWellMeans = [];
            matWellVars = [];            
            matWellCountsPerBin = [];
            
            matWellCount(iRow,iCol) = size(matCurrentWellTrainingData,1);

            for iEdgeBin = unique(matCurrentWellTrainingData(:,intEdgeColumn))'            
%                 for iSizeBin = unique(matCurrentWellTrainingData(:,intSizeColumn))'
%                     for iDensityBin = unique(matCurrentWellTrainingData(:,intLcdColumn))'
% 
%                         matCurWellCellIndices = (matCurrentWellTrainingData(:,intLcdColumn) == iDensityBin) & ...
%                                         (matCurrentWellTrainingData(:,intSizeColumn) == iSizeBin) & ...
%                                         (matCurrentWellTrainingData(:,intEdgeColumn) == iEdgeBin);

%                         matCurWellCellIndices = (matCurrentWellTrainingData(:,intSizeColumn) == iSizeBin) & ...
%                                         (matCurrentWellTrainingData(:,intEdgeColumn) == iEdgeBin);
%                         matCurWellCellIndices = (matCurrentWellTrainingData(:,intLcdColumn) == iDensityBin);
                        matCurWellCellIndices = (matCurrentWellTrainingData(:,intEdgeColumn) == iEdgeBin);
                        

                        %%%%
                        matVars = [matVars; nanstd(single(matCurrentWellTrainingData(matCurWellCellIndices,1)-1))];%nanvar

                        matSTDs = [matSTDs; nanstd(single(matCurrentWellTrainingData(matCurWellCellIndices,1)-1))];
                        matMeans = [matMeans; nanmean(single(matCurrentWellTrainingData(matCurWellCellIndices,1)-1))];                
                        matCount = [matCount; sum(matCurWellCellIndices)];

                        %%%%                        
                        matWellVars = [matWellVars; nanstd(single(matCurrentWellTrainingData(matCurWellCellIndices,1)-1))];%nanvar
                        matWellMeans = [matWellMeans; nanmean(single(matCurrentWellTrainingData(matCurWellCellIndices,1)-1))];
                        matWellCountsPerBin = [matWellCountsPerBin; sum(matCurWellCellIndices)];

%                     end
%                 end
            end
            
            %%%%
            matPerWellVarRatios(iRow,iCol)=nanstd(matWellMeans(matWellCountsPerBin>intMinimalBinSize))/nanmean(matWellVars(matWellCountsPerBin>intMinimalBinSize));%nanvar

        end
    end    
end

nanstd(matMeans(matCount>intMinimalBinSize))
nanmean(matVars(matCount>intMinimalBinSize))


% nanmax(matPerWellVarRatios(:))
nanmean(matPerWellVarRatios(:))

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PLOT THE PER WELL PER BIN VARIANCE %%%
    
figure();
subplot(2,5,[1:4,6:9])
hold on
imagesc(flipud(matPerWellVarRatios))
axis off
title(sprintf('Plate heatmap with per well variance ratio\n average ( variance of mean values per bin / mean variance within bins) : %.3f',nanmean(matPerWellVarRatios(:))),'fontsize',10)
colorbar('location','southoutside','fontsize',8)
hold off

subplot(2,5,5)
hold on
hist(matPerWellVarRatios(:))
title('histogram of variance ratio''s','fontsize',10)
hold off

subplot(2,5,10)
hold on
S = repmat(3,size(matCount));
C = ones(size(matCount));
C(matCount<intMinimalBinSize)=2;
scatter(matCount,matVars,S,C,'o','filled')
vline(intMinimalBinSize,':r',sprintf('minimum (%d)',intMinimalBinSize))
x=matCount(matCount>0);
[x,nx]=sort(x);
y=matVars(matCount>0);
y=y(nx);
yLowess = malowess(x,y);
plot(x,yLowess,'k','linewidth',2)
title('scatter of bin-variance and bin-cellcount','fontsize',10)
xlabel('number of cells per bin','fontsize',8)
ylabel('variance per bin','fontsize',8)
hold off
drawnow






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CHECK THE WITHIN BIN VARIANCES OF THE ENTIRE MODEL %%%

matTrainingData = Tensor.TrainingData;
intMinBinSize = 50;
matOkBinIndices = find(Tensor.Model.TotalCells>intMinBinSize);
intNumOfOkBins = length(matOkBinIndices);
matBinVariance = nan(1,intNumOfOkBins);
iBinCounter = 0;
matBiggestVaryingDim = find(Tensor.BinSizes(2:end)==max(Tensor.BinSizes(2:end)),1,'first')+1;
for i = 1:Tensor.BinSizes(matBiggestVaryingDim)
    matCurrentXTrainingData = matTrainingData(matTrainingData(:,matBiggestVaryingDim)==i,:);
    
    matCurrentXIndices = find(Tensor.Model.TotalCells>intMinBinSize & Tensor.Model.X(:,matBiggestVaryingDim)==(i-1));    
    matCurrentX = Tensor.Model.X(matCurrentXIndices,:);
    
    for iBin = 1:length(matCurrentXIndices)
        iBinCounter=iBinCounter+1;
        disp(sprintf('bin %d of %d',iBinCounter,intNumOfOkBins))
        matBinDims = matCurrentX(iBin,2:end)+1;
        matCellsInCurrentBin=ismember(matCurrentXTrainingData(:,2:end),matBinDims,'rows');
        matCellsInCurrentBinIndices = find(matCellsInCurrentBin);

        %%%%        
        matBinVariance(iBinCounter) = nanvar(single(matCurrentXTrainingData(matCellsInCurrentBinIndices,1)-1));%nanvar
    end
    
    % remove processed cells from trainingdata
    matTrainingData(matTrainingData(:,matBiggestVaryingDim)==i,:) = [];
end

% hist(matBinVariance)
nanmean(matBinVariance)

%%% CHECK THE VARIANCE OF ALL BIN MEANS OF THE DATA
matYs = Tensor.Model.Y(Tensor.Model.TotalCells>50);
nanvar(matYs)%nanvar

%%% CHECK THE VARIANCE OF THE ENTIRE PREDICTIONS OF THE MODEL
matYHats = glmval(Tensor.Model.Params, Tensor.Model.X((Tensor.Model.TotalCells>50),2:end),'identity');
nanvar(matYHats)%nanvar


% scatter(matPerWellVarRatios(:),matWellCount(:))
% corrcoef(matPerWellVarRatios(~isnan(matPerWellVarRatios)),matWellCount(~isnan(matPerWellVarRatios)))

% sum(matPerWellVarRatios(~isnan(matPerWellVarRatios))>0.5) / sum(~isnan(matPerWellVarRatios(:)))




% figure()
% subplot(1,3,1:2)
% scatter(matCount,matSTDs)
% vline(200,':k')
% vline(50,':r')
% hline(nanmean(matSTDs(matCount>200)),'-b')
% hline(max(matMeans(matCount>200)) - min(matMeans(matCount>200)),'-g')
% subplot(1,3,3)
% boxplot(matMeans(matCount>200))
% drawnow
% 
% nanstd(matMeans(matCount>200)) / nanmean(matSTDs(matCount>200))
% 
% nanvar(matMeans)/nanmean(matVars)
% 
% nanmean(matWellVars)/nanmean(matVars)
% 
% 
% 
% matOutp1=[];
% matOutp2=[];
% for i = matCount'
%     if i < max(matCount)
%     matOutp1 = [matOutp1;max(matMeans(matCount>i))-min(matMeans(matCount>i))];
%     matOutp2 = [matOutp2;max(matSTDs(matCount>i))];
%     end
% end
% 
% [x,nx] = sort(matCount(1:end-1));
% 
% figure()
% plot(x,matOutp1(nx),'-g',...
%     x,matOutp2(nx),'-b'...
%     )
% legend({'max difference','max stdev'})
% xlabel('minimal amount of cells per bin')

