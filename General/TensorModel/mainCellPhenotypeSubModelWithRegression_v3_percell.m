
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\070111_SV40_MZ_MZ_P1_1_1\';
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\';
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\Ad5_MZ\061117_Ad5_50K_MZ_2_1\';
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\Ad3_MZ\070313_Ad3_MZ_P1_1\';
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\';
strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\EvaBerend\081117_MCF10A_SV40_ChTxBup_pFAK\BATCH\';
% strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\EvaBerend\081210_A431_SV40_pFAK_ChtxBuptake\BATCH\';

% strSettingsFile = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\ProbModel_Settings.txt';        
strSettingsFile = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\EvaBerend\081117_MCF10A_SV40_ChTxBup_pFAK\ProbModel_Settings_all_cells_included.txt';
% strSettingsFile = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\EvaBerend\081210_A431_SV40_pFAK_ChtxBuptake\ProbModel_Settings_all_cells_included.txt';

[structDataColumnsToUse, structMiscSettings] = initStructDataColumnsToUse(strSettingsFile);

cellstrDataPaths = getbasedir(SearchTargetFolders(strRootPath,'Measurements_Image_FileNames.mat'));

intNumOfDirs = size(cellstrDataPaths,1);

matCompleteData = [];
matMeanValuesPerWell = {};
strFinalFieldName = {};

for iDir = 1:intNumOfDirs
    
    matFinalData = [];
    
    strDataPath = cellstrDataPaths{iDir};    
    disp(sprintf('  analyzing %s',strDataPath))


    %%% INITIALIZE PLATEDATAHANDLES
    PlateDataHandles = struct();
    PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,'Measurements_Image_FileNames.mat'));    
    PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,'Measurements_Image_ObjectCount.mat'));

    PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,structMiscSettings.ObjectsToExclude.MeasurementsFileName));
    PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,structMiscSettings.ImagesToExclude.MeasurementsFileName));        

    matImageOutOfFocus = PlateDataHandles.Measurements.(structMiscSettings.ImagesToExclude.ObjectName).(structMiscSettings.ImagesToExclude.MeasurementName);
    cellObjectsToExclude = PlateDataHandles.Measurements.(structMiscSettings.ObjectsToExclude.ObjectName).(structMiscSettings.ObjectsToExclude.MeasurementName);    
    matObjectsToExcludeColumn = structMiscSettings.ObjectsToExclude.Column;       

    %%% GET A LIST OF WHICH IMAGES TO INCLUDE FROM
    %%% structMiscSettings.RegExpImageNamesToInclude
    cellImageNames = cell(size(PlateDataHandles.Measurements.Image.FileNames));
    for k = 1:length(PlateDataHandles.Measurements.Image.FileNames)
        cellImageNames{k} = PlateDataHandles.Measurements.Image.FileNames{k}{1,1};
    end
    matImageIndicesToInclude = ~cellfun(@isempty,regexp(cellImageNames,structMiscSettings.RegExpImageNamesToInclude));
    disp(sprintf('  analyzing %d images, structMiscSettings.RegExpImageNamesToInclude = "%s"',sum(matImageIndicesToInclude(:)),structMiscSettings.RegExpImageNamesToInclude))

    %%% GET PER IMAGE INFORMATION ON PLATE WELL LOCATION
    [matImageNamePlateRows,matImageNamePlateColumns]=cellfun(@filterimagenamedata,cellImageNames','UniformOutput',1);
    
    %%% LOOP OVER ALL FIELDNAMES IN STRUCTDATACOLUMNSTOUSE
    cellstrNucleiFieldnames = fieldnames(structDataColumnsToUse);
    for i = 1:length(cellstrNucleiFieldnames)%%% ORIGINAL
%     for i = 2:6%%% SKIP THE READOUT, INFECTION, AND THE CELL TYPE CLASSIFICATIONS
        
        strCurrentFieldName = char(cellstrNucleiFieldnames{i});
        strObjectName = structDataColumnsToUse.(strCurrentFieldName).ObjectName;

        for ii = 1:size(structDataColumnsToUse.(strCurrentFieldName).Column,2)

            strFinalFieldName = [strFinalFieldName; [strObjectName,'_',strCurrentFieldName,'_',num2str(structDataColumnsToUse.(strCurrentFieldName).Column(ii))]];
            intCurrentColumn = structDataColumnsToUse.(strCurrentFieldName).Column(ii);
            intNumberOfBins = structDataColumnsToUse.(strCurrentFieldName).NumberOfBins;
            
            %%% IF THE CURRENT REQUIRED DATA IS NOT PRESENT, THEN LOAD
            %%% THE CORRESPONDING RAW DATA FILE 
            if ~isfield(PlateDataHandles.Measurements,strObjectName) || ~isfield(PlateDataHandles.Measurements.(strObjectName),strCurrentFieldName)
                PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,structDataColumnsToUse.(strCurrentFieldName).MeasurementsFileName));
            end

            
            
            matPlateData = cell(8,12);
            
            for k = find(~matImageOutOfFocus & matImageIndicesToInclude)
