
function CreateMeanMeasurmentWell_forChildren(strBASIC)
%Load project directory   
% strBASIC = '\\nas-biol-imsb-1\share-3-$\Data\Users\Prisca\100402_A431_Macropinocytosis';
strBASIC = npc(strBASIC);

% list of paths to load
cellPlateNames = CPdir(strBASIC);
cellPlateNames = {cellPlateNames([cellPlateNames(:).isdir]).name}';
matHasBATCHDirectory = cellfun(@(x) fileattrib(fullfile(strBASIC, x, 'BATCH')),cellPlateNames);
cellPlateNames(~matHasBATCHDirectory) = [];

%%%%%%%%%%
% Description of which measurements to load

strObjectName = 'Cells';
strFeatureName = '_Children';
%file_names = {['Measurements_',strObjectName,'_Intensity',strFeatureName]};
file_names = {'Measurements_Cells_Children'};

%file_names = {['Measurements_',strObjectName,'_Intensity',strFeatureName],['Measurements_',strObjectName,'_Texture_3',strFeatureName]};
%file_names = {'Measurements_Cells_SumIntensity_OrigGreenLampVesicles.mat'};
%file_names = {'Measurements_Cells_CorrectedMeanIllumination_OrigGreen'};
 %strObjectName = 'Cells';
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
        'Blob',2; ...
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
    cellMeanIntensity = cell(1,384);
    

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
    
%     %get the z' score (value divided by non targeting mean divided by non tegeting standard deviation
%     
%     %get Non Targeting mean and SD
%     % get from meta_feature_vector the rowIX that correspond to
%     % non-targeting cells, and put all matNonTargeting
%     % 1. ObjectID
%     % 2. Image Number
%     matNonTargetingImageIX = BASICDATA.ImageIndices(strcmpi(BASICDATA.GeneData,'Non-targeting'));
%     matNonTargetingImageIX = cat(1,matNonTargetingImageIX{:});
%     matNonTargetingCellIX = ismember(meta_feature_vector(:,2),matNonTargetingImageIX);
%     % get all single cell non targeting measurements
%     matNonTargeting = feature_vector(matNonTargetingCellIX,:);
%     matAverageNonTargeting = nanmean(matNonTargeting);
%     matSDNonTargeting = nanstd(matNonTargeting);
%     matSDNonTargeting0 = matSDNonTargeting;
%     matSDNonTargeting0(matSDNonTargeting0==0) = 1;
%     
%     %calculate the z'value
%     matPlateIntensity_zprime = bsxfun(@minus,feature_vector, matAverageNonTargeting);
%     matPlateIntensity_zprime = bsxfun(@rdivide, matPlateIntensity_zprime, matSDNonTargeting0);
    
    
    
    
    
%     %zscore measurment per plate
     matPlateIntensity_zscore = nanzscore(feature_vector);
%     
    for iWell=1:384
         
        if mod(iWell,38)==0
            fprintf(' %d%%',round(100*(iWell/384)))
        end
        
        % get all single cell per gene      
        matCurrentWellCellIX = ismember(meta_feature_vector(:,2),BASICDATA.ImageIndices{iWell});
        %use the z'prime value
        mateGene = matPlateIntensity_zscore(matCurrentWellCellIX,:);
        %use the zscored value
        %mateGene = matPlateIntensity_zscore(matCurrentWellCellIX,:);
        %use the raw data
        %mateGene = feature_vector(matCurrentWellCellIX,:);
        
        % Average per well all measurments
        cellMeanIntensity{1,iWell} = mean(mateGene,1);
         
    end
    

    % make newline
    fprintf('\n')
    
 
    
    %%%%%
    %Add well measurment as Measurment_Well_*
    
       

    %Check if the Well order in this measurment is the same as the well
    %order of the previous measurments
    cellstrPlateBasicData = SearchTargetFolders(strPlatePath,'Measurements_Well_GeneName*.mat','rootonly');
    if ~isempty(cellstrPlateBasicData)
        load(cellstrPlateBasicData{1});
        if  ~isequal(handles.Measurements.Well.GeneName,BASICDATA.GeneData')
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
   
        
        %save Mean Intensity per well
    handles = struct();
    handles.Measurements.Well.(['Children',strObjectName]) = [];
    handles.Measurements.Well.(['Children',strObjectName]) = cellMeanIntensity';
    handles.Measurements.Well.(['Children',strObjectName,'Features']) = plate_feature_vector_names;
    %strOutputFileName = fullfile(strPlatePath,['Measurements_Well_MeanVesiclesIntensity',strFeatureName,strObjectName,'.mat']);
    strOutputFileName = fullfile(strPlatePath,['Measurements_Well_Children','.mat']);

    fprintf('%s: storing %s\n',mfilename,strOutputFileName)
    save(strOutputFileName,'handles')
     
    
    %%%%%%%%
    


end

