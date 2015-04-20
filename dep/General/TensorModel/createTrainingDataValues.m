function [TrainingData, cellBinEdges] = createTrainingDataValues(strDataPath, strRootPath, settings)

    if nargin == 0
%         strDataPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\DV_KY\070902_50K_DV_KY_2_1_3\';
        strDataPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\50K_Tfn\20071130132432_M1_071129_A431_50k_Tfn_P1_1\';
        strRootPath = strDataPath;
    end
    
    MasterTrainingData = load(fullfile(strRootPath,'ProbModel_TrainingDataEdges.mat'));
    MasterTrainingData = MasterTrainingData.TrainingData;    
    
    %%% WHICH COLUMNS TO USE FOR EACH MEASUREMENT, TRANSPOSE DATA, RAW
    %%% MEASUREMENT FILE NAMES, NUMBER OF BINS, ETC... 
    if nargin < 3
        [structDataColumnsToUse, structMiscSettings] = initStructDataColumnsToUse();
    else
        structDataColumnsToUse = settings.structDataColumnsToUse;
        structMiscSettings = settings.structMiscSettings;        
    end

    
    
    boolUpdatedTrainingData = 0;
    boolUpdatedTrainingMetaData = 0;    
    
    %%% IF PRESENT LOAD THE TRAININGDATA STRUCT. FROM THE CURRENT FOLDER
    boolTrainingDataFileExists =  fileattrib(fullfile(strDataPath,'ProbModel_TrainingDataValues.mat'));
    if boolTrainingDataFileExists
%         disp('LOADING FILE')
        load(fullfile(strDataPath,'ProbModel_TrainingDataValues.mat'));
        
        if isfield(TrainingData, 'settings')
            oldSettings = TrainingData.settings;
            
            newSettings = struct();
            newSettings.structMiscSettings = structMiscSettings;
            newSettings.structDataColumnsToUse = structDataColumnsToUse;
            
            if ~isequal(oldSettings, newSettings)
                disp(sprintf('%s: old settings do not match new settings. clearing old data',mfilename))
                TrainingData = struct(); 
                cellBinEdges = {};
            else
                disp(sprintf('%s: old settings matches new settings. skipping training data creation',mfilename))
                return
            end
            
        else
            disp(sprintf('%s: old file did not contain settings field. clearing old data',mfilename))            
            TrainingData = struct();             
            cellBinEdges = {};
        end
                
        
    else
        TrainingData = struct();
        cellBinEdges = {};
    end

    %%% INITIALIZE PLATEDATAHANDLES
    PlateDataHandles = struct();
    PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,'Measurements_Image_FileNames.mat'));    
    PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,'Measurements_Image_ObjectCount.mat'));
    
    PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,structMiscSettings.ObjectsToExclude.MeasurementsFileName));
    PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,structMiscSettings.ImagesToExclude.MeasurementsFileName));        

    matImageOutOfFocus = PlateDataHandles.Measurements.(structMiscSettings.ImagesToExclude.ObjectName).(structMiscSettings.ImagesToExclude.MeasurementName);
    cellObjectsToExclude = PlateDataHandles.Measurements.(structMiscSettings.ObjectsToExclude.ObjectName).(structMiscSettings.ObjectsToExclude.MeasurementName);    
    matObjectsToExcludeColumn = structMiscSettings.ObjectsToExclude.Column;    
    %%%
    
    
    
    %%% GET A LIST OF WHICH IMAGES TO INCLUDE FROM
    %%% structMiscSettings.RegExpImageNamesToInclude
    cellImageNames = cell(size(PlateDataHandles.Measurements.Image.FileNames));
    for k = 1:length(PlateDataHandles.Measurements.Image.FileNames)
        cellImageNames{k} = PlateDataHandles.Measurements.Image.FileNames{k}{1,1};
    end
    matImageIndicesToInclude = ~cellfun(@isempty,regexp(cellImageNames,structMiscSettings.RegExpImageNamesToInclude));
    disp(sprintf('%s: analyzing %d images, structMiscSettings.RegExpImageNamesToInclude = "%s"',mfilename,sum(matImageIndicesToInclude(:)),structMiscSettings.RegExpImageNamesToInclude))
    
    cellstrNucleiFieldnames = fieldnames(structDataColumnsToUse);
    for i = 1:length(cellstrNucleiFieldnames)
        strCurrentFieldName = char(cellstrNucleiFieldnames{i});
        strObjectName = structDataColumnsToUse.(strCurrentFieldName).ObjectName;
