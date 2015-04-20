function constructTensorFromTrainingDataValues(strDataPath, settings)

    if nargin == 0
%         strDataPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\50K_checkers\060118_EV1_Kyo_CB\BATCH\';
%         strDataPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\061102_MHV_KY_GFP_50K_GFP_P1_1\';
        strDataPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\DV_KY\070902_50K_DV_KY_1_1_3\';
    end

    %%% WHICH COLUMNS TO USE FOR EACH MEASUREMENT, TRANSPOSE DATA, RAW
    %%% MEASUREMENT FILE NAMES, NUMBER OF BINS, ETC... 
    if nargin < 2
%         disp('reading settings')
        [structDataColumnsToUse, structMiscSettings] = initStructDataColumnsToUse();
    else
%         disp('getting settings as input param')        
        structDataColumnsToUse = settings.structDataColumnsToUse;
        structMiscSettings = settings.structMiscSettings;        
    end    
    
    % fullfile(cellstrTargetFolderList{i},'ProbModel_TrainingDataValues.mat')
    load(fullfile(strDataPath,'ProbModel_TrainingDataValues.mat'))
    
    
    
    %%% CHECK IF TENSOR IS ALREADY PRESENT AND HAS THE SAME SETTINGS AS THE
    %%% NEW SETTINGS
    [boolTensorFilePresent] = fileattrib(fullfile(strDataPath,'ProbModel_Tensor.mat'));
    if boolTensorFilePresent
        AlreadyPresentTensor = load(fullfile(strDataPath,'ProbModel_Tensor.mat'));
        AlreadyPresentTensor = AlreadyPresentTensor.Tensor;
        
        if isfield(AlreadyPresentTensor, 'settings')
            oldSettings = AlreadyPresentTensor.settings;
            
            newSettings = struct();
            newSettings.structMiscSettings = structMiscSettings;
            newSettings.structDataColumnsToUse = structDataColumnsToUse;
            
            if ~isequal(oldSettings, newSettings)
                disp('   old settings do not match new settings. reconstructing tensor')
            else
                disp('   old settings match new settings. skipping tensor reconstruction')                
                return
            end
        else
            disp('   old tensor file did not contain settings field. reconstructing tensor')            
        end
    end    
    
    matBinSizes = [];
    matStepSizes = [];    
    matOriginalTrainingData = uint8([]);

    DataFieldNames = {};

    tempDataFieldNames = fieldnames(TrainingData)';
    
    % remove settings from being merged...
    tempDataFieldNames(strcmp(tempDataFieldNames, 'settings')) = [];

    for ii = 1:length(tempDataFieldNames)
        if isempty(strfind(tempDataFieldNames{ii},'MetaData'))
            % IF INDEPENDENT COLUMNS IS SET THEN THE BINSIZES ARE NOT THE
            % NUMBER OF BINS (m) BUT A MATRIX OF 2's OF SIZE 1xm...
            if TrainingData.(tempDataFieldNames{ii}).IndependentColumns
                matBinSizes = [matBinSizes,repmat(2,1,TrainingData.(tempDataFieldNames{ii}).Bins)];
                matStepSizes = [matStepSizes,repmat(2,1,TrainingData.(tempDataFieldNames{ii}).StepSize)];
                % add per column datafieldnames...
                for iii = 1:TrainingData.(tempDataFieldNames{ii}).Bins
                    DataFieldNames = [DataFieldNames,[char(tempDataFieldNames{ii}),'_',num2str(iii)]];
                end
            else
                matBinSizes = [matBinSizes,TrainingData.(tempDataFieldNames{ii}).Bins];
                matStepSizes = [matStepSizes,TrainingData.(tempDataFieldNames{ii}).StepSize];                
                DataFieldNames = [DataFieldNames,tempDataFieldNames{ii}];                
            end
            
            try
                matOriginalTrainingData = [matOriginalTrainingData,uint8(TrainingData.(tempDataFieldNames{ii}).Data)];
            catch
                strDataPath
                size(matOriginalTrainingData)
                size(TrainingData.(tempDataFieldNames{ii}).Data)
                rethrow(lasterror)
            end
            
            
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% HERE, DISCARD ANY TRAININGDATA ROWS WITH THE VALUE 0 IN IT, THESE
    %%% ARE NUCLEI WITH NaNs/INFs (uint8 CONVERTED) OR VALUES OUTSIDE THE
    %%% BIN EDGES! 
    disp(sprintf('discarding %d individual cells with NaNs or INFs or 0s from training- & metadata',sum(any(matOriginalTrainingData==0,2))))
    matOriginalTrainingData(any(matOriginalTrainingData==0,2),:)=[];
    TrainingData.MetaData(any(matOriginalTrainingData==0,2),:)=[];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    DataTypeCount = length(DataFieldNames);
    
