% function displayLinearFits(strRootPath)

% if nargin == 0
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\VV_DG\20071022095251_M2_071020_VV_DG_batch1_CP001-1db\';         
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\50K_Tfn\20071130131036_M1_071129_A431_50k_Tfn_P3_2_CP001-1aa\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\DV_KY\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\RV_KY\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\Ad3_MZ\';
    strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ2\philip_071006_Tfn_MZ_AWaa\';
    
% end

intWeightThreshold = 8;

MasterTensor = load(fullfile(strRootPath,'ProbModel_Tensor.mat'));
MasterTensor = MasterTensor.Tensor;

% calculate the most common dimension-indices from all trainingdata (single
% cells)
matDimensionMedians = round(nanmedian(MasterTensor.TrainingData,1));

intNumDims = length(matDimensionMedians);

intNumIndices = size(MasterTensor.Model.X,1);

matAllDims = 1:intNumDims;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% AUTOMATICALLY SELECT WHICH DIMENSION TO VARY, AND OVER WHICH BINS
matWeightedModelParams = MasterTensor.Model.Params' .* MasterTensor.BinSizes;
[a,b]=sort(abs(matWeightedModelParams));

intDimensionToVary = b(find(b~=1 & b < 6, 1,'last'));% get the strongest varying dimension, excluding the constant and the cell type classifications

% intDimensionToVary = 2

if MasterTensor.BinSizes(intDimensionToVary)==2
    iDimToVaryBinSteps=1:2;
else
    intMin = max([1,matDimensionMedians(intDimensionToVary)-0]);
    intMax = min([MasterTensor.BinSizes(intDimensionToVary),matDimensionMedians(intDimensionToVary)+3]);
    iDimToVaryBinSteps=intMin:intMax;    
