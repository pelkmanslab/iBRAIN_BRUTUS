function MeasureMahalanobisDistance_Green(strBASIC)

%Load project directory   
%strBASIC = '\\nas-biol-imsb-1\share-3-$\Data\Users\Prisca\091113_A431_GPIGFP';
strBASIC = npc(strBASIC);

% list of paths to load
cellPlateNames = CPdir(strBASIC);
cellPlateNames = {cellPlateNames([cellPlateNames(:).isdir]).name}';
matHasBATCHDirectory = cellfun(@(x) fileattrib(fullfile(strBASIC, x, 'BATCH')),cellPlateNames);
cellPlateNames(~matHasBATCHDirectory) = [];

%%%%%%%%%%
% Description of which measurements to load

strObjectName = 'Cells';
strFeatureName = '_OrigGreen';
% file_names = {['Measurements_',strObjectName,'_Intensity',strFeatureName],['Measurements_',strObjectName,'_Texture_3',strFeatureName]};
file_names = {['Measurements_',strObjectName,'_Intensity',strFeatureName],['Measurements_',strObjectName,'_Texture_3',strFeatureName],'Measurements_Nuclei_LocalCellDensity','Measurements_Nuclei_Edge','Measurements_Nuclei_DistanceToEdge','Measurements_PreNuclei_AreaShape'};

% strObjectName = 'Cells';
% strFeatureName = '_AreaShape';
% file_names  = {['Measurements_',strObjectName,strFeatureName],['Measurements_',strObjectName,strFeatureName]};
%%%%%%%%%

% list of SVM names to look for (load_latest) and values to keep
cellstrListOfSvmsAndValuesToKeep = { ...
        'BiNuclei',2; ...
        'interphase',1; ...
        'mitotic',2; ...
        'OutofFocus',2; ...
        'Crap',2; ...
        'Blob',2 ...
    };