%                     disp(sprintf('PROCESSING %s',PlateDataHandles.Measurements.Image.FileNames{k}{1,1}))
                matTempData = [];
                if not(isempty(PlateDataHandles.Measurements.(strObjectName).(strCurrentFieldName){k}))
                    % intObjectCount = PlateDataHandles.Measurements.Image.ObjectCount{k}(1,1);
                    intObjectCount = length(find(~cellObjectsToExclude{k}(:,matObjectsToExcludeColumn)));

                    %%% ONLY TAKE OBJECTS FROM NON-OTHER CLASSIFIED
                    %%% NUCLEI
                    if strcmpi(strObjectName,'Nuclei') || strcmpi(strObjectName,'Cells')
                        % exclude other-classified cells
                        matOKCells = find(~cellObjectsToExclude{k}(:,matObjectsToExcludeColumn));                            
                    elseif strcmpi(strObjectName,'Image')
                        matOKCells = 1;
                    else
                        %assume default is objects
                        matOKCells = find(~cellObjectsToExclude{k}(:,matObjectsToExcludeColumn));                                                        
                    end

                    if intObjectCount > 1                        

                        %%% TRANSPOSE IF THE DATA REQUIRES IT
                        if structDataColumnsToUse.(strCurrentFieldName).Transpose
                            matTempData = PlateDataHandles.Measurements.(strObjectName).(strCurrentFieldName){k}(intCurrentColumn,matOKCells)';
                        else
                            matTempData = PlateDataHandles.Measurements.(strObjectName).(strCurrentFieldName){k}(matOKCells,intCurrentColumn);          
                        end

                        %%% REPEAT MEASUREMENT IF IT IS A 1xN SIZE MATRIX &&
                        %%% OBJECTCOUNT > 1
                        %%% ADDED strcmpi(strObjectName,'Image') &&
                        %%% SINCE THIS SHOULD ONLY HAPPEN FOR IMAGE
                        %%% MEASUREMENTS...
                        if strcmpi(strObjectName,'Image') && size(matTempData,1) == 1 && size(matTempData,2) == 1 && intObjectCount > 1
                            matTempData = repmat(matTempData,intObjectCount,1);
                        end

                        %%% LOG10 TRANSFORM DATA IF SETTINGS SAY TO DO SO                            
                        if isfield(structDataColumnsToUse.(strCurrentFieldName),'Log10Transform')
                           if structDataColumnsToUse.(strCurrentFieldName).Log10Transform
                                matTempData = log10(matTempData);
                                matTempData(isinf(matTempData) | isnan(matTempData)) = NaN;
                           end
                        end

                        matPlateData{matImageNamePlateRows(k),matImageNamePlateColumns(k)} = [matPlateData{matImageNamePlateRows(k),matImageNamePlateColumns(k)};matTempData];

                    end % if objectcount > 1 check

                end
            end
    
            %%% take mean value per well
            matMeanValuesPerWell{i} = cellfun(@nanmean,matPlateData);
%             matMeanValuesPerWell(isnan(matMeanValues)) = [];
%             matFinalDataPerWell = [matFinalDataPerWell, single(matMeanValues(:))];

            %%% take all single cell values
            matFinalData = [matFinalData, single(cell2mat(matPlateData(:)))];            
            
            
            size(matFinalData)
            
        end
    end
    
    matCompleteData = [matCompleteData;matFinalData];
    size(matCompleteData)
end

matCompleteData = nanzscore(matCompleteData)';

node_labels = cellstrNucleiFieldnames;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%% TRY ALL PAIRWISE REGRESSIONS %%%

% bootstrapped, of course
nodes=size(matCompleteData,1);
intNumOfRounds = 15;
matBs = zeros(nodes,nodes+1,intNumOfRounds);
matPs = zeros(nodes,nodes+1,intNumOfRounds);
for i = 1:intNumOfRounds
    disp(sprintf('%s: bootstrapping, round %d of %d',mfilename,i,intNumOfRounds))
    matRndSubsetData = matCompleteData(:,randperm(size(matCompleteData,2)));
    matRndSubsetData = matRndSubsetData(:,1:35000);
