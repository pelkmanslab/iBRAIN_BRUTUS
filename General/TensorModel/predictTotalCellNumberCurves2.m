function predictTotalCellNumberCurves2(strRootPath)

if nargin == 0
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\David\Pictures\David_iBRAIN\080220davidvirus\BATCH\';
    strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\50K_checkers\060118_EV1_Kyo_CB\BATCH\';
end
strFigureTitle = [strrep(getlastdir(strRootPath),'_','\_'),' '];


cellstrTargetFolderList = SearchTargetFolders(strRootPath,'Measurements_Image_FileNames.mat');
cellstrTargetFolderList = cellfun(@getbasedir,cellstrTargetFolderList,'UniformOutput',0);
intNumOfFolders = length(cellstrTargetFolderList);

PlateTensor = cell(intNumOfFolders,1);

MasterTensor = load(fullfile(strRootPath,'ProbModel_Tensor.mat'));
MasterTensor = MasterTensor.Tensor;


matRows = cellstr(regexp(char(65:80),'\w','match'));
matCols = regexp(sprintf('%.2d',1:24),'\d\d','match');

intTotalBins = 16;

matRawIIs = nan(intNumOfFolders,intTotalBins);
matRawTotalCells = nan(intNumOfFolders,intTotalBins);
matRawInfectedCells = nan(intNumOfFolders,intTotalBins);
matModelExpectedInfectedCells = nan(intNumOfFolders,intTotalBins);
matCorrectedTCNs = nan(intNumOfFolders,intTotalBins);

cellMeanModelParameterValue = {};

