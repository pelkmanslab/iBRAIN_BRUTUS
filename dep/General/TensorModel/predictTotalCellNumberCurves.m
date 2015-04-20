function predictTotalCellNumberCurves(strRootPath)

if nargin == 0
    strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\RRV_MZ\';
end
strFigureTitle = [strrep(getlastdir(strRootPath),'_','\_'),' '];





cellstrTargetFolderList = SearchTargetFolders(strRootPath,'Measurements_Image_FileNames.mat');
intNumOfFolders = length(cellstrTargetFolderList);

PlateTensor = cell(intNumOfFolders,1);

MasterTensor = load(fullfile(strRootPath,'ProbModel_Tensor.mat'));
MasterTensor = MasterTensor.Tensor;


%%% WHAT TO DO IF TCN COUNT IS A MODEL VARIABLE???
% % % matTCNIndex = find(~cellfun('isempty',strfind(MasterTensor.Model.Features,'Edges')));
% % % matOtherIndices = find(cellfun('isempty',strfind(MasterTensor.Model.Features,'Edges')));
% % % 
% % % if matTCNIndex
% % %     disp(sprintf('  REMOVING TCN FIELD %s FROM TENSOR',MasterTensor.Model.Features{matTCNIndex}))
% % %     MasterTensor.Model.Features = MasterTensor.Model.Features(matOtherIndices)
% % %     MasterTensor.Model.X = MasterTensor.Model.X
% % % else
% % %     
% % % end
    
matRows = cellstr(regexp(char(65:80),'\w','match'));
matCols = regexp(sprintf('%.2d',1:24),'\d\d','match');

matRawIIs = nan(intNumOfFolders,50);
matRawTotalCells = nan(intNumOfFolders,50);
matRawInfectedCells = nan(intNumOfFolders,50);
matModelExpectedInfectedCells = nan(intNumOfFolders,50);
matCorrectedTCNs = nan(intNumOfFolders,50);

cellMeanModelParameterValue = {};

