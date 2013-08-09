figure();
hold on

strRootPaths = {...
%     '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ\philip_071006_Tfn_MZ_AWaa\';...
    '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ2\philip_071006_Tfn_MZ_AWaa\';...
    '\\nas-biol-imsb-1\share-2-$\Data\Users\Lilli\070716_ChTxB_A431\';...    
    '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\RV_KY\';...
    '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\';...
%                     '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\VV_KY\';...
    '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\';...
    '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\DV_KY\';...
%                     '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\AD3_MZ\'
    };

            
            
for iProject = 1:length(strRootPaths)

    strRootPath = strRootPaths{iProject};

    strFigureTitle = [strrep(getlastdir(strRootPath),'_','\_'),' '];

    load(fullfile(strRootPath,'ProbModel_TrainingDataEdges.mat'));
    
    MasterTensor = load(fullfile(strRootPath,'ProbModel_Tensor.mat'));
    MasterTensor = MasterTensor.Tensor;

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
    cellModelExpectedIILowerBound = cell(1,intNumDims);
    cellModelExpectedIIUpperBound = cell(1,intNumDims);
    cellWeights = cell(1,intNumDims);
    cellTotalCells = cell(1,intNumDims);
    
   
    %%% ONLY ANALYZE DIMENSION CONTAINING TOTAL CELL NUMBER!
    iDim = find(strcmpi(MasterTensor.Features','Image_CorrectedTotalCellNumberPerWell_1'));

    intCurrentDimBins = MasterTensor.BinSizes(iDim);
    intCurrentDimBinStep = MasterTensor.StepSizes(iDim);        
    intCurrentDimBinBeginning = TrainingData.Image_CorrectedTotalCellNumberPerWell_1.Min;            
    
    for iBin = 1:intCurrentDimBins

        % individual bins need at least 500 cells to be included
        [intCurrentRowIndex,foo] = find(MasterTensor.Model.X(:,iDim) == iBin & MasterTensor.TotalCells > 500);
        
        nansum(MasterTensor.TotalCells(intCurrentRowIndex))
        
        % total number of cells per point needs to be at least 1800
        if nansum(MasterTensor.TotalCells(intCurrentRowIndex)) > 1800
            cellMeasuredII{iDim}(1,iBin) = nansum(MasterTensor.Model.Y(intCurrentRowIndex) .* MasterTensor.TotalCells(intCurrentRowIndex)) / nansum(MasterTensor.TotalCells(intCurrentRowIndex));
            cellTotalCells{iDim}(1,iBin) = nansum(MasterTensor.TotalCells(intCurrentRowIndex));                    
        else
            cellMeasuredII{iDim}(1,iBin) = NaN;
            cellTotalCells{iDim}(1,iBin) = NaN;                    
        end
%         cellMeasuredII{iDim}(1,iBin) = nanmedian(MasterTensor.Model.Y(intCurrentRowIndex));

%         [yhat,dylo,dyhi] = glmval(MasterTensor.Model.Params, MasterTensor.Model.X(intCurrentRowIndex,2:end),'identity',MasterTensor.Model.Stats);
%         if MasterTensor.BinSizes(1,1)==2
%             yhat(yhat<0) = 0;
%             yhat(yhat>1) = 1;
%         end
%         cellModelExpectedII{iDim}(1,iBin) = nansum(yhat.*MasterTensor.TotalCells(intCurrentRowIndex)) / nansum(MasterTensor.TotalCells(intCurrentRowIndex));



    end

%     intMaxPlotII = .4;

    subplot(3,3,iProject)

    hold on
%     
%     if strcmpi(getlastdir(strRootPath),'070716_ChTxB_A431')
%         iDim = 3;
%     else
%         iDim = 5;        
%     end
        
    matWeightedIndices = find(cellTotalCells{iDim}>0);
    matWeights = cellTotalCells{iDim}(matWeightedIndices) .^ (1/3);
    if ~isempty(strfind(strRootPath,'Tfn_MZ'))
        matWeights = 1.5 * matWeights;
    elseif ~isempty(strfind(strRootPath,'ChTxB'))
        matWeights = 1.5 * matWeights;
    elseif ~isempty(strfind(strRootPath,'MHV_KY'))
        matWeights = .75 * matWeights;
    elseif ~isempty(strfind(strRootPath,'RV_KY'))
        matWeights = .75 * matWeights;
    elseif ~isempty(strfind(strRootPath,'SV40_MZ'))
        matWeights = .75 * matWeights;
    elseif ~isempty(strfind(strRootPath,'DV_KY'))
        matWeights = .75 * matWeights;
    end

%     cellColor = {'k','r','b','g'};
%     cellColors = {...
%         [0 0 0],...
%         [1 0 0],...
%         [0 0 1],...
%         [0 1 0],...
%         [0 0 0],...
%         [1 0 0],...
%         [0 0 1],...
%         [0 1 0]...
%         };
%     
%     cellColors2 = {...
%         [.75 .75 .75],...
%         [1 .75 .75],...
%         [.75 .75 1],...
%         [.75 1 .75],...
%         [.75 .75 .75],...
%         [1 .75 .75],...
%         [.75 .75 1],...
%         [.75 1 .75]...
%         };    

    cellColors = {...
        [0 0 0],...
        [0 0 0],...
        [0 0 0],...
        [0 0 0],...
        [0 0 0],...
        [0 0 0],...
        [0 0 0],...
        [0 0 0]...
        };
    
    cellColors2 = {...
        [.75 .75 .75],...
        [.75 .75 .75],...
        [.75 .75 .75],...
        [.75 .75 .75],...
        [.75 .75 .75],...
        [.75 .75 .75],...
        [.75 .75 .75],...
        [.75 .75 .75]...
        }; 

%     cellSymbol = {'+','o','*','x'};    
    cellSymbol = {'*','*','*','*','*','*','*'};    

    matXAxis = (matWeightedIndices * intCurrentDimBinStep) + intCurrentDimBinBeginning;
    matReadout = cellMeasuredII{iDim}(1,matWeightedIndices) / median(cellMeasuredII{iDim}(1,matWeightedIndices));
    
    %%% FROM MATLAB HELP: Example: Programmatic Fitting
    [p,ErrorEst] = polyfit(matXAxis,matReadout,2);
    % Evaluate the fit and the prediction error estimate (delta)
    [pop_fit,delta] = polyval(p,[min(matXAxis):.25:max(matXAxis)],ErrorEst);
    % Plot the data, the fit, and the confidence bounds
%     plot(matWeightedIndices,pop_fit,[cellColor{iProject},'-'],'linewidth',3)    
    plot([min(matXAxis):.25:max(matXAxis)],pop_fit,'Color',cellColors2{iProject},'linewidth',1,'linestyle','--')
    % The following plots the 95% confidence interval for large samples:
%     plot(matWeightedIndices,pop_fit+2*delta,[cellColor{iProject},':'],'linewidth',1)
%     plot(matWeightedIndices,pop_fit-2*delta,[cellColor{iProject},':'],'linewidth',1)
    
%     plot(matWeightedIndices,matReadout,[cellSymbol{iProject},':',cellColor{iProject}],'linewidth',1,'markersize',12)
%     plot(matXAxis,matReadout,'Color',cellColors{iProject},'markersize',10,'Marker',cellSymbol{iProject},'linestyle','none','MarkerFaceColor',cellColors{iProject})
%     s(matXAxis,matReadout,'Color',cellColors{iProject},'markersize',10,'Marker',cellSymbol{iProject},'linestyle','none','MarkerFaceColor',cellColors{iProject})
%     plot(x,yPredicted(1,matWeightedIndices),'Color',[0 0 0],'linewidth',1)
    scatter(matXAxis,matReadout,matWeights,'filled','Marker','o','MarkerFaceColor','k','MarkerEdgeColor','k')

    
    
    ylabel('relative infection index')
    xlabel('population size')
    set(gca,'fontsize',12)
    title(strrep(getlastdir(strRootPaths{iProject}),'_','\_'),'fontweight','bold')

%     xlabel(['\alpha_',num2str(iDim),' = ',num2str(MasterTensor.Model.Params(iDim)),'  (p = ',num2str(MasterTensor.Model.p(iDim)),')'],'Interpreter','tex','fontsize',8)

    if ~isempty(strfind(strRootPath,'\Tfn_MZ2\'))
        ylim([0.9 1.1])
    elseif ~isempty(strfind(strRootPath,'\070716_ChTxB_A431\'))
        ylim([0.8 1.2])
    end
    
    hold off
    
    drawnow
    
end

% legend(strrep(getlastdir(strRootPaths),'_','\_'),'Location','best')

hold off
drawnow