% % %     %%% EXPLICIT INTEGRITY CHECK OF TRAININGDATA
% % %     for i = 1:length(matBinSizes)
% % %         matDataColumnValues = unique(matOriginalTrainingData(:,i));
% % %         disp([min(matDataColumnValues(:)), max(matDataColumnValues(:)), matBinSizes(i)])
% % %         if ~(min(matDataColumnValues(:)) >= 1) || ~(max(matDataColumnValues(:)) <= matBinSizes(i))
% % %             error('training data failed to pass explicit integrity check...')
% % %         end
% % %     end
    

    %%% TAKE RANDOM 1/100th SUBSET OF TRAININGDATA
%     if nargin == 0
%         intNumOfRows = size(matTrainingData,1)
%         matRowIndices = randperm(intNumOfRows);
%         matRowIndices = matRowIndices(1:round(intNumOfRows/100));
%         matTrainingData = matTrainingData(matRowIndices,:);
%         size(matTrainingData,1)
% %         pause(2)
%     end
	
    matAllPossibleCombinations = uint8(all_possible_combinations2(matBinSizes(2:end)));
%     matAllPresentCombinations = uint8(all_possible_combinations2(matBinSizes(2:end)));
    
    

    
    
    %%% DISPLAY ALL POSSIBLE DIMENSION VALUES AND ALL PRESENT DIMENSION
    %%% VALUES