cellstrDataLabels = cell(intNumOfFolders,50);
    
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
    wellcounter = 0;
    
    for iRows = 3:7
        for iCols = 2:11
            wellcounter = wellcounter + 1;

            matCurWellCellIndices = find(PlateTensor{i}.MetaData(:,1) == iRows & PlateTensor{i}.MetaData(:,2) == iCols);
            
            %%% LOOK FOR WHICH IMAGES MATCH THIS WELL AND GET THE TOTAL
            %%% WELL CELL NUMBER FROM CORRECTEDTOTALCELLNUMBERPERWELL
            %%% CHECK IMAGE INDICES FROM FILENAMES
            str2match = strcat('_',matRows(iRows), matCols(iCols));
            matImageIndices = find(~cellfun('isempty',strfind(cellFileNames, char(str2match))));

            if not(isempty(matImageIndices))
                matTCNs = cell2mat(handles.Measurements.Image.CorrectedTotalCellNumberPerWell(matImageIndices));
                if length(unique(matTCNs)) == 1
                    matCorrectedTCNs(i,wellcounter) = matTCNs(1);
                else
                    warning('MATLAB:programmo','  predictTotalCellNumberCurves: the images of this well have more then one CorrectedTCN values')
                    matCorrectedTCNs(i,wellcounter) = matTCNs(1);
                end
            end
            
            %%% DATA LABELS: OLIGO NUMBER AND WELL NAME
            cellstrDataLabels{i,wellcounter} = [num2str(PlateTensor{i}.Oligo),'_',matRows{iRows},matCols{iCols}];

            if ~isempty(matCurWellCellIndices)
                %%% ORIGINAL INFECTION INDEX                
                intInfectedCells = sum(PlateTensor{i}.TrainingData(matCurWellCellIndices,1)-1);
                intTotalCells = length(matCurWellCellIndices);
                matRawInfectedCells(i,wellcounter) = intInfectedCells;
                matRawTotalCells(i,wellcounter) = intTotalCells;
                matRawIIs(i,wellcounter) = intInfectedCells./intTotalCells;
                
                %%% MODEL EXPECTED INFECTION INDEX            
                X = PlateTensor{i}.TrainingData(matCurWellCellIndices,2:end);
                X = X - 1;
                X = [ones(size(X,1),1),X];
                Y = repmat(MasterTensor.Model.Params',size(X,1),1) .* double(X);
                matModelExpectedInfectedCells(i,wellcounter) = sum(Y(:));
                
                for iDim = 2:size(PlateTensor{i}.TrainingData,2)
                    if isempty(cellMeanModelParameterValue{iDim-1})
                        cellMeanModelParameterValue{iDim-1} = nan(intNumOfFolders,50);
                    end
                    cellMeanModelParameterValue{iDim-1}(i,wellcounter) = mean(PlateTensor{i}.TrainingData(matCurWellCellIndices,iDim));
                end
            end
        end
    end
end

matModelIIs = matModelExpectedInfectedCells./matRawTotalCells;

%%% lowess sorting and trendline settings
intLowessSpanValue = 0.25;
intLowessOrderValue = 1;      
[foo,sortix] = sort(matCorrectedTCNs(:));    
clear foo;

    
%%% NEW FIGURE    
hFigure = [];
hFigure(1) = figure();

%%% MAKE FIRST PLOT/AXIS AS BASIS
hold on
scatter(matCorrectedTCNs(:),matRawIIs(:),'.r')
YSmooth = malowess(matCorrectedTCNs(sortix), matRawIIs(sortix), 'Robust', 'true', 'span', intLowessSpanValue, 'Order',intLowessOrderValue);    
plot(matCorrectedTCNs(sortix), YSmooth,'-r','LineWidth',3)           
% scatter(matCorrectedTCNs(:),matModelIIs(:),'.k')
% YSmooth = malowess(matCorrectedTCNs(sortix), matModelIIs(sortix), 'Robust', 'true', 'span', intLowessSpanValue, 'Order',intLowessOrderValue);    
% plot(matCorrectedTCNs(sortix), YSmooth,'-k','LineWidth',3)           

% YSmooth = malowess(matCorrectedTCNs(sortix), matRawTotalCells(sortix), 'Robust', 'true', 'span', intLowessSpanValue, 'Order',intLowessOrderValue);    
% plot(matCorrectedTCNs(sortix), YSmooth,'-','LineWidth',1,'Color',[.8,.8,.8])           

h1=gca;

axis tight
matH1Position = get(h1,'Position');
matH1Position(1) = matH1Position(1) + .05;% slight shift to
set(h1,'Position',matH1Position)
xlabel('total number of cells in well')
hold off
   
drawnow

h = [];% plot axis
h2 = [];% second axis to show yticks
cellColor = {'g','b','y','m','c','k','g','b','y','m','c','k'};
matH1Position = get(h1,'Position');
matH1Position1 = matH1Position;
matH1Position1(1) = matH1Position1(1) - .03;% initial offset
for i = 1:length(cellMeanModelParameterValue)
    h(i)=axes();
    hold on
%     scatter(matCorrectedTCNs(:),cellMeanModelParameterValue{i}(:),'.g')
    YSmooth = malowess(matCorrectedTCNs(sortix), cellMeanModelParameterValue{i}(sortix), 'Robust', 'true', 'span', intLowessSpanValue, 'Order',intLowessOrderValue);    
    plot(matCorrectedTCNs(sortix), YSmooth,'-','LineWidth',1,'Color',cellColor{i})
    axis tight
    set(h(i),'Position',matH1Position,'Color','none','XTick',[],'YAxisLocation','right','XColor','w','YColor','w','ZColor','w')
    hold off    

    h2(i)=axes();
    set(h2(i),'Position',matH1Position1,'Color','none','XTick',[],'YLim',get(h(i),'YLim'),'YTick',get(h(i),'YTick'),'YColor',cellColor{i},'XColor','w','ZColor','w','FontSize',6,'FontWeight','bold')    
    matH1Position1(1) = matH1Position1(1) - .03;    
    
    set(h(i),'YTick',[])
end


%%% ADD EMPTY AXIS WITH JUST TEXT AS LEGEND
cellstrLegend = ['Infection index','Predicted infection index',PlateTensor{end}.Features(2:end)];
cellstrBGColor = ['r','k',cellColor];

i = i + 1;
h(i)=axes();
hold on
set(h(i),'Position',matH1Position,'Color','none','XTick',[],'YTick',[],'YAxisLocation','right')
for i = 1:length(cellstrLegend)
    text(1.05,.75-(i/25),strrep(cellstrLegend{i},'_','\_'),'BackgroundColor','w','EdgeColor',cellstrBGColor{i},'FontSize',7,'LineWidth',1,'Margin',3,'HorizontalAlignment','right')
end
hold off    

%%% ADD TITLE
title(strFigureTitle)

drawnow


% 
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
% 
