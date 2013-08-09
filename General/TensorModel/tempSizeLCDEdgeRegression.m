

%     strDataPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\070111_SV40_MZ_MZ_P1_1_1\';
    strDataPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\EV1_KY\070123_EV1_50K_KY_P3_1_2\';

    %%% INITIALIZE PLATEDATAHANDLES
    PlateDataHandles = struct();
    PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,'Measurements_Image_FileNames.mat'));    
    PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,'Measurements_Image_ObjectCount.mat'));
    PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,'Measurements_Image_OutOfFocus.mat'));
    PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,'Measurements_Nuclei_CellTypeClassificationPerColumn.mat'));    

    
    %%% WHICH COLUMNS TO USE FOR EACH MEASUREMENT, TRANSPOSE DATA, RAW
    %%% MEASUREMENT FILE NAMES, NUMBER OF BINS, ETC... 
    structDataColumnsToUse.GridNucleiCountCorrected.Include = true;
    structDataColumnsToUse.GridNucleiCountCorrected.Column = 1;
    structDataColumnsToUse.GridNucleiCountCorrected.Transpose = false;
    structDataColumnsToUse.GridNucleiCountCorrected.NumberOfBins = 16;
    structDataColumnsToUse.GridNucleiCountCorrected.MeasurementsFileName = 'Measurements_Nuclei_GridNucleiCountCorrected.mat';
    structDataColumnsToUse.GridNucleiCountCorrected.ObjectName = 'Nuclei';
    structDataColumnsToUse.GridNucleiCountCorrected.IndependentColumns = false;    

    structDataColumnsToUse.AreaShape.Include = true;
    structDataColumnsToUse.AreaShape.Column = 1;
    structDataColumnsToUse.AreaShape.Transpose = false;
    structDataColumnsToUse.AreaShape.NumberOfBins = 16;
    structDataColumnsToUse.AreaShape.MeasurementsFileName = 'Measurements_Nuclei_AreaShape.mat';
    structDataColumnsToUse.AreaShape.ObjectName = 'Nuclei';
    structDataColumnsToUse.AreaShape.IndependentColumns = false;    

    structDataColumnsToUse.GridNucleiEdges.Include = true;
    structDataColumnsToUse.GridNucleiEdges.Column = 1;
    structDataColumnsToUse.GridNucleiEdges.Transpose = false;
    structDataColumnsToUse.GridNucleiEdges.NumberOfBins = 2;
    structDataColumnsToUse.GridNucleiEdges.MeasurementsFileName = 'Measurements_Nuclei_GridNucleiEdges.mat';
    structDataColumnsToUse.GridNucleiEdges.ObjectName = 'Nuclei';    
    structDataColumnsToUse.GridNucleiEdges.IndependentColumns = false;  

    
    boolUpdatedTrainingData = 1;
    TrainingData = struct();    

    cellstrNucleiFieldnames = fieldnames(structDataColumnsToUse);
    cellstrFieldNames = {};
    X=[];
    Y=[];

    %%% LOOP OVER ALL FIELDNAMES IN STRUCTDATACOLUMNSTOUSE AND CHECK DATA
    %%% MINIMA AND MAXIMA
    for i = 1:length(cellstrNucleiFieldnames)
        strCurrentFieldName = char(cellstrNucleiFieldnames{i});
        strObjectName = structDataColumnsToUse.(strCurrentFieldName).ObjectName;

        for ii = 1:size(structDataColumnsToUse.(strCurrentFieldName).Column,2)

            matTempData = [];
                    
            strFinalFieldName = [strObjectName,'_',strCurrentFieldName,'_',num2str(structDataColumnsToUse.(strCurrentFieldName).Column(ii))];
            intCurrentColumn = structDataColumnsToUse.(strCurrentFieldName).Column(ii);
            intNumberOfBins = structDataColumnsToUse.(strCurrentFieldName).NumberOfBins;

            if ~isfield(TrainingData,strFinalFieldName)

                %%% IF THE CURRENT REQUIRED DATA IS NOT PRESENT, THEN LOAD
                %%% THE CORRESPONDING RAW DATA FILE 
                if ~isfield(PlateDataHandles.Measurements,strObjectName) || ~isfield(PlateDataHandles.Measurements.(strObjectName),strCurrentFieldName)
                    PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,structDataColumnsToUse.(strCurrentFieldName).MeasurementsFileName));
                end

                for k = find(~PlateDataHandles.Measurements.Image.OutOfFocus)

                    
                    if not(isempty(PlateDataHandles.Measurements.(strObjectName).(strCurrentFieldName){k}))
                        
                        %%% ONLY TAKE OBJECTS FROM NON-OTHER CLASSIFIED
                        %%% NUCLEI
                        if strcmpi(strObjectName,'nuclei') || strcmpi(strObjectName,'cells')
                            % exclude other-classified cells
                            matOKCells = find(~PlateDataHandles.Measurements.Nuclei.CellTypeClassificationPerColumn{k}(:,4));
                        elseif strcmpi(strObjectName,'image')
                            matOKCells = 1;
                        end
                        
                        if not(isempty(matOKCells))%& not(PlateDataHandles.Measurements.(strObjectName).(strCurrentFieldName){k} == 0)
                            if structDataColumnsToUse.(strCurrentFieldName).Transpose
                                matTempData = [matTempData;PlateDataHandles.Measurements.(strObjectName).(strCurrentFieldName){k}(intCurrentColumn,matOKCells)'];
                            else
                                matTempData = [matTempData;PlateDataHandles.Measurements.(strObjectName).(strCurrentFieldName){k}(matOKCells,intCurrentColumn)];
                            end
                            
                        end
                    end
                end

                cellstrFieldNames = [cellstrFieldNames;strFinalFieldName];
                boolUpdatedTrainingData = 1;
                
                X=[X,matTempData];
            end
        end
    end

    
    



%%% Y = total cell number per well
Y = X(:,2);
%%% X = all model parameters except Total Cell Number
X = [ones(length(Y), 1), X(:,[1,3])];

% NORMALIZATION FOR NORMALIZED MODEL PARAMETERS
X2 = (X - repmat(nanmin(X),size(X,1),1)) ./ repmat(nanmax(X),size(X,1),1);
X2(:,1)=1;%restore constant term column

Y2 = (Y - nanmin(Y)) / nanmax(Y);


%%% LEAST SQUARES REGRESSION
% matLSModelParams = pinv(X'*X)*X'*Y
matNormalizedLSModelParams = pinv(X2'*X2)*X2'*Y2
