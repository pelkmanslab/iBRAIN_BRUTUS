function createTrainingDataEdges(strDataPath,settings)

    if nargin==0
%         strDataPath = 'Z:\Data\Users\VV_DG\20071022095251_M2_071020_VV_DG_batch1_CP001-1db\BATCH\';
%         strSettingsFile = 'Z:\Data\Users\VV_DG\ProbModel_Settings.txt';
%         strDataPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\50K_Tfn\20071130131036_M1_071129_A431_50k_Tfn_P3_2\';
        strDataPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\50K_Tfn\20071130132432_M1_071129_A431_50k_Tfn_P1_1\BATCH\';
        strSettingsFile = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\50K_Tfn\ProbModel_Settings.txt';        
    end
    
    %%% WHICH COLUMNS TO USE FOR EACH MEASUREMENT, TRANSPOSE DATA, RAW
    %%% MEASUREMENT FILE NAMES, NUMBER OF BINS, ETC... 
    if nargin == 0
        disp(sprintf('  getting settings from %s',strSettingsFile))
        [structDataColumnsToUse, structMiscSettings] = initStructDataColumnsToUse(strSettingsFile);
    elseif nargin < 2
        disp('  getting settings from initStructDataColumnsToUse')
        [structDataColumnsToUse, structMiscSettings] = initStructDataColumnsToUse();
    else
        disp('  getting settings as input parameter')        
        structDataColumnsToUse = settings.structDataColumnsToUse;
        structMiscSettings = settings.structMiscSettings;        
    end
    
    boolUpdatedTrainingData = 0;       
    
    %%% IF PRESENT LOAD THE TRAININGDATA STRUCT. FROM THE CURRENT FOLDER
    [boolTrainingDataFileExists] =  fileattrib(fullfile(strDataPath,'ProbModel_TrainingDataEdges.mat'));
    if boolTrainingDataFileExists
        load(fullfile(strDataPath,'ProbModel_TrainingDataEdges.mat'));
        
        if isfield(TrainingData, 'settings')
            oldSettings = TrainingData.settings;
            
            newSettings = struct();
            newSettings.structMiscSettings = structMiscSettings;
            newSettings.structDataColumnsToUse = structDataColumnsToUse;
            
            if ~isequal(oldSettings, newSettings)
                disp('  old settings do not match new settings. clearing old data')
                TrainingData = struct(); 
            else
                disp('  old settings matches new settings. skipping edge calculation')                
                return
            end
            
        else
            disp('  old file did not contain settings field. clearing old data')
            TrainingData = struct();             
        end
        
    else
        disp('  old file did not contain settings field. clearing old data')        
        TrainingData = struct();    
        boolUpdatedTrainingData = 1;
    end

    TrainingData.settings.structMiscSettings = structMiscSettings;
    TrainingData.settings.structDataColumnsToUse = structDataColumnsToUse;    
    

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

    
    %%% LOOP OVER ALL FIELDNAMES IN STRUCTDATACOLUMNSTOUSE AND CHECK DATA
    %%% MINIMA AND MAXIMA
    cellstrNucleiFieldnames = fieldnames(structDataColumnsToUse);
    for i = 1:length(cellstrNucleiFieldnames)
        strCurrentFieldName = char(cellstrNucleiFieldnames{i});
        strObjectName = structDataColumnsToUse.(strCurrentFieldName).ObjectName;

        for ii = 1:size(structDataColumnsToUse.(strCurrentFieldName).Column,2)

            strFinalFieldName = [strObjectName,'_',strCurrentFieldName,'_',num2str(structDataColumnsToUse.(strCurrentFieldName).Column(ii))];
            intCurrentColumn = structDataColumnsToUse.(strCurrentFieldName).Column(ii);
            intNumberOfBins = structDataColumnsToUse.(strCurrentFieldName).NumberOfBins;
            
            boolIntegerData = 0;
            
            if ~isfield(TrainingData,strFinalFieldName)

                %%% IF THE CURRENT REQUIRED DATA IS NOT PRESENT, THEN LOAD
                %%% THE CORRESPONDING RAW DATA FILE 
                if ~isfield(PlateDataHandles.Measurements,strObjectName) || ~isfield(PlateDataHandles.Measurements.(strObjectName),strCurrentFieldName)
                    PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,structDataColumnsToUse.(strCurrentFieldName).MeasurementsFileName));
                end

                intMinData = Inf;
                intMaxData = -Inf;

                for k = find(~matImageOutOfFocus & matImageIndicesToInclude)
%                     disp(sprintf('PROCESSING %s',PlateDataHandles.Measurements.Image.FileNames{k}{1,1}))
                    matTempData = [];
                    
                    if not(isempty(PlateDataHandles.Measurements.(strObjectName).(strCurrentFieldName){k}))
                        
                        %%% ONLY TAKE OBJECTS FROM NON-OTHER CLASSIFIED
                        %%% NUCLEI
                        if strcmpi(strObjectName,'nuclei') || strcmpi(strObjectName,'cells')
                            % exclude other-classified cells
                            if ~isempty(cellObjectsToExclude{k})
                                matOKCells = find(~cellObjectsToExclude{k}(:,matObjectsToExcludeColumn));
                            else
                                matOKCells = [];
                            end
                        elseif strcmpi(strObjectName,'image')
                            % if image
                            matOKCells = 1;
                        else
                            % default, assume nuclear objects
                            matOKCells = find(~cellObjectsToExclude{k}(:,matObjectsToExcludeColumn));                            
                        end
                        
                        if not(isempty(matOKCells))%& not(PlateDataHandles.Measurements.(strObjectName).(strCurrentFieldName){k} == 0)
                            %%% TRANSPOSE IF SETTINGS SAY TO DO SO
                            if structDataColumnsToUse.(strCurrentFieldName).Transpose
                                matTempData = PlateDataHandles.Measurements.(strObjectName).(strCurrentFieldName){k}(intCurrentColumn,matOKCells)';
                            else
                                matTempData = PlateDataHandles.Measurements.(strObjectName).(strCurrentFieldName){k}(matOKCells,intCurrentColumn);
                            end

                            %%% LOG10 TRANSFORM IF SETTINGS SAY TO DO SO                            
                            if isfield(structDataColumnsToUse.(strCurrentFieldName),'Log10Transform')
                               if structDataColumnsToUse.(strCurrentFieldName).Log10Transform
                                    matTempData = log10(matTempData);
                                    matTempData(isinf(matTempData) | isnan(matTempData)) = [];                                    
                               end
                            end

                            %%% DATA INTEGER CHECK
                            if sum(matTempData(:) == int64(matTempData(:))) == length(matTempData(:))
                                boolIntegerData = 1;
                            end
                            
                            intMinData = min([matTempData(:);intMinData]);
                            intMaxData = max([matTempData(:);intMaxData]);
                        end
                    end
                end

                TrainingData.(strFinalFieldName).Min = intMinData;
                TrainingData.(strFinalFieldName).Max = intMaxData;
                TrainingData.(strFinalFieldName).BoolIntegerData = boolIntegerData;
                
                disp(sprintf('%s = %g (min), %g (max), %d (integer)',strFinalFieldName,intMinData,intMaxData,boolIntegerData))
                
                boolUpdatedTrainingData = 1;
            end
        end
    end
    
    if boolUpdatedTrainingData
        disp(sprintf('  saved %s',fullfile(strDataPath,'ProbModel_TrainingDataEdges.mat')))        
        save(fullfile(strDataPath,'ProbModel_TrainingDataEdges.mat'),'TrainingData')
    end

end% function