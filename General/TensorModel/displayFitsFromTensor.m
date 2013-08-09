function displayFitsFromTensor(strRootPath)

if nargin == 0
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\50K_checkers\060118_EV1_Kyo_CB\BATCH\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\50K_checkers\060118_EV1_MZ_CB\BATCH\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\David\Pictures\David_iBRAIN\080312Davidtestplaterescan3\BATCH\';             
    strRootPath = 'U:\Data\Users\Berend\EvaBerend\081117_MCF10A_SV40_ChTxBup_pFAK\';             
    
end

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

for iDim = 2:intNumDims % skipping first dimension, constant
    
    intCurrentDimBins = MasterTensor.BinSizes(iDim);
    
    for iBin = 1:intCurrentDimBins
        
        [intCurrentRowIndex,foo] = find(MasterTensor.Model.X(:,iDim) == iBin);

        
        cellMeasuredII{iDim}(1,iBin) = nansum(MasterTensor.Model.Y(intCurrentRowIndex) .* MasterTensor.TotalCells(intCurrentRowIndex)) / nansum(MasterTensor.TotalCells(intCurrentRowIndex));

        [yhat,dylo,dyhi] = glmval(MasterTensor.Model.Params, MasterTensor.Model.X(intCurrentRowIndex,2:end),'identity',MasterTensor.Model.Stats);
        
        if MasterTensor.BinSizes(1,1)==2
            yhat(yhat<0) = 0;
            yhat(yhat>1) = 1;
        end

%         sum(repmat(MasterTensor.Model.Params',size(intCurrentRowIndex,1),1) .* (MasterTensor.Model.X(intCurrentRowIndex,:)-1),2)
        
        cellModelExpectedII{iDim}(1,iBin) = nansum(yhat.*MasterTensor.TotalCells(intCurrentRowIndex)) / nansum(MasterTensor.TotalCells(intCurrentRowIndex));
        
        cellTotalCells{iDim}(1,iBin) = nansum(MasterTensor.TotalCells(intCurrentRowIndex));        
%         cellWeights{iDim}(1,iBin) = MasterTensor.Model.W(intCurrentRowIndex,intCurrentRowIndex);
        
    end
end


% get the plusminus part of the confidence intervals
% matConfidenceIntervals = MasterTensor.Model.Params - MasterTensor.Model.ConfidenceIntervals(:,1);
intMaxDataII = max([cellfun(@max,cellMeasuredII(~cellfun(@isempty,cellMeasuredII))),cellfun(@max,cellModelExpectedII(~cellfun(@isempty,cellModelExpectedII)))]);
intMaxPlotII = intMaxDataII + .2;
intMaxPlotII = round(intMaxPlotII*10)/10;
if intMaxPlotII > 1 && MasterTensor.BinSizes(1,1)==2
    intMaxPlotII = 1;
end


figure();
for iDim = 2:intNumDims
    matWeightedIndices = find(cellTotalCells{iDim}>10);

    subplot(2,3,iDim-1)
    hold on

    bar(matWeightedIndices,intMaxPlotII*(cellTotalCells{iDim}(matWeightedIndices)/max(cellTotalCells{iDim}(matWeightedIndices))),'FaceColor',[.85 .85 .85],'EdgeColor',[.85 .85 .85])

    scatter(matWeightedIndices,cellMeasuredII{iDim}(1,matWeightedIndices),'b','filled')
%     scatter(matWeightedIndices,cellModelExpectedII{iDim}(1,matWeightedIndices),'g','filled')    
    plot(matWeightedIndices,cellModelExpectedII{iDim}(1,matWeightedIndices),'-g','linewidth',2)

    if ~MasterTensor.Model.DiscardParamBasedOnCIs(iDim)
        title([strrep(MasterTensor.Features{iDim},'_','\_')],'fontsize',10)
    else
        title([strrep(MasterTensor.Features{iDim},'_','\_')],'fontsize',10,'color','r')        
    end

    hold off

    set(gca,'YLim',[0, intMaxPlotII])
    xlabel(['\alpha_',num2str(iDim),' = ',num2str(MasterTensor.Model.Params(iDim)),'  (p = ',num2str(MasterTensor.Model.p(iDim)),')'],'Interpreter','tex','fontsize',8)

    drawnow
end


% add axis w/color none that overlaps entire figure as title placeholder
strFigureTitle = strrep(sprintf('%s',char(getlastdir(strRootPath))),'_','\_');
hold on
axes('Color','none','Position',[0,0,1,.95])
axis off
title(['fits including all other dimensions: ',strFigureTitle],'FontSize',14,'FontWeight','bold')
hold off
drawnow


% plot figure

% prepare for pdf printing
scrsz = [1,1,1920,1200];
set(gcf, 'Position', [1 scrsz(4) scrsz(3) scrsz(4)]);     
orient landscape
shading interp
set(gcf,'PaperPositionMode','auto', 'PaperOrientation','landscape')
set(gcf, 'PaperUnits', 'normalized'); 
printposition = [0 .2 1 .8];
set(gcf,'PaperPosition', printposition)
set(gcf, 'PaperType', 'a4');            
orient landscape

drawnow


filecounter = 0;
filepresentbool = 1;
while filepresentbool
    filecounter = filecounter + 1;    
    strPrintName = fullfile(strRootPath,['ProbModel_displayFitsFromTensor_',getlastdir(strRootPath),'_',num2str(filecounter)]);
    filepresentbool = fileattrib([strPrintName,'.*']);
end
disp(sprintf('stored %s',strPrintName))

%%% UNIX CLUSTER HACK, TRY PRINTING DIFFERENT PRINT FORMATS UNTIL ONE
%%% SUCCEEDS, IN ORDER OF PREFERENCE
    
cellstrPrintFormats = {...
    '-dpdf',...
    '-depsc2',...      
    '-depsc',...      
    '-deps2',...        
    '-deps',...        
    '-dill',...
    '-dpng',...   
    '-tiff',...
    '-djpeg'};

boolPrintSucces = 0;
for i = 1:length(cellstrPrintFormats)
    if boolPrintSucces == 1
        continue
    end        
    try
        print(gcf,cellstrPrintFormats{i},strPrintName);    
        disp(sprintf('PRINTED %s FILE',cellstrPrintFormats{i}))        
        boolPrintSucces = 1;
    catch
        disp(sprintf('FAILED TO PRINT %s FILE',cellstrPrintFormats{i}))
        boolPrintSucces = 0;            
    end
end
close(gcf) 
