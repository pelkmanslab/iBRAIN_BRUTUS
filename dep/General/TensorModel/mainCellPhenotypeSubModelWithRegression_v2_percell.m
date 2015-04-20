
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\070111_SV40_MZ_MZ_P1_1_1\';
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\';
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\Ad5_MZ\061117_Ad5_50K_MZ_2_1\';
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\Ad3_MZ\070313_Ad3_MZ_P1_1\';
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\';
strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\EvaBerend\081117_MCF10A_SV40_ChTxBup_pFAK\BATCH\';

% strSettingsFile = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\ProbModel_Settings.txt';        
strSettingsFile = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\EvaBerend\081117_MCF10A_SV40_ChTxBup_pFAK\ProbModel_Settings_all_cells_included.txt';


[structDataColumnsToUse, structMiscSettings] = initStructDataColumnsToUse(strSettingsFile);

cellstrDataPaths = getbasedir(SearchTargetFolders(strRootPath,'Measurements_Image_FileNames.mat'));

intNumOfDirs = size(cellstrDataPaths,1);

matCompleteData = [];
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
    for i = 2:length(cellstrNucleiFieldnames)%%% ORIGINAL
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
            matMeanValues = cellfun(@nanmean,matPlateData);

            matMeanValues(isnan(matMeanValues)) = [];
            
            matFinalData = [matFinalData, single(matMeanValues(:))];
            
            size(matFinalData)
            
        end
    end
    
    matCompleteData = [matCompleteData;matFinalData];
    size(matCompleteData)
end

% matFinalData = matFinalData(:,2:end);
matCompleteData = nanzscore(matCompleteData);

matRndIndices = randperm(size(matCompleteData,1));
matRndIndices = matRndIndices(1:end);

[vif,r2,bs,cellstats] = testVIF(zscore(matCompleteData(matRndIndices,1:4)));

bs(:,2:end)
strFinalFieldName(1:4)

% scatterhist(matCompleteData(matRndIndices,1),matCompleteData(matRndIndices,2))
% boxplot(matCompleteData(matRndIndices,2),matCompleteData(matRndIndices,1))
% scatterhist(matCompleteData(matRndIndices,3),matCompleteData(matRndIndices,1))
% boxplot(matCompleteData(matRndIndices,1),matCompleteData(matRndIndices,3))