%     for i = 1:size(matAllPossibleCombinations,2)
%         disp(unique(matAllPossibleCombinations(:,i))')
%     end
%     
%     for i = 1:size(matAllPresentCombinations,2)
%         disp(unique(matAllPresentCombinations(:,i))')
%     end

    tic

    matClassInfectedCells = zeros(size(matAllPossibleCombinations,1),1);
    matClassTotalCells = zeros(size(matAllPossibleCombinations,1),1);
    % will contain mean readouts for intensity measurements, etc.
    matClassMeanReadout = zeros(size(matAllPossibleCombinations,1),1);
            
    intStepSize = 40000;%optimal for 1500(?)
    intNumOfSteps = round(size(matOriginalTrainingData,1)/intStepSize)+1;
    intNumOfRows = size(matOriginalTrainingData,1);

    matTimeSteps = 0;
    intLastTimeStep = 0;
    for j = 0:intNumOfSteps
        
%%% DISPLAY TIME ESTIMATION        
% % %         if j>0;intLastTimeStep = matTimeSteps(j);end
% % %         matTimeSteps(j+1) = toc;
% % %         disp(sprintf('  step %d of %d - %.1fs',j,intNumOfSteps,matTimeSteps(j+1)-intLastTimeStep))
% % %         if mod(j,10)==1
% % %             disp(sprintf('  estimated total time %d seconds (~%.1f minutes)',round(intNumOfSteps*median(diff(matTimeSteps))), intNumOfSteps*median(diff(matTimeSteps))/60 ))
% % %         end
        
        if (intStepSize+(j*intStepSize)) > intNumOfRows
            matDataRange = [1+(j*intStepSize):intNumOfRows];
        else
            matDataRange = [1+(j*intStepSize):intStepSize+(j*intStepSize)];
        end

        matTrainingData = uint8(matOriginalTrainingData(matDataRange,:));
        matAllPresentCombinationsInCycle = uint8(unique(matTrainingData(:,2:end),'rows'));

        for ii = 1:size(matAllPresentCombinationsInCycle,1)
            
            matCurrentClassInfected = repmat([2,matAllPresentCombinationsInCycle(ii,:)],size(matTrainingData,1),1);
            matCurrentClassUninfected = repmat([1,matAllPresentCombinationsInCycle(ii,:)],size(matTrainingData,1),1);
            matCurrentClassAll = repmat(matAllPresentCombinationsInCycle(ii,:),size(matTrainingData,1),1);

            % matching all but first column of trainingdata
            [matAllCurrentRowIndices, foo] = find(sum(matTrainingData(:,2:end) == matCurrentClassAll,2) == size(matCurrentClassAll,2));
            
            % matching first column to 2 (infected)
            [matInfectedRowIndices, foo] = find(sum(matTrainingData == matCurrentClassInfected,2) == size(matCurrentClassInfected,2));
            % matching first column to 1 (non-infected)            
            [matUninfectedRowIndices, foo] = find(sum(matTrainingData == matCurrentClassUninfected,2) == size(matCurrentClassInfected,2));

            intTotalCells = length(matAllCurrentRowIndices);            
            intInfected = length(matInfectedRowIndices);
            intUninfected = length(matUninfectedRowIndices);
            
%             if intTotalCells ~= (intInfected+intUninfected)
%                disp('this looks like a intensity readout, not binary readout') 
%             end

            %%% LOOK FOR ROW IN TENSOR THAT MATCHES ALL CURRENT CRITERIA (DIMENSIONS)
            [intCurRow, foo] = find(sum(matAllPossibleCombinations == repmat(matAllPresentCombinationsInCycle(ii,:),size(matAllPossibleCombinations,1),1),2) == size(matAllPresentCombinationsInCycle,2));

            % IF READOUT IS NOT BINARY, LIKE INFECTION, CALCULATE THE MEAN
            % READOUT VALUE, I.E. FOR INTENSITY READOUTS
            if matBinSizes(1,1)>2
                if matClassTotalCells(intCurRow,1) == 0
                    matClassMeanReadout(intCurRow,1) = nanmean(matTrainingData(matAllCurrentRowIndices,1));
                else
                    matClassMeanReadout(intCurRow,1) = ((matClassMeanReadout(intCurRow,1) * matClassTotalCells(intCurRow,1)) + ...
                                                        nansum(matTrainingData(matAllCurrentRowIndices,1))) / ...
                                                        (length(matAllCurrentRowIndices) + matClassTotalCells(intCurRow,1));
                end
            end

            matClassInfectedCells(intCurRow,1) = matClassInfectedCells(intCurRow,1) + intInfected;
            matClassTotalCells(intCurRow,1) = matClassTotalCells(intCurRow,1) + intTotalCells;

            % remove processed cells from matTrainingData
            matTrainingData(matAllCurrentRowIndices,:) = [];            
        end
        
        if ~(isempty(matTrainingData))
            disp('***ALERT MATTRAININGDATA IS NOT EMPTY!')
            disp(sprintf('number of unclassifyable objects: %d',size(matTrainingData,1)))
            disp(unique(matTrainingData,'rows'))            
        end

    end %for j

%     if nargin==0
        disp('      ***TENSOR CONSTRUCTION RESULTS***')
        disp(sprintf('      data path: %s',strDataPath))        
        disp(sprintf('      duration: %d seconds = %d minutes',round(toc),round(toc/60)))
        disp(sprintf('      total cells in training data: %d',intNumOfRows))
        disp(sprintf('      total cells in tensor: %d',sum(matClassTotalCells(:))))
        disp(sprintf('      data step size: %d',intStepSize))
%     end
    
    matClassInfectionIndex = matClassInfectedCells ./ matClassTotalCells;
    
    Tensor = struct();
    
    Tensor.Oligo = NaN;
    Tensor.TrainingData = matOriginalTrainingData;
    Tensor.MetaData = TrainingData.MetaData;
    Tensor.MetaDataFeatures = TrainingData.MetaDataFeatures;    
    Tensor.DataPath = strDataPath;
    
    intOligoNumber = Oligo_logic(strDataPath);
    Tensor.Oligo = intOligoNumber;
    
    Tensor.TotalCells = matClassTotalCells;
    Tensor.InfectedCells = matClassInfectedCells;    
    Tensor.InfectionIndex = matClassInfectionIndex;
    Tensor.MeanReadout = matClassMeanReadout;
    if matBinSizes(1,1)>2
        Tensor.InfectionIndex = matClassMeanReadout;
        Tensor.InfectedCells = matClassTotalCells;        
        disp('  (NOTE: overwriting InfectionIndex with MeanReadouts, and InfectedCells with TotalCells!)')
    end
    
    Tensor.Indices = matAllPossibleCombinations;
	Tensor.Features = DataFieldNames;
    Tensor.BinSizes = matBinSizes;
    Tensor.StepSizes = matStepSizes;
    
    Tensor.settings.structMiscSettings = structMiscSettings;
    Tensor.settings.structDataColumnsToUse = structDataColumnsToUse;
    
    disp(sprintf('  saved %s',fullfile(strDataPath,'ProbModel_Tensor.mat')))
    save(fullfile(strDataPath,'ProbModel_Tensor.mat'),'Tensor')

end