%     [vif,r2,matBs(:,:,i),cellstats] = testVIF(zscore(matRndSubsetData'));    
    [vif,r2,matBs(:,:,i),cellstats,matPs(:,:,i)] = testVIF_glmfit(zscore(matRndSubsetData'));
%     [vif,r2,matBs(:,:,i),cellstats] = testVIF_robustfit(zscore(matRndSubsetData'));
end


% dag3 = bs(:,2:end)'
dag3 = nanmedian(matBs(:,2:end,:),3)';
% dag3Stdevs = nanstd(matBs(:,2:end,:),[],3)';
dag3Ps = nanmedian(matPs(:,2:end,:),3)';

% get the ranks of the sorted explainatory variables, in stead of the
% actual values
[foo,dag3Ranks] = sort(abs(dag3),2,'ascend');


%%% DISCARD NON-SIGNIFICANT CONNECTIONS
numPThreshold = 0;
dag3(dag3Ps>numPThreshold) = 0;


%%% DISCARD WEAK CORRELATIONS
numThreshold = 0.1;
for i = 1:size(dag3,2)
    for ii = 1:size(dag3,1)
        if i == ii; continue; end
        if abs(dag3(ii,i)) < numThreshold &  abs(dag3(i,ii)) < numThreshold
            dag3(i,ii) = 0;
            dag3(ii,i) = 0;
        end
    end
end

% dag3(find(abs(dag3)<numThreshold | isnan(dag3)))=0;
dag3(find(isnan(dag3)))=0;
% dag3 = triu(dag3);

% [Pauli's idea to get directonality from the regression] Set the weaker
% connection to 0 such that the arrow is created properly by biograph.

%%% ON RANK VALUES
for i = 1:size(dag3,2)
    for ii = 1:size(dag3,1)
        if i == ii; continue; end
        if abs(dag3Ranks(ii,i)) > abs(dag3Ranks(i,ii))
            dag3(i,ii) = 0;
        elseif abs(dag3Ranks(ii,i)) < abs(dag3Ranks(i,ii))
            dag3(ii,i) = 0;
        elseif abs(dag3Ranks(ii,i)) == abs(dag3Ranks(i,ii))
            if abs(dag3(ii,i)) > abs(dag3(i,ii))
                dag3(i,ii) = 0;
            elseif abs(dag3(ii,i)) < abs(dag3(i,ii))
                dag3(ii,i) = 0;
            end
        end
    end
end

% %%% ON P-VALUES
% for i = 1:size(dag3,2)
%     for ii = 1:size(dag3,1)
%         if i == ii; continue; end
%         if abs(dag3Ps(ii,i)) < abs(dag3Ps(i,ii))
%             dag3(i,ii) = 0;
%         elseif abs(dag3Ps(i,ii)) < abs(dag3Ps(ii,i))
%             dag3(ii,i) = 0;
%         end
%     end
% end


%%% ON ACTUAL VALUES
% for i = 1:size(dag3,2)
%     for ii = 1:size(dag3,1)
%         if i == ii; continue; end
%         if abs(dag3(ii,i)) > abs(dag3(i,ii))
%             dag3(i,ii) = 0;
%         elseif abs(dag3(ii,i)) < abs(dag3(i,ii))
%             dag3(ii,i) = 0;
%         end
%     end
% end
dag3

Graph=biograph(sparse(dag3),node_labels,'ShowWeights','on','ShowArrows','off');
% Graph=biograph(sparse(dag3),node_labels,'ShowWeights','on');%
hG = view(Graph)


% matWeights = abs(dag3(find(dag3~=0)))
for i = 1:length(hG.Edges)
    % get the edge connection details
    strEdgeID=hG.Edges(i).ID;
    strEdgeNode1 = strtrim(strEdgeID(1:strfind(strEdgeID,' -> ')));
    strEdgeNode2 = strtrim(strEdgeID(strfind(strEdgeID,' -> ')+4:end));
    iNode1 = find(strcmp(node_labels,strEdgeNode1));
    iNode2 = find(strcmp(node_labels,strEdgeNode2));
    
    set(hG.Edges(i),'LineWidth',abs(dag3(iNode1,iNode2))*20)
    
%     strLabel = sprintf('%.3f (%.3f)',dag3(iNode1,iNode2),dag3Stdevs(iNode1,iNode2));
%     set(hG.Edges(i),'Label',strLabel);

    if dag3(iNode1,iNode2) > 0
        set(hG.Edges(i),'LineColor',[0 1 0]);    
    else
        set(hG.Edges(i),'LineColor',[1 0 0]);
    end

    disp(sprintf('%s: %.3f',strEdgeID,dag3(iNode1,iNode2)))
end

structMiscSettings.RegExpImageNamesToInclude
