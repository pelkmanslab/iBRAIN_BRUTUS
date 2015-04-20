% function mainCellPhenotypeSubModel(strRootPath)
clear all
close all

% if nargin == 0
    strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\';
%     strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\50K_checkers\';
% end


strCellLine = '_MZ';
strFigureTitle = [strrep([getlastdir(strRootPath),strCellLine],'_',' ')];


list=dir(sprintf('%s*%s*.',strRootPath,strCellLine));
list=struct2cell(list);
list=list';
item_isdir=cell2mat(list(:,4));
cellTargetAssays=list(item_isdir,1);
if strcmp(cellTargetAssays(1),'.') && ...
    strcmp(cellTargetAssays(2),'..')
    cellTargetAssays(1:2)=[];
end


cellstrTargetFolderList = {};
for iDir = cellTargetAssays'
    %%% ONLY TAKE _MZ CELL ASSAYS TO START WITH
    if cellfun(@isempty,strfind(iDir,strCellLine))
        continue
    end
    cellstrTargetFolderList = [cellstrTargetFolderList;SearchTargetFolders(fullfile(strRootPath,char(iDir),filesep),'Measurements_Image_FileNames.mat')];
end
cellstrTargetFolderList = getbasedir(cellstrTargetFolderList);


intNumOfFolders = length(cellstrTargetFolderList);
disp(sprintf('mainCellPhenotypeSubModel: found %d target folders',intNumOfFolders))

matRows = cellstr(regexp(char(65:80),'\w','match'));
matCols = regexp(sprintf('%.2d',1:24),'\d\d','match');

matCorrectedTCNs = nan(intNumOfFolders,50);

cellMeanModelParameterValue = {};

cellstrDataLabels = cell(intNumOfFolders,50);

matOligoNumbers = nan(intNumOfFolders,1);

bs = cell(intNumOfFolders,1);

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
    
%     [vif,r2,bs{i}] = testVIF(PlateTensor.TrainingData);
    
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

% cellColor2 =  {[0.5,0.5,0.5],[1,0.5,0.5],[0.5,1,0.5],[0.5,0.5,1],[1,1,0.5],[1,0.5,1],[0.5,1,1],[0.5,0.5,0.5],[0.5,1,0.5],[0.5,0.5,1],[1,1,0.5],[1,0.5,1],[0.5,1,1],[0.5,0.5,0.5]};
% cellColor = {[0,0,0],[1,0,0],[0,1,0],[0,0,1],[1,1,0],[1,0,1],[0,1,1],[0,0,0],[0,1,0],[0,0,1],[1,1,0],[1,0,1],[0,1,1],[0,0,0]};

cellColor2 =  {[0.5,0.5,0.5],[0.5,0.5,0.5],[0.5,0.5,0.5],[0.5,0.5,0.5],[0.5,0.5,0.5],[0.5,0.5,0.5],[0.5,0.5,0.5],[0.5,0.5,0.5]};
cellColor = {[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]};

cellstrLegend = [PlateTensor.Features(2:end)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CALCULATING 'MODEL', POLYNOMIAL FITS %%%
%%% SORTING OF DATA FOR FITTING
[foo,sortix] = sort(matCorrectedTCNs(:));    
clear foo;

intNumOfPolynomials = 3;
intNumOfDimensions = length(cellMeanModelParameterValue);
matModelParams = NaN(intNumOfDimensions,intNumOfPolynomials+1);

figure()
for i = 1:intNumOfDimensions
    if i<4;ii=i;else;ii=i-1;end
    if i==4;continue;end
    
    disp(sprintf('PLOTTING %d OF %d',i,intNumOfDimensions))

    
    x2 = matCorrectedTCNs(sortix);
    y2 = cellMeanModelParameterValue{i}(sortix);
    
    %%% TRASHING INDICES WITH LESS THEN 500 OR MORE THEN 20000 CELLS
%     matIndices2keep = find(~isnan(x2) & ~isnan(y2) & x2>1000 & x2<20000);
    matIndices2keep = find(~isnan(x2) & ~isnan(y2) & x2>1000);
%     matIndices2keep = find(~isnan(x2) & ~isnan(y2));
    x = x2(matIndices2keep);
    y = y2(matIndices2keep);    
    
    subplot(2,3,ii)
    
    hold on
    
    scatter(x,y,2,cellColor{i},'filled')%,'MarkerFaceColor',

%     matModelParams(i,:) = polyfit(x,y,intNumOfPolynomials);
%     f = polyval(matModelParams(i,:),x);
%     plot(x,f,'-','LineWidth',3,'Color',cellColor{i})
    
    title(strrep(cellstrLegend{i},'_','\_'))

    if max(y2(:))<=2
        set(gca,'YLim',[1 2]);
    end
    
    hold off    

    
    drawnow
end
subplot(2,3,6);
axis();
drawnow

% % % gcf2pdf('C:\Documents and Settings\imsb\Desktop\',strrep(strFigureTitle,' ','_'))






x = cellMeanModelParameterValue{1}(sortix);
y = cellMeanModelParameterValue{2}(sortix);
matIndices2keep = find(~isnan(x) & ~isnan(y));
x = x(matIndices2keep);
y = y(matIndices2keep);    

subplot(2,3,6)
scatter(x,y,2,cellColor{1},'filled')%,'MarkerFaceColor',
% title(strrep([cellstrLegend{1},':',cellstrLegend{2}],'_','\_'))
xlabel(strrep(cellstrLegend{1},'_','\_'))
ylabel(strrep(cellstrLegend{2},'_','\_'))
if max(y(:))<=2;set(gca,'YLim',[1 2]);end
drawnow