for iPlate = 1:size(cellPlateNames,1)

    % current plate path
    strPlatePath = fullfile(strBASIC,cellPlateNames{iPlate},'BATCH');    
    strPlateOutputPath = fullfile(strBASIC,cellPlateNames{iPlate},'POSTANALYSIS');
    % Load plat e specific BASICDATA_*.mat file
    cellstrPlateBasicData = SearchTargetFolders(strPlatePath,'BASICDATA_*.mat','rootonly');
    if ~isempty(cellstrPlateBasicData)
        load(cellstrPlateBasicData{1});
    else
        error('%s: could not find BASICDATA_*.mat in %s',mfilename,strPlatePath)
    end    
     
    
    % initialazing the output, 1 x 384
    feature_weights = cell(1,384); 
    cellMahalDistances =  cell(1,384);
    matMeanWellDistanceMahal =  NaN(1,384);

    %%%
    % Object discarding settings
    % 
    structMiscSettings = struct(); 
    structMiscSettings.RegExpImageNamesToInclude = '_[A-P]\d{2,}_';%typical plate well names

    % look for matching SVM file with highest number (could also be newest
    % file by adding third input argin 'newest'
    structMiscSettings.ObjectsToExclude(1).Column = 1;
    structMiscSettings.ObjectsToExclude(1).MeasurementsFileName = 'Measurements_Cells_AreaShape';
    structMiscSettings.ObjectsToExclude(1).ObjectName = 'Cells';
    structMiscSettings.ObjectsToExclude(1).MeasurementName = 'AreaShape';
    structMiscSettings.ObjectsToExclude(1).ValueToKeepMethodString = '<16000';
    
    structMiscSettings.ObjectsToExclude(2).Column = 1;
    structMiscSettings.ObjectsToExclude(2).MeasurementsFileName = 'Measurements_Cells_BorderCells';
    structMiscSettings.ObjectsToExclude(2).ObjectName = 'Cells';
    structMiscSettings.ObjectsToExclude(2).MeasurementName = 'BorderCells';
    structMiscSettings.ObjectsToExclude(2).ValueToKeep = 0;
     
    iSvmCounter = 2;
     
    for iSVM = 1:size(cellstrListOfSvmsAndValuesToKeep,1)
        [strSvmMeasurementName] = search_latest_svm_file(strPlatePath, cellstrListOfSvmsAndValuesToKeep{iSVM,1});
        if ~isempty(strSvmMeasurementName)
            iSvmCounter = iSvmCounter + 1;
            structMiscSettings.ObjectsToExclude(iSvmCounter).Column = 1;
            structMiscSettings.ObjectsToExclude(iSvmCounter).MeasurementsFileName = ['Measurements_SVM_',strSvmMeasurementName,'.mat'];
            structMiscSettings.ObjectsToExclude(iSvmCounter).ObjectName = 'SVM';
            structMiscSettings.ObjectsToExclude(iSvmCounter).MeasurementName = strSvmMeasurementName;
            structMiscSettings.ObjectsToExclude(iSvmCounter).ValueToKeep = cellstrListOfSvmsAndValuesToKeep{iSVM,2};
        end
    end
    %%%
    
    %generate cell arrays per well per plate
    [feature_vector,meta_feature_vector,plate_feature_vector_names,matObjectCountPerImage] = createFeatureVector(strPlatePath,file_names,structMiscSettings);
    
    
    % let's see how the features correlate
    correlation = corr(feature_vector);
    figure()
    image_correlation = imagesc(correlation);
    gcf2pdf(strPlateOutputPath,['Correlation_Population_',strObjectName,strFeatureName]);


    % let's see what the partial correlation is
    [matWeights, matDirectionality, matPartialVariances] = GGM(feature_vector(1:10:end,:));
    figure()
    image_Partialcorrelation = imagesc(matWeights);
    gcf2pdf(strPlateOutputPath,['PartialCorrelation_Population',strObjectName,strFeatureName]);

%     %zscore the feature vector
%     zscorefeature_vector = zscore((feature_vector));
    %PCA
    % let's do PCA on zscored classification results. the tsquare is the
    % mahalanobis distance
    [COEFF,SCORE,latent,tsquare] = princomp(zscore(feature_vector));

    % percentage variation explained for each classification
    figure()
    PCA = pareto(latent / sum(latent));
    gcf2pdf(strPlateOutputPath,['Pareto_Population',strObjectName,strFeatureName]);

    
%     %Measure the Mahanobis distance from each cell to the total
%     %distribution
%     matMahalanobis = mahal(feature_vector,feature_vector);

    %check the distribution of the Mahanobis distances
    figure()
    hist(tsquare,10000)
    gcf2pdf(strPlateOutputPath,['HistogramComplete_Population',strObjectName,strFeatureName]);
    
    figure()
    hold on
    x = min(tsquare):1:350
    hist(tsquare,x)
    axis([0 350 0 25000])
    ylabel('fraction of total cells')
    xlabel(['Mahalanobis_',strObjectName,strFeatureName])
    hold off
    gcf2pdf(strPlateOutputPath,['HistogramHR_Population',strObjectName,strFeatureName]);
    
    
   
    for iWell=1:384
        % get all single cell non targeting measurements        
        matCurrentWellCellIX = ismember(meta_feature_vector(:,2),BASICDATA.ImageIndices{iWell});
        %matGene = feature_vector(matCurrentWellCellIX,:);
        matGeneMahanobis = tsquare(matCurrentWellCellIX,:);

        % Average Mahalanobis distance can be used to determine the average distance of the well to the control well 
        matQuantileWellDistanceMahal(1,iWell) = quantile(matGeneMahanobis,0.9);
    end
    
    %%%%%
    %Add well measurment as Measurment_Well_*
    %Check if the Well order in this measurment is the same as the well
    %order of the previous measurments
    cellstrPlateBasicData = SearchTargetFolders(strPlatePath,'Measurements_Well_GeneName*.mat','rootonly');
    if ~isempty(cellstrPlateBasicData)
        load(cellstrPlateBasicData{1});
        if  ~cellfun(@isequal,handles.Measurements.Well.GeneName,BASICDATA.GeneData')
            error('Well order is not the same as the previous Well Measurments')
        end
    else
            % save well measurment with geneName information
            handles = struct();
            handles.Measurements.Well.GeneName = [];
            handles.Measurements.Well.GeneName = BASICDATA.GeneData';
            strOutputFileName = fullfile(strPlatePath,['Measurements_Well_GeneName','.mat']);
            fprintf('%s: storing %s\n',mfilename,strOutputFileName)
            save(strOutputFileName,'handles')

            %save well measurment with geneID information
            handles = struct();
            handles.Measurements.Well.GeneID = [];
            handles.Measurements.Well.GeneID = BASICDATA.GeneID';
            strOutputFileName = fullfile(strPlatePath,['Measurements_Well_GeneID','.mat']);
            fprintf('%s: storing %s\n',mfilename,strOutputFileName)
            save(strOutputFileName,'handles')

            %save well measurment with Well Name information
            handles = struct();
            handles.Measurements.Well.Number = [];
            handles.Measurements.Well.Number(:,1) = BASICDATA.WellRow'
            handles.Measurements.Well.Number(:,2) = BASICDATA.WellCol';
            strOutputFileName = fullfile(strPlatePath,['Measurements_Well_WellName','.mat']);
            fprintf('%s: storing %s\n',mfilename,strOutputFileName)
            save(strOutputFileName,'handles')
      
    end
   
        
     %save Mean Mahalanobis distances per well
     handles = struct();
     handles.Measurements.Well.(['MahalDistanceTotalCellQuantilePopulation',strFeatureName]) = [];
     handles.Measurements.Well.(['MahalDistanceTotalCellQuantilePopulation',strFeatureName]) = matQuantileWellDistanceMahal';
     handles.Measurements.Well.(['MahalDistanceTotalCellQuantilePopulation',strFeatureName,'Features']) = {'QuantileMahalanobis_distance_from_AllGenes'};
     strOutputFileName = fullfile(strPlatePath,['Measurements_Well_MahalDistanceTotalCellQuantilePopulation',strFeatureName,'.mat']);
     fprintf('%s: storing %s\n',mfilename,strOutputFileName)
     save(strOutputFileName,'handles')
     
   
    
    % Also store as single cell measurement the Mahalanobis distance for
    % each cell from the non_targeting cells
    fprintf('%s: creating data for storing measurement\n',mfilename)
    %matMahalMeasurements = cell2mat(cellMahalDistances(~cellfun(@isempty,cellMahalDistances))');
    
    % init handles for storing
    handles = struct();
    handles.Measurements.(strObjectName).(['MahalDistanceTotPopulation',strFeatureName]) = [];
    handles.Measurements.(strObjectName).(['MahalDistanceTotPopulation',strFeatureName]) = createMeasurement(meta_feature_vector,tsquare,matObjectCountPerImage);
    handles.Measurements.(strObjectName).(['MahalDistanceTotPopulation',strFeatureName,'Features']) = {'Mahalanobis_distance_from_Tot'};
    strOutputFileName = fullfile(strPlatePath,['Measurements_',strObjectName,'_MahalDistanceTotPopulation',strFeatureName,'.mat']);
    fprintf('%s: storing %s\n',mfilename,strOutputFileName)
    save(strOutputFileName,'handles')
    %%%%%%%%
    


end