cellstrDataLabels = cell(intNumOfFolders,intTotalBins);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GET RANGE FOR BINNING OF TCN PLOT %%%
matTempData = [];
handles = struct();
for i = 1:intNumOfFolders
    handles = LoadMeasurements(handles,fullfile(cellstrTargetFolderList{i},'Measurements_Image_CorrectedTotalCellNumberPerWell.mat'));
    matTempData = [matTempData;cell2mat(handles.Measurements.Image.CorrectedTotalCellNumberPerWell')];
end
intMinTCN = min(matTempData(:));
intMaxTCN = max(matTempData(:));
% [intMinTCN,intMaxTCN]=Detect_Outlier_levels(matTempData);
disp('hardcoded minima and maxima tcn!')
matBinEdges = linspace(0,4000,intTotalBins);
%%%


for i = 1:intNumOfFolders
    
    disp(sprintf('PROCESSING %s',getlastdir(cellstrTargetFolderList{i})))
    
    PlateTensor{i} = load(fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat'));
    PlateTensor{i} = PlateTensor{i}.Tensor;

    
    if length(cellMeanModelParameterValue) < (size(PlateTensor{i}.TrainingData,2)-1)
        cellMeanModelParameterValue = cell(1,(size(PlateTensor{i}.TrainingData,2)-1));
    end
    
    if isempty(PlateTensor{i}.TrainingData)
        disp(sprintf('  EMPTY TRAININGDATA IN %s',getlastdir(cellstrTargetFolderList{i})))
        continue
    end    
    
    handles = struct();
    handles = LoadMeasurements(handles, fullfile(cellstrTargetFolderList{i},'Measurements_Image_CorrectedTotalCellNumberPerWell.mat'));    
    handles = LoadMeasurements(handles, fullfile(cellstrTargetFolderList{i},'Measurements_Image_FileNames.mat'));        

    intNumberOfImages = length(handles.Measurements.Image.FileNames);
    
    cellFileNames = cell(1,intNumberOfImages);
    %convert ImageNames to something we can index
    for l = 1:length(handles.Measurements.Image.FileNames)
        cellFileNames{1,l} = char(handles.Measurements.Image.FileNames{l}(1));
    end

    intCurrentTcnBin = 0;
    
    for iRows = 1:16
        for iCols = 1:24

            matCurWellCellIndices = find(PlateTensor{i}.MetaData(:,1) == iRows & PlateTensor{i}.MetaData(:,2) == iCols);
            
            %%% LOOK FOR WHICH IMAGES MATCH THIS WELL AND GET THE TOTAL
            %%% WELL CELL NUMBER FROM CORRECTEDTOTALCELLNUMBERPERWELL
            %%% CHECK IMAGE INDICES FROM FILENAMES
            str2match = strcat('_',matRows(iRows), matCols(iCols));
            matImageIndices = find(~cellfun('isempty',strfind(cellFileNames, char(str2match))));
            
            if not(isempty(matImageIndices))
                matTCNs = cell2mat(handles.Measurements.Image.CorrectedTotalCellNumberPerWell(matImageIndices));
                if length(unique(matTCNs)) ~= 1
                    warning('MATLAB:berend:programmo','  predictTotalCellNumberCurves: the images of this well have more then one CorrectedTCN values')
                end
                %%% GET TCN-BIN FOR THIS WELL
                if ~isempty(matTCNs)
                    [foo, intCurrentTcnBin] = histc(matTCNs(1),matBinEdges');
                    if intCurrentTcnBin > 0
                        matCorrectedTCNs(i,intCurrentTcnBin) = nansum([matCorrectedTCNs(i,intCurrentTcnBin), matTCNs(1)]);                
                    end
                end
            end
            
            %%% DATA LABELS: OLIGO NUMBER AND WELL NAME
%             cellstrDataLabels{i,intCurrentTcnBin} = [num2str(PlateTensor{i}.Oligo),'_',matRows{iRows},matCols{iCols}];

            if ~isempty(matCurWellCellIndices) && intCurrentTcnBin > 0
                %%% ORIGINAL INFECTION INDEX                
                intInfectedCells = sum(PlateTensor{i}.TrainingData(matCurWellCellIndices,1)-1);
                intTotalCells = length(matCurWellCellIndices);
                matRawInfectedCells(i,intCurrentTcnBin) = nansum([matRawInfectedCells(i,intCurrentTcnBin), intInfectedCells]);
                matRawTotalCells(i,intCurrentTcnBin) = nansum([matRawTotalCells(i,intCurrentTcnBin), intTotalCells]);
                matRawIIs(i,intCurrentTcnBin) = matRawInfectedCells(i,intCurrentTcnBin) / matRawTotalCells(i,intCurrentTcnBin);
                
                %%% MODEL EXPECTED INFECTION INDEX            
                X = PlateTensor{i}.TrainingData(matCurWellCellIndices,2:end);
                X = X - 1;
                X = [ones(size(X,1),1),X];
                Y = repmat(MasterTensor.Model.Params',size(X,1),1) .* double(X);
                Y = sum(Y,2);
                Y(Y>1)=1;
                Y(Y<0)=0;
                matModelExpectedInfectedCells(i,intCurrentTcnBin) = nansum([matModelExpectedInfectedCells(i,intCurrentTcnBin), sum(Y(:))]);
                
%                 for iDim = 2:size(PlateTensor{i}.TrainingData,2)
%                     if isempty(cellMeanModelParameterValue{iDim-1})
%                         cellMeanModelParameterValue{iDim-1} = nan(intNumOfFolders,50);
%                     end
%                     cellMeanModelParameterValue{iDim-1}(i,intCurrentTcnBin) = [cellMeanModelParameterValue{iDim-1}(i,intCurrentTcnBin); PlateTensor{i}.TrainingData(matCurWellCellIndices,iDim)];
%                 end
            end
        end
    end
end


% %%% get mean model parameter values per bin and plate
% for iDim = 2:size(PlateTensor{i}.TrainingData,2)
%     if isempty(cellMeanModelParameterValue{iDim-1})
%         cellMeanModelParameterValue{iDim-1} = nan(intNumOfFolders,50);
%     end
%     cellMeanModelParameterValue{iDim-1}(i,intCurrentTcnBin) = mean(PlateTensor{i}.TrainingData(matCurWellCellIndices,iDim));
% end


%%% DISCARD DATAPPOINTS WITH TOO FEW CELLS
matDiscardIndices = find(matRawTotalCells<2500);

matRawInfectedCells(matDiscardIndices) = NaN;
matRawTotalCells(matDiscardIndices) = NaN;
matRawIIs(matDiscardIndices) = NaN;
matModelExpectedInfectedCells(matDiscardIndices) = NaN;

matModelIIs = matModelExpectedInfectedCells./matRawTotalCells;






%%% lowess sorting and trendline settings
intLowessSpanValue = 0.25;
intLowessOrderValue = 1;      
[foo,sortix] = sort(matCorrectedTCNs(:));    
clear foo;

    
%%% NEW FIGURE    
hFigure = [];
hFigure(1) = figure();


    [rowPresent,colPresent]=find(~isnan(matRawIIs));
    matNewXLim = [min(colPresent)-1,max(colPresent)+1];

    h=[];
    
    hold on
    bar(nansum(matCorrectedTCNs,1),'FaceColor',[.8 .8 .8],'EdgeColor',[.8 .8 .8])
    title([strFigureTitle, ' - model predicted total-cell-number correlation'])
    set(gca,'FontSize',6,'XLim',matNewXLim)
    h(1) = gca;

    if size(matRawIIs,1)==1
        h(2)=axes();        
        plot(matRawIIs,'b')    
        ylabel('')
        xlabel('')    
        
        h(3)=axes();        
        plot(matModelIIs,'r')
        ylabel('')
        xlabel('')    
        
        disp('plots!')
        
    else
        
        h(2)=axes();
        boxplot(matRawIIs,'colors','b')    
        ylabel('')
        xlabel('')        

        h(3)=axes();
        boxplot(matModelIIs,'colors','r')
        ylabel('')
        xlabel('')    
    end

    %%% SET YLim FOR BOTH BOXPLOTS THE SAME
%     matNewYLim = [min([get(h(2),'YLim'),get(h(3),'YLim')]),max([get(h(2),'YLim'),get(h(3),'YLim')])];
    matNewYLim = [0 .7];
    set(h(2),'YLim',matNewYLim,'Position',get(h(1),'Position'),'XLim',matNewXLim,'Color','none','XTick',[],'YAxisLocation','right','FontSize',6,'XColor','w','YColor','k','ZColor','w','YTick',[])    
    set(h(3),'YLim',matNewYLim,'Position',get(h(1),'Position'),'XLim',matNewXLim,'Color','none','XTick',[],'YAxisLocation','right','FontSize',6,'XColor','w','YColor','k','ZColor','w')
    drawnow
    
    hold off 
    drawnow
    

    
    
%%% ADD EMPTY AXIS WITH JUST TEXT AS LEGEND
cellstrLegend = {'measured infection','model predicted infection'};
cellstrBGColor = {'b','r'};

h(4)=axes();
hold on
set(h(4),'Position',get(h(1),'Position'),'Color','none','XTick',[],'YTick',[],'YAxisLocation','right')
for i = 1:length(cellstrLegend)
    text(1.05,.75-(i/25),strrep(cellstrLegend{i},'_','\_'),'BackgroundColor','w','EdgeColor',cellstrBGColor{i},'FontSize',7,'LineWidth',1,'Margin',3,'HorizontalAlignment','right')
end
hold off     

drawnow



% 
% for i = 1:length(hFigure)
%     figure(hFigure(i))
% 
%     % prepare for pdf printing
%     scrsz = [1,1,1920,1200];
%     set(hFigure(i), 'Position', [1 scrsz(4) scrsz(3) scrsz(4)]);     
%     orient landscape
%     shading interp
%     set(hFigure(i),'PaperPositionMode','auto', 'PaperOrientation','landscape')
%     set(hFigure(i), 'PaperUnits', 'normalized'); 
%     printposition = [0 .2 1 .8];
%     set(hFigure(i),'PaperPosition', printposition)
%     set(hFigure(i), 'PaperType', 'a4');            
%     orient landscape
% 
%     drawnow
% 
%     filecounter = 1;
%     strPrintName = fullfile(strRootPath,['ProbModel_TcnPrediction_',getlastdir(strRootPath),'_',num2str(filecounter),'.pdf']);
%     filepresentbool = fileattrib(fullfile(strRootPath,['ProbModel_TcnPrediction_',getlastdir(strRootPath),'_',num2str(filecounter),'.pdf']));
%     while filepresentbool
%         filecounter = filecounter + 1;    
%         strPrintName = fullfile(strRootPath,['ProbModel_TcnPrediction_',getlastdir(strRootPath),'_',num2str(filecounter),'.pdf']);
%         filepresentbool = fileattrib(strPrintName);
%     end
%     disp(sprintf('stored %s',strPrintName))
%     print(hFigure(i),'-dpdf',strPrintName);
%     close(hFigure(i))
% end