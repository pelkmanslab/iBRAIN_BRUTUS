% function displayFitsFromTensor_Manuscript_style(strRootPath)

% if nargin == 0
% strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ2\philip_071006_Tfn_MZ_AWaa\';
% strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Lilli\070716_ChTxB_A431\';
% strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\RV_KY\';
% strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\';
% strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\';
% strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\DV_KY\';       
    
% end

MasterTensor = load(fullfile(strRootPath,'ProbModel_Tensor.mat'));
MasterTensor = MasterTensor.Tensor;

TensorEdges = load(fullfile(strRootPath,'ProbModel_TrainingDataEdges.mat'));

% calculate the most common dimension-indices from all trainingdata (single
% cells)
% matDimensionMedians = nanmedian(MasterTensor.TrainingData,1);

intNumDims = size(MasterTensor.Model.X,2);
intNumIndices = size(MasterTensor.Model.X,1);

matAllDims = 1:intNumDims;

% loop over all dimensions, per dimension, keep all other dimensions
% constant at their medians, scatter the current dimension against the
% infectionindices (Y) and show model prediction and/or linear fit

cellMeasuredII = cell(1,intNumDims);
cellModelExpectedII = cell(1,intNumDims);
cellMeasuredIISTDEV = cell(1,intNumDims);
cellModelExpectedIILowerBound = cell(1,intNumDims);
cellModelExpectedIIUpperBound = cell(1,intNumDims);
cellWeights = cell(1,intNumDims);
cellTotalCells = cell(1,intNumDims);

for iDim = 2:intNumDims % skipping first dimension, constant
    
    intCurrentDimBins = MasterTensor.BinSizes(iDim);
    
    for iBin = 1:intCurrentDimBins
        
        [intCurrentRowIndex,foo] = find(MasterTensor.Model.X(:,iDim) == iBin-1);

        
        cellMeasuredII{iDim}(1,iBin) = nansum(MasterTensor.Model.Y(intCurrentRowIndex) .* MasterTensor.TotalCells(intCurrentRowIndex)) / nansum(MasterTensor.TotalCells(intCurrentRowIndex));
        cellMeasuredIISTDEV{iDim}(1,iBin) = nanstd(MasterTensor.Model.Y(intCurrentRowIndex));

        [yhat,dylo,dyhi] = glmval(MasterTensor.Model.Params, MasterTensor.Model.X(intCurrentRowIndex,2:end),'identity',MasterTensor.Model.Stats);
        
        if MasterTensor.BinSizes(1,1)==2
            yhat(yhat<0) = 0;
            yhat(yhat>1) = 1;
        end