end
disp(sprintf('decided to vary dimension %d, from bin %d to bin %d',intDimensionToVary,intMin,intMax))
% intDimensionToVary = 3;
% iDimToVaryBinSteps=4:7;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



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
    
    for iBin = 1:intCurrentDimBins
        
        if iDim == intDimensionToVary
            iDensityBinSteps=1;
        else
            iDensityBinSteps=iDimToVaryBinSteps;
        end        
        
        for iDensityBin = iDensityBinSteps
        
            matCurrentClass = zeros(size(matAllDims));
            matCurrentClass(matAllDims~=iDim) = matDimensionMedians(matAllDims(matAllDims~=iDim));
            matCurrentClass(iDim) = iBin;
            matCurrentClass = matCurrentClass - 1;
            matCurrentClass(1) = 1;
            
            if iDim ~= intDimensionToVary
                matCurrentClass(intDimensionToVary) = iDensityBin-1;
            end

            intCurrentRowIndex = find(sum(MasterTensor.Model.X == repmat(matCurrentClass,intNumIndices,1),2) == size(matCurrentClass,2));

            cellMeasuredII{iDim}(iDensityBin,iBin) = MasterTensor.Model.Y(intCurrentRowIndex);

            [yhat,dylo,dyhi] = glmval(MasterTensor.Model.Params, matCurrentClass(1,2:end),'identity',MasterTensor.Model.Stats);

            if MasterTensor.BinSizes(1,1)==2
                yhat(yhat<0) = 0;
                yhat(yhat>1) = 1;
            end        


            cellModelExpectedII{iDim}(iDensityBin,iBin) = yhat;%sum(MasterTensor.Model.Params' .* matCurrentClass);
    %         cellModelExpectedIILowerBound{iDim}(1,iBin) = yhat-dylo;
    %         cellModelExpectedIIUpperBound{iDim}(1,iBin) = yhat+dyhi;

            cellTotalCells{iDim}(iDensityBin,iBin) = MasterTensor.TotalCells(intCurrentRowIndex);        
            cellWeights{iDim}(iDensityBin,iBin) = MasterTensor.Model.W(intCurrentRowIndex,intCurrentRowIndex);
        
        end
        
    end
end

% get the plusminus part of the confidence intervals
% matConfidenceIntervals = MasterTensor.Model.Params - MasterTensor.Model.ConfidenceIntervals(:,1);

%%% CALCULATE MAXIMUM Y-AXIS VALUE


% intMaxDataII = max([max(max(cell2mat(cellMeasuredII))),max(max(cell2mat(cellModelExpectedII)))]);
% % intMaxDataII = max([cellfun(@max,cellMeasuredII(~cellfun(@isempty,cellMeasuredII'))),cellfun(@max,cellModelExpectedII(~cellfun(@isempty,cellModelExpectedII)))]);
% if MasterTensor.BinSizes(1,1)==2
%     intMaxPlotII = intMaxDataII + .2;
%     intMaxPlotII = round(intMaxPlotII*10)/10;
%     if intMaxPlotII > 1 && MasterTensor.BinSizes(1,1)==2
%         intMaxPlotII = 1;
%     end
% else
%     intMaxPlotII = intMaxDataII + 5;
%     intMaxPlotII = round(intMaxPlotII);
% end

figure();
for iDim = 2:intNumDims

    intMaxPlotII = -inf;
    intMinPlotII = inf;    
        
    subplot(2,2,iDim-1)
    hold on

%     iDensityBin = matDimensionMedians(2);
%     matCurWeights = cellWeights{iDim}(iDensityBin,:);
%     matWeightedIndices = find(matCurWeights>0);
%     
%     bar(matWeightedIndices,intMaxPlotII*(cellTotalCells{iDim}(iDensityBin,matWeightedIndices)/max(cellTotalCells{iDim}(iDensityBin,matWeightedIndices))),'FaceColor',[.85 .85 .85],'EdgeColor',[.85 .85 .85])    

    if iDim == intDimensionToVary
        iDensityBinSteps=1;
    else
        iDensityBinSteps=iDimToVaryBinSteps;
    end
    
    for iDensityBin = iDensityBinSteps

        matCurWeights = cellWeights{iDim}(iDensityBin,:);
        matWeightedIndices = find(matCurWeights>intWeightThreshold);

%         bar(matWeightedIndices,intMaxPlotII*(cellTotalCells{iDim}(iDensityBin,matWeightedIndices)/max(cellTotalCells{iDim}(iDensityBin,matWeightedIndices))),'FaceColor',[.85 .85 .85],'EdgeColor',[.85 .85 .85])

        scatter(matWeightedIndices,cellMeasuredII{iDim}(iDensityBin,matWeightedIndices),cellWeights{iDim}(iDensityBin,matWeightedIndices),'b','filled')
        
        plot(matWeightedIndices,cellMeasuredII{iDim}(iDensityBin,matWeightedIndices),':b','linewidth',1)    
        plot(matWeightedIndices,cellModelExpectedII{iDim}(iDensityBin,matWeightedIndices),'-g','linewidth',2)

        intMaxPlotII = max([intMaxPlotII,max(cellMeasuredII{iDim}(iDensityBin,matWeightedIndices)),max(cellModelExpectedII{iDim}(iDensityBin,matWeightedIndices))]);
        intMinPlotII = min([intMinPlotII,min(cellMeasuredII{iDim}(iDensityBin,matWeightedIndices)),min(cellModelExpectedII{iDim}(iDensityBin,matWeightedIndices))]);

%         line([matDimensionMedians(iDim) matDimensionMedians(iDim)],[intMinPlotII,intMaxPlotII],'LineStyle','-','Color',[.75 .75 .75])                
    end    

%     for iDensityBin = iDensityBinSteps    
        matCurWeights = cellWeights{iDim};
        matWeightedIndices = find(any(matCurWeights>intWeightThreshold,1));
        matTotalCellNumber = sum(cellTotalCells{iDim}(:,matWeightedIndices),1);
        matTotalCellNumber = matTotalCellNumber / max(matTotalCellNumber(:));
        matTotalCellNumber = (matTotalCellNumber * (intMaxPlotII-intMinPlotII)) + intMinPlotII;
        plot(matWeightedIndices,matTotalCellNumber,'color',[.9 .9 .9],'linewidth',1)            
%     end
    
    if ~MasterTensor.Model.DiscardParamBasedOnCIs(iDim)
        title(strrep(MasterTensor.Features{iDim},'_','\_'),'fontsize',10)
    else
        title(strrep(MasterTensor.Features{iDim},'_','\_'),'fontsize',10,'color','r')        
    end
        
    hold off
    
    
    if MasterTensor.BinSizes(1,1)==2%%%  readout is a binary fraction/ratio
        intMaxPlotII = intMaxPlotII + .05;
        intMaxPlotII = round(intMaxPlotII*100)/100;
        if intMaxPlotII > 1; intMaxPlotII = 1; end
    else
        intMaxPlotII = intMaxPlotII + 2;
        intMaxPlotII = round(intMaxPlotII);
        
        intMinPlotII = max(0,intMinPlotII - 2);
    end
    
    
%     if ((max(get(gca,'XLim')) <= 2.5) && (length(get(gca,'XLim')) == 2))
%         set(gca,'XLim',[.5, 2.5])
%     end


    set(gca,'YLim',[intMinPlotII, intMaxPlotII])
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



% prepare for pdf printing
% % % scrsz = [1,1,1920,1200];
% % % set(gcf, 'Position', [1 scrsz(4) scrsz(3) scrsz(4)]);     
% % % orient landscape
% % % shading interp
% % % set(gcf,'PaperPositionMode','auto', 'PaperOrientation','landscape')
% % % set(gcf, 'PaperUnits', 'normalized'); 
% % % printposition = [0 .2 1 .8];
% % % set(gcf,'PaperPosition', printposition)
% % % set(gcf, 'PaperType', 'a4');            
% % % orient landscape
% % % 
% % % drawnow
% % % 
% % % 
% % % filecounter = 0;
% % % filepresentbool = 1;
% % % while filepresentbool
% % %     filecounter = filecounter + 1;    
% % %     strPrintName = fullfile(strRootPath,['ProbModel_DisplayLinearFits_',getlastdir(strRootPath),'_',num2str(filecounter)]);
% % %     filepresentbool = fileattrib([strPrintName,'.*']);
% % % end
% % % disp(sprintf('stored %s',strPrintName))
% % % 
% % % %%% UNIX CLUSTER HACK, TRY PRINTING DIFFERENT PRINT FORMATS UNTIL ONE
% % % %%% SUCCEEDS, IN ORDER OF PREFERENCE
% % %     
% % % cellstrPrintFormats = {...
% % %     '-dpdf',...
% % %     '-depsc2',...      
% % %     '-depsc',...      
% % %     '-deps2',...        
% % %     '-deps',...        
% % %     '-dill',...
% % %     '-dpng',...   
% % %     '-tiff',...
% % %     '-djpeg'};
% % % 
% % % boolPrintSucces = 0;
% % % for i = 1:length(cellstrPrintFormats)
% % %     if boolPrintSucces == 1
% % %         continue
% % %     end        
% % %     try
% % %         print(gcf,cellstrPrintFormats{i},strPrintName);    
% % %         disp(sprintf('PRINTED %s FILE',cellstrPrintFormats{i}))        
% % %         boolPrintSucces = 1;
% % %     catch
% % %         disp(sprintf('FAILED TO PRINT %s FILE',cellstrPrintFormats{i}))
% % %         boolPrintSucces = 0;            
% % %     end
% % % end
% % % close(gcf) 
% % % 
