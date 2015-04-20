% function mainCellPhenotypeSubModel(strRootPath)

% if nargin == 0
    strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\';
% end

strCellLine = '_MZ';
strFigureTitle = [strrep([getlastdir(strRootPath),strCellLine],'_',' ')];

cellTargetAssays = dirc(strRootPath,'de');
cellTargetAssays = cellTargetAssays(:,1);

cellstrTargetFolderList = {};
for iDir = cellTargetAssays'
    %%% ONLY TAKE _MZ CELL ASSAYS TO START WITH
    if cellfun(@isempty,strfind(iDir,strCellLine))
        continue
    end
    cellstrTargetFolderList = [cellstrTargetFolderList;getbasedir(SearchTargetFolders(fullfile(strRootPath,char(iDir),filesep),'Measurements_Image_FileNames.mat'))];
end
intNumOfFolders = length(cellstrTargetFolderList);
disp(sprintf('mainCellPhenotypeSubModel: found %d target folders',intNumOfFolders))

matRows = cellstr(regexp(char(65:80),'\w','match'));
matCols = regexp(sprintf('%.2d',1:24),'\d\d','match');

matCorrectedTCNs = nan(intNumOfFolders,50);

cellMeanModelParameterValue = {};

cellstrDataLabels = cell(intNumOfFolders,50);

matOligoNumbers = nan(intNumOfFolders,1);

