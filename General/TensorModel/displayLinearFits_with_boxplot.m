% function displayLinearFits(strRootPath)

% if nargin == 0
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\VV_DG\20071022095251_M2_071020_VV_DG_batch1_CP001-1db\';         
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ2\philip_071006_Tfn_MZ_AWaa\';
    strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\DV_KY\';

% end

cellstrTargetFolderList = SearchTargetFolders(strRootPath,'Measurements_Image_FileNames.mat');
cellstrTargetFolderList = getbasedir(cellstrTargetFolderList);
intNumOfFolders = length(cellstrTargetFolderList);

matOrigTCN = single([]);
matOrigInfected = single([]);

% get model data per plate, to calculate variation/boxplot per bin
boolGoLoadData=0;
if ~exist('strLoadedDataPath','var')
    boolGoLoadData=1;
else
    if ~strcmpi(strLoadedDataPath,strRootPath)
        boolGoLoadData=1;
    end
end

if boolGoLoadData
    disp('merging tensors')
    for i = 1:intNumOfFolders
        strLoadedDataPath = strRootPath;
        load(fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat'));
        matOrigTCN = [matOrigTCN,single(Tensor.TotalCells)];
        matOrigInfected = [matOrigInfected, single(Tensor.InfectedCells)];
    end
else
    disp('data already loaded')    
end

matOrigY = matOrigInfected ./ matOrigTCN;
matPlateIIs = nansum(matOrigInfected,1) ./ nansum(matOrigTCN,1);
matOverallII = nansum(matOrigInfected(:)) ./ nansum(matOrigTCN(:));
% matOrigY = matOrigY ./ repmat(matPlateIIs, size(matOrigY,1),1);
% matOrigY = log2(matOrigY);


%%% LOAD COMPLETE MODEL
MasterTensor = load(fullfile(strRootPath,'ProbModel_Tensor.mat'));
MasterTensor = MasterTensor.Tensor;

if size(matOrigY,1) ~= size(MasterTensor.Model.Y,1)
    error('individual plate models are not the same as the total model')
end

% calculate the most common dimension-indices from all trainingdata (single
% cells)
matDimensionMedians = nanmedian(MasterTensor.TrainingData,1);

intNumDims = length(matDimensionMedians);

intNumIndices = size(MasterTensor.Model.X,1);

matAllDims = 1:intNumDims;

% loop over all dimensions, per dimension, keep all other dimensions
% constant at their medians, scatter the current dimension against the
% infectionindices (Y) and show model prediction and/or linear fit
cellMeasuredIIAverage = cell(1,intNumDims);
cellMeasuredIIStd = cell(1,intNumDims);

cellMeasuredII = cell(1,intNumDims);
cellMeasuredIIBin = cell(1,intNumDims);
cellModelExpectedII = cell(1,intNumDims);
cellModelExpectedIILowerBound = cell(1,intNumDims);
cellModelExpectedIIUpperBound = cell(1,intNumDims);
cellWeights = cell(1,intNumDims);
cellTotalCells = cell(1,intNumDims);

% matDimensionMedians(2)=2

for iDim = 2:intNumDims % skipping first dimension, constant
    
    intCurrentDimBins = MasterTensor.BinSizes(iDim);
    

    
    for iBin = 1:intCurrentDimBins
        
        matCurrentClass = zeros(size(matAllDims));
        matCurrentClass(matAllDims~=iDim) = matDimensionMedians(matAllDims(matAllDims~=iDim));
        matCurrentClass(iDim) = iBin;
        matCurrentClass = matCurrentClass - 1;
        matCurrentClass(1) = 1;
        
        intCurrentRowIndex = find(sum(MasterTensor.Model.X == repmat(matCurrentClass,intNumIndices,1),2) == size(matCurrentClass,2));
        
        matCurrentYValues = matOrigY(intCurrentRowIndex,:)';
        matCurrentYValues(matOrigTCN(intCurrentRowIndex,:)<75)=[]; % discard bins with too few cells
        
        if length(matCurrentYValues)<3
            matCurrentYValues = [];
        end
        
        cellMeasuredII{iDim} = [cellMeasuredII{iDim};matCurrentYValues];
        cellMeasuredIIBin{iDim} = [cellMeasuredIIBin{iDim};repmat(iBin,length(matCurrentYValues),1)];
        
        cellMeasuredIIAverage{iDim}(1,iBin) = nanmean(matCurrentYValues);
        cellMeasuredIIStd{iDim}(1,iBin) = nanstd(matCurrentYValues);                
        
        [yhat,dylo,dyhi] = glmval(MasterTensor.Model.Params, matCurrentClass(1,2:end),'identity',MasterTensor.Model.Stats);
        
        if MasterTensor.BinSizes(1,1)==2
            yhat(yhat<0) = 0;
            yhat(yhat>1) = 1;
        end        

%         yhat = yhat / matOverallII;
        cellModelExpectedII{iDim}(1,iBin) = yhat;%sum(MasterTensor.Model.Params' .* matCurrentClass);
        
%         cellModelExpectedIILowerBound{iDim}(1,iBin) = yhat-dylo;
%         cellModelExpectedIIUpperBound{iDim}(1,iBin) = yhat+dyhi;
        
        cellTotalCells{iDim}(1,iBin) = MasterTensor.TotalCells(intCurrentRowIndex);        
        cellWeights{iDim}(1,iBin) = MasterTensor.Model.W(intCurrentRowIndex,intCurrentRowIndex);
        
    end
end

% get the plusminus part of the confidence intervals
% matConfidenceIntervals = MasterTensor.Model.Params - MasterTensor.Model.ConfidenceIntervals(:,1);


%%% CALCULATE MAXIMUM Y-AXIS VALUE
% intMaxDataII = max([cellfun(@max,cellMeasuredII(~cellfun(@isempty,cellMeasuredII))),cellfun(@max,cellModelExpectedII(~cellfun(@isempty,cellModelExpectedII)))]);
% intMaxPlotII = intMaxDataII + .2;
% intMaxPlotII = round(intMaxPlotII*10)/10;
% if intMaxPlotII > 1 && MasterTensor.BinSizes(1,1)==2

intMaxPlotII = .75;
intMinPlotII = 0;

% end

figure();
for iDim = 2:intNumDims
    
    matCurWeights = cellWeights{iDim};
    matWeightedIndices = find(matCurWeights>0);
    
    subplot(2,3,iDim-1)
    hold on
    
    bar(matWeightedIndices,intMaxPlotII*(cellTotalCells{iDim}(matWeightedIndices)/max(cellTotalCells{iDim}(matWeightedIndices))),'FaceColor',[.85 .85 .85],'EdgeColor',[.85 .85 .85])

    line([matDimensionMedians(iDim) matDimensionMedians(iDim)],[0 1],'LineStyle','-','Color',[.95 .95 .95])

%     boxplot(cellMeasuredII{iDim},cellMeasuredIIBin{iDim},'positions',unique(cellMeasuredIIBin{iDim}),'colors','k')
    
    errorbar(matWeightedIndices,cellMeasuredIIAverage{iDim}(1,matWeightedIndices),cellMeasuredIIStd{iDim}(1,matWeightedIndices),'-k', 'linestyle', 'none')
    scatter(matWeightedIndices,cellMeasuredIIAverage{iDim}(1,matWeightedIndices),cellWeights{iDim}(1,matWeightedIndices),'k','filled')

    plot(matWeightedIndices,cellModelExpectedII{iDim}(1,matWeightedIndices),'-b','linewidth',2)
    
    if ~MasterTensor.Model.DiscardParamBasedOnCIs(iDim)
        title(strrep(MasterTensor.Features{iDim},'_','\_'),'fontsize',10)
    else
        title(strrep(MasterTensor.Features{iDim},'_','\_'),'fontsize',10,'color','r')        
    end

    
    hold off
    
    set(gca,'YLim',[intMinPlotII, intMaxPlotII])
    xlabel(['\alpha_',num2str(iDim),' = ',num2str(MasterTensor.Model.Params(iDim)),'  (p = ',num2str(MasterTensor.Model.p(iDim)),')'],'Interpreter','tex','fontsize',8)
    
    
    drawnow
end


% add axis w/color none that overlaps entire figure as title placeholder
strFigureTitle = strrep(sprintf('%s',char(getlastdir(strRootPath))),'_','\_');
hold on
axes('Color','none','Position',[0,0,1,.95])
axis off
title(['fits keeping all other dimensions fixed: ',strFigureTitle],'FontSize',14,'FontWeight','bold')
hold off
drawnow


