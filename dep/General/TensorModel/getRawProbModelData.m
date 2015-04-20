function [matCompleteData, strFinalFieldName, matCompleteMetaData] = getRawProbModelData(strRootPath,strSettingsFile,intNumOfDirs)
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

    strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Prisca\090203_Mz_Tf_EEA1_vesicles\090203_Mz_Tf_EEA1_CP394-1ad\BATCH\';
    strSettingsFile = '\\nas-biol-imsb-1\share-3-$\Data\Users\Prisca\090203_Mz_Tf_EEA1_vesicles\090203_Mz_Tf_EEA1_CP394-1ad\ProbModel_Settings_Graph.txt';
        
        
%         strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Prisca\090203_Mz_Tf_EEA1_vesicles\090203_Mz_Tf_EEA1_CP395-1ad\BATCH\';
%         strRootPath = npc (strRootPath);
%         strSettingsFile = '/Volumes/share-3-$/Data/Users/Prisca/090203_Mz_Tf_EEA1_vesicles/ProbModel_Settings_TEST.txt';
%         strSettingsFile = npc(strSettingsFile);
        intNumOfDirs = 1;
    end

    disp(sprintf('%s:  retreiving settings from %s',mfilename,strSettingsFile))
    [structDataColumnsToUse, structMiscSettings] = initStructDataColumnsToUse(strSettingsFile);

    disp(sprintf('%s:  looking for plates in %s',mfilename,strRootPath))
    cellstrDataPaths = getbasedir(SearchTargetFolders(strRootPath,'Measurements_Image_FileNames.mat'));
    cellstrDataPaths = sort(cellstrDataPaths);
    
    if nargin < 3
        disp(sprintf('%s:  found %d plates',mfilename,size(cellstrDataPaths,1)))
        intNumOfDirs = [1:size(cellstrDataPaths,1)];
    else
        fprintf('%s:  found %d plates, but taking only the following plate-number(s)\n',mfilename,size(cellstrDataPaths,1))
        fprintf('\t\t\tnumber %d\n',intNumOfDirs)
    end

    matCompleteData = [];
    matCompleteMetaData = [];
    matMeanValuesPerWell = {};


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

        %%% GET A LIST OF WHICH IMAGES TO INCLUDE FROM
        %%% structMiscSettings.RegExpImageNamesToInclude
        cellImageNames = cell(size(PlateDataHandles.Measurements.Image.FileNames));
        for k = 1:length(PlateDataHandles.Measurements.Image.FileNames)
            cellImageNames{k} = PlateDataHandles.Measurements.Image.FileNames{k}{1,1};
        end
        matImageIndicesToInclude = ~cellfun(@isempty,regexp(cellImageNames,structMiscSettings.RegExpImageNamesToInclude));
        disp(sprintf('%s:  analyzing %d images, structMiscSettings.RegExpImageNamesToInclude = "%s"',mfilename,sum(matImageIndicesToInclude(:)),structMiscSettings.RegExpImageNamesToInclude))

        %%% FOLLOWING ITEMS ARE OPTIONAL, OBJECT EXLCUSION AND IMAGE
        %%% EXCLUSION
         if isfield(structMiscSettings,'ObjectsToExclude')
             % init object exclusion variable
             cellObjectsToExclude = cell(1,length(structMiscSettings.ObjectsToExclude));
             matObjectsToExcludeColumn = NaN(1,length(structMiscSettings.ObjectsToExclude));
             matObjectsToExcludeValueToKeep = NaN(1,length(structMiscSettings.ObjectsToExclude));
             cellObjectsToExcludeValueToKeepMethodString = cell(1,length(structMiscSettings.ObjectsToExclude));
             
             for iExclObj = 1:length(structMiscSettings.ObjectsToExclude)
                 strExclObjFile = fullfile(strDataPath,structMiscSettings.ObjectsToExclude(iExclObj).MeasurementsFileName);
                 fprintf('%s: loading object exclusion data\n',mfilename,strExclObjFile)
                 PlateDataHandles = LoadMeasurements(PlateDataHandles, strExclObjFile);
                 cellObjectsToExclude{iExclObj} = PlateDataHandles.Measurements.(structMiscSettings.ObjectsToExclude(iExclObj).ObjectName).(structMiscSettings.ObjectsToExclude(iExclObj).MeasurementName);
                 matObjectsToExcludeColumn(iExclObj) = structMiscSettings.ObjectsToExclude(iExclObj).Column;
                 
                 if isfield(structMiscSettings.ObjectsToExclude(iExclObj),'ValueToKeep')
                     if ~isempty(structMiscSettings.ObjectsToExclude(iExclObj).ValueToKeep)
                        matObjectsToExcludeValueToKeep(iExclObj) = structMiscSettings.ObjectsToExclude(iExclObj).ValueToKeep;
                     end
                 else
                    % default to value to keep = 1
                    matObjectsToExcludeValueToKeep(iExclObj) = 1;
                 end

                 % note that ValueToKeepMethodString overrules ValueToKeep
                 if isfield(structMiscSettings.ObjectsToExclude(iExclObj),'ValueToKeepMethodString')
                     strMethod = structMiscSettings.ObjectsToExclude(iExclObj).ValueToKeepMethodString;
                     if ~isempty(strMethod)
                         % let's parse out nonsense to keep stuff save, we are
                         % going to eval this string after all :-)
                         strMethod = strrep(strMethod,' ','');
                         strMethod = regexp(strMethod,'([<=>]{1,}[\d.]{1,})','Tokens');
                         strMethod = strMethod{1}{1};
                         cellObjectsToExcludeValueToKeepMethodString(iExclObj) = {strMethod};
                     end
                 end                 
                 
             end
         end
       
         if isfield(structMiscSettings,'ImagesToExclude')
             PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,structMiscSettings.ImagesToExclude.MeasurementsFileName));
             matImageOutOfFocus = PlateDataHandles.Measurements.(structMiscSettings.ImagesToExclude.ObjectName).(structMiscSettings.ImagesToExclude.MeasurementName);
         else
             % otherwise, include all images, i.e. nothing is out of focus
            matImageOutOfFocus = zeros(size(matImageIndicesToInclude));
         end

        
        



        %%% GET PER IMAGE INFORMATION ON PLATE WELL LOCATION
        [matImageNamePlateRows,matImageNamePlateColumns]=cellfun(@filterimagenamedata,cellImageNames','UniformOutput',1);

        %%% FILTER PLATE DATA, GET CELL-PLATE AND REPLICA NUMBER
        [intCPNumber, intReplicaNumber] = filterplatedata(strDataPath);
        
        %%% LOOP OVER ALL FIELDNAMES IN STRUCTDATACOLUMNSTOUSE
        cellstrNucleiFieldnames = fieldnames(structDataColumnsToUse);

        cellDataLabels = {};

        fprintf('%s: looping over %d fields\n',mfilename,length(cellstrNucleiFieldnames))        
        for i = 1:length(cellstrNucleiFieldnames)%%% ORIGINAL
    %     for i = 2:6%%% SKIP THE READOUT, INFECTION, AND THE CELL TYPE CLASSIFICATIONS
            
            strCurrentFieldName = char(cellstrNucleiFieldnames{i});
    
            % loop over multiple instances of the same 'parent' field
            for iiX = 1:length(structDataColumnsToUse.(strCurrentFieldName))
                
                strObjectName = structDataColumnsToUse.(strCurrentFieldName)(iiX).ObjectName;                

    %             fprintf('%s: looping over %d columns for field %s\n',mfilename,size(structDataColumnsToUse.(strCurrentFieldName)(iiX).Column,2),strCurrentFieldName)
                for ii = 1:size(structDataColumnsToUse.(strCurrentFieldName)(iiX).Column,2)

                    intCurrentColumn = structDataColumnsToUse.(strCurrentFieldName)(iiX).Column(ii);

                    cellDataLabels = {cellDataLabels,sprintf('%s_%d',cellstrNucleiFieldnames{i},intCurrentColumn)};


                    %%% IF THE CURRENT REQUIRED DATA IS NOT PRESENT, THEN LOAD
                    %%% THE CORRESPONDING RAW DATA FILE 
                    if ~isfield(PlateDataHandles.Measurements,strObjectName) || ~isfield(PlateDataHandles.Measurements.(strObjectName),strCurrentFieldName)
    %                     fprintf('%s:  +-- loading measurement file %s\n',mfilename,fullfile(strDataPath,structDataColumnsToUse.(strCurrentFieldName)(iiX).MeasurementsFileName))
                        PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,structDataColumnsToUse.(strCurrentFieldName)(iiX).MeasurementsFileName));
                    else
    %                     fprintf('%s:  +-- already have measurement file %s\n',mfilename,fullfile(strDataPath,structDataColumnsToUse.(strCurrentFieldName)(iiX).MeasurementsFileName))
                    end

                    % assemble description, first take labels
                    if isfield(structDataColumnsToUse.(strCurrentFieldName)(iiX),'Label')
                        labeldata = structDataColumnsToUse.(strCurrentFieldName)(iiX).Label;
                        if iscell(labeldata) && length(labeldata) > 1 && size(structDataColumnsToUse.(strCurrentFieldName)(iiX).Column,2) > 1
                            strFinalFieldName = [strFinalFieldName, labeldata{ii}];
                        else
                            strFinalFieldName = [strFinalFieldName, char(labeldata)];
                        end
                    else
                        % catch if features field does not exist.
                        try
                            cellstrMeasurementFeatures = PlateDataHandles.Measurements.(strObjectName).([strCurrentFieldName,'Features']);
            %                 strFinalFieldName = [strFinalFieldName, strrep(sprintf('%s_%s_%s',strObjectName,strCurrentFieldName,cellstrMeasurementFeatures{intCurrentColumn}),' ','_')];
                            strFinalFieldName = [strFinalFieldName, sprintf('%s_%s_%d',strObjectName,strCurrentFieldName,intCurrentColumn)];
                        catch foo
                            strFinalFieldName = [strFinalFieldName, [strObjectName,'_',strCurrentFieldName,'_',num2str(structDataColumnsToUse.(strCurrentFieldName)(iiX).Column(ii))]];
                        end
                    end




                    matPlateData = cell(16,24);
                    matPlateMetaData = cell(16,24);
                    
                    % check if the object we're looking for is present in
                    % objectcount
                    intObjectCountColumn = strcmpi(PlateDataHandles.Measurements.Image.ObjectCountFeatures,strObjectName);
                    
                    if sum(intObjectCountColumn)==0
                        % if we're looking at image object, or there is no
                        % cellprofiler object that matches the current
                        % object name, assume first object  count is the
                        % target number of object we wanna have 
                        intObjectCountColumn = 1;
                    end

                    for k = find(~matImageOutOfFocus & matImageIndicesToInclude)
        %                     disp(sprintf('PROCESSING %s',PlateDataHandles.Measurements.Image.FileNames{k}{1,1}))
                        matTempData = [];
                        matTempMetaData = [];
                        
                        if not(isempty(PlateDataHandles.Measurements.(strObjectName).(strCurrentFieldName){k}))

                            if isfield(structMiscSettings,'ObjectsToExclude') & PlateDataHandles.Measurements.Image.ObjectCount{k}(1,intObjectCountColumn) > 0
                                matOKCells = ones(size(cellObjectsToExclude{iExclObj}{k}(:,matObjectsToExcludeColumn(iExclObj))));
                                for iExclObj = 1:length(structMiscSettings.ObjectsToExclude)
                                    if isempty(cellObjectsToExcludeValueToKeepMethodString{iExclObj})
                                        % let's match exclusion data to
                                        % valuetokeep value
                                        matOKCells = matOKCells & (cellObjectsToExclude{iExclObj}{k}(:,matObjectsToExcludeColumn(iExclObj))==matObjectsToExcludeValueToKeep(iExclObj));
                                    else
                                        % let's try and evaluate the
                                        % ValueToKeepMethodString
                                        matOKCells = matOKCells & eval(['(cellObjectsToExclude{iExclObj}{k}(:,matObjectsToExcludeColumn(iExclObj))',cellObjectsToExcludeValueToKeepMethodString{iExclObj},')']);
                                    end
                                end
%                                 if mean(matOKCells) < 1;
%                                     fprintf('%s: discarding %.1f%% objects\n',mfilename,(100*mean(~matOKCells)))
%                                 end 
                                intObjectCount = sum(matOKCells);
                            else
                                % take classical objectcount corresponding to
                                % current object
                                intObjectCount = PlateDataHandles.Measurements.Image.ObjectCount{k}(1,intObjectCountColumn);
                            end

                            %%% ONLY TAKE OBJECTS FROM NON-OTHER CLASSIFIED
                            %%% NUCLEI
                            if isfield(structMiscSettings,'ObjectsToExclude') & intObjectCount > 0
                                if strcmpi(strObjectName,'Image')
                                    matOKCells = 1;
                                else %if strcmpi(strObjectName,'Nuclei') || strcmpi(strObjectName,'Cells')
                                    % exclude other-classified cells
                                    % matOKCells = find(~cellObjectsToExclude{k}(:,matObjectsToExcludeColumn));
                                    matOKCells = ones(size(cellObjectsToExclude{iExclObj}{k}(:,matObjectsToExcludeColumn(iExclObj))));
                                    if isempty(cellObjectsToExcludeValueToKeepMethodString{iExclObj})
                                        % let's match exclusion data to
                                        % valuetokeep value
                                        matOKCells = matOKCells & (cellObjectsToExclude{iExclObj}{k}(:,matObjectsToExcludeColumn(iExclObj))==matObjectsToExcludeValueToKeep(iExclObj));
                                    else
                                        % let's try and evaluate the
                                        % ValueToKeepMethodString
                                        matOKCells = matOKCells & eval(['(cellObjectsToExclude{iExclObj}{k}(:,matObjectsToExcludeColumn(iExclObj))',cellObjectsToExcludeValueToKeepMethodString{iExclObj},')']);
                                    end
