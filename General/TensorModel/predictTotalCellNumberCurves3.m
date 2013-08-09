% function predictTotalCellNumberCurves2(strRootPath)

% if nargin == 0
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\David\080220davidvirus\BATCH\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\50K_checkers\060118_EV1_Kyo_CB\BATCH\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\50K_checkers\061120_SV40_GM1_MZ_checker\BATCH\'; 
%      strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\SV40_MZ\';
strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\';
     
% end
strFigureTitle = [strrep(getlastdir(strRootPath),'_','\_'),' '];


cellstrTargetFolderList = SearchTargetFolders(strRootPath,'Measurements_Image_FileNames.mat');
cellstrTargetFolderList = cellfun(@getbasedir,cellstrTargetFolderList,'UniformOutput',0);
intNumOfFolders = length(cellstrTargetFolderList);

PlateTensor = cell(intNumOfFolders,1);

MasterTensor = load(fullfile(strRootPath,'ProbModel_Tensor.mat'));
MasterTensor = MasterTensor.Tensor;


matRows = cellstr(regexp(char(65:80),'\w','match'));
matCols = regexp(sprintf('%.2d',1:24),'\d\d','match');

intTotalBins = 384;

matRawIIs = nan(intNumOfFolders,intTotalBins);
matRawTotalCells = nan(intNumOfFolders,intTotalBins);
matRawInfectedCells = nan(intNumOfFolders,intTotalBins);
matModelExpectedInfectedCells = nan(intNumOfFolders,intTotalBins);
matCorrectedTCNs = nan(intNumOfFolders,intTotalBins);

cellMeanModelParameterValue = {};

cellstrDataLabels = cell(intNumOfFolders,intTotalBins);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GET RANGE FOR BINNING OF TCN PLOT %%%
% % % matTempData = [];
% % % handles = struct();
% % % for i = 1:intNumOfFolders
% % %     handles = LoadMeasurements(handles,fullfile(cellstrTargetFolderList{i},'Measurements_Image_CorrectedTotalCellNumberPerWell.mat'));
% % %     matTempData = [matTempData;cell2mat(handles.Measurements.Image.CorrectedTotalCellNumberPerWell')];
% % % end
% % % intMinTCN = min(matTempData(:));
% % % intMaxTCN = max(matTempData(:));
% % % % [intMinTCN,intMaxTCN]=Detect_Outlier_levels(matTempData);
% % % disp('hardcoded minima and maxima tcn!')
% % % matBinEdges = linspace(0,10000,intTotalBins);
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
    
    for iRows = 3:7
        for iCols = 2:11
            intCurrentTcnBin = intCurrentTcnBin + 1;
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
                matCorrectedTCNs(i,intCurrentTcnBin) = matTCNs(1);
            end
            
            %%% DATA LABELS: OLIGO NUMBER AND WELL NAME
%             cellstrDataLabels{i,intCurrentTcnBin} = [num2str(PlateTensor{i}.Oligo),'_',matRows{iRows},matCols{iCols}];

            if ~isempty(matCurWellCellIndices)
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

matModelIIs = matModelExpectedInfectedCells./matRawTotalCells;

indices2plot = ~isnan(matCorrectedTCNs) & ~isnan(matRawIIs) & ~isnan(matModelIIs);

figure();

% subplot(1,2,1)
hold on
scatter(matCorrectedTCNs(indices2plot),matRawIIs(indices2plot),'b')
scatter(matCorrectedTCNs(indices2plot),matModelIIs(indices2plot),'r')
legend({'measured','predicted'})
title(sprintf('checkerboard curve %s',strrep(getlastdir(getbasedir(strRootPath)),'_','\_')))
hold off

% subplot(1,2,2)
% hold on
% plot(matCorrectedTCNs(indices2plot),matRawIIs(indices2plot)./matModelIIs(indices2plot),'g')
% plot(matCorrectedTCNs(indices2plot),matRawIIs(indices2plot)/median(matRawIIs(indices2plot)),'b')
% hold off

drawnow


