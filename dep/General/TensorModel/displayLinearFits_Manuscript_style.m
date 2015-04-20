% function displayLinearFits_Manuscript_style(strRootPath)

% if nargin == 0
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\VV_DG\20071022095251_M2_071020_VV_DG_batch1_CP001-1db\';         
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\50K_Tfn\20071130131036_M1_071129_A431_50k_Tfn_P3_2_CP001-1aa\';
% end

% strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ2\philip_071006_Tfn_MZ_AWaa\';
% strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Lilli\070716_ChTxB_A431\';
% strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\RV_KY\';
% strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\';
% strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\';
strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\DV_KY\';  

MasterTensor = load(fullfile(strRootPath,'ProbModel_Tensor.mat'));
MasterTensor = MasterTensor.Tensor;

TensorEdges = load(fullfile(strRootPath,'ProbModel_TrainingDataEdges.mat'));

% calculate the most common dimension-indices from all trainingdata (single
% cells)
intNumDims = size(MasterTensor.TrainingData,2);

intNumIndices = size(MasterTensor.Model.X,1);

matDimensionMedians = nanmedian(MasterTensor.TrainingData,1);

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

for iDim = 2:intNumDims % skipping first dimension, constant

    intCurrentDimBins = MasterTensor.BinSizes(iDim);
    
