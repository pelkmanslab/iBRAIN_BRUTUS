strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ\philip_071006_Tfn_MZ_AWaa\';
strSettingsFile = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ\philip_071006_Tfn_MZ_AWaa\ProbModel_Settings.txt';        

[structDataColumnsToUse, structMiscSettings] = initStructDataColumnsToUse(strSettingsFile);

cellstrDataPaths = getbasedir(SearchTargetFolders(strRootPath,'Measurements_Image_FileNames.mat'));

intNumOfDirs = size(cellstrDataPaths,1);

matCompleteDataPerCell = [];
matCompleteDataPerWell = [];

matSelectedWellDataPerCell = [];
cellComplete = {};

strFinalFieldName = {};
for iDir = 1:intNumOfDirs
    
    matFinalDataPerWell = [];
    matFinalDataPerCell = [];    
    
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
    
    strRegexp = structMiscSettings.RegExpImageNamesToInclude;
%     strRegexp = '_H\d\d';%%% OVERWRITE
    disp(sprintf('*** NOTE, strRegExp = %s',strRegexp))
    
    %%% ALSO SKIP WELL D03 (PLK1) 
    matImageIndicesToInclude = (~cellfun(@isempty,regexp(cellImageNames,strRegexp)) & cellfun(@isempty,strfind(cellImageNames,'_D03')));
    disp(sprintf('  analyzing %d images, structMiscSettings.RegExpImageNamesToInclude = "%s"',sum(matImageIndicesToInclude(:)),strRegexp))

    %%% GET PER IMAGE INFORMATION ON PLATE WELL LOCATION
    [matImageNamePlateRows,matImageNamePlateColumns]=cellfun(@filterimagenamedata,cellImageNames','UniformOutput',1);
    
    %%% LOOP OVER ALL FIELDNAMES IN STRUCTDATACOLUMNSTOUSE
    cellstrNucleiFieldnames = fieldnames(structDataColumnsToUse);
%     for i = 2:length(cellstrNucleiFieldnames)%%% ORIGINAL
    for i = 1:size(cellstrNucleiFieldnames,1)%%% INCLUDE THE READOUT
        
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

            
            matPlateDataPerCell = [];                        
            matPlateDataPerWell = cell(8,12);

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

                    if intObjectCount > 100

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

                        matPlateDataPerWell{matImageNamePlateRows(k),matImageNamePlateColumns(k)} = [matPlateDataPerWell{matImageNamePlateRows(k),matImageNamePlateColumns(k)};matTempData];
                        matPlateDataPerCell = [matPlateDataPerCell;matTempData];                        

                    end % if objectcount > 1 check

                end
            end

            
            cellComplete{i} = matPlateDataPerWell;
            
            %%% take mean value per well
            matMeanValuesPerWell = cellfun(@nanmean,matPlateDataPerWell);
            matMeanValuesPerWell(isnan(matMeanValuesPerWell)) = [];
            matFinalDataPerWell = [matFinalDataPerWell, single(matMeanValuesPerWell(:))];
            
            %%% all data per single cell
            matFinalDataPerCell = [matFinalDataPerCell, single(matPlateDataPerCell(:))];
            
        end
    end
    
    matCompleteDataPerCell = [matCompleteDataPerCell;matFinalDataPerCell];
    matCompleteDataPerWell = [matCompleteDataPerWell;matFinalDataPerWell];    

end


matStats = nan(8,12);
matVarianceRations = nan(8,12);
for iRow = 1:8
    for iCol = 1:12
        
        TrainingData = [];
        for iii = 1:i-1%skip total cell number
            TrainingData=[TrainingData,cellComplete{iii}{iRow,iCol}];
        end

        TrainingData = nanzscore(single(TrainingData));
        
        if ~isempty(TrainingData)

            matAllColumns = 2:size(TrainingData,2);
            yt = single(TrainingData(:,1));
            xt = TrainingData(:,matAllColumns);
            xt = single([ones(size(xt,1),1),xt]); % add column of ones

            [b,bint,r,rint,stats]=regress(yt,xt);
            matStats(iRow,iCol)=stats(1);
    %         stats = regstats(yt,xt,'linear');
    
            stats = regstats(yt,xt(:,2:end),'linear');

            matVarianceRations(iRow,iCol)=(var(stats.yhat) / stats.mse);
            disp(sprintf('%.3f ratio of model variance over residual variance',var(stats.yhat) / stats.mse))
    
    
        end

    end
end