%         sum(repmat(MasterTensor.Model.Params',size(intCurrentRowIndex,1),1) .* (MasterTensor.Model.X(intCurrentRowIndex,:)-1),2)
        
        cellModelExpectedII{iDim}(1,iBin) = nansum(yhat.*MasterTensor.TotalCells(intCurrentRowIndex)) / nansum(MasterTensor.TotalCells(intCurrentRowIndex));
        
        cellTotalCells{iDim}(1,iBin) = nansum(MasterTensor.TotalCells(intCurrentRowIndex));        
        
%         matWeights = MasterTensor.Model.W(intCurrentRowIndex,intCurrentRowIndex);
%         cellWeights{iDim}(1,iBin) = nanmean(full(matWeights(matWeights>0)));

        cellWeights{iDim}(1,iBin) = nansum(MasterTensor.TotalCells(intCurrentRowIndex)) .^ (1/3);
        
    end
end


% %%% CALCULATE MAXIMUM Y-AXIS VALUE TO DETERMINE THE y-AXIS VALUES
matPlottedIIs = [];
cellstrFieldNames = fieldnames(TensorEdges.TrainingData);
for iDim = 2:intNumDims
    matCurWeights = cellWeights{iDim};
    matWeightedIndices = find(matCurWeights>0);

    
    if MasterTensor.StepSizes(1) ~= 1
        yPredicted = ((cellModelExpectedII{iDim}-1) .* MasterTensor.StepSizes(1)) + TensorEdges.TrainingData.(cellstrFieldNames{1}).Min;
        yMeasured = ((cellMeasuredII{iDim}-1) .* MasterTensor.StepSizes(1)) + TensorEdges.TrainingData.(cellstrFieldNames{1}).Min;    
    else
        yPredicted = cellModelExpectedII{iDim};
        yMeasured = cellMeasuredII{iDim};
    end
    matPlottedIIs = [matPlottedIIs, yPredicted(1,matWeightedIndices), yMeasured(1,matWeightedIndices)];

%     matPlottedIIs = [matPlottedIIs, cellModelExpectedII{iDim}(1,matWeightedIndices), cellMeasuredII{iDim}(1,matWeightedIndices)];
end

intMaxDataII = nanmax(matPlottedIIs);
intMinPlotII = nanmin(matPlottedIIs);
if MasterTensor.BinSizes(1,1)==2
    intMinDataII = 0;
    intMaxPlotII = intMaxDataII + .05;
    intMaxPlotII = round(intMaxPlotII*10)/10;
elseif intMaxDataII < 0
    % log10 intensity readouts
    intMinPlotII = intMinPlotII - .025;
    intMaxPlotII = intMaxDataII + .025;
elseif intMinPlotII > 2
    % binned intensity readout
    intMinPlotII = intMinPlotII - 2;
    intMinPlotII = round(intMinPlotII*10)/10;
    intMaxPlotII = intMaxDataII + 2;
    intMaxPlotII = round(intMaxPlotII*10)/10;
end

%%% PLOT FIGURES
figure();
for iDim = 2:intNumDims
    
    matCurWeights = cellWeights{iDim};
    matWeightedIndices = find(matCurWeights>10);
    
    if ~isempty(strfind(strRootPath,'Tfn_MZ'))
        matColormap = flipud(colormap(gray(20)))        
        intWeightFactor = .65
    elseif ~isempty(strfind(strRootPath,'ChTxB'))
        matColormap = flipud(colormap(gray(35)))        
        intWeightFactor =.65   
    elseif ~isempty(strfind(strRootPath,'MHV_KY'))
        matColormap = flipud(colormap(gray(30)))        
        intWeightFactor = .65
    elseif ~isempty(strfind(strRootPath,'RV_KY'))
        matColormap = flipud(colormap(gray(40)))        
        intWeightFactor = .65
    elseif ~isempty(strfind(strRootPath,'SV40_MZ'))
        matColormap = flipud(colormap(gray(40)))        
        intWeightFactor = .65  
    elseif ~isempty(strfind(strRootPath,'DV_KY'))
        matColormap = flipud(colormap(gray(40)))        
        intWeightFactor = .65   
    end
    
    subplot(2,3,iDim-1)
    hold on

    % get the correct x-axis
    cellstrFieldNames = fieldnames(TensorEdges.TrainingData);
    if ~isempty(strfind(cellstrFieldNames{iDim},'AreaShape_1'))
        matSizeToMicrometerCorrectionFactor = 0.81;
    else
        matSizeToMicrometerCorrectionFactor = 1;
    end
    x = ((matWeightedIndices-1) .* MasterTensor.StepSizes(iDim)) + TensorEdges.TrainingData.(cellstrFieldNames{iDim}).Min;
    x = x .* matSizeToMicrometerCorrectionFactor;

    %%% INTENSITY BASED READOUTS
    if MasterTensor.StepSizes(1) ~= 1
        yPredicted = ((cellModelExpectedII{iDim}-1) .* MasterTensor.StepSizes(1)) + TensorEdges.TrainingData.(cellstrFieldNames{1}).Min;
        yMeasured = ((cellMeasuredII{iDim}-1) .* MasterTensor.StepSizes(1)) + TensorEdges.TrainingData.(cellstrFieldNames{1}).Min;    
    else
        yPredicted = cellModelExpectedII{iDim};
        yMeasured = cellMeasuredII{iDim};
    end

    
    plot(x,yPredicted(1,matWeightedIndices),'Color',[1 0 0],'linewidth',1)

%     errorbar(x,yMeasured(1,matWeightedIndices),cellMeasuredIISTDEV{iDim}(1,matWeightedIndices),'Color',[0 0 0],'linewidth',1)
    scatter(x,yMeasured(1,matWeightedIndices),(matCurWeights(matWeightedIndices)*intWeightFactor)-5,'filled','Marker','o','MarkerFaceColor','k','MarkerEdgeColor','k')


%     plot(x,cellModelExpectedII{iDim}(1,matWeightedIndices),'Color',[0 0 0],'linewidth',1)
%     scatter(x,cellMeasuredII{iDim}(1,matWeightedIndices),(matCurWeights(matWeightedIndices)*intWeightFactor)-5,'filled','Marker','o','MarkerFaceColor','k','MarkerEdgeColor','k')
%     matPlottedIIs = [matPlottedIIs, cellModelExpectedII{iDim}(1,matWeightedIndices), cellMeasuredII{iDim}(1,matWeightedIndices)];

%     title(strrep([strrep(getlastdir(strRootPath),'_','\_'),'_',MasterTensor.Features{iDim}],'_','\_'),'fontsize',10)
   switch MasterTensor.Features{iDim}
     case 'Nuclei_GridNucleiCountCorrected_1'
        strPanelTitle = 'LCD'
    strXaxisLabel = ['LCD (cells / 2\cdot10^3)\mum \alpha_',num2str(iDim),' = ',sprintf('%.2f',MasterTensor.Model.Params(iDim)),'  (p = ',sprintf('%.g',MasterTensor.Model.p(iDim)),')']            
     case 'Nuclei_AreaShape_1'
        strPanelTitle = 'SIZE'         
    strXaxisLabel = ['SIZE \mum \alpha_',num2str(iDim),' = ',sprintf('%.2f',MasterTensor.Model.Params(iDim)),'  (p = ',sprintf('%.g',MasterTensor.Model.p(iDim)),')']                    
     case 'Nuclei_GridNucleiEdges_1'
        strPanelTitle = 'EDGE'         
    strXaxisLabel = ['EDGE \alpha_',num2str(iDim),' = ',sprintf('%.2f',MasterTensor.Model.Params(iDim)),'  (p = ',sprintf('%.g',MasterTensor.Model.p(iDim)),')']                    
     case 'Image_CorrectedTotalCellNumberPerWell_1'
        strPanelTitle = 'POP.SIZE'         
    strXaxisLabel = ['POP.SIZE (cells) \alpha_',num2str(iDim),' = ',sprintf('%.2f',MasterTensor.Model.Params(iDim)),'  (p = ',sprintf('%.g',MasterTensor.Model.p(iDim)),')']                    
     case 'Nuclei_CellTypeClassificationPerColumn_2'
        strPanelTitle = 'MIT'         
    strXaxisLabel = ['MIT \alpha_',num2str(iDim),' = ',sprintf('%.2f',MasterTensor.Model.Params(iDim)),'  (p = ',sprintf('%.g',MasterTensor.Model.p(iDim)),')']                    
     case 'Nuclei_CellTypeClassificationPerColumn_3'
        strPanelTitle = 'APOP'         
    strXaxisLabel = ['APOP \alpha_',num2str(iDim),' = ',sprintf('%.2f',MasterTensor.Model.Params(iDim)),'  (p = ',sprintf('%.g',MasterTensor.Model.p(iDim)),')']                    
   otherwise
        strPanelTitle = 'unknown'
    end
    
    title(strPanelTitle,'fontsize',10,'fontweight','bold')
    xlabel(strXaxisLabel,'Interpreter','tex','fontsize',8)
%     xlabel([strPanelTitle,' \alpha_',num2str(iDim),' = ',sprintf('%.2f',MasterTensor.Model.Params(iDim)),'  (p = ',sprintf('%.g',MasterTensor.Model.p(iDim)),')'],'Interpreter','tex','fontsize',8)    
    
    hold off
    
    % fix YLim over all plots the same
    set(gca,'YLim',[intMinPlotII, intMaxPlotII])
    
    % if it is a binary class, add trailing x-points
    if isequal(x,[0,1])    
        set(gca,'XLim',[-1, 2])    
    end
    


    
    drawnow
end



% % add axis w/color none that overlaps entire figure as title placeholder
if ~isempty(strfind(strRootPath,'Tfn'))
    strFigureTitle = 'Tfn';    
elseif ~isempty(strfind(strRootPath,'ChTxB'))
    strFigureTitle = 'ChTxB';    
elseif ~isempty(strfind(strRootPath,'DV'))
    strFigureTitle = 'DV';    
elseif ~isempty(strfind(strRootPath,'MHV'))
    strFigureTitle = 'MHV';    
elseif ~isempty(strfind(strRootPath,'RV'))
    strFigureTitle = 'RV';    
elseif ~isempty(strfind(strRootPath,'SV40'))
    strFigureTitle = 'SV40';    
end
%     strFigureTitle = strrep(sprintf('%s',char(getlastdir(strRootPath))),'_','\_');
hold on
axes('Color','none','Position',[0,0,1,.95])
axis off
title(['fits including all other dimensions: ',strFigureTitle],'FontSize',12,'FontWeight','bold')
hold off
drawnow



gcf2pdf
close(gcf)