%     if intCurrentDimBins == 2
%         % optimize linear fit display by selecting fixexd bin dimensions
%         % such that the second class of the current dimension has the
%         % maximimum possible number of cells
%         matCurDimIndices = MasterTensor.Indices(:,iDim-1) == 2;
%         matCurDimIndexIndex = find(matCurDimIndices);
%         matOfThoseIndicesMaxIndex = find(MasterTensor.TotalCells(matCurDimIndices) == max(MasterTensor.TotalCells(matCurDimIndices)));
%         disp(sprintf('binary class, fixed dim settings to maximize num of cells (%d) in that bin',max(MasterTensor.TotalCells(matCurDimIndices))))
%         matDimensionMedians = [1,MasterTensor.Indices(matCurDimIndexIndex(matOfThoseIndicesMaxIndex),:)]        
%     else
%         % optimize linear fit display by selecting fixed bin dimensions
%         % such that the overall number of cells in the current
%         % dimension-bins is maximized 
%         matOtherDimIndices = matAllDims~=iDim;
%         matOtherDimIndices(1) = [];
%         matTempIndices = MasterTensor.Indices(:,matOtherDimIndices);
%         matTempIndices(full(diag(MasterTensor.Model.W)) == 0,:) = [];
%         matTempIndices = unique(matTempIndices,'rows');
%         
%         matTempIndices2 = MasterTensor.Indices(:,matOtherDimIndices);
%         matTempIndexCellCounts = nan(size(matTempIndices,1),1);
%         for i = 1:size(matTempIndices,1)
%             matCurDimValues = matTempIndices(i,:);
%             [tf,loc]=ismember(matTempIndices2,matCurDimValues,'rows');
%             matTempIndexCellCounts(i,1) = nansum(MasterTensor.TotalCells(tf));
%         end
%         matBiggestIndex = find(matTempIndexCellCounts == max(matTempIndexCellCounts));
%         disp(sprintf('found fixed dim settings with a total of %d cells',matTempIndexCellCounts(matBiggestIndex)))
%         matDimensionMedians = zeros(size(matAllDims));
%         matDimensionMedians(matAllDims~=iDim) = [1,matTempIndices(matBiggestIndex,:)]
%     end

    

    
    for iBin = 1:intCurrentDimBins
        
        matCurrentClass = zeros(size(matAllDims));
        matCurrentClass(matAllDims~=iDim) = matDimensionMedians(matAllDims(matAllDims~=iDim));
        matCurrentClass(iDim) = iBin;
        matCurrentClass = matCurrentClass - 1;
        matCurrentClass(1) = 1;
        
        intCurrentRowIndex = find(sum(MasterTensor.Model.X == repmat(matCurrentClass,intNumIndices,1),2) == size(matCurrentClass,2));
        disp(sprintf('DIM %d BIN %d --> matches to row %d with %d cells',iDim,iBin,intCurrentRowIndex,MasterTensor.TotalCells(intCurrentRowIndex)));
        
        cellMeasuredII{iDim}(1,iBin) = MasterTensor.Model.Y(intCurrentRowIndex);

        [yhat,dylo,dyhi] = glmval(MasterTensor.Model.Params, matCurrentClass(1,2:end),'identity',MasterTensor.Model.Stats);
        
        if MasterTensor.BinSizes(1,1)==2
            yhat(yhat<0) = 0;
            yhat(yhat>1) = 1;
        end        

        
        cellModelExpectedII{iDim}(1,iBin) = yhat;%sum(MasterTensor.Model.Params' .* matCurrentClass);
%         cellModelExpectedIILowerBound{iDim}(1,iBin) = yhat-dylo;
%         cellModelExpectedIIUpperBound{iDim}(1,iBin) = yhat+dyhi;
        
        cellTotalCells{iDim}(1,iBin) = MasterTensor.TotalCells(intCurrentRowIndex);        
        cellWeights{iDim}(1,iBin) = MasterTensor.Model.W(intCurrentRowIndex,intCurrentRowIndex);
        
    end
end

% %%% CALCULATE MAXIMUM Y-AXIS VALUE TO DETERMINE THE y-AXIS VALUES
matPlottedIIs = [];
cellstrFieldNames = fieldnames(TensorEdges.TrainingData);
for iDim = 2:intNumDims
    matCurWeights = cellWeights{iDim};
    matWeightedIndices = find(matCurWeights>0);

    if MasterTensor.StepSizes(1) == 1
    %%% INFECTION BASED READOUTS        
        yPredicted = cellModelExpectedII{iDim};
        yMeasured = cellMeasuredII{iDim};            
    else
    %%% INTENSITY BASED READOUTS        
        yPredicted = ((cellModelExpectedII{iDim}-1) .* MasterTensor.StepSizes(1)) + TensorEdges.TrainingData.(cellstrFieldNames{1}).Min;
        yMeasured = ((cellMeasuredII{iDim}-1) .* MasterTensor.StepSizes(1)) + TensorEdges.TrainingData.(cellstrFieldNames{1}).Min;    
    end
    
    matPlottedIIs = [matPlottedIIs, yPredicted(1,matWeightedIndices), yMeasured(1,matWeightedIndices)];
    
%     matPlottedIIs = [matPlottedIIs, cellModelExpectedII{iDim}(1,matWeightedIndices), cellMeasuredII{iDim}(1,matWeightedIndices)];
end

intMaxDataII = nanmax(matPlottedIIs);
intMinPlotII = nanmin(matPlottedIIs);
if MasterTensor.BinSizes(1,1)==2
    intMinDataII = 0;
    intMaxPlotII = intMaxDataII + .2;
    intMaxPlotII = round(intMaxPlotII*10)/10;
elseif intMaxDataII < 0
    % log10 intensity readouts
    intMinPlotII = intMinPlotII - .025;
    intMaxPlotII = intMaxDataII + .025;
elseif intMinPlotII > 2
    % binned intensity readout
    intMinPlotII = intMinPlotII - 5;
    intMinPlotII = round(intMinPlotII*10)/10;
    intMaxPlotII = intMaxDataII + 5;
    intMaxPlotII = round(intMaxPlotII*10)/10;
end

%%% PLOT FIGURES
figure();
for iDim = 2:intNumDims
    
    matCurWeights = cellWeights{iDim};
    matWeightedIndices = find(matCurWeights>0);
    
    if ~isempty(strfind(strRootPath,'Tfn_MZ'))
        matColormap = flipud(colormap(gray(20)));
        intWeightFactor = 4;
    elseif ~isempty(strfind(strRootPath,'ChTxB'));
        matColormap = flipud(colormap(gray(35)));
        intWeightFactor = 3;  
    elseif ~isempty(strfind(strRootPath,'MHV_KY'));
        matColormap = flipud(colormap(gray(30)));
        intWeightFactor = 2;
    elseif ~isempty(strfind(strRootPath,'RV_KY'));
        matColormap = flipud(colormap(gray(40)));
        intWeightFactor = 2;
    elseif ~isempty(strfind(strRootPath,'SV40_MZ'));
        matColormap = flipud(colormap(gray(40)));
        intWeightFactor = 2;   
    elseif ~isempty(strfind(strRootPath,'DV_KY'));
        matColormap = flipud(colormap(gray(40)));
        intWeightFactor = 2;   
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


    if MasterTensor.StepSizes(1) == 1
    %%% INFECTION BASED READOUTS        
        yPredicted = cellModelExpectedII{iDim};
        yMeasured = cellMeasuredII{iDim};            
    else
    %%% INTENSITY BASED READOUTS        
        yPredicted = ((cellModelExpectedII{iDim}-1) .* MasterTensor.StepSizes(1)) + TensorEdges.TrainingData.(cellstrFieldNames{1}).Min;
    %     yPredicted = 10 .^ yPredicted
        yMeasured = ((cellMeasuredII{iDim}-1) .* MasterTensor.StepSizes(1)) + TensorEdges.TrainingData.(cellstrFieldNames{1}).Min;    
    %     yMeasured = 10 .^ yMeasured    
    end

    bar(x,intMaxPlotII*(cellTotalCells{iDim}(matWeightedIndices)/max(cellTotalCells{iDim}(matWeightedIndices))),'FaceColor',[.95 .95 .95],'EdgeColor','none')    
    plot(x,yPredicted(1,matWeightedIndices),'Color',[1 0 0],'linewidth',.5)
%     scatter(x,yMeasured(1,matWeightedIndices),(matCurWeights(matWeightedIndices)*intWeightFactor)-5,'filled','Marker','o','MarkerFaceColor','k','MarkerEdgeColor','k')
    scatter(x,yMeasured(1,matWeightedIndices),repmat(5,size(x)),'filled','Marker','o','MarkerFaceColor','k','MarkerEdgeColor','k')

%     plot(x,cellModelExpectedII{iDim}(1,matWeightedIndices),'Color',[0 0 0],'linewidth',1)
%     scatter(x,cellMeasuredII{iDim}(1,matWeightedIndices),(matCurWeights(matWeightedIndices)*intWeightFactor)-5,'filled','Marker','o','MarkerFaceColor','k','MarkerEdgeColor','k')
%     matPlottedIIs = [matPlottedIIs, cellModelExpectedII{iDim}(1,matWeightedIndices), cellMeasuredII{iDim}(1,matWeightedIndices)];

%     title(strrep([strrep(getlastdir(strRootPath),'_','\_'),'_',MasterTensor.Features{iDim}],'_','\_'),'fontsize',10)
    
    hold off
    
    % fix YLim over all plots the same
    set(gca,'YLim',[intMinPlotII, intMaxPlotII])
    
    % if it is a binary class, add trailing x-points
    if isequal(x,[0,1])    
        set(gca,'XLim',[-1, 2])    
    end
    
   switch MasterTensor.Features{iDim}
     case 'Nuclei_GridNucleiCountCorrected_1'
        strPanelTitle = 'LCD';
    strXaxisLabel = ['LCD (cells / 2\cdot10^3 \mum) \alpha_',num2str(iDim),' = ',sprintf('%.2f',MasterTensor.Model.Params(iDim)),'  (p = ',sprintf('%.g',MasterTensor.Model.p(iDim)),')']            ;
     case 'Nuclei_AreaShape_1'
        strPanelTitle = 'SIZE';         
    strXaxisLabel = ['SIZE \mum \alpha_',num2str(iDim),' = ',sprintf('%.2f',MasterTensor.Model.Params(iDim)),'  (p = ',sprintf('%.g',MasterTensor.Model.p(iDim)),')']                    ;
     case 'Nuclei_GridNucleiEdges_1'
        strPanelTitle = 'EDGE'         ;
    strXaxisLabel = ['EDGE \alpha_',num2str(iDim),' = ',sprintf('%.2f',MasterTensor.Model.Params(iDim)),'  (p = ',sprintf('%.g',MasterTensor.Model.p(iDim)),')']                    ;
     case 'Image_CorrectedTotalCellNumberPerWell_1'
        strPanelTitle = 'POP.SIZE'         ;
    strXaxisLabel = ['POP.SIZE (cells) \alpha_',num2str(iDim),' = ',sprintf('%.2f',MasterTensor.Model.Params(iDim)),'  (p = ',sprintf('%.g',MasterTensor.Model.p(iDim)),')']                    ;
     case 'Nuclei_CellTypeClassificationPerColumn_2'
        strPanelTitle = 'MIT'         ;
    strXaxisLabel = ['MIT \alpha_',num2str(iDim),' = ',sprintf('%.2f',MasterTensor.Model.Params(iDim)),'  (p = ',sprintf('%.g',MasterTensor.Model.p(iDim)),')']                    ;
     case 'Nuclei_CellTypeClassificationPerColumn_3'
        strPanelTitle = 'APOP'         ;
    strXaxisLabel = ['APOP \alpha_',num2str(iDim),' = ',sprintf('%.2f',MasterTensor.Model.Params(iDim)),'  (p = ',sprintf('%.g',MasterTensor.Model.p(iDim)),')']                    ;
   otherwise
        strPanelTitle = 'unknown'
    end
    
    title(strPanelTitle,'fontsize',10,'fontweight','bold')
    xlabel(strXaxisLabel,'Interpreter','tex','fontsize',8)    
    
    
%     xlabel(['\alpha_',num2str(iDim),' = ',sprintf('%.2f',MasterTensor.Model.Params(iDim)),'  (p = ',sprintf('%.g',MasterTensor.Model.p(iDim)),')'],'Interpreter','tex','fontsize',8)
    
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
title(['fits keeping all other dimensions fixed: ',strFigureTitle],'FontSize',12,'FontWeight','bold')
hold off
drawnow

% % add axis w/color none that overlaps entire figure as title placeholder
% strFigureTitle = strrep(sprintf('%s',char(getlastdir(strRootPath))),'_','\_');
% hold on
% axes('Color','none','Position',[0,0,1,.95])
% axis off
% title(['fits keeping all other dimensions fixed: ',strFigureTitle],'FontSize',14,'FontWeight','bold')
% hold off
% drawnow

gcf2pdf
close(gcf)