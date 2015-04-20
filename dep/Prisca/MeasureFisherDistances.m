function MeasureFisherDistances(strBASIC)

%Load project directory   
% strBASIC = '\\nas-biol-imsb-1\share-3-$\Data\Users\Prisca\091127_A431_Chtx_Golgi_AcidWash';
strBASIC = npc(strBASIC);

% list of paths to load
cellPlateNames = CPdir(strBASIC);
cellPlateNames = {cellPlateNames([cellPlateNames(:).isdir]).name}';
matHasBATCHDirectory = cellfun(@(x) fileattrib2(fullfile(strBASIC, x, 'BATCH')),cellPlateNames);
cellPlateNames(~matHasBATCHDirectory) = [];

%%%%%%%%%%
% Description of which measurements to load

strObjectName = 'Cells';
strFeatureName = '_OrigGreen';
% file_names = {['Measurements_',strObjectName,'_Intensity',strFeatureName],['Measurements_',strObjectName,'_Texture_3',strFeatureName]};
file_names = {['Measurements_',strObjectName,'_Intensity',strFeatureName],['Measurements_',strObjectName,'_Texture_3',strFeatureName]};

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
    };

for iPlate = 1:size(cellPlateNames,1)

    % current plate path
    strPlatePath = fullfile(strBASIC,cellPlateNames{iPlate},'BATCH');    

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
    structMiscSettings.ObjectsToExclude(1).ValueToKeepMethodString = '<18000';
    
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
    
    % get from meta_feature_vector the rowIX that correspond to
    % non-targeting cells, and put all matNonTargeting
    % 1. ObjectID
    % 2. Image Number
    matNonTargetingImageIX = BASICDATA.ImageIndices(strcmpi(BASICDATA.GeneData,'Non-targeting'));
    matNonTargetingImageIX = cat(1,matNonTargetingImageIX{:});
    matNonTargetingCellIX = ismember(meta_feature_vector(:,2),matNonTargetingImageIX);
    % get all single cell non targeting measurements
    matNonTargeting = feature_vector(matNonTargetingCellIX,:);

    % turn off this warning...
    s = warning('off', 'all');
    
    fprintf('%s: starting single cell measurements: ',mfilename)
    
    % loop over all BASICDATA.GeneID indices that have a non-empty and
    % numerical gene id, this indicates siRNA.
    for iWell=1:384
         
        if mod(iWell,38)==0
            fprintf(' %d%%',round(100*(iWell/384)))
        end

        % get all single cell non targeting measurements        
        matCurrentWellCellIX = ismember(meta_feature_vector(:,2),BASICDATA.ImageIndices{iWell});
        matGene = feature_vector(matCurrentWellCellIX,:);

         if ~isnan(matGene) & ~isempty(matGene)
             
             %Create a Non targeting sample as big as the siRNA sample
             A=false(size(matNonTargeting,1),1);
             rp=randperm(size(matNonTargeting,1));
             A(rp(1:size(matGene,1)))=true;
             TempmatNonTargeting=matNonTargeting(A,:)';

             matGene = matGene';
             
             % Creating data for the Fisher's linear discriminant
             %tempmatNonTargeting = matNonTargeting(size(matGene,1))
             data.X=[TempmatNonTargeting matGene]; % Datamatrix: totcells (Nontargeting+Gene), each with all features
             data.y=[1*ones(1,size(TempmatNonTargeting,2)) 2*ones(1,size(matGene,2))]; % Label vector: first cells are from control, next cells from an siRNA well

             % actual Fisher's linear discriminant analysis (using the stprtool toolbox)
             model=fld(data); 

             
             %Fisher's weigths = importance of each feature for the separation
             feature_weights{1,iWell}=model.W; 

             % Mahalanobis distance vector: each siRNA well cell's distance to the control population
             % This can be used to determine which individual CELLS are not encountered in control wells
             cellMahalDistances{1,iWell} = mahal(matGene',feature_vector);

             % Average Mahalanobis distance can be used to determine the average distance of the well to the control well 
             matMeanWellDistanceMahal(1,iWell) = mean(cellMahalDistances{1,iWell});

         end 
    end
    % make newline
    fprintf('\n')
    
    % put back original warning state
    warning(s)
    
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
   
        
%     %save Mean Mahalanobis distances per well
%     handles = struct();
%     handles.Measurements.Well.(['MahalDistanceTotalCell',strFeatureName]) = [];
%     handles.Measurements.Well.(['MahalDistanceTotalCell',strFeatureName]) = matMeanWellDistanceMahal';
%     handles.Measurements.Well.(['MahalDistanceTotalCell',strFeatureName,'Features']) = {'Mahalanobis_distance_from_AllGenes'};
%     strOutputFileName = fullfile(strPlatePath,['Measurements_Well_MahalDistanceTotalCell',strFeatureName,'.mat']);
%     fprintf('%s: storing %s\n',mfilename,strOutputFileName)
%     save(strOutputFileName,'handles')
     
    %save Mean Mahalanobis distances per well
    handles = struct();
    handles.Measurements.Well.(['MahalDistanceTot',strFeatureName]) = [];
    handles.Measurements.Well.(['MahalDistanceTot',strFeatureName]) = matMeanWellDistanceMahal';
    handles.Measurements.Well.(['MahalDistanceTot',strFeatureName,'Features']) = {'Mahalanobis_distance_from_AllGenes'};
    strOutputFileName = fullfile(strPlatePath,['Measurements_Well_MahalDistanceTot',strFeatureName,'.mat']);
    fprintf('%s: storing %s\n',mfilename,strOutputFileName)
    save(strOutputFileName,'handles')
    
    
    %save Fisher Linear Disciminant per well
    handles = struct();
    handles.Measurements.Well.(['FisherLDWeight',strFeatureName]) = [];
    handles.Measurements.Well.(['FisherLDWeight',strFeatureName]) = feature_weights';
    handles.Measurements.Well.(['FisherLDWeight',strFeatureName,'Features']) = plate_feature_vector_names;
    strOutputFileName = fullfile(strPlatePath,['Measurements_Well_FisherLDWeight',strFeatureName,'.mat']);
    fprintf('%s: storing %s\n',mfilename,strOutputFileName)
    save(strOutputFileName,'handles')
    
%     %%%%%%%%
%     % Add well measurements to BASICDATA_*.mat
%     cellstrPlateBasicData = SearchTargetFolders(strPlatePath,'BASICDATA_*.mat','rootonly');
%     if ~isempty(cellstrPlateBasicData)
%         load(cellstrPlateBasicData{1});
%     else
%         error('%s: could not find BASICDATA_*.mat in %s',mfilename,strPlatePath)
%     end
%     % add well measurements to BASICDATA
%     if isfield(BASICDATA,['FisherLDWeight_',strObjectName,strFeatureName]) || isfield(BASICDATA,['FisherLDWeight_',strObjectName,strFeatureName])
%         warning('bs:Bla','%s: overwriting fields MeanMahal%s and FisherLDWeight%s',mfilename,strFeatureName,strFeatureName)
%     end
%     BASICDATA.(['FisherLDWeight_',strObjectName,strFeatureName]) = feature_weights(1,:);
%     BASICDATA.(['MeanMahal_',strObjectName,strFeatureName]) = matMeanWellDistanceMahal(1,:);
%     
%     % cleaning up old measurements...
%     if isfield(BASICDATA,'FisherLDWeight')
%         fprintf('%s: removing old FisherLDWeight field\n',mfilename)
%         BASICDATA = rmfield(BASICDATA,'FisherLDWeight');
%     end
%     if isfield(BASICDATA,'MeanMahal')
%         fprintf('%s: removing old MeanMahal field\n',mfilename)
%         BASICDATA = rmfield(BASICDATA,'MeanMahal');
%     end
%     
%     % overwrite BASICDATA_*.mat file
%     fprintf('%s: storing %s with extra fields\n',mfilename,cellstrPlateBasicData{1})
%     save(cellstrPlateBasicData{1},'BASICDATA');
%     %%%%%%%%
%     
    %%%%%%%%
    % Also store as single cell measurement the Mahalanobis distance for
    % each cell from the non_targeting cells
%     fprintf('%s: creating data for storing measurement\n',mfilename)
%     matMahalMeasurements = cell2mat(cellMahalDistances(~cellfun(@isempty,cellMahalDistances))');
%     
%     % init handles for storing
%     handles = struct();
%     handles.Measurements.(strObjectName).(['MahalDistance',strFeatureName]) = [];
%     handles.Measurements.(strObjectName).(['MahalDistance',strFeatureName]) = createMeasurement(meta_feature_vector,matMahalMeasurements,matObjectCountPerImage);
%     handles.Measurements.(strObjectName).(['MahalDistance',strFeatureName,'Features']) = {'Mahalanobis_distance_from_Non_Targeting'};
%     strOutputFileName = fullfile(strPlatePath,['Measurements_',strObjectName,'_MahalDistance',strFeatureName,'.mat']);
%     fprintf('%s: storing %s\n',mfilename,strOutputFileName)
%     save(strOutputFileName,'handles')
%     %%%%%% %%
    
    % Also store as single cell measurement the Mahalanobis distance for
    % each cell from the non_targeting cells
    fprintf('%s: creating data for storing measurement\n',mfilename)
    matMahalMeasurements = cell2mat(cellMahalDistances(~cellfun(@isempty,cellMahalDistances))');
    
    % init handles for storing
    handles = struct();
    handles.Measurements.(strObjectName).(['MahalDistanceTot',strFeatureName]) = [];
    handles.Measurements.(strObjectName).(['MahalDistanceTot',strFeatureName]) = createMeasurement(meta_feature_vector,matMahalMeasurements,matObjectCountPerImage);
    handles.Measurements.(strObjectName).(['MahalDistanceTot',strFeatureName,'Features']) = {'Mahalanobis_distance_from_Tot'};
    strOutputFileName = fullfile(strPlatePath,['Measurements_',strObjectName,'_MahalDistanceTot',strFeatureName,'.mat']);
    fprintf('%s: storing %s\n',mfilename,strOutputFileName)
    save(strOutputFileName,'handles')
    %%%%%%%%
    


end

