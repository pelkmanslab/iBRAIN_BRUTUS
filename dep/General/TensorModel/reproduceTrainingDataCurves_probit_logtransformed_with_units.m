function reproduceTrainingDataCurves_probit_logtransformed_with_units(strRootPath,strFigureTitle)


if nargin == 0
%     strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\50K_copy\RV_KY_2\';
%     strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\50K_copy\MHV_KY\';
%     strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\50K_copy\DV_KY2\';
%     strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\50K_copy\SV40_MZ\';
    strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\EvaBerend\081117_MCF10A_SV40_ChTxBup_pFAK\081117_MCF10A_SV40_ChTxBup_pFAK\';
    strFigureTitle = [strrep(getlastdir(strRootPath),'_','\_'),' '];
end
strRootPath = npc(strRootPath);

cellstrTargetFolderList = SearchTargetFolders(strRootPath,'Measurements_Image_FileNames.mat');
cellstrTargetFolderList = cellfun(@getbasedir,cellstrTargetFolderList,'UniformOutput',0);

intNumOfFolders = length(cellstrTargetFolderList);

PlateTensor = cell(intNumOfFolders,1);

MasterTensor = load(fullfile(strRootPath,'ProbModel_Tensor.mat'));
MasterTensor = MasterTensor.Tensor;

TensorEdges = load(fullfile(strRootPath,'ProbModel_TrainingDataEdges.mat'));

matRows = cellstr(regexp(char(65:80),'\w','match'));
matCols = regexp(sprintf('%.2d',1:24),'\d\d','match');


matRawIIs = {};
matRawTotalCells = {};
matRawInfectedCells = {};
matModelExpectedInfectedCells = {};
matTensorExpectedInfectedCells = {};
strDimFeature = {};

cellstrDataLabels = cell(intNumOfFolders,16);


matProbDistEdges = linspace(-.1,.4,100);

matCurrentProbDistAll = zeros(size(matProbDistEdges));
matCurrentProbDistInfected = zeros(size(matProbDistEdges));
matProbDistAll = zeros(size(matProbDistEdges))';
matProbDistInfected = zeros(size(matProbDistEdges))';


