function [cellObjectsToInclude, matIncludedFractionPerWell] = getObjectsToInclude(strRootPath, handles, structMiscSettings)

% cellObjectsToInclude = getObjectsToInclude(strRootPath, handles, structMiscSettings) 
%
% returns a cellArray per image with for the typical cell/nucleus object
% wether to include (true/1) or exclude (false/0) those objects.
%
% settings are loaded from structMiscSettings as it comes from
% initStructDataColumnsToUse(strSettingsFile) for a given settings file. 
%
% regular-expression filename exclusion, image, and object exclusion is
% done by this function. 

    % output
    cellObjectsToInclude = {};
    matIncludedFractionPerWell = nan(16,24);

    % objects to look for that represent the target object type.
    cellstrTargetObjects = {'Nuclei','PreNuclei','Cells'};

    if nargin==0
        
%         strRootPath = 'Y:\Data\Users\Prisca\090203_Mz_Tf_EEA1_harlink_03_1ad\090203_Mz_Tf_EEA1_CP395-1ad\BATCH';
%         strRootPath = npc(strRootPath);
%         strSettingsFile = 'Y:\Data\Users\Prisca\090203_Mz_Tf_EEA1_harlink_03_1ad\ProbModel_Settings_Graph.txt';
%         strSettingsFile = npc(strSettingsFile);

        strRootPath = npc('Z:\Data\Users\CVB3_CNX_GW\20100924T133231_100924_384_CVB3_CNX_P072_1A_CP751-1aa\BATCH');
        strSettingsFile = npc('\\nas-biol-imsb-1\share-2-$\Data\Users\CVB3_CNX_GW\getdata_settings_file_2.txt');
        
