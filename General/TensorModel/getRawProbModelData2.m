function [matCompleteData, strFinalFieldName, matCompleteMetaData] = getRawProbModelData2(strRootPath,strSettingsFile,intNumOfDirs, structDataColumnsToUse, structMiscSettings)
% Usage: 
%
% [matCompleteData, strFinalFieldName, matCompleteMetaData] = getRawProbModelData(strRootPath,strSettingsFile)
%
% Where matCompleteMetaData contains 
%     Row, 
%     Column, 
%     Plate number, 
%     Cell Plate number, 
%     Replica number, 
%     Image number, 
%     Object number
    

    if nargin==0
%         strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\50K_final_reanalysis\DV_KY2\';
%         strSettingsFile = '\\nas-biol-imsb-1\share-3-$\Data\Users\50K_final_reanalysis\ProbModel_Settings.txt';

%         strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Eva\iBRAIN\090930_ChtxB_density_MCF10A3\BATCH\';
%         strSettingsFile = '\\nas-biol-imsb-1\share-3-$\Data\Users\Eva\iBRAIN\090930_ChtxB_density_MCF10A3\ProbModel_Settings_TEST.txt';

%     strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Prisca\090203_Mz_Tf_EEA1_vesicles\090203_Mz_Tf_EEA1_CP394-1ad\BATCH\';
%     strSettingsFile = '\\nas-biol-imsb-1\share-3-$\Data\Users\Prisca\090203_Mz_Tf_EEA1_vesicles\090203_Mz_Tf_EEA1_CP394-1ad\ProbModel_Settings_Graph.txt';
        
    strRootPath = 'Y:\Data\Users\Eva\BS_iBRAIN\090930_ChtxB_density_MCF10A3\BATCH';
    strSettingsFile = 'Y:\Data\Users\Eva\BS_iBRAIN\090930_ChtxB_density_MCF10A3\ProbModel_Settings_TEST.txt';
        