%         intObjectcountColumn = find(strcmpi(PlateDataHandles.Measurements.Image.ObjectCountFeatures,strObjectName));    

        for ii = 1:size(structDataColumnsToUse.(strCurrentFieldName).Column,2)

            strFinalFieldName = [strObjectName,'_',strCurrentFieldName,'_',num2str(structDataColumnsToUse.(strCurrentFieldName).Column(ii))];
            intCurrentColumn = structDataColumnsToUse.(strCurrentFieldName).Column(ii);
            intNumberOfBins = structDataColumnsToUse.(strCurrentFieldName).NumberOfBins;
            
            %%% SEE IF THERE IS ALREADY TRAININGDATA FOR THIS FIELDNAME, AND
            %%% IF IT HAS THE SAME BINSIZE AS WE WANT, IF NOT, CREATE IT
            if ~isfield(TrainingData,strFinalFieldName) || ...
                    ~isfield(TrainingData.(strFinalFieldName),'Data') || ...
                    ~isfield(TrainingData.(strFinalFieldName),'Max') || ...
                    TrainingData.(strFinalFieldName).Max ~= MasterTrainingData.(strFinalFieldName).Max || ...
                    TrainingData.(strFinalFieldName).Min ~= MasterTrainingData.(strFinalFieldName).Min

                % RESET METADATA FOR ENTIRE PLATE...
                if not(boolUpdatedTrainingMetaData)
                    TrainingData.MetaDataFeatures = {'PlateRow','PlateCol','ImageNumber','ObjectNumber'};
                    TrainingData.MetaData = uint16([]);
                    for k = find(~matImageOutOfFocus & matImageIndicesToInclude)
                        % exclude other classified cells                        
%                         intObjectIDs = find(~PlateDataHandles.Measurements.Nuclei.CellTypeClassificationPerColumn{k}(:,4));                        
                        if ~isempty(cellObjectsToExclude{k})
                            intObjectIDs = find(~cellObjectsToExclude{k}(:,matObjectsToExcludeColumn));
                        else
                            intObjectIDs = [];
                        end
                        intObjectCount = length(intObjectIDs);
%                        intObjectCount = PlateDataHandles.Measurements.Image.ObjectCount{k}(1,1);                        
                        if intObjectCount > 1
                            [intRow, intCol] = check_image_well_position(PlateDataHandles.Measurements.Image.FileNames{k}(1,1));
                            tempMetaData = [repmat(uint16([intRow, intCol, k]),intObjectCount,1),intObjectIDs];
                            TrainingData.MetaData = uint16([TrainingData.MetaData;tempMetaData]);
                        end
                    end
                    boolUpdatedTrainingMetaData = 1;                    
                end
                
                %%% RESET DATA FIELD
                TrainingData.(strFinalFieldName).Data = uint8([]);

                %%% IF THE CURRENT REQUIRED DATA IS NOT PRESENT, THEN LOAD
                %%% THE CORRESPONDING RAW DATA FILE 
                if ~isfield(PlateDataHandles.Measurements,strObjectName) || ~isfield(PlateDataHandles.Measurements.(strObjectName),strCurrentFieldName)
                    PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,structDataColumnsToUse.(strCurrentFieldName).MeasurementsFileName));
                end

                %%% STORE CURRENT SETTINGS IN THIS TRAININGDATA INSTANCE
                TrainingData.(strFinalFieldName).BoolIntegerData = MasterTrainingData.(strFinalFieldName).BoolIntegerData;
                
                %%% IF CURRENT DIMENSION DATA IS INTEGER DATA, AND IF THE
                %%% NUMBER OF BINS PRESENT IS SMALLER THAN THE NUMBER OF
                %%% BINS MANUALLY SET, REDUCE BIN SIZE SETTINGS.
                if MasterTrainingData.(strFinalFieldName).BoolIntegerData == 1
                    intNewNumberOfBins = (MasterTrainingData.(strFinalFieldName).Max - MasterTrainingData.(strFinalFieldName).Min) + 1;
                    if intNewNumberOfBins < intNumberOfBins
                        disp(sprintf('%s: integer data detected for %s with fewer unique values than the number of bins. Setting number of bins from %d to %d',mfilename,strFinalFieldName,intNumberOfBins,intNewNumberOfBins))
                        disp(sprintf('%s: Minimum = %d, Maximum = %d',mfilename,MasterTrainingData.(strFinalFieldName).Min,MasterTrainingData.(strFinalFieldName).Max))
                        intNumberOfBins = intNewNumberOfBins;
                    end
                end
                    
                TrainingData.(strFinalFieldName).Histogram = zeros(intNumberOfBins,1);
                TrainingData.(strFinalFieldName).BinEdges = linspace(MasterTrainingData.(strFinalFieldName).Min, MasterTrainingData.(strFinalFieldName).Max, intNumberOfBins);
                cellBinEdges = [cellBinEdges, TrainingData.(strFinalFieldName).BinEdges];
                
                TrainingData.(strFinalFieldName).StepSize = unique(single(diff(linspace(MasterTrainingData.(strFinalFieldName).Min, MasterTrainingData.(strFinalFieldName).Max, intNumberOfBins))));
                TrainingData.(strFinalFieldName).Bins = intNumberOfBins;
                TrainingData.(strFinalFieldName).Min = MasterTrainingData.(strFinalFieldName).Min;
                TrainingData.(strFinalFieldName).Max = MasterTrainingData.(strFinalFieldName).Max;
                TrainingData.(strFinalFieldName).IndependentColumns = structDataColumnsToUse.(strCurrentFieldName).IndependentColumns;
                
                
                %%% TAKE ALONG SOME ORIGINAL DATA FROM
                %%% INITSTRUCTDATACOLUMNGSTOUSE
                TrainingData.(strFinalFieldName).OrigDataColumn = structDataColumnsToUse.(strCurrentFieldName).Column;
                TrainingData.(strFinalFieldName).OrigDataMeasurementsFileName = structDataColumnsToUse.(strCurrentFieldName).MeasurementsFileName;
                TrainingData.(strFinalFieldName).OrigDataObjectName = structDataColumnsToUse.(strCurrentFieldName).ObjectName;
                TrainingData.(strFinalFieldName).OrigDataTranspose = structDataColumnsToUse.(strCurrentFieldName).Transpose;                
                TrainingData.(strFinalFieldName).OrigDataIndependentColumns = structDataColumnsToUse.(strCurrentFieldName).IndependentColumns;                                

                
