% function reproduceTrainingDataCurves_Manuscript_style(strRootPath,strFigureTitle)

% if nargin == 0
strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ2\philip_071006_Tfn_MZ_AWaa\';
% strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Lilli\070716_ChTxB_A431\';
% strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\RV_KY\';
% strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\';
% strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\';
% strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\DV_KY\';

    strFigureTitle = [strrep(getlastdir(strRootPath),'_','\_'),' '];
% end

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
    
    disp(sprintf('processing %s',getlastdir(cellstrTargetFolderList{i})))   

    try
        PlateTensor{i} = load(fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat'));
    catch
        disp(sprintf('  failed to add tensor %s',fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat')))
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
                intInfectedCells = sum(PlateTensor{i}.TrainingData(matCurBinCellIndices,1)-1);
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

%                 X = [X,X.^2];                
%                 X = [X,X.^2,X.^3];

                X = [ones(size(X,1),1),X];
                Y = repmat(MasterTensor.Model.Params',size(X,1),1) .* double(X);
                Y = sum(Y,2);

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
      3,4,10;... % edge
      3,2,4;... % tcn      
      3,4,11;... % mitotic
      3,4,12;... % apoptotic
    ];


%%% PLOT FORMULA DETAILS        
subplot(matSubPlot(1,1),matSubPlot(1,2),matSubPlot(1,3))
axis off

intLineStep = 14;
intLineTop = 1.1;
intColumn1 = 0.05;
intColumn2 = 0.65;
intColumn3 = 0.80;

text(intColumn1,intLineTop+.05,'Model dimensions','FontSize',10,'FontWeight','bold')
text(intColumn2,intLineTop+.05,'\alpha','FontSize',10,'FontWeight','bold')
text(intColumn3,intLineTop+.05,'p-value','FontSize',10,'FontWeight','bold')

for iii = 1:length(MasterTensor.Model.Params)
    strModelText1 = sprintf('%.4f',MasterTensor.Model.Params(iii));
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
        strModelText3 = sprintf('%g',MasterTensor.Model.p(iii));    
        text(intColumn3,(intLineTop-((iii)/intLineStep)),strModelText3,'FontSize',6)        
    end
    
end

%%% ADD MODEL DESCRIPTION IF PRESENT...
if isfield(MasterTensor.Model,'Description')
    cellstrDescriptionFieldnames = sort(fieldnames(MasterTensor.Model.Description));
    for iiii = 1:length(cellstrDescriptionFieldnames)
        strModelText1 = char(MasterTensor.Model.Description.(char(cellstrDescriptionFieldnames{iiii})));
        strModelText2 = char(cellstrDescriptionFieldnames{iiii});
        strModelText3 = [strModelText2,':  ',strModelText1];
        text(intColumn1,(intLineTop-((iii+1+iiii)/intLineStep)),strModelText3,'FontSize',6)
    end
end
drawnow    

%%% PRECALCULTAE VERTICAL AXIS
% %%% CALCULATE MAXIMUM Y-AXIS VALUE TO DETERMINE THE y-AXIS VALUES
matPlottedIIs = [];
cellstrFieldNames = fieldnames(TensorEdges.TrainingData);
for iDim = 2:length(MasterTensor.Model.Params)
    %%% CLAMP MODEL: 0>model<1    
    matY1 = matModelExpectedInfectedCells{iDim}./matRawTotalCells{iDim};
    matY1(matRawTotalCells{iDim}<500)=NaN;
    matY2 = matRawIIs{iDim};
    matY2(matRawTotalCells{iDim}<500)=NaN;
    matPlottedIIs = [matPlottedIIs;matY1(:);matY2(:)];
end
% round off vertical axis properly
intMaxDataII = nanmax(matPlottedIIs);
intMinPlotII = nanmin(matPlottedIIs);
if MasterTensor.BinSizes(1,1)==2
    intMinDataII = 0;
    intMaxPlotII = intMaxDataII + .025;
    intMaxPlotII = round(intMaxPlotII*5)/5;
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



%%% PLOT DATA AND INFECTION CURVES OVER ALL MODEL DIMENSIONS
for i = 2:length(MasterTensor.Model.Params)
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
    
    [rowPresent,colPresent]=find(~isnan(matRawIIs{i}));

    
    
    %%% ADD A ROW OF NaNs IF THERE IS ONLY ONE ROW IN THE CURRENT DATA,
    %%% OTHERWISE BOXPLOT WILL PUT ALL DATAPOINTS IN ONE BOXPLOT
    if size(matRawTotalCells{i},1) == 1
        matRawTotalCells{i} = [matRawTotalCells{i};repmat(NaN,size(matRawTotalCells{i}))];
        matRawIIs{i} = [matRawIIs{i};repmat(NaN,size(matRawIIs{i}))];
        matModelIIs = [matModelIIs;repmat(NaN,size(matModelIIs))];
    end
    
    %%% AXIS HOLDER
    matWeightedIndices = nansum(matRawTotalCells{i});
    matWeightedIndices = find(matWeightedIndices>=0);
    % get the correct x-axis
    cellstrEdgeFieldNames = fieldnames(TensorEdges.TrainingData);
    if ~isempty(strfind(cellstrEdgeFieldNames{i},'AreaShape_1'))
        matSizeToMicrometerCorrectionFactor = 0.81;
    else
        matSizeToMicrometerCorrectionFactor = 1;
    end
    x = ((matWeightedIndices-1) .* MasterTensor.StepSizes(i)) + TensorEdges.TrainingData.(cellstrFieldNames{i}).Min;
    x = x .* matSizeToMicrometerCorrectionFactor;

    if isequal(x,[0,1])    
        matNewXLim = [-1, 2];
    elseif max(x) < 24
        %density
        matNewXLim = [min(x)-1,max(x)+1];
    elseif max(x) < 1200
        %cell size
        matNewXLim = [max(min(x)-100,0),max(x)+100];
    elseif max(x) < 10000
        %cell size
        matNewXLim = [max(min(x)-200,0)-500,max(x)+200];        
    else
        matNewXLim = [min(x)-1,max(x)+1];        
    end    

    
% % %     %%% INTENSITY BASED READOUTS
% % %     yPredicted = ((cellModelExpectedII{iDim}-1) .* MasterTensor.StepSizes(1)) + TensorEdges.TrainingData.(cellstrFieldNames{1}).Min;
% % % %     yPredicted = 10 .^ yPredicted
% % %     yMeasured = ((cellMeasuredII{iDim}-1) .* MasterTensor.StepSizes(1)) + TensorEdges.TrainingData.(cellstrFieldNames{1}).Min;    
% % % %     yMeasured = 10 .^ yMeasured    
% % % 
% % %     plot(x,yPredicted(1,matWeightedIndices),'Color',[0 0 0],'linewidth',1)
% % %     scatter(x,yMeasured(1,matWeightedIndices),(matCurWeights(matWeightedIndices)*intWeightFactor)-5,'filled','Marker','o','MarkerFaceColor','k','MarkerEdgeColor','k')
% % %     
% % %     title(strrep([strrep(getlastdir(strRootPath),'_','\_'),'_',MasterTensor.Features{iDim}],'_','\_'),'fontsize',10)
% % %     
% % %     hold off
% % %     
% % %     % fix YLim over all plots the same
% % %     set(gca,'YLim',[intMinPlotII, intMaxPlotII])
% % %     
% % %     % if it is a binary class, add trailing x-points

% % %     
% % %     xlabel(['\alpha_',num2str(iDim),' = ',sprintf('%.2f',MasterTensor.Model.Params(iDim)),'  (p = ',sprintf('%.g',MasterTensor.Model.p(iDim)),')'],'Interpreter','tex','fontsize',8)
% % %     
% % %     drawnow    
    
    
    h=[];
    
    hold on
    bar(x,nansum(matRawTotalCells{i}),'FaceColor',[.975 .975 .975],'EdgeColor','none')
    title(strDimFeature{i},'FontSize',6)            
    set(gca,'XLim',matNewXLim,'FontSize',6)
    h(1) = gca;

    h(2)=axes();
    boxplot(matRawIIs{i},'colors','g','positions',x,'plotstyle','compact')    
    ylabel('')
    xlabel('')        
    
    h(3)=axes();
    boxplot(matModelIIs,'colors','b','positions',x,'plotstyle','compact')
    ylabel('')
    xlabel('')    

    hold off 
    drawnow

    
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
    
    %%% SET YLim FOR BOTH BOXPLOTS THE SAME
    matNewYLim = [intMinPlotII, intMaxPlotII];
    set(h(2),'YLim',matNewYLim,'Position',get(h(1),'Position'),'XLim',matNewXLim,'Color','none','XTick',[],'YAxisLocation','right','FontSize',6,'XColor','w','YColor','k','ZColor','w','YTick',[])    
    set(h(3),'YLim',matNewYLim,'Position',get(h(1),'Position'),'XLim',matNewXLim,'Color','none','XTick',[],'YAxisLocation','right','FontSize',6,'XColor','w','YColor','k','ZColor','w')
%     set(h(2),'YLim',matNewYLim,'Position',get(h(1),'Position'),'Color','none','XTick',[],'YAxisLocation','right','FontSize',6,'XColor','w','YColor','k','ZColor','w','YTick',[])    
%     set(h(3),'YLim',matNewYLim,'Position',get(h(1),'Position'),'Color','none','XTick',[],'YAxisLocation','right','FontSize',6,'XColor','w','YColor','k','ZColor','w')

    drawnow
    
    
    
    % set page title
    hold on
    axes('Color','none','Position',[0,0,1,.95])
    axis off
    title([strFigureTitle,': Linear model'],'FontSize',14,'FontWeight','bold')
    hold off
    drawnow
    
end