for i = 1:intNumOfFolders
    
    matOligoNumbers(i,1) = Oligo_logic(getlastdir(cellstrTargetFolderList{i}));
    
    disp(sprintf('PROCESSING %d OF %d, OLIGO %d: %s',i,intNumOfFolders,matOligoNumbers(i,1),getlastdir(cellstrTargetFolderList{i})))
    
    try
        PlateTensor = load(fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat'));
    catch
        disp(sprintf('  FAILED TO LOAD ProbModel_Tensor.mat FROM %s',getlastdir(cellstrTargetFolderList{i})))        
        continue
    end
    
    PlateTensor = PlateTensor.Tensor;
    
    if length(cellMeanModelParameterValue) < (size(PlateTensor.TrainingData,2)-1)
        cellMeanModelParameterValue = cell(1,(size(PlateTensor.TrainingData,2)-1));
    end
    
    if isempty(PlateTensor.TrainingData)
        disp(sprintf('  EMPTY TRAININGDATA IN %s',getlastdir(cellstrTargetFolderList{i})))
        continue
    end    
    
    try
        handles = struct();
        handles = LoadMeasurements(handles, fullfile(cellstrTargetFolderList{i},'Measurements_Image_CorrectedTotalCellNumberPerWell.mat'));    
        handles = LoadMeasurements(handles, fullfile(cellstrTargetFolderList{i},'Measurements_Image_FileNames.mat'));        
    catch
        disp(sprintf('  FAILED TO LOAD Measurements_Image_CorrectedTotalCellNumberPerWell.mat OR Measurements_Image_FileNames.mat FROM %s',getlastdir(cellstrTargetFolderList{i})))
        continue        
    end

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

            matCurWellCellIndices = find(PlateTensor.MetaData(:,1) == iRows & PlateTensor.MetaData(:,2) == iCols);
            
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
            cellstrDataLabels{i,wellcounter} = [num2str(PlateTensor.Oligo),'_',matRows{iRows},matCols{iCols}];

            if ~isempty(matCurWellCellIndices)
                
                for iDim = 2:size(PlateTensor.TrainingData,2)
                    if isempty(cellMeanModelParameterValue{iDim-1})
                        cellMeanModelParameterValue{iDim-1} = nan(intNumOfFolders,50);
                    end
                    cellMeanModelParameterValue{iDim-1}(i,wellcounter) = double(mean(PlateTensor.TrainingData(matCurWellCellIndices,iDim))) * PlateTensor.StepSizes(iDim);
                end
            end
        end
    end
end


return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CALCULATING 'MODEL', POLYNOMIAL FITS %%%

%%% SORTING OF DATA FOR FITTING
[foo,sortix] = sort(matCorrectedTCNs(:));    
clear foo;
    
%%% NEW FIGURE    
hFigure = [];
hFigure(1) = figure();

%%% MAKE FIRST PLOT/AXIS AS BASIS
hold on
h1=gca;
axis tight
matH1Position = get(h1,'Position');
matH1Position(1) = matH1Position(1) + .05;% slight shift to
set(h1,'Position',matH1Position)
xlabel('total number of cells in well')
hold off
   
drawnow

%%% AXIS HANDLE CONTAINERS
h = [];% plot axis
h2 = [];% second axis to show yticks

%%% COLORS
% cellColor = {   'k',    'r',    'g',    'b',    'y',    'm',    'c',    'k',    'g',    'b',    'y',    'm',    'c',    'k'};
cellColor2 =  {[0.5,0.5,0.5],[1,0.5,0.5],[0.5,1,0.5],[0.5,0.5,1],[1,1,0.5],[1,0.5,1],[0.5,1,1],[0.5,0.5,0.5],[0.5,1,0.5],[0.5,0.5,1],[1,1,0.5],[1,0.5,1],[0.5,1,1],[0.5,0.5,0.5]};
cellColor = {[0,0,0],[1,0,0],[0,1,0],[0,0,1],[1,1,0],[1,0,1],[0,1,1],[0,0,0],[0,1,0],[0,0,1],[1,1,0],[1,0,1],[0,1,1],[0,0,0]};

%%% AXIS POSITIONS
matH1Position = get(h1,'Position');
matH1Position1 = matH1Position;
matH1Position1(1) = matH1Position1(1) - .03;% initial offset

intNumOfPolynomials = 4;
intNumOfDimensions = length(cellMeanModelParameterValue);
matModelParams = NaN(intNumOfDimensions,intNumOfPolynomials+1);
for i = 1:intNumOfDimensions
    disp(sprintf('PLOTTING %d OF %d',i,intNumOfDimensions))
    h(i)=axes();
    hold on
    
    x2 = matCorrectedTCNs(sortix);
    y2 = cellMeanModelParameterValue{i}(sortix);
    x = x2(find(~isnan(x2) & ~isnan(y2)));
    y = y2(find(~isnan(x2) & ~isnan(y2)));    
    
    scatter(x,y,1,cellColor2{i})%,'MarkerFaceColor',

    matModelParams(i,:) = polyfit(x,y,intNumOfPolynomials);
    f = polyval(matModelParams(i,:),x);
    plot(x,f,'-','LineWidth',3,'Color',cellColor{i})

    axis tight
    set(h(i),'Position',matH1Position,'Color','none','XTick',[],'YAxisLocation','right','XColor','w','YColor','w','ZColor','w')
    hold off    

    h2(i)=axes();
    set(h2(i),'Position',matH1Position1,'Color','none','XTick',[],'YLim',get(h(i),'YLim'),'YTick',get(h(i),'YTick'),'YColor',cellColor{i},'XColor','w','ZColor','w','FontSize',6,'FontWeight','bold')    
    matH1Position1(1) = matH1Position1(1) - .025;    
    
    set(h(i),'YTick',[])
    drawnow
end


%%% ADD EMPTY AXIS WITH JUST TEXT AS LEGEND
cellstrLegend = [PlateTensor.Features(2:end)];
cellstrBGColor = [cellColor];

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

% strPrintName = gcf2pdf(strRootPath,'ProbModel_TcnCurves_')

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LINEAR REGRESSION %%%
%%%%%%%%%%%%%%%%%%%%%%%%%

matIncludeDataColumns = find(cellfun(@isempty,strfind(cellstrLegend,'TotalCellNumber')));


%%% Y = total cell number per well
Y = matCorrectedTCNs(:);
%%% X = all model parameters except Total Cell Number
X = [ones(length(matCorrectedTCNs(:)), 1), zeros(length(matCorrectedTCNs(:)), length(cellMeanModelParameterValue) - 1)];

cellstrModelFeatures=['Constant';cellstrLegend(matIncludeDataColumns)'];
for xIndex = 1:length(matIncludeDataColumns)
    X(:,xIndex+1) = cellMeanModelParameterValue{matIncludeDataColumns(xIndex)}(:);
end

%%% REMOVING NANS FROM DATASET
[iX,j]=find(isnan(X));

X([iX],:)=[];
Y([iX],:)=[];

% NORMALIZATION FOR NORMALIZED MODEL PARAMETERS
X2 = (X - repmat(nanmin(X),size(X,1),1)) ./ repmat(nanmax(X),size(X,1),1);
Y2 = (Y - nanmin(Y)) / nanmax(Y);
X2(:,1)=1;%restore constant term column

%%% LEAST SQUARES REGRESSION
cellstrModelFeatures
% matLSModelParams = inv(X'*X)*X'*Y
matNormalizedLSModelParams = inv(X2'*X2)*X2'*Y2


%%% NEW FIGURE    
hFigure = [];
hFigure(1) = figure();

%%% MAKE FIRST PLOT/AXIS AS BASIS
hold on
h1=gca;
axis tight
matH1Position = get(h1,'Position');
set(h1,'Position',matH1Position)
xlabel('total number of cells in well')
hold off
drawnow

%%% AXIS HANDLE CONTAINERS
h = [];% plot axis
%%% AXIS POSITIONS
matH1Position = get(h1,'Position');
for i = 2:size(X,2)
    h(i)=axes();
    hold on
    scatter(Y,X(:,i),1,cellColor2{i})%,'MarkerFaceColor',
    axis tight
    set(h(i),'Position',matH1Position,'Color','none','XTick',[],'YAxisLocation','right','XColor','w','YColor','w','ZColor','w')
    hold off    
    set(h(i),'YTick',[])
    drawnow
end

matPredictedY = round(sum(repmat(matLSModelParams',size(X,1),1) .* X,2));
for i = size(X,2)+1
    h(i)=axes();
    hold on
    scatter(Y,matPredictedY,2,'k')
    axis tight
    set(h(i),'Position',matH1Position,'Color','none','XTick',[],'YAxisLocation','right','XColor','w','YColor','w','ZColor','w')
    hold off    
    set(h(i),'YTick',[])
    drawnow
end



return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CALCULATION OF DIFFERENCES BETWEEN MODEL AND ACTUAL MEASUREMENTS %%%

x=matCorrectedTCNs;
y=cell(1,intNumOfDimensions);
delta=cell(1,intNumOfDimensions);
data=[];
for iOligo = 1:3
    oligodata=[];
    for iDim = 1:intNumOfDimensions
        matOligoRows = find(matOligoNumbers == iOligo);
        y{iDim} = polyval(matModelParams(iDim,:),x(matOligoRows,:));
        delta{iDim} = cellMeanModelParameterValue{iDim}(matOligoRows,:) - y{iDim};

        if size(x(matOligoRows,:)) == size(y{iDim}) & size(y{iDim}) == size(cellMeanModelParameterValue{iDim}(matOligoRows,:))
            disp('OK')
        end
        
        %%% DONT ADD THE DIFFERENCE OF THE TCN AND PREDICTED TCN, BUT ADD
        %%% THE ACTUAL TCN
        if iDim==4
            disp(sprintf('adding different tcn number',cellstrLegend{4}))
            oligodata = [oligodata,nanmedian(x(matOligoRows,:))'];
        else
            oligodata = [oligodata,nanmedian(delta{iDim})'];            
        end
    end
    data=[data;oligodata];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CLUSTERING OF PARAMETERS %%%

origData=data;

%%% GENE NAMES FOR ROWS
dataRowLabels = {};
[f1,f2]=xlsread('gene_labels3.xls');
dataGeneLabels=f2(2:end,1);
for i=1:3
    dataRowLabels=[dataRowLabels;strcat(dataGeneLabels,['_',num2str(i)])];
end


%%% DIMENSION NAMES FOR COLUMNS
dataColumnLabels=cellstrLegend;

data=origData;

%%% REMOVE PLK
disp('REMOVING PLK FROM DATA')
matPLKIndices2remove = find(~cellfun('isempty',strfind(dataRowLabels,'PLK')));
data(matPLKIndices2remove,:)=[];
dataRowLabels(matPLKIndices2remove)=[];
dataGeneLabels(matPLKIndices2remove(1))=[];

%%% REMOVE COLUMNS
% disp('REMOVING TOTAL CELL NUMBER COLUMN FROM DATA')
% matColumns2Remove = find(~cellfun('isempty',strfind(dataColumnLabels,'TotalCellNumber')));
% data(:,matColumns2Remove) = [];
% dataColumnLabels(:,matColumns2Remove) = [];

%%% ZSCORE NORMALIZATION PER COLUMN
data2 = nanzscore(data);
data3 = [];
for i = 1:size(data,2)
    data3 = [data3,nanmedian(reshape(data(:,i),size(data(:,i),1)/3,3)')'];
end
data3 = nanzscore(data3);

%%% COLORMAP
map=[ [sqrt(linspace(1,0,32)'),zeros(32,1),zeros(32,1)] ; [zeros(32,1),sqrt(linspace(0,1,32)'),zeros(32,1)]];

%%% CLUSTERGRAM PER SIRNA
figure
clustergram_Pauli(data2,'dimension',2,'LINKAGE','average','COLUMNLABELS',dataColumnLabels,'ROWLABELS',dataRowLabels,'PDIST','cosine','Dendrogram',{'colorthreshold',1.5}) % 
                                                                                                                            %,'cityblock','Dendrogram',{'colorthreshold',3.2}
                                                                                                                            %,'cosine','Dendrogram',{'colorthreshold',.6}
                                                                                                                            %,'cosine','Dendrogram',{'colorthreshold',1}
colormap(map)
drawnow

%%% CLUSTERGRAM PER GENE
figure
clustergram_Pauli(data3,'dimension',2,'LINKAGE','average','COLUMNLABELS',dataColumnLabels,'ROWLABELS',dataRowLabels,'PDIST','cosine','Dendrogram',{'colorthreshold',1.5}) % 
colormap(map)
drawnow



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% MAKE CYTOSCAPE NETWORK BETWEEN PROPERTIES AND GENES %%%

% virus-tree-branches and genes
Cytoscape_network=cell(1,4);
%node attributes
Cytoscape_nodeattributes=cell(1,4);

% CONNECT POPULATION PROPERTIES WITH KINASES
dataPhenotypeNodeLabels = {'density','size','edge','cellnumber','mitotic','apoptotic'};%dataColumnLabels
intIQRthreshold = .5;
index=0;
for i=1:size(data3,2)
%     [intLower,intUpper]=Detect_Outlier_levels(data3(:,i),intIQRthreshold);
%     intLower=-.5;
%     intUpper=+.5;
    for j = 1:size(data3,1)
%         if data3(j,i) < intLower | data3(j,i) > intUpper
            index=index+1;
            Cytoscape_network{index,1}=dataPhenotypeNodeLabels{i};            
            Cytoscape_network{index,2}='connection';
            Cytoscape_network{index,3}=dataGeneLabels{j};
            Cytoscape_network{index,4}=num2str(data3(j,i));
%         end
    end
end

%%% ADD ALL VIRUS TREE BRANCHES AS INDIVIDUAL NODES
for i=1:size(data3,2)
  index=index+1;
  Cytoscape_network{index,1}=dataPhenotypeNodeLabels{i};
end

%%% ADD ALL INCLUDED 50K GENES AS INDIVIDUAL NODES
cellIncludedGeneNames = Cytoscape_network(:,3);
cellIncludedGeneNames = cellIncludedGeneNames(cellfun(@ischar,cellIncludedGeneNames));
cellIncludedGeneNames = unique(cellIncludedGeneNames);
% cellIncludedGeneNames = dataGeneLabels;
for i=1:length(cellIncludedGeneNames)
  index=index+1;
  Cytoscape_network{index,1}=cellIncludedGeneNames{i};
end

writelists(Cytoscape_network,'C:\Documents and Settings\imsb\Desktop\temp_kinases_phenotypes.sif',[],' ');

return




d = pdist(data2,'cosine');
squared = squareform(d);
Z = linkage(d,'average');
c = cluster(Z,'maxclust',15)



matUniqueClusterPerGene = NaN(49,1);
matMeanDistanceAmongOligos = NaN(49,1);
matMinDistanceAmongOligos = NaN(49,1);
for i = 1:length(dataRowLabels)/3
    matCurrentGeneIndices = find(strncmpi(dataRowLabels,dataGeneLabels{i},length(dataGeneLabels{i})));

    matUniqueClusterPerGene(i) = length(unique(c(matCurrentGeneIndices,:)));
    matMeanDistanceAmongOligos(i) = mean([squared(matCurrentGeneIndices(1),matCurrentGeneIndices(2:3)),squared(matCurrentGeneIndices(2),matCurrentGeneIndices(3))]);
    matMinDistanceAmongOligos(i) = min([squared(matCurrentGeneIndices(1),matCurrentGeneIndices(2:3)),squared(matCurrentGeneIndices(2),matCurrentGeneIndices(3))]); 
end

figure
subplot(2,2,1)
hist(c,max(c))
title('histogram: number of oligos per unique cluster')

subplot(2,2,2)
hist(matUniqueClusterPerGene,max(matUniqueClusterPerGene))
title('histogram: number of unique clusters per gene')
subplot(2,2,3)
hist(matMeanDistanceAmongOligos,15)
title('mean distance among oligos')
subplot(2,2,4)
hist(matMinDistanceAmongOligos,15)
title('minimal distance among oligos')
% strPrintName = gcf2pdf(strRootPath,'PhenotypeSubModel_DeltaCluster_')

dataRowLabels(matUniqueClusterPerGene == 1)
dataRowLabels(matUniqueClusterPerGene == 2)
dataRowLabels(matUniqueClusterPerGene == 3)
dataRowLabels(find(matMeanDistanceAmongOligos<.7))
dataRowLabels(find(matMinDistanceAmongOligos<.6))
dataRowLabels(find(matMinDistanceAmongOligos>.8))
% %%%%%%%%%%%%%%%%
% %%% BOXPLOTS %%%
% 
% %%% GENE NAMES FOR BOXPLOT LABELS
% [f1,f2]=xlsread('gene_labels3.xls');
% BoxplotLabels=f2(2:end,1);
% 
% figure()
% for iDim = 1:intNumOfDimensions
%     subplot(intNumOfDimensions,1,iDim)
%     boxplot(delta{iDim},'labels',BoxplotLabels)
%     title(dataColumnLabels{iDim})
%     drawnow
% end