for i = 1:intNumOfFolders
    
    disp(sprintf('%s: processing %s',mfilename,getlastdir(cellstrTargetFolderList{i})))   

    try
        PlateTensor{i} = load(fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat'));
    catch
        disp(sprintf('%s: failed to add tensor %s',mfilename,fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat')))
        break
    end
    PlateTensor{i} = PlateTensor{i}.Tensor;

    for iDim = 2:length(PlateTensor{i}.Features)
        strDimFeature{iDim} = strrep(PlateTensor{i}.Features{iDim},'_','\_');

        %%% GO TO THE MAX iDim VALUE, WITH A MINIMUM OF 2
        if not(isempty(PlateTensor{i}.TrainingData))
            intUpperBin = max(2,max(PlateTensor{i}.TrainingData(:,iDim)));
        else
            intUpperBin = 2;
        end
        for iBin = 1:intUpperBin

            if not(isempty(PlateTensor{i}.TrainingData))

                %%% FIND ALL THE CELL INDICES THAT MATCH THE CURRENT
                %%% DIMENSION BIN...
                matCurBinCellIndices = find(PlateTensor{i}.TrainingData(:,iDim) == iBin);

                %%% ORIGINAL INFECTION INDEX                
                intInfectedCells = nansum(PlateTensor{i}.TrainingData(matCurBinCellIndices,1)-1);
                intTotalCells = length(matCurBinCellIndices);

                % SET TOTALCELLS<=100 TOT NaN
                if intTotalCells==0
                    intTotalCells = NaN;
                    intInfectedCells = NaN; 
                end                

                matRawInfectedCells{iDim}(i,iBin) = intInfectedCells;
                matRawTotalCells{iDim}(i,iBin) = intTotalCells;
                matTempII=intInfectedCells./intTotalCells;
                matRawIIs{iDim}(i,iBin) = matTempII;


                %%% MODEL EXPECTED INFECTION INDEX            
                X = PlateTensor{i}.TrainingData(matCurBinCellIndices,2:end);
                X = X - 1;
                X = [ones(size(X,1),1),X];
                
                
                Y = glmval(single(MasterTensor.Model.Params), single(X),'probit','constant','off');
%                 Y = glmval(MasterTensor.Model.Params', X,'probit','size', n);                
                
                %%% only clamp predicted output to 0/1 if it is a binary
                %%% readout
                if MasterTensor.BinSizes(1,1) == 2
                    Y(Y<0)=0;
                    Y(Y>1)=1;
                end
                    
                
                matModelExpectedInfectedCells{iDim}(i,iBin) = round(sum(Y(:)));


                %%% GET PROBABILITY-DISTRIBUTIONS OF ALL CELLS AND
                %%% PROBABILIY-DISTRIBUTIONS OF INFECTED CELLS
                Y2 = sum(Y,2);
                
                [matCurrentProbDistAll] = histc(Y2,matProbDistEdges);

                if size(matCurrentProbDistAll,2) > size(matCurrentProbDistAll,1)
                    matCurrentProbDistAll = matCurrentProbDistAll';
                end
                
                matProbDistAll = matProbDistAll + matCurrentProbDistAll;

                Y2InfIndices = find(PlateTensor{i}.TrainingData(matCurBinCellIndices,1)==2);

                if not(isempty(Y2InfIndices))
                    
                    [matCurrentProbDistInfected] = histc(Y2(Y2InfIndices),matProbDistEdges);
                    if size(matCurrentProbDistInfected,2) > size(matCurrentProbDistInfected,1)
                        matCurrentProbDistInfected = matCurrentProbDistInfected';
                    end

                    matProbDistInfected = matProbDistInfected + matCurrentProbDistInfected;
                end

% % %                 %%% TENSOR EXPECTED INFECTION INDEX
% % %                 X2 = PlateTensor{i}.TrainingData(matCurBinCellIndices,2:end);
% % %                 X2unique = unique(PlateTensor{i}.TrainingData(matCurBinCellIndices,2:end),'rows');
% % %                 for iX = 1:size(X2unique,1)
% % %                     %%% LOOK FOR THE NUMBER OF MATCHING CELLS FOR THIS
% % %                     %%% UNIQUE INDEX
% % %                     intNumOfCells = length(find(sum( repmat(X2unique(iX,:),size(X2,1),1) == X2 , 2) == size(X2,2)));                    
% % %                     %%% LOOK FOR THE MATCHING TENSOR INDEX
% % %                     rowInd2 = find(sum( repmat(X2unique(iX,:),size(MasterTensor.Indices,1),1) == MasterTensor.Indices , 2) == size(MasterTensor.Indices,2));
% % %                     %%% CALCULATE THE CURRENT NUMBER OF EXPECTED INFECTED
% % %                     %%% CELLS
% % %                     matTensorExpectedInfectedCells(i,wellcounter) = matTensorExpectedInfectedCells(i,wellcounter) + (intNumOfCells * MasterTensor.InfectionIndex(rowInd2));
% % %                 end

            else % if TrainingData is empty
%                 disp(sprintf('warning: bin %d of %s is empty',iBin,strDimFeature{iDim}))
                matRawInfectedCells{iDim}(i,iBin) = NaN;
                matRawTotalCells{iDim}(i,iBin) = NaN;
                matRawIIs{iDim}(i,iBin) = NaN;
                matModelExpectedInfectedCells{iDim}(i,iBin) = NaN;

            end% if not TrainingData is empty        
        end   
    end
end


%%% FORMAT FORMULA STRING
tempstr = '';
for i = 2:length(MasterTensor.Model.Params)
%     tempstr = [tempstr, sprintf(' %.4f\chi_%d + ',MasterTensor.Model.Params(i),i-1)];
    tempstr = [tempstr, ' ',sprintf('%.4f',MasterTensor.Model.Params(i)), 'X_' ,num2str(i-1),' + '];    
end
tempstr = [tempstr,sprintf('%.4f',MasterTensor.Model.Params(1))];


%%% CREATE WINDOWS WITH ALL FEATURES AND CORRESPONDING FITS
subplotminus = 1;
figurecounter = 1;
hFigure=[];
hFigure(figurecounter) = figure();


matSubPlot = ...
    [ 3,2,3;... % model text
      3,2,1;... % lcd
      3,2,2;... % size
      3,3,7;... % edge
      3,2,4;... % tcn      
      3,3,8;... % mitotic
      3,3,9;... % apoptotic
    ];


%%% PLOT FORMULA DETAILS        
subplot(matSubPlot(1,1),matSubPlot(1,2),matSubPlot(1,3))
axis off

intLineStep = 14;
intLineTop = 1.1;
intColumn1 = 0.05;
intColumn2 = 0.60;
intColumn3 = 0.75;
intColumn4 = 0.90;

text(intColumn1,intLineTop+.05,'Model dimensions','FontSize',8,'FontWeight','bold')
text(intColumn2,intLineTop+.05,'\alpha','FontSize',8,'FontWeight','bold')
text(intColumn3,intLineTop+.05,'p-value','FontSize',8,'FontWeight','bold')
if isfield(MasterTensor.Model.Description,'RsquaredPerParam')
    text(intColumn4,intLineTop+.05,'R^2 / param','FontSize',8,'FontWeight','bold')
elseif isfield(MasterTensor.Model.Description,'PartialCorrelations')
    text(intColumn4,intLineTop+.05,'Partial Corr.','FontSize',8,'FontWeight','bold')
end    


for iii = 1:length(MasterTensor.Model.Params)
    strModelText1 = sprintf('%.3f',MasterTensor.Model.Params(iii));
    strModelText2 = strrep(MasterTensor.Model.Features{iii},'_','\_');
    
    
    %%% IF MODEL PARAM SHOULD BE DISCARDED
    if isfield(MasterTensor.Model,'DiscardParamBasedOnCIs') && (MasterTensor.Model.DiscardParamBasedOnCIs(iii) == 1)
%         strModelText1 = strcat(strModelText1, '  (DISCARD)');
        text(intColumn2,(intLineTop-((iii)/intLineStep)),strModelText1,'FontSize',6, 'Color', 'r')
    else
        text(intColumn2,(intLineTop-((iii)/intLineStep)),strModelText1,'FontSize',6)            
    end
    
    text(intColumn1,(intLineTop-((iii)/intLineStep)),strModelText2,'FontSize',6)

    if isfield(MasterTensor.Model,'p')
        strModelText3 = sprintf('%.2g',MasterTensor.Model.p(iii));    
        text(intColumn3,(intLineTop-((iii)/intLineStep)),strModelText3,'FontSize',6)        
    end

    if isfield(MasterTensor.Model.Description,'RsquaredPerParam')
        strModelText4 = sprintf('%.2f',MasterTensor.Model.Description.RsquaredPerParam(iii));
        text(intColumn4,(intLineTop-((iii)/intLineStep)),strModelText4,'FontSize',6)        
    elseif isfield(MasterTensor.Model.Description,'PartialCorrelations')
        strModelText4 = sprintf('%.2f',MasterTensor.Model.Description.PartialCorrelations(iii));
        text(intColumn4,(intLineTop-((iii)/intLineStep)),strModelText4,'FontSize',6)        
    end    
    
end

%%% ADD MODEL DESCRIPTION IF PRESENT...
if isfield(MasterTensor.Model,'Description')
    cellstrDescriptionFieldnames = sort(fieldnames(MasterTensor.Model.Description));
    removeFieldNames = ismember(cellstrDescriptionFieldnames,{'RsquaredPerParam','PartialCorrelations'});
    cellstrDescriptionFieldnames(removeFieldNames) = [];

    % remove indices which are not of type character
    cellstrDescriptionFieldnames2 = [];
    for iiii = 1:length(cellstrDescriptionFieldnames)
        if ischar(MasterTensor.Model.Description.(char(cellstrDescriptionFieldnames{iiii})))
            cellstrDescriptionFieldnames2 = [cellstrDescriptionFieldnames2; cellstrDescriptionFieldnames(iiii)];
        end
    end
    cellstrDescriptionFieldnames=cellstrDescriptionFieldnames2;
    
    % plot all character-type descriptions
    for iiii = 1:length(cellstrDescriptionFieldnames)
        if ischar(MasterTensor.Model.Description.(char(cellstrDescriptionFieldnames{iiii})))
            strModelText1 = char(MasterTensor.Model.Description.(char(cellstrDescriptionFieldnames{iiii})));
            strModelText2 = char(cellstrDescriptionFieldnames{iiii});
            strModelText3 = [strModelText2,':  ',strModelText1];
            text(intColumn1,(intLineTop-((iii+1+iiii)/intLineStep)),strModelText3,'FontSize',6)
        end
    end
end
drawnow    

cellstrEdgeFieldNames = fieldnames(TensorEdges.TrainingData);

%%% PLOT DATA AND INFECTION CURVES OVER ALL MODEL DIMENSIONS
for i = 2:iDim
    subplot(matSubPlot(i,1),matSubPlot(i,2),matSubPlot(i,3))

    %%% CLAMP MODEL: 0>model<1    
    matModelIIs = matModelExpectedInfectedCells{i}./matRawTotalCells{i};
    
    %%% only clamp predicted output to 0/1 if it is a binary
    %%% readout
    if MasterTensor.BinSizes(1,1) == 2    
        matModelIIs(find(matModelIIs<0))=0;
        matModelIIs(find(matModelIIs>1))=1;
    end
    
    %%% REMOVE DATAPOINTS WITH TOO FEW CELLS
    matRawTotalCells{i}(find(matRawTotalCells{i}<500))=NaN;
    matRawIIs{i}(find(isnan(matRawTotalCells{i})))=NaN;
    matModelIIs(find(isnan(matRawTotalCells{i})))=NaN;
    
    
    %%% CALCULATE THE AVERAGE PLATE INFECTION INDICES FOR LOG2-NORMALIZATION
    matRawAvgPlateIIs = nansum(matRawInfectedCells{i},2) ./ nansum(matRawTotalCells{i},2);
    matModelAvgPlateIIs = nansum(matModelExpectedInfectedCells{i},2) ./ nansum(matRawTotalCells{i},2);    
    
    %%% MAKE PLATE AVERAGE RELATIVE
    matRawLog2RIIs = matRawIIs{i} ./ repmat(matRawAvgPlateIIs,1,size(matRawIIs{i},2));
    matModelLog2RIIs = matModelIIs ./ repmat(matModelAvgPlateIIs,1,size(matModelIIs,2));

    %%% LOG2 TRANSFORM
    matRawLog2RIIs = log2(matRawLog2RIIs);
    matModelLog2RIIs = log2(matModelLog2RIIs);
    
    
    [rowPresent,colPresent]=find(~isnan(matRawIIs{i}));
    matNewXLim = [min(colPresent)-1,max(colPresent)+1];
    
    
    
    %%% ADD A ROW OF NaNs IF THERE IS ONLY ONE ROW IN THE CURRENT DATA,
    %%% OTHERWISE BOXPLOT WILL PUT ALL DATAPOINTS IN ONE BOXPLOT
    if size(matRawTotalCells{i},1) == 1
        matRawTotalCells{i} = [matRawTotalCells{i};repmat(NaN,size(matRawTotalCells{i}))];
        matRawIIs{i} = [matRawIIs{i};repmat(NaN,size(matRawIIs{i}))];
        matModelIIs = [matModelIIs;repmat(NaN,size(matModelIIs))];
        
        matRawLog2RIIs = [matRawLog2RIIs;repmat(NaN,size(matRawLog2RIIs))];
        matModelLog2RIIs = [matModelLog2RIIs;repmat(NaN,size(matModelLog2RIIs))];
    end

    %%% CALCULATE BACK ORIGINAL UNITS FOR THE X-AXIS
    %%% correction factor to go from pixels to square micrometer on 10x
    %%% CellWorx images.
    if ~isempty(strfind(cellstrEdgeFieldNames{i},'AreaShape_1'))
        matSizeToMicrometerCorrectionFactor = 0.81;
    else
        matSizeToMicrometerCorrectionFactor = 1;
    end

    matXUnits = (([min(colPresent):max(colPresent)]-1) .* MasterTensor.StepSizes(i)) + TensorEdges.TrainingData.(cellstrEdgeFieldNames{i}).Min;
    matXUnits = matXUnits .* matSizeToMicrometerCorrectionFactor;
    
    if isequal(matXUnits,[0,1])    
        matNewXLim = [-1, 2];
    elseif max(matXUnits) < 24
        %density
        matNewXLim = [min(matXUnits)-1,max(matXUnits)+1];
    elseif max(matXUnits) < 1200
        %cell size
        matNewXLim = [max(min(matXUnits)-100,0),max(matXUnits)+100];
    elseif max(matXUnits) < 10000
        %cell size
        matNewXLim = [max(min(matXUnits)-200,0)-500,max(matXUnits)+200];        
    else
        matNewXLim = [min(matXUnits)-1,max(matXUnits)+1];        
    end    
    
    
    %%% AXIS HOLDER
    h=[];
    
    hold on
    if size(matRawTotalCells{i},2) > 2
        % curve for non-binary dimensions
        matCellCount = nansum(matRawTotalCells{i});
        plot(matXUnits,matCellCount(min(colPresent):max(colPresent)),'Color',[.8 .8 .8],'linewidth',2)
    else
        % bar plot for binary dimensions
        bar(matXUnits,nansum(matRawTotalCells{i}),'FaceColor','none','EdgeColor',[.8 .8 .8],'linewidth',2)
    end
    h(1) = gca;    
    title(strDimFeature{i},'FontSize',6)
    set(h(1),'XLim',matNewXLim,'FontSize',6,'YAxisLocation','right')%,'YColor',[.8 .8 .8]
%     hh = ylabel('Total number of cells','Color',[.8 .8 .8]);%,'YAxisLocation','right'


    h(2)=axes();
    boxplot(matRawLog2RIIs(:,min(colPresent):max(colPresent)),'positions',matXUnits,'colors','b','labels',{})    

    
    h(3)=axes();
    boxplot(matModelLog2RIIs(:,min(colPresent):max(colPresent)),'positions',matXUnits,'colors','r','labels',{})
    ylabel('Log2 relative infection index','FontSize',7)

    hold off 
    drawnow

    
    %%% SET YLim FOR BOTH BOXPLOTS THE SAME
    matNewYLim = [min([get(h(2),'YLim'),get(h(3),'YLim')]),max([get(h(2),'YLim'),get(h(3),'YLim')])]

%     if abs(diff(matNewYLim)) < 0.15
%         matNewYLim = [max(0,matNewYLim(1) - 0.03), min(1,matNewYLim(2) + 0.03)]
%     end
    matNewYLim = [matNewYLim(1) - (diff(matNewYLim) / 14), matNewYLim(2) + (diff(matNewYLim) / 14)]
    
    matPositionFirstAxis = get(h(1),'Position');
    set(h(1),'Position',matPositionFirstAxis);%,'XLim',matNewXLim
    set(h(2),'XLim',matNewXLim,'YLim',matNewYLim,'Position',matPositionFirstAxis,'Color','none','XTick',[],'XTickLabel',[],'YAxisLocation','left','FontSize',6,'XColor','w','YColor','k','ZColor','w','YTick',[],'Box','off')    
    set(h(3),'XLim',matNewXLim,'YLim',matNewYLim,'Position',matPositionFirstAxis,'Color','none','XTick',[],'XTickLabel',[],'YAxisLocation','left','FontSize',6,'XColor','w','YColor','k','ZColor','w','Box','off')
%     set(h(4),'Position',get(h(1),'Position'),'XLim',matNewXLim,'Color','none','XTick',[],'YAxisLocation','right','FontSize',6,'XColor','w','YColor','k','ZColor','w')
%     set(h(5),'Position',get(h(1),'Position'),'XLim',matNewXLim,'Color','none','XTick',[],'YAxisLocation','right','FontSize',6,'XColor','w','YColor','k','ZColor','w')
%     set(h(6),'Position',get(h(1),'Position'),'XLim',matNewXLim,'Color','none','XTick',[],'YAxisLocation','right','FontSize',6,'XColor','w','YColor','k','ZColor','w')    
    drawnow
    
    
    
    % set page title
    hold on
    axes('Color','none','Position',[0,0,1,.95])
    axis off
    title([strFigureTitle,': Probit model'],'FontSize',14,'FontWeight','bold')
    hold off
    drawnow
    
end


%%% PLOT PROBABILITY DISTRIBUTION
% figure()
% subplot(2,1,1)
% plot([matProbDistAll,matProbDistInfected])
% subplot(2,1,2)
% plot([matProbDistInfected./matProbDistAll])
% ylim([0,1])
% drawnow
% 
% if nargin==0
%     return
% end

% return

for i = 1:figurecounter
    figure(hFigure(i))

    % prepare for pdf printing
    scrsz = [1,1,1920,1200];
    set(hFigure(i), 'Position', [1 scrsz(4) scrsz(3) scrsz(4)]);     
    orient landscape
    shading interp
    set(hFigure(i),'PaperPositionMode','auto', 'PaperOrientation','landscape')
    set(hFigure(i), 'PaperUnits', 'normalized'); 
    printposition = [0 .2 1 .8];
    set(hFigure(i),'PaperPosition', printposition)
    set(hFigure(i), 'PaperType', 'a4');            
    orient landscape

    drawnow

%     filecounter = 1;
%     strPrintName = fullfile(strRootPath,['ProbModel_CurveReproduction_',getlastdir(strRootPath),'_',num2str(filecounter),'.pdf']);
%     filepresentbool = fileattrib(fullfile(strRootPath,['ProbModel_CurveReproduction_',getlastdir(strRootPath),'_',num2str(filecounter),'.pdf']));
%     while filepresentbool
%         filecounter = filecounter + 1;    
%         strPrintName = fullfile(strRootPath,['ProbModel_CurveReproduction_',getlastdir(strRootPath),'_',num2str(filecounter),'.pdf']);
%         filepresentbool = fileattrib(strPrintName);
%     end
%     disp(sprintf('stored %s',strPrintName))
%     print(hFigure(i),'-dpdf',strPrintName);
%     close(hFigure(i))
    
    
    

    filecounter = 0;
    filepresentbool = 1;
    while filepresentbool
        filecounter = filecounter + 1;    
        strPrintName = fullfile(strRootPath,['ProbModel_CurveReproduction_Probit_logtransformed_units_',getlastdir(strRootPath),'_',num2str(filecounter)]);
        filepresentbool = fileattrib([strPrintName,'.*']);
    end
    disp(sprintf('%s: stored %s',mfilename,strPrintName))

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
    for ii = 1:length(cellstrPrintFormats)
        if boolPrintSucces == 1
            continue
        end        
        try
            print(hFigure(i),cellstrPrintFormats{ii},strPrintName);    
            disp(sprintf('%s: PRINTED %s FILE',mfilename,cellstrPrintFormats{ii}))        
            boolPrintSucces = 1;
        catch
            disp(sprintf('%s: FAILED TO PRINT %s FILE',mfilename,cellstrPrintFormats{ii}))
            boolPrintSucces = 0;            
        end
    end
    close(hFigure(i)) 
    
    
    
end