%                 for k = find(PlateDataHandles.Measurements.Image.OutOfFocus | matImageIndicesToExclude)                
%                     disp(sprintf('skipping %s',PlateDataHandles.Measurements.Image.FileName{k}{1,1}))
%                 end
                
                for k = find(~matImageOutOfFocus & matImageIndicesToInclude)
%                     disp(sprintf('PROCESSING %s',PlateDataHandles.Measurements.Image.FileNames{k}{1,1}))
                    matTempData = [];
                    if not(isempty(PlateDataHandles.Measurements.(strObjectName).(strCurrentFieldName){k}))
                        % intObjectCount = PlateDataHandles.Measurements.Image.ObjectCount{k}(1,1);
                        if ~isempty(cellObjectsToExclude{k})
                            intObjectCount = length(find(~cellObjectsToExclude{k}(:,matObjectsToExcludeColumn)));
                        else
                            intObjectCount = 0;
                        end
                        
                        %%% ONLY TAKE OBJECTS FROM NON-OTHER CLASSIFIED
                        %%% NUCLEI
                        if strcmpi(strObjectName,'Nuclei') || strcmpi(strObjectName,'Cells')
                            % exclude other-classified cells
                            if ~isempty(cellObjectsToExclude{k})
                                matOKCells = find(~cellObjectsToExclude{k}(:,matObjectsToExcludeColumn));                            
                            else
                                matOKCells = [];
                            end                            
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
                            
                            %%% DO HISTOGRAM CLASSIFICATION WITH MATTEMPDATA
                            %%% AND BINEDGES, CONVERT OUTPUT TO uint8 TO
                            %%% REDUCE DATA SIZE.
                            [matCurrentHistogram,matCellBinNumber] = histc(double(matTempData),TrainingData.(strFinalFieldName).BinEdges);
                            matCellBinNumber = uint8(matCellBinNumber);

                            %%% IF INDEPENDENTCOLUMNS VALUE IS SET, CREATE A
                            %%% NxM COLUMNS OF ONES WHERE n,m = 2 IF CELL n
                            %%% WAS IN BIN m... fo shizzle!
                            if structDataColumnsToUse.(strCurrentFieldName).IndependentColumns
                                matCellBinNumberSplitColumns = ones(size(matCellBinNumber,1),intNumberOfBins);
                                for iBinColumn = 1:intNumberOfBins
                                    [rowInd, colInd] = find(matCellBinNumber == iBinColumn);
                                    matCellBinNumberSplitColumns(rowInd,iBinColumn)=2;
                                end
                                matCellBinNumber = matCellBinNumberSplitColumns;
                                clear matCellBinNumberSplitColumns
                            end

    % % %                         %%% EXPLICIT INTEGRITY CHECK OF TRAININGDATA (1)                     
    % % %                         if ~isempty(find(matCellBinNumber == 0))
    % % %                             
    % % %                             disp(sprintf('\n\nERROR in %s',strFinalFieldName))                                                        
    % % %                             disp(sprintf('%d cells are in bin 0, outside data range!',length(find(matCellBinNumber == 0))))                            
    % % %                             disp('bin edges are:')
    % % %                             disp(TrainingData.(strFinalFieldName).BinEdges)
    % % %                             disp('unique input values:')
    % % %                             disp(unique(matTempData)')
    % % %                             disp(sprintf('max possible value: %f',TrainingData.(strFinalFieldName).Max))
    % % %                             disp(sprintf('min possible value: %f',TrainingData.(strFinalFieldName).Min))                            
    % % % 
    % % %                             error('Cells outside the data bin/data range have been found. This is not possible. Fix the bug!')
    % % %                         end
    % % %                         
    % % %                         %%% EXPLICIT INTEGRITY CHECK OF TRAININGDATA RANGE
    % % %                         %%% (2)
    % % %                         matDataColumnValues = unique(matCellBinNumber);
    % % %                         if ~(min(matDataColumnValues(:)) >= 1) || ~(max(matDataColumnValues(:)) <= intNumberOfBins)
    % % %                             disp(sprintf('min present: %d',min(matDataColumnValues(:))))
    % % %                             disp(sprintf('max present: %d',max(matDataColumnValues(:))))
    % % %                             disp(sprintf('max possible: %d',intNumberOfBins))
    % % %                             error('training data failed to pass explicit integrity check...')
    % % %                         end

                            %%% IF ONLY ONE DATAPOINT WAS PUT INTO HISTC, IT
                            %%% RETURNS A COLUMN-VECTOR INSTEAD OF A ROW-VECTOR
                            if size(matCurrentHistogram) ~= size(TrainingData.(strFinalFieldName).Histogram) & ...
                                size(matCurrentHistogram') == fliplr(size(TrainingData.(strFinalFieldName).Histogram))
                                matCurrentHistogram = matCurrentHistogram';
                                disp(sprintf('%s: --- applied quickfix for an obsolete bug? ---',mfilename))
                            end                        

    %                         disp(sprintf('- %d ',size(TrainingData.(strFinalFieldName).Histogram)))
    %                         disp(sprintf('+ %d ',size(matCurrentHistogram)))                        

                            try
                                TrainingData.(strFinalFieldName).Histogram = TrainingData.(strFinalFieldName).Histogram + matCurrentHistogram;
                            catch
                                size(TrainingData.(strFinalFieldName).Histogram)
                                size(matCurrentHistogram)
                                strDataPath
                                rethrow(lasterror)
                            end

                            %%% NOTE THAT TRANSFORMING A NaN TO UINT8 SETS
                            %%% IT TO 0... AT THIS POINT, ALL INDIVIDUAL
                            %%% CELLS WITH ANY TRAININGDATA VALUE OF 0
                            %%% SHOULD BE DISCARDED! (0 IS ALSO THE VALUE
                            %%% HISTC RETURNS IF A VALUE FALLS OUTSIDE ITS
                            %%% RANGE)
                            TrainingData.(strFinalFieldName).Data = uint8([TrainingData.(strFinalFieldName).Data;matCellBinNumber]);
                        
                            TrainingData.settings.structMiscSettings = structMiscSettings;
                            TrainingData.settings.structDataColumnsToUse = structDataColumnsToUse;
                            
                        end % if objectcount > 1 check
                        
                    end
                end
                boolUpdatedTrainingData = 1;
            end
        end
    end
    
    if boolUpdatedTrainingData
        disp(sprintf('%s: saved %s',mfilename,fullfile(strDataPath,'ProbModel_TrainingDataValues.mat')))
        save(fullfile(strDataPath,'ProbModel_TrainingDataValues.mat'),'TrainingData','cellBinEdges')
    end
    
end% function