%                                     if mean(matOKCells) < 1;
%                                         fprintf('%s: discarding %.1f%% objects\n',mfilename,(100*mean(~matOKCells)))
%                                     end
                                    matOKCells = find(matOKCells);
                                end
                            else
                                % there is no object exclusion data, include
                                % all objects
                                if strcmpi(strObjectName,'Image')
                                    matOKCells = 1;
                                else
                                    %assume default is objects
                                    matOKCells = find(ones(intObjectCount,1));
                                end

                            end

                            
                            if intObjectCount > 1                        

                              %%% TRANSPOSE IF THE DATA REQUIRES IT
                               if structDataColumnsToUse.(strCurrentFieldName)(iiX).Transpose
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
    %                                 fprintf('doing repmat.. ')
                                    matTempData = repmat(matTempData,intObjectCount,1);
                                end

                                %%% LOG10 TRANSFORM DATA IF SETTINGS SAY TO DO SO                            
                                if isfield(structDataColumnsToUse.(strCurrentFieldName)(iiX),'Log10Transform')
                                   if structDataColumnsToUse.(strCurrentFieldName)(iiX).Log10Transform
                                        matTempData = log10(matTempData);
                                        matTempData(isinf(matTempData) | isnan(matTempData)) = NaN;
                                   end
                                end

                                %%% ADD META DATA FOR EACH CELL MEASUREMENT
                                %%% ROW, COLUMN, PLATE-#, CP-#, REPLICA-#,
                                %%% IMAGE-#, OBJECT-#
                                if isequal(size(matOKCells), [1,1])
                                    matOKCells = find(repmat(matOKCells,size(matTempData)));
                                end
                                
                                matTempMetaData = double([repmat(matImageNamePlateRows(k),size(matTempData)), ...
                                                    repmat(matImageNamePlateColumns(k),size(matTempData)), ...
                                                    repmat(iDir,size(matTempData)), ...
                                                    repmat(intCPNumber,size(matTempData)), ...
                                                    repmat(intReplicaNumber,size(matTempData)) ...
                                                    repmat(k,size(matTempData)) ...
                                                    matOKCells ...
                                                ]);

                                matPlateData{matImageNamePlateRows(k),matImageNamePlateColumns(k)} = [matPlateData{matImageNamePlateRows(k),matImageNamePlateColumns(k)};matTempData];
                                matPlateMetaData{matImageNamePlateRows(k),matImageNamePlateColumns(k)} = [matPlateMetaData{matImageNamePlateRows(k),matImageNamePlateColumns(k)};matTempMetaData];
                            end % if objectcount > 1 check
    %                     else
    %                         fprintf('object %s field %s image %d is empty\n',strObjectName,strCurrentFieldName,k)
                        end
                    end

                    %%% take mean value per well
                    matWellAverages = cellfun(@nanmean,matPlateData);
                    if all(isnan(matWellAverages(:)))
                        error('%s: warning all measurements are empty or nans for this field',mfilename)
                    end

        %             matMeanValuesPerWell(isnan(matMeanValues)) = [];
        %             matFinalDataPerWell = [matFinalDataPerWell, single(matMeanValues(:))];

                    %%% take all single cell values
    %                 matFinalData = [matFinalData, uint16(cell2mat(matPlateData(:)))];            
                    matFinalData = [matFinalData, cell2mat(matPlateData(:))];
                    matFinalMetaData = uint16(cell2mat(matPlateMetaData(:)));

                    fprintf('%s:  +-- added feature %d: %d %s measurements from plate %d of %d\n',mfilename,size(matFinalData,2),size(matFinalData,1),strFinalFieldName{end},find(intNumOfDirs==iDir),length(intNumOfDirs))


                end
            end
        end

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
   
%     size(matFinalData)
%     size(matFinalMetaData) 
%     size(matCompleteData) 
%     size(matCompleteMetaData) 
end