%         strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Prisca\090203_Mz_Tf_EEA1_vesicles\090203_Mz_Tf_EEA1_CP395-1ad\BATCH\';
%         strRootPath = npc (strRootPath);
%         strSettingsFile = '/Volumes/share-3-$/Data/Users/Prisca/090203_Mz_Tf_EEA1_vesicles/ProbModel_Settings_TEST.txt';
%         strSettingsFile = npc(strSettingsFile);
        intNumOfDirs = 1;
    end

    if nargin <= 3

        disp(sprintf('%s:  retreiving settings from %s',mfilename,strSettingsFile))
        [structDataColumnsToUse, structMiscSettings] = initStructDataColumnsToUse(strSettingsFile);
        
    else
        
        fprintf('%s:  using directly applied settings',mfilename,strSettingsFile)
        
    end

    disp(sprintf('%s:  looking for plates in %s',mfilename,strRootPath))
    cellstrDataPaths = getbasedir(SearchTargetFolders(strRootPath,'Measurements_Image_FileNames.mat'));
    cellstrDataPaths = sort(cellstrDataPaths);
    
    if nargin < 3 || isempty(intNumOfDirs)
        disp(sprintf('%s:  found %d plates',mfilename,size(cellstrDataPaths,1)))
        intNumOfDirs = [1:size(cellstrDataPaths,1)];
    else
        fprintf('%s:  found %d plates, but taking only the following plate-number(s)\n',mfilename,size(cellstrDataPaths,1))
        fprintf('\t\t\tnumber %d\n',intNumOfDirs)
    end

    matCompleteData = [];
    matCompleteMetaData = [];

    for iDir = intNumOfDirs

        matFinalData = [];
        matFinalMetaData = [];
        strFinalFieldName = {};

        strDataPath = cellstrDataPaths{iDir};    
        disp(sprintf('%s:  analyzing %s',mfilename,strDataPath))


        %%% INITIALIZE PLATEDATAHANDLES
        PlateDataHandles = struct();
        PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,'Measurements_Image_FileNames.mat'));    
        PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,'Measurements_Image_ObjectCount.mat'));

        % parse filenames
        cellImageNames = cat(1,PlateDataHandles.Measurements.Image.FileNames{:});
        cellImageNames = cellImageNames(:,1);
        
        % Check regular-expression, image, and object exclusion
        cellObjectsToInclude = getObjectsToInclude(strDataPath, PlateDataHandles, structMiscSettings);

        %%% GET PER IMAGE INFORMATION ON PLATE WELL LOCATION
        [matImageNamePlateRows,matImageNamePlateColumns]=cellfun(@filterimagenamedata,cellImageNames','UniformOutput',1);

        %%% FILTER PLATE DATA, GET CELL-PLATE AND REPLICA NUMBER
        [intCPNumber, intReplicaNumber] = filterplatedata(strDataPath);
        
        %%% LOOP OVER ALL FIELDNAMES IN STRUCTDATACOLUMNSTOUSE
        cellstrNucleiFieldnames = fieldnames(structDataColumnsToUse);

        for i = 1:length(cellstrNucleiFieldnames)%%% ORIGINAL
                
            strMeasurementName = char(cellstrNucleiFieldnames{i});
    
            % loop over multiple instances of the same 'parent' field
            for iiX = 1:length(structDataColumnsToUse.(strMeasurementName))
                
                strObjectName = structDataColumnsToUse.(strMeasurementName)(iiX).ObjectName;                

                for ii = 1:size(structDataColumnsToUse.(strMeasurementName)(iiX).Column,2)

                    intColumnIX = structDataColumnsToUse.(strMeasurementName)(iiX).Column(ii);

                    %%% IF THE CURRENT REQUIRED DATA IS NOT PRESENT, THEN LOAD
                    %%% THE CORRESPONDING RAW DATA FILE 
                    if ~isfield(PlateDataHandles.Measurements,strObjectName) || ~isfield(PlateDataHandles.Measurements.(strObjectName),strMeasurementName)
                        strMeasurementFilePath = fullfile(strDataPath,structDataColumnsToUse.(strMeasurementName)(iiX).MeasurementsFileName);
                        if fileattrib(strMeasurementFilePath)
                            PlateDataHandles = LoadMeasurements(PlateDataHandles, strMeasurementFilePath);
                        else
                            warning('bsBla:FileNotFound','%s: file ''%s'' does not exist in ''%s''.',mfilename,getlastdir(strMeasurementFilePath),getbasedir(strMeasurementFilePath))
                            continue
                        end
                    end
                    
                    % get measurement in cell array
                    cellMeasurement = PlateDataHandles.Measurements.(strObjectName).(strMeasurementName);                    

                    % if it's not a cell, let's convert it to one (OutOfFocus for
                    % example...)
                    if ~iscell(cellMeasurement);
                        cellMeasurement = arrayfun(@(x) {x},cellMeasurement);
                    end
                    
                    % default final field name
                    strFinalFieldName = [strFinalFieldName, sprintf('%s_%s_%d',strMeasurementName,strObjectName,intColumnIX)];
                    % if label is given, overwrite fieldname with label
                    if isfield(structDataColumnsToUse.(strMeasurementName)(iiX),'Label')
                        if ~isempty(structDataColumnsToUse.(strMeasurementName)(iiX).Label)
                            strFinalFieldName{end} = structDataColumnsToUse.(strMeasurementName)(iiX).Label;
                        end
                    end
                    
                    % kick out other columns than the selected one
                    matEmptyImages = cellfun(@isempty,cellMeasurement);% skip empty wells
                    cellMeasurement(~matEmptyImages) = cellfun(@(x) x(:,intColumnIX),cellMeasurement(~matEmptyImages),'UniformOutput',false);

                    % if we're dealing with an image-object, let's repeat the value for
                    % each object, so that the dimensions match.
                    if strcmpi(strObjectName,'Image')
                        cellMeasurement = cellfun(@(x,y) repmat(y(1,1),x(1,intColumnIX),1), PlateDataHandles.Measurements.Image.ObjectCount, cellMeasurement,'UniformOutput',false);
                    end
                    
                    fprintf('%s:  +-- processing Measurements.%s.%s column %d\n',mfilename,strObjectName,strMeasurementName,intColumnIX)
                    
                    % look up images with cells to include. unfortunately,
                    % sometimes cells with a single measurement are empty.
                    matNonEmptyImages = cellfun(@sum,cellObjectsToInclude)>1;
                    % get data from those images
                    matPlateData = cellfun(@(x,y) x(y,1), cellMeasurement(matNonEmptyImages),cellObjectsToInclude(matNonEmptyImages),'UniformOutput',false);
                    matPlateData = cell2mat(matPlateData');

                    %%% LOG10 TRANSFORM DATA IF SETTINGS SAY TO DO SO                            
                    if isfield(structDataColumnsToUse.(strMeasurementName)(iiX),'Log10Transform')
                       if structDataColumnsToUse.(strMeasurementName)(iiX).Log10Transform
                            matPlateData = log10(matPlateData);
                            matPlateData(isinf(matPlateData)) = NaN;
                       end
                    end

                    matFinalData = [matFinalData, matPlateData];

                    fprintf('%s:  +-- added feature %d: %d %s measurements from plate %d of %d\n',mfilename,size(matFinalData,2),size(matFinalData,1),strFinalFieldName{end},find(intNumOfDirs==iDir),length(intNumOfDirs))
                    
                end
            end
            

        end

        % create meta data where matCompleteMetaData contains 
        %     Row, 
        %     Column, 
        %     Plate number, 
        %     Cell Plate number, 
        %     Replica number, 
        %     Image number, 
        %     Object number                    
        matObjectCount = cellfun(@sum,cellObjectsToInclude(matNonEmptyImages));
        matObjectIX = cell2mat(cellfun(@find,cellObjectsToInclude(matNonEmptyImages),'UniformOutput',false)');
        matImageIX = find(matNonEmptyImages);

        % init meta data
        matFinalMetaData = nan(size(matPlateData,1),7);

        matFinalMetaData(:,[1,2,6]) = cell2mat(arrayfun(@(a,b,c,d) repmat([a,b,c],d,1), ...
                matImageNamePlateRows(matNonEmptyImages), ...
                matImageNamePlateColumns(matNonEmptyImages), ...
                matImageIX, ...
                matObjectCount ...
                ,'UniformOutput',false)');

        matFinalMetaData(:,3) = iDir;
        matFinalMetaData(:,4) = intCPNumber;
        matFinalMetaData(:,5) = intReplicaNumber;
        matFinalMetaData(:,7) = matObjectIX;

        
        % merge data from different plates
        try
            matCompleteData = [matCompleteData;matFinalData];
            matCompleteMetaData = [matCompleteMetaData;matFinalMetaData];
%             size(matCompleteData)
            if iDir == intNumOfDirs
                fprintf('%s:  total cell number: %d\n',mfilename,size(matCompleteData,1))            
            else
                fprintf('%s:  sub-total cell number: %d\n',mfilename,size(matCompleteData,1))            
            end
        catch foo
            foo
            warning('BSBla','%s: failed to add plate data to total data, probably out of memory',mfilename)
        end
    end

    % remove any cells with NaN values   
    matNaNRowIndices = any(isnan(matCompleteData),2);
    if sum(matNaNRowIndices) > 0
        fprintf('%s:  removing %d NaN values\n',mfilename,sum(matNaNRowIndices))
        matCompleteData(matNaNRowIndices,:) = [];
        matCompleteMetaData(matNaNRowIndices,:) = [];
    end

end