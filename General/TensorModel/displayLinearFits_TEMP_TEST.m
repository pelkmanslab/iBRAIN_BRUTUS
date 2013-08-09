strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ\philip_071006_Tfn_MZ_AWaa\';    

MasterTensor = load(fullfile(strRootPath,'ProbModel_Tensor.mat'));
MasterTensor = MasterTensor.Tensor;

% calculate the most common dimension-indices from all trainingdata (single
% cells)
matDimensionMedians = nanmedian(MasterTensor.TrainingData,1);

% disp('taking slices TCN is ')
% matDimensionMedians(5) = 6;

intNumDims = length(matDimensionMedians);

intNumIndices = size(MasterTensor.Model.X,1);

matAllDims = 1:intNumDims;

% loop over all dimensions, per dimension, keep all other dimensions
% constant at their medians, scatter the current dimension against the
% infectionindices (Y) and show model prediction and/or linear fit

cellMeasuredII = cell(1,intNumDims);
cellModelExpectedII = cell(1,intNumDims);
cellModelExpectedIILowerBound = cell(1,intNumDims);
cellModelExpectedIIUpperBound = cell(1,intNumDims);
cellWeights = cell(1,intNumDims);
cellTotalCells = cell(1,intNumDims);
cellStandardDeviation = cell(1,intNumDims);

for iDim = 2:intNumDims % skipping first dimension, constant
    
    intCurrentDimBins = MasterTensor.BinSizes(iDim);
    
    for iBin = 1:intCurrentDimBins
        
        matCurrentClass = zeros(size(matAllDims));
        matCurrentClass(matAllDims~=iDim) = matDimensionMedians(matAllDims(matAllDims~=iDim));
        matCurrentClass(iDim) = iBin;
        matCurrentClass = matCurrentClass - 1;
        matCurrentClass(1) = 1;
        
        intCurrentRowIndex = find(sum(MasterTensor.Model.X == repmat(matCurrentClass,intNumIndices,1),2) == size(matCurrentClass,2));

        cellMeasuredII{iDim}(1,iBin) = MasterTensor.Model.Y(intCurrentRowIndex);
        cellTotalCells{iDim}(1,iBin) = MasterTensor.TotalCells(intCurrentRowIndex);        
        cellWeights{iDim}(1,iBin) = MasterTensor.Model.W(intCurrentRowIndex,intCurrentRowIndex);

        matCurrentCellIndices = ismember(MasterTensor.TrainingData(:,2:end),(matCurrentClass(2:end)+1), 'rows');
        
        cellStandardDeviation{iDim}(1,iBin) = nanstd(single(MasterTensor.TrainingData(matCurrentCellIndices,1)-1));
        
    end
end



% get the plusminus part of the confidence intervals
% matConfidenceIntervals = MasterTensor.Model.Params - MasterTensor.Model.ConfidenceIntervals(:,1);


%%% CALCULATE MAXIMUM Y-AXIS VALUE
intMaxDataII = max([cellfun(@max,cellMeasuredII(~cellfun(@isempty,cellMeasuredII))),cellfun(@max,cellModelExpectedII(~cellfun(@isempty,cellModelExpectedII)))]);
intMaxPlotII = intMaxDataII + .2;
intMaxPlotII = round(intMaxPlotII*10)/10;
if intMaxPlotII > 1 && MasterTensor.BinSizes(1,1)==2
    intMaxPlotII = 1;
end

figure();
for iDim = 2:intNumDims
    
    matCurWeights = cellWeights{iDim};
    matWeightedIndices = find(matCurWeights>0);
    
    subplot(2,3,iDim-1)
    hold on
    
    bar(matWeightedIndices,intMaxPlotII*(cellTotalCells{iDim}(matWeightedIndices)/max(cellTotalCells{iDim}(matWeightedIndices))),'FaceColor',[.95 .95 .95],'EdgeColor',[.95 .95 .95])

    line([matDimensionMedians(iDim) matDimensionMedians(iDim)],[0 1],'LineStyle','-','Color',[.75 .75 .75])
    
%     scatter(matWeightedIndices,cellMeasuredII{iDim}(1,matWeightedIndices),cellWeights{iDim}(1,matWeightedIndices),'b','filled')
    errorbar(matWeightedIndices,cellMeasuredII{iDim}(1,matWeightedIndices),cellStandardDeviation{iDim}(1,matWeightedIndices))
    
%     scatter(matWeightedIndices,cellModelExpectedII{iDim}(1,matWeightedIndices),cellWeights{iDim}(1,matWeightedIndices),'g','filled')
%     plot(matWeightedIndices,cellModelExpectedII{iDim}(1,matWeightedIndices),'-g','linewidth',2)
%     plot(matWeightedIndices,cellModelExpectedIILowerBound{iDim}(1,matWeightedIndices),':k')
%     plot(matWeightedIndices,cellModelExpectedIIUpperBound{iDim}(1,matWeightedIndices),':k')
    
    if ~MasterTensor.Model.DiscardParamBasedOnCIs(iDim)
        title(strrep(MasterTensor.Features{iDim},'_','\_'),'fontsize',10)
    else
        title(strrep(MasterTensor.Features{iDim},'_','\_'),'fontsize',10,'color','r')        
    end

    
    hold off
    
%     if ((max(get(gca,'XLim')) <= 2.5) && (length(get(gca,'XLim')) == 2))
%         set(gca,'XLim',[.5, 2.5])
%     end
    
    set(gca,'YLim',[0, intMaxPlotII])
%     xlabel(sprintf('\alpha _%d \eq %.4f \pm %.4f',iDim,MasterTensor.Model.Params(iDim),matConfidenceIntervals(iDim)),'Interpreter','tex')    
%     xlabel(['\alpha_',num2str(iDim),' = ',num2str(MasterTensor.Model.Params(iDim)),' \pm ',num2str(matConfidenceIntervals(iDim))],'Interpreter','tex')
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