%         strSettingsFile = npc('Y:\Data\Users\Prisca\endocytome\090203_MZ_w2Tf_w3EEA1\getRawProbModData2_NEW_INPUT.txt');        
        
        
        
        fprintf('%s:  retreiving settings from %s\n',mfilename,strSettingsFile)
        [structDataColumnsToUse, structMiscSettings] = initStructDataColumnsToUse(strSettingsFile);     %#ok<ASGLU>

        %%% init handles
        handles = struct();
        handles = LoadMeasurements(handles, fullfile(strRootPath,'Measurements_Image_FileNames.mat'));    
        handles = LoadMeasurements(handles, fullfile(strRootPath,'Measurements_Image_ObjectCount.mat'));
    end        

    fprintf('%s:  analyzing "%s"\n',mfilename,strRootPath)

    % parse filename
    cellImageNames = cat(1,handles.Measurements.Image.FileNames{:});
    cellImageNames = cellImageNames(:,1);
    
    % let's start by assuming all nuclei/cells should be included
    
    % if the misc settings contains the field "ObjectCountName", which
    % refers to a object for which we have an object count, use that,
    % otherwise use the standard behaviour of the first match with the
    % names in cellstrTargetObjects 
    intTargetobjectIX = 0;
    if isfield(structMiscSettings,'ObjectCountName')
        if any(ismember(handles.Measurements.Image.ObjectCountFeatures,structMiscSettings.ObjectCountName))
            intTargetobjectIX = find(ismember(handles.Measurements.Image.ObjectCountFeatures,structMiscSettings.ObjectCountName),1,'first');
        end
    end
    % previous conditions not met, fall back on default behaviour
    if intTargetobjectIX==0
        intTargetobjectIX = find(ismember(handles.Measurements.Image.ObjectCountFeatures,cellstrTargetObjects),1,'first');
    end
    % get object name
    strTargetObjectName = handles.Measurements.Image.ObjectCountFeatures{intTargetobjectIX};
    
    if isempty(intTargetobjectIX)
        cellstrTargetObjects %#ok<NOPRT>
        handles.Measurements.Image.ObjectCountFeatures        
        error('%s: couldn''t find a match for the target object list!',mfilename)
    end

    % init cellObjectsToInclude as trues for each object for each image.
    % Next, for each exclusion step we'll one-by-one set objects to 'false'
    cellObjectsToInclude = cellfun(@(x) repmat(true,x(1,intTargetobjectIX),1), handles.Measurements.Image.ObjectCount,'UniformOutput',false);
    % same for objects to include in model..
    cellObjectsToIncludeInModel = cellObjectsToInclude;

    
    % Let's make backward compatibility with old settings file. Translate
    % 'ImagesToExclude' to ObjectsToExclude block, assuming outoffocus.mat
    % measurement
    if isfield(structMiscSettings,'ImagesToExclude')
        fprintf('%s: found ''ImagesToExclude'' field. Updating to new format.\n',mfilename)
        intObjBlockCount = length(structMiscSettings.ObjectsToExclude) + 1;
        structMiscSettings.ObjectsToExclude(intObjBlockCount).ObjectName = structMiscSettings.ImagesToExclude.ObjectName;
        structMiscSettings.ObjectsToExclude(intObjBlockCount).MeasurementsFileName = structMiscSettings.ImagesToExclude.MeasurementsFileName;
        structMiscSettings.ObjectsToExclude(intObjBlockCount).MeasurementName = 'OutOfFocus';
        structMiscSettings.ObjectsToExclude(intObjBlockCount).Column = structMiscSettings.ImagesToExclude.Column;
        % Assume value to keep is '0', assuming standard
        % Measurements_Image_OutOfFocus.mat measurement.
        structMiscSettings.ObjectsToExclude(intObjBlockCount).ValueToKeep = 0;
    end
    
    
    % let's load all (unique) exclusion data files
    % also, we need to make smart guess as to object and measurement names,
    % as in getRawProbModelData2.m
    cellstrMeasurementFileList = unique(cat(1,{structMiscSettings.ObjectsToExclude(:).MeasurementsFileName}));
    
    % see if we can load the measurement directly, or if we need to find
    % the latest matching file... 
    cellstrMeasurementFileList2 = cellstrMeasurementFileList;
    for iExclObj = 1:length(cellstrMeasurementFileList)
        strMeasurementFilePath = fullfile(strRootPath,cellstrMeasurementFileList{iExclObj});

        % if this isnt an esiting file, do the lookup, and store that result
        if ~fileattrib(strMeasurementFilePath)
            strLatestFile = find_best_matching_file(strRootPath,cellstrMeasurementFileList{iExclObj});
            cellstrMeasurementFileList2{iExclObj} = strLatestFile;
        end        
    end
    
    % we should check if we have already stored these settings in the BATCH
    % directory
    strObjectDiscardingMeasurementFile = fullfile(strRootPath,sprintf('Measurements_%s_ObjectsToInclude.mat',strTargetObjectName));
    if fileattrib(strObjectDiscardingMeasurementFile)
        foo = load(strObjectDiscardingMeasurementFile);
        % we can store the settings (structMiscSettings) in the Features
        % field. I.e., if these are equal we can just load it from this
        % file (hmm... assuming files have not changed...)
        if isequal(structMiscSettings,foo.handles.Measurements.(strTargetObjectName).ObjectsToIncludeFeatures)
            
            cellstrMeasurementPaths = cellfun(@(x) fullfile(strRootPath,x),cellstrMeasurementFileList2,'UniformOutput',false);
            matDatesLastModified = cellfun(@getDatenumLastModified, cellstrMeasurementPaths);

            % if current resultfile is newer than all measurement files,
            % just use this...
            if all(getDatenumLastModified(strObjectDiscardingMeasurementFile) > matDatesLastModified)
                cellObjectsToInclude = foo.handles.Measurements.(strTargetObjectName).ObjectsToInclude;
                fprintf('%s:  - loaded results from ''%s''\n',mfilename,strObjectDiscardingMeasurementFile)
                fprintf('%s: including %d %s\n',mfilename,sum(cell2mat(cellObjectsToInclude')),strTargetObjectName)

                % also calculate second output, as this is not stored in
                % the file itself
                if nargout==2
                    [intRow, intColumn] = cellfun(@filterimagenamedata,cellImageNames);
                    matImagePosData = [intRow, intColumn];
                    matIncludedFractionPerWell = NaN(16,24);
                    for iPos = unique(matImagePosData,'rows')'
                        matImageIX = ismember(matImagePosData,iPos','rows');
                        matIncludedFractionPerWell(iPos(1),iPos(2)) = nanmean(cat(1,cellObjectsToInclude{matImageIX}));
                    end                
                end
                return
            end
            
        end
    end    
    
    
    % if there is a regular expression for image-name exlcusion
    if isfield(structMiscSettings,'RegExpImageNamesToInclude')
        % look which images to exclude from the regular expression
        matImageIndicesToExclude = cellfun(@isempty,regexp(cellImageNames,structMiscSettings.RegExpImageNamesToInclude));
        fprintf('%s:  - excluding %d images (%.0f%%) with regular expression = "%s"\n',mfilename,sum(matImageIndicesToExclude(:)),100*mean(matImageIndicesToExclude(:)),structMiscSettings.RegExpImageNamesToInclude)    

        % exclude objects from images that are not included in the regular
        % expression
        cellObjectsToInclude(matImageIndicesToExclude) = cellfun(@(x) ~x(x), cellObjectsToInclude(matImageIndicesToExclude),'UniformOutput',false);
        fprintf('%s:  - excluding %.0f%% (%d) of the %s with this regular expression\n',mfilename,100*mean(~cell2mat(cellObjectsToInclude')),sum(~cell2mat(cellObjectsToInclude')),strTargetObjectName)
    end

%     % if there is a regular expression for image-name exlcusion
%     if isfield(structMiscSettings,'RegExpImageNamesToInclude')
%         % look which images to exclude from the regular expression
%         matImageIndicesToExclude = cellfun(@isempty,regexp(cellImageNames,structMiscSettings.RegExpImageNamesToInclude));
%         fprintf('%s:  - excluding %d images (%.0f%%) with regular expression = "%s"\n',mfilename,sum(matImageIndicesToExclude(:)),100*mean(matImageIndicesToExclude(:)),structMiscSettings.RegExpImageNamesToInclude)    
% 
%         % exclude objects from images that are not included in the regular
%         % expression
%         cellObjectsToInclude(matImageIndicesToExclude) = cellfun(@(x) ~x(x), cellObjectsToInclude(matImageIndicesToExclude),'UniformOutput',false);
%         fprintf('%s:  - excluding %.0f%% (%d) of the %s with this regular expression\n',mfilename,100*mean(~cell2mat(cellObjectsToInclude')),sum(~cell2mat(cellObjectsToInclude')),strTargetObjectName)
%     end    
%     cellObjectsToIncludeInModel
    
    % if there is no ObjectsToExclude field for object exclusion, we're
    % done
    if ~isfield(structMiscSettings,'ObjectsToExclude')
        fprintf('%s: Finished: settings file did not contain objects to exclude settings.\n',mfilename)
        return
    end


    
    
    % loop over each measurement, and load and parse the measurements
    cellLoadedFiles = cell(3,0);    
    fprintf('%s:  - loading %d measurement files\n',mfilename,size(cellstrMeasurementFileList,2))
    for iExclObj = 1:length(cellstrMeasurementFileList)
        
        
        % check if the file exists, if not, or if it does not end
        % on .mat, we should check if it evaluates to a valid
        % measurement file
        strMeasurementFilePath = fullfile(strRootPath,cellstrMeasurementFileList{iExclObj});
        if ~fileattrib(strMeasurementFilePath)
            strMeasurementFilePath = fullfile(strRootPath,cellstrMeasurementFileList2{iExclObj});
            [handles,cellAvailableObjects, cellAvailableMeasurements] = LoadMeasurements(handles,strMeasurementFilePath);
            fprintf('%s:    - %s (%s)\n',mfilename,cellstrMeasurementFileList2{iExclObj},cellstrMeasurementFileList{iExclObj})
        else
            [handles,cellAvailableObjects, cellAvailableMeasurements] = LoadMeasurements(handles,strMeasurementFilePath);
            fprintf('%s:    - %s\n',mfilename,cellstrMeasurementFileList{iExclObj})
        end        
        
        % remove uwanted measurement names, like
        % measurements ending with '...Features'.
        cellAvailableMeasurements( ...
            ~cellfun(@isempty,regexp(cellAvailableMeasurements,'.*Features$')) ...
            ) = [];
        cellAvailableObjects(strcmp(cellAvailableObjects,'SVMp')) = [];
        
        % add to list of loaded files
        cellLoadedFiles(1,end+1) = cellstrMeasurementFileList2(iExclObj); %#ok<AGROW>
        cellLoadedFiles{2,end} = unique(cellAvailableObjects);
        cellLoadedFiles{3,end} = unique(cellAvailableMeasurements);
        
    end    

        

    % for each ObjectsToExclude field
    for iExclObj = 1:length(structMiscSettings.ObjectsToExclude)

        %%% NOTE TO SELF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% MAKE IT WORK WITHOUT OBJECTNAME AND MEASUREMENTNAME! %%%
        matLoadedFileIX = strcmpi(cellstrMeasurementFileList,structMiscSettings.ObjectsToExclude(iExclObj).MeasurementsFileName);
        cellAvailableObjects = cellLoadedFiles{2,matLoadedFileIX};
        cellAvailableMeasurements = unique(cellLoadedFiles{3,matLoadedFileIX});
        
        
        % get object name, either from user, or from
        % measurement file
        strObjectName = '';
        if isfield(structMiscSettings.ObjectsToExclude(iExclObj),'ObjectName') 
            strObjectName = structMiscSettings.ObjectsToExclude(iExclObj).ObjectName;
        end
        if isempty(strObjectName) && size(cellAvailableObjects{1},1)==1
            strObjectName = cellAvailableObjects{1};
        elseif isempty(strObjectName) && size(cellAvailableObjects{1},1)>1
            error('I do not know what object to take from this measurement file... please specify')
        end

        % get measurement name, either from user, or from
        % measurement file 
        strMeasurementName = '';
        if isfield(structMiscSettings.ObjectsToExclude(iExclObj),'MeasurementName')
            strMeasurementName = structMiscSettings.ObjectsToExclude(iExclObj).MeasurementName;
        end
        if isempty(strMeasurementName) && size(cellAvailableMeasurements{1},1)==1
            strMeasurementName = cellAvailableMeasurements{1};
        elseif isempty(strMeasurementName) && size(cellAvailableMeasurements{1},1)>1
            error('I do not know what measurement to take from this measurement file... please specify')
        end
                
        % default column to number 1.
        intColumnIX = [];
        if isfield(structMiscSettings.ObjectsToExclude(iExclObj),'Column')
            intColumnIX = structMiscSettings.ObjectsToExclude(iExclObj).Column;
        end
        if isempty(intColumnIX)
            intColumnIX = 1;
        end
        
        cellMeasurement = handles.Measurements.(strObjectName).(strMeasurementName);
        % if it's not a cell, let's convert it to one (OutOfFocus for
        % example...)
        if ~iscell(cellMeasurement);
            cellMeasurement = arrayfun(@(x) {x},cellMeasurement);
        end
        % kick out other columns than the selected one
        matEmptyImages = cellfun(@isempty,cellMeasurement);% skip empty wells
        cellMeasurement(~matEmptyImages) = cellfun(@(x) x(:,intColumnIX),cellMeasurement(~matEmptyImages),'UniformOutput',false);
        
        % if we're dealing with an image-object, let's repeat the value for
        % each object, so that dimensions match.
        if strcmpi(strObjectName,'Image')
            cellMeasurement = cellfun(@(x,y) repmat(y(1,1),x(1,intTargetobjectIX),1), handles.Measurements.Image.ObjectCount, cellMeasurement,'UniformOutput',false);
        end

        % default to 'value to keep' is 1        
        intValueToKeep = 1;
        if isfield(structMiscSettings.ObjectsToExclude(iExclObj),'ValueToKeep') 
            if ~isempty(structMiscSettings.ObjectsToExclude(iExclObj).ValueToKeep)
                intValueToKeep = structMiscSettings.ObjectsToExclude(iExclObj).ValueToKeep;
            end
        end

        % note that ValueToKeepMethodString overrules ValueToKeep
        strValueToKeepMethod = '';
        if isfield(structMiscSettings.ObjectsToExclude(iExclObj),'ValueToKeepMethodString')
            strMethod = structMiscSettings.ObjectsToExclude(iExclObj).ValueToKeepMethodString;
            if ~isempty(strMethod)
                % let's parse out nonsense to keep stuff save, we are
                % going to eval this string after all :-)
                strMethod = strrep(strMethod,' ','');
                strMethod = regexp(strMethod,'([<=>]{1,}[\d.]{1,})','Tokens');
                strMethod = strMethod{1}{1};
                strValueToKeepMethod = strMethod;
            end
        end    

        % do object exclusion, remember that strValueToKeepMethod overrules
        % intValueToKeep
        
        matEmptyImages = cellfun(@isempty,cellObjectsToInclude);% skip empty wells        
        if isempty(strValueToKeepMethod)
            cellObjectsToInclude(~matEmptyImages) = cellfun(@(x,y) x==intValueToKeep & y, cellMeasurement(~matEmptyImages), cellObjectsToInclude(~matEmptyImages), 'UniformOutput',false);
            % report object exclusion
            fprintf('%s:  - excluding %02.0f%% (%d) of the %s (from remaining images) by keeping Measurement.%s.%s(:,%d)==%d',mfilename,100*mean(~cell2mat(cellObjectsToInclude(~matImageIndicesToExclude)')),sum(~cell2mat(cellObjectsToInclude(~matImageIndicesToExclude)')),strTargetObjectName,strObjectName,strMeasurementName,intColumnIX,intValueToKeep)
        else
            cellObjectsToInclude(~matEmptyImages) = cellfun(@(x,y) eval(sprintf('x%s',strValueToKeepMethod)) & y, cellMeasurement(~matEmptyImages), cellObjectsToInclude(~matEmptyImages), 'UniformOutput',false);
            % report object exclusion
            fprintf('%s:  - excluding %02.0f%% (%d) of the %s (from remaining images) by keeping Measurement.%s.%s(:,%d)%s',mfilename,100*mean(~cell2mat(cellObjectsToInclude(~matImageIndicesToExclude)')),sum(~cell2mat(cellObjectsToInclude(~matImageIndicesToExclude)')),strTargetObjectName,strObjectName,strMeasurementName,intColumnIX,strValueToKeepMethod)
        end
        % report Feature description for field
        if isfield(handles.Measurements.(strObjectName),([strMeasurementName,'Features']))
            strFieldDescription = handles.Measurements.(strObjectName).([strMeasurementName,'Features']){1,intColumnIX};
            fprintf(' (%s)\n',strFieldDescription)
        elseif isfield(handles.Measurements.(strObjectName),([strMeasurementName,'_Features']))
            strFieldDescription = handles.Measurements.(strObjectName).([strMeasurementName,'_Features']){intValueToKeep};
            fprintf(' (%s)\n',strFieldDescription)
        else
            fprintf('\n')
        end
        
        
    end
    
    % also discarding measurements from images with only one object. the
    % measurements from CellProfiler from these images are sometimes weird.
    % (also my own fault).
    cellObjectsToInclude(cellfun(@numel,cellObjectsToInclude)<=1) = {false};
    
    fprintf('%s: including %d %s\n',mfilename,sum(cell2mat(cellObjectsToInclude')),strTargetObjectName)
    
    % store results as measurement file, which we load if the settings are
    % new enough
    handles = struct();
    handles.Measurements.(strTargetObjectName).ObjectsToIncludeFeatures = structMiscSettings;
    handles.Measurements.(strTargetObjectName).ObjectsToInclude = cellObjectsToInclude;
    save(strObjectDiscardingMeasurementFile,'handles')
    fprintf('%s: stored results in %s\n',mfilename,getlastdir(strObjectDiscardingMeasurementFile))

            
    
    % let's write a PDF file with an overview of where did we discard the
    % cells from
    [intRow, intColumn] = cellfun(@filterimagenamedata,cellImageNames);
    matImagePosData = [intRow, intColumn];
    matIncludedFractionPerWell = NaN(16,24);
    for iPos = unique(matImagePosData,'rows')'
        matImageIX = ismember(matImagePosData,iPos','rows');
        matIncludedFractionPerWell(iPos(1),iPos(2)) = nanmean(cat(1,cellObjectsToInclude{matImageIX}));
    end
    
    % create figure and store as PDF
    h = figure();
    imagesc(matIncludedFractionPerWell,[0,1])
    title(sprintf('Fraction of included cells per well. Median %% = %d',round(100*nanmedian(matIncludedFractionPerWell(:)))))
    suptitle(sprintf('%s',getplatenames(strRootPath)))
    colorbar
    drawnow
    strFileName = gcf2pdf(strrep(strRootPath,'BATCH','POSTANALYSIS'),sprintf('%s_overview',mfilename),'overwrite');
    fprintf('%s: stored PDF in %s\n',mfilename,strFileName)
    close(h)
    
    
end% end of function



function strSvmMeasurementName = find_best_matching_file(strRootPath, strSvmStrMatch)
% find svm files matching current searchstring, and return the one with the
% highest number

% get list of all matching files present
cellSvmDataFiles = findfilewithregexpi(strRootPath,sprintf('Measurements_.*%s.*\\.mat',strSvmStrMatch));

if isempty(cellSvmDataFiles)
    warning('bs:Bla','no files found in %s matching to %s',strRootPath,strSvmStrMatch)
    return
elseif ~iscell(cellSvmDataFiles) && ischar(cellSvmDataFiles)
    % only one hit found, use that...
    strSvmMeasurementName=  cellSvmDataFiles;
    return
end

% see if they all have a number at the end. if so, base pick on highest
% number
cellSvmPartMatches = regexpi(cellSvmDataFiles,'Measurements_.*_(\d*).mat','Tokens');

if all(~cellfun(@isempty,cellSvmPartMatches))
    matSvmNumbers = cellfun(@(x) str2double(x{1}),cellSvmPartMatches);

    % find highest number
    [~,intMaxIX] = max(matSvmNumbers);

    % return file name corresponding to highest number
    strSvmMeasurementName = cellSvmDataFiles{intMaxIX};
else
    
    % otherwise, pick the alphabetically last one... (works often for SVMs
    % for isntance)
    strSvmMeasurementName = cellSvmDataFiles{end};
end

end