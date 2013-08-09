function mainTensorModel_glmfit_probit(strRootPath, strSettingsFile)

if nargin==0
% strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\50K_copy\DV_KY2\';
% strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\50K_copy\MHV_KY\';
% strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\50K_copy\RV_KY_2\';
% strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\50K_copy\SV40_MZ\';
    strRootPath = 'Z:\Data\Users\Manuel\iBRAIN_VSV_Subscreen\';
    
end

if nargin < 1
%     strSettingsFile = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\50K_copy\ProbModel_Settings.txt';
%     strSettingsFile = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\50K_copy\ProbModel_Settings_ClassicalInfection.txt';
%     strSettingsFile = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\50K_copy\ProbModel_Settings_SVMInfection_MHVselection.txt';
%     strSettingsFile = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\50K_copy\ProbModel_Settings_SVMInfection_MHVselection_classicalinfection.txt';
%     strSettingsFile = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\EvaBerend\081117_MCF10A_SV40_ChTxBup_pFAK\081117_MCF10A_SV40_ChTxBup_pFAK\ProbModel_Settings_Probit.txt';
%     strSettingsFile = '\\nas-biol-imsb-1\share-3-$\Data\Users\50K_final_reanalysis\ProbModel_Settings.txt';
    strSettingsFile = 'Z:\Data\Users\Manuel\iBRAIN_VSV_Subscreen\ProbModel_Settings.txt';
end

% run paths trough the nas-path converter function (npc)
strRootPath = npc(strRootPath);
strSettingsFile = npc(strSettingsFile);

%%% LOOK FOR ALL FOLDERS BELOW TARGETFOLDER THAT CONTAIN TARGET FILE
disp(sprintf('%s: checking target folders',mfilename))
cellstrTargetFolderList = SearchTargetFolders(strRootPath,'Measurements_Image_FileNames.mat');
% remove filename from TargetFolders
cellstrTargetFolderList = getbasedir(cellstrTargetFolderList);

intNumOfFolders = length(cellstrTargetFolderList);
disp(sprintf('%s: found %d target folders',mfilename,intNumOfFolders))

%%% IF NO TARGET FOLDERS ARE FOUND, QUIT
if intNumOfFolders==0
    return
end

%%% GET SETTINGS FROM initStructDataColumnsToUse.m AND PASS THIS TO ALL
%%% DOWNSTREAM FUNCTIONS
disp(sprintf('%s: checking model settings',mfilename))
settings = struct();
[settings.structDataColumnsToUse, settings.structMiscSettings] = initStructDataColumnsToUse(strSettingsFile);


%%% ADD MODEL SPECIFIC MEASUREMENTS, LIKE A OUT-OF-FOCUS IMAGE CORRECTED
%%% TOTAL CELL NUMBER AND TOTAL INFECTED NUMBER PER WELL. ALL FUNCTIONS
%%% SHOULD SKIP IF THE MEASUREMENT IS ALREADY PRESENT.
disp(sprintf('%s: adding tensor specific data structures',mfilename))
for i = 1:intNumOfFolders
        addTotalCellNumberMeasurement(cellstrTargetFolderList{i});
%         addAverageTotalCellNumberPerImagePerWell(cellstrTargetFolderList{i});   
%         addTotalInfectedMeasurement(cellstrTargetFolderList{i});
%         addCellTypeClassificationPerColumn(cellstrTargetFolderList{i})
        addFakeCellTypeClassificationPerColumn(cellstrTargetFolderList{i})
        addGridNucleiCountCorrected(cellstrTargetFolderList{i})
%     catch
%         cellstrTargetFolderList{i}
%         rethrow(lasterror)
%     end
end

%%% SIMPLE BINNING OPTIMIZATION: LOOK FOR MINIMA AND MAXIMA PER PLATE PER DIMENSION
disp(sprintf('%s: checking data distributions',mfilename))
for i = 1:intNumOfFolders
    createTrainingDataEdges(cellstrTargetFolderList{i}, settings);
end

%%% SIMPLE BINNING OPTIMIZATION: LOOK FOR MINIMA AND MAXIMA PER DIMENSION
%%% OVER ALL PLATES 
%%% ADDITIONALLY, IF A TRAINING DATASET HAS INTEGER VALUES FOR ANY
%%% DIMENSION, ADJUST THE DIMENSION SIZE SUCH THAT IT HAS NUMOFBINS=(MAX-MIN)+1
disp(sprintf('%s: calculating total data distribution',mfilename))
TrainingData = struct();
for i = 1:intNumOfFolders
    TrainingData = mergeTrainingDataEdges(cellstrTargetFolderList{i}, TrainingData);
end
save(fullfile(strRootPath,'ProbModel_TrainingDataEdges.mat'),'TrainingData')


%%% CLASSIFY PER PLATE ALL THE NUCLEI FOR THE GIVEN DIMENSIONS AND FOR THE
%%% GIVEN BINNING AS FOUND IN strRootPath\ProbModel_TrainingDataEdges.mat
%%% DISCARDING OTHER-CLASS NUCLEI AND OUT-OF-FOCUS IMAGES
disp(sprintf('%s: creating training data',mfilename))
cellBinEdges = {};% take along exact bin edges into final fused tensor, for easy processing.
for i = 1:intNumOfFolders
    [TrainingData, cellCurrentBinEdges] = createTrainingDataValues(cellstrTargetFolderList{i}, strRootPath, settings);
    if isempty(cellBinEdges)
        cellBinEdges = cellCurrentBinEdges;
    elseif ~isequal(cellBinEdges,cellCurrentBinEdges)
        error('%s: bin edges do not match between plates!?',mfilename)
    else
        cellBinEdges = cellCurrentBinEdges;
    end
    clear TrainingData;
end


%%% GENERAL APPROACH, FILL THE TENSOR WITH TOTAL CELL NUMBERS AND TOTAL
%%% INFECTED CELLS PER PLATE FIRST, THEN COMBINE FOR ALL PLATES.

%%% CREATING PER PLATE TCN, INFECTEDCELLS & II TENSORS
disp(sprintf('%s: creating per plate tensor',mfilename))
for i = 1:intNumOfFolders
	constructTensorFromTrainingDataValues(cellstrTargetFolderList{i}, settings)
end

%%% COMBINE TENSORS FROM ALL PLATES
disp(sprintf('%s: merging tensors',mfilename))
TensorContainer = cell(intNumOfFolders,1);
Tensor = struct();
Tensor.TrainingData = uint8([]);
Tensor.MetaData = uint16([]);
Tensor.NumberOfPlates = 0;
Tensor.BinEdges = cellBinEdges;
Tensor.Oligo = [];
Tensor.settings = settings;

for i = 1:intNumOfFolders
    try
        TensorContainer{i} = load(fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat'));
        disp(sprintf('%s: merging %s',mfilename,fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat')))        
    catch
        disp(sprintf('%s: failed to add tensor %s',mfilename,fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat')))
        break
    end
    TensorContainer{i} = TensorContainer{i}.Tensor;

    if TensorContainer{i}.BinSizes(1,1)==2;    
        disp(sprintf('%s: binary readout detected',mfilename))
        % binary readout, recalculate infection index        
        if i==1
            Tensor.TotalCells = TensorContainer{i}.TotalCells;
            Tensor.InfectedCells = TensorContainer{i}.InfectedCells;
        else
            Tensor.TotalCells = Tensor.TotalCells + TensorContainer{i}.TotalCells;
            Tensor.InfectedCells = Tensor.InfectedCells + TensorContainer{i}.InfectedCells;
        end

        Tensor.InfectionIndex = Tensor.InfectedCells ./ Tensor.TotalCells;
    end
    
    if TensorContainer{i}.BinSizes(1,1)>2;
        disp(sprintf('%s: non-binary readout detected',mfilename))        
        % non binary readout (like intensity)
        if i==1
            Tensor.TotalCells = TensorContainer{i}.TotalCells;
            Tensor.InfectedCells = TensorContainer{i}.InfectedCells;
            
            Tensor.InfectionIndex = TensorContainer{i}.InfectionIndex;
        else
            % make it a weighted average (i.e. mean)
            Tensor.InfectionIndex = ((Tensor.TotalCells .* Tensor.InfectionIndex) + ... 
                (TensorContainer{i}.TotalCells .* TensorContainer{i}.InfectionIndex)) ./ ... 
                (Tensor.TotalCells + TensorContainer{i}.TotalCells);
            
            Tensor.TotalCells = Tensor.TotalCells + TensorContainer{i}.TotalCells;
            Tensor.InfectedCells = Tensor.InfectedCells + TensorContainer{i}.InfectedCells;
        end
    end

    
    Tensor.InfectionIndexPerPlate(:,i) = TensorContainer{i}.InfectedCells ./ TensorContainer{i}.TotalCells;    

    if intNumOfFolders == 1
        Tensor.Oligo = TensorContainer{i}.Oligo;
    else
        Tensor.Oligo = [Tensor.Oligo;TensorContainer{i}.Oligo];
    end
    
    Tensor.NumberOfPlates = Tensor.NumberOfPlates + 1;
    Tensor.Indices = TensorContainer{i}.Indices;
    Tensor.BinSizes = TensorContainer{i}.BinSizes;
    Tensor.StepSizes = TensorContainer{i}.StepSizes;    
    Tensor.Features = TensorContainer{i}.Features;        
    Tensor.TrainingData = [Tensor.TrainingData;uint8(TensorContainer{i}.TrainingData)];
    Tensor.MetaData = [Tensor.MetaData;... % add previousmetadata
        uint16([TensorContainer{i}.MetaData, ... % add current plate metadata
        repmat(TensorContainer{i}.Oligo,size(TensorContainer{i}.MetaData,1),1),... % add oligo number
        repmat(i,size(TensorContainer{i}.MetaData,1),1)])]; % add plate number
    Tensor.MetaDataFeatures = [TensorContainer{i}.MetaDataFeatures,{'OligoNumber','PlateNumber'}];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CORRECT FOR DIFFERENCES IN THE PLATE AVERAGE INFECTION INDICES? %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % matAveragePlateII = [];
% % % for i = 1:length(TensorContainer)
% % %     matAveragePlateII(i) = nansum(TensorContainer{i}.InfectedCells) / nansum(TensorContainer{i}.TotalCells);
% % % end
% % % matCorrectionFactors = median(matAveragePlateII) - matAveragePlateII;
% % % Tensor.InfectionIndex = nanmedian(Tensor.InfectionIndexPerPlate + repmat(matCorrectionFactors,size(Tensor.InfectionIndexPerPlate,1),1),2);
% % % Tensor.InfectedCells = round(Tensor.InfectionIndex .* Tensor.TotalCells);
% % % Tensor.InfectedCells(isnan(Tensor.InfectedCells))=0;
% % % Tensor.InfectedCells(Tensor.InfectedCells > Tensor.TotalCells)=Tensor.TotalCells(Tensor.InfectedCells > Tensor.TotalCells);
% % % Tensor.InfectedCells(Tensor.TotalCells == 0)=0;
% % % Tensor.InfectedCells(Tensor.InfectedCells < 0)=0;
% % % Tensor.InfectionIndex(Tensor.InfectionIndex < 0)=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% clear TensorContainer


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% WEIGHTED LEAST-SQUARES REGRESSION %%%

[rowInd,colInd]=find(Tensor.Indices(:,end)+1);
matTensorColumsToUse = find(~cellfun('isempty',Tensor.Features));

intDatapoints = length(rowInd);
Tensor.Model.Description.LinearRegression='BINOMIAL DISTRIBUTION, PROBIT REGRESSION';

Tensor.Model.Description.X='Binned';
X = double(Tensor.Indices);
% MOVE ALL BIN POSITIONS ONE BACK, SUCH THAT 1,2 BECOMES 0,1, ETC...
X = X - 1; 
% ADD FIRST COLUMN WITH 1s FOR FITTING
X = [ones(intDatapoints,1),X]; 

% Y MATRIX IS THE MODEL OUTPUT, I.E. INFECTION INDEX
Tensor.Model.Description.Y='Infected cells per bin (pooled over all plates)';
% Y = Tensor.InfectionIndex;
Y = Tensor.InfectedCells; % total number of infected cells!
n = Tensor.TotalCells; % total number of cells

% Note, remove bins with no cells (this might have unknown downstream
% consequences....) 
% X = X(n>0,:);
% Y = Y(n>0);
% n = n(n>0);

%%% PROBIT REGRESSION USING GLMFIT
[b,dev,stats] = glmfit(X,[Y n],'binomial','link','probit','constant','off');

cellstrModelParamFeatures = Tensor.Features(matTensorColumsToUse)';
cellstrModelParamFeatures{1} = 'Constant';

matModelParams = b;

% STORE DESCRIPTION IN TENSOR.MODEL.DESCRIPTION
Tensor.Model.Description.NumOfWeighedIndices = num2str(size(Y,1));
if size(Tensor.TrainingData,1) ~= nansum(n); warning('bs:FunkyError','number of cells in ''n'' does not equal number of cells in ''TrainingData''');end
Tensor.Model.Description.TotalNumberOfCells=num2str(size(Tensor.TrainingData,1));
Tensor.Model.Description.NumberOfPlates=num2str(Tensor.NumberOfPlates);
Tensor.Model.Description.W=['NOT APPLICABLE; PROBIT REGRESSION USED'];

% STORE MODEL IN TENSOR
Tensor.Model.Params = matModelParams;
Tensor.Model.Features = cellstrModelParamFeatures;
Tensor.Model.X = X;
Tensor.Model.Y = Y;
% FOR SAKE OF BACKWARD COMPATIBILITY, SAY W = Tensor.TotalCells;
Tensor.Model.W = Tensor.TotalCells;
Tensor.Model.TotalCells = Tensor.TotalCells;



Tensor.Model.DiscardParamBasedOnCIs=(stats.p>0.01) | isnan(stats.p);%(ConfidenceIntervals(:,1)<=0 & ConfidenceIntervals(:,2)>=0);
Tensor.Model.p=stats.p;%(ConfidenceIntervals(:,1)<=0 & ConfidenceIntervals(:,2)>=0);
Tensor.Model.Stats = stats;

%%% FROM THE MATLAB HELP: Curve Fitting Toolbox™ --> Residual Analysis
% matWeights = full(diag(W));
% SSE = nansum(matWeights .* (stats.resid .^ 2));
% SST = nansum(matWeights .* ((Y - nanmean(Y)).^2));
% RSquare = 1-(SSE/SST);
% Tensor.Model.Description.PearsonsR2=num2str(RSquare);

% note that R-squared is not a valid measure for probit models :( (although
% not clear why, one paper reports that it is hard to obtain high values,
% which we are getting without any problem...).
% so we should look at pseudo-R-squared values. See:
% http://www.ats.ucla.edu/stat/mult_pkg/faq/general/Psuedo_RSquareds.htm
% for a good overview of methods.
SSE = nansum(stats.resid .^ 2);
SST = nansum((Y - nanmean(Y)).^2);
RSquare = 1-(SSE/SST)

Tensor.Model.Description.PearsonsR2=num2str(RSquare);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculate the R2 per single dimension %%%
RSquarePerSingleParam = NaN(size(X,2),1);
for i  = 1:size(X,2)
    [foo1,foo2,statsperparam] = glmfit(X(:,i),[Y n],'binomial','link','probit');
    SSE = nansum(statsperparam.resid .^ 2);
    SST = nansum((Y - nanmean(Y)).^2);
    RSquarePerSingleParam(i) = 1-(SSE/SST);
end
Tensor.Model.Description.RsquaredPerParam = RSquarePerSingleParam';
clear foo1 foo2 statsperparam SSE SST RSquarePerSingleParam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% calculation of McFaddens pseudo-R-Square
% LLmodel = round(real(nansum(((Y./n).*log((Yhat./n))) + ((1-(Y./n)).*log(1-(Yhat./n))))))
% b_null = glmfit(ones(size(n)),[Y n],'binomial','link','probit','constant','off');
% Yhat_null = glmval(b_null,ones(size(n)),'probit','size',n,'constant','off');
% LL_null = round(real(nansum(((Y./n).*log((Yhat_null./n))) + ((1-(Y./n)).*log(1-(Yhat_null./n))))))
% Xsquared = 2*(LLmodel - LL_null)
% McFaddensRsquared = 1-(LLmodel / LL_null)

%%% We might try a chi-square goodness of fit test...
% Yhat = glmval(b,X,'probit','constant','off');
% loglikeliyhood = Y .* Yhat + (1-Y) .* YHat)
% MinusTwoLLR = -2 * log(Lnull / Lfull)
% [h,p]=chi2gof(Y,'expected',Yhat)


% Squared sample correlation coefficient is a measure of GOF (isn't this
% pracically the same as R-squared?
Yhat = glmval(b,X,'probit','size',n,'constant','off');
corr(Y,Yhat)^2


% Calculate the proportional variation reduction per parameter
% Tensor.Model.Description.RsquaredPerParam = nan(1,length(b));
% for iDim = 1:length(b)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We can re-fit an R2 based on only the current dimension
%     [b2,dev,stats2] = glmfit(X(:,iDim),[Y n],'binomial','link','probit');
%     SSE = nansum(stats2.resid .^ 2);
%     SST = nansum((Y - nanmean(Y)).^2);
%     RSquarePerParam = 1-(SSE/SST);
%     Tensor.Model.Description.RsquaredPerParam(1,iDim)=RSquarePerParam;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Or we can see what the R2 would be if we only had the constant and the
% current dimension b from the original/total model. Note, let's include
% the constant only R2 to also see what that looks like.
%     if iDim == 1
%         Yhat = glmval(b(1),ones(size(X,1),1),'probit','size',n,'constant','off');
%     else
%         Yhat = glmval(b([1,iDim]),X(:,iDim),'probit','size',n);
%     end
%     SSE = nansum((Y - Yhat) .^ 2);
%     SST = nansum((Y - nanmean(Y)).^2);
% 
%     RSquarePerParam = 1-(SSE/SST);
%     Tensor.Model.Description.RsquaredPerParam(1,iDim)=RSquarePerParam;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end

%%% CALCULATE & STORE PARTIAL CORRELATIONS (Bootstrapped on single cell
%%% data...)
intNumOfCells=size(Tensor.TrainingData,1);
intNumOfNodes=size(Tensor.TrainingData,2);
intNumOfRounds = 10;
matPartialCorrelationsBootstrp = zeros(intNumOfNodes,intNumOfNodes,intNumOfRounds);
for i = 1:intNumOfRounds
    disp(sprintf('%s: bootstrapping partial correlations, round %d of %d',mfilename,i,intNumOfRounds))
    matRndSubsetData = Tensor.TrainingData(randperm(intNumOfCells),:);
    matRndSubsetData = matRndSubsetData(1:round(intNumOfCells * 0.3),:);
    try
        [matPartialCorrelationsBootstrp(:,:,i)] = GGM(nanzscore(single(matRndSubsetData)));
    catch foo
        warning('berend:Bla','failed to do GGM on data')
    end
end
matPartialCorrelations = nanmedian(matPartialCorrelationsBootstrp,3);
Tensor.Model.Description.PartialCorrelations = nan(1,length(b));
Tensor.Model.Description.PartialCorrelations(1,2:end)=matPartialCorrelations(1,2:end);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % matCompleteData = Tensor.Model.X;
% % matCompleteData(:,1) = Y ./ n; % overwrite constant with infection indices
% % matCompleteData = matCompleteData'; % transpose
% % 
% % node_labels = Tensor.Features;
% % 
% % intNumOfNodes=size(matCompleteData,1);
% % intNumOfRounds = 20;
% % matWeightsBootstrp = zeros(intNumOfNodes,intNumOfNodes,intNumOfRounds);
% % matDirectionalityBootstrp = zeros(intNumOfNodes,intNumOfNodes,intNumOfRounds);
% % matPartialVariancesBootstrp = zeros(1,intNumOfNodes,intNumOfRounds);
% % intNumOfCells = size(matCompleteData,2);
% % for i = 1:intNumOfRounds
% %     disp(sprintf('%s: bootstrapping, round %d of %d',mfilename,i,intNumOfRounds))
% %     matRndSubsetData = matCompleteData(:,randperm(intNumOfCells));
% %     matRndSubsetData = nanzscore(matRndSubsetData(:,1:round(intNumOfCells * 0.9))');
% %     [matWeightsBootstrp(:,:,i), matDirectionalityBootstrp(:,:,i), matPartialVariancesBootstrp(:,:,i)] = GGM(matRndSubsetData);
% % end
% % 
% % matWeights = nanmedian(matWeightsBootstrp,3);
% % matDirectionality = nanmedian(matDirectionalityBootstrp,3);
% % matPartialVariances = nanmedian(matPartialVariancesBootstrp,3);
% % 
% % matPartialVariances.^2; % approximation of the partial R-squared?
% % 
% % dag3 = zeros(intNumOfNodes);
% % for i = 1:intNumOfNodes
% %     for ii = 1:intNumOfNodes
% %         if i == ii;continue;end
% %         if (abs(matWeights(i,ii)) > 0.2) & (matDirectionality(i,ii) > -0.1)
% %             dag3(i,ii) = matWeights(i,ii);
% %         end
% %     end
% % end
% % handleGraph = drawGraph(dag3,node_labels,5,1);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CALCULATE THE ESTIMATED TOTAL VARIANCE EXPLAINED %%%
%%% estimate within-bin variance as the variance over replicate infection
%%% indices measurements for the same bin, calculate the total variance
%%% explained as    
%%%               variance_between_bin_model
%%% ---------------------------------------------------------
%%% variance_between_bin_data + average(variance_within_bins)

%%% [BS 2009-02-24] Now with added correction for average infection level
%%% differences, experimental though!

% for i = 1:length(TensorContainer)
%     (nansum(TensorContainer{i}.InfectedCells) / nansum(TensorContainer{i}.TotalCells))
% end

matIIPerBinPerPlate = nan(size(TensorContainer{1}.InfectionIndex,1),length(TensorContainer));
matTCNPerBinPerPlate = nan(size(TensorContainer{1}.InfectionIndex,1),length(TensorContainer));
for i = 1:length(TensorContainer)
    matIIPerBinPerPlate(:,i) = TensorContainer{i}.InfectionIndex;
    matTCNPerBinPerPlate(:,i) = TensorContainer{i}.TotalCells;
end
% only include bins that have more than 6 replicates with more than 100
% cells for each replicate
matIndicesToUse = nansum(matTCNPerBinPerPlate>100,2) > 6;
% estimated within-bin variance by looking at replica variance of ii's
avgWithinBinVar = nanmean(nanvar(matIIPerBinPerPlate(matIndicesToUse,:) - repmat(nanmedian(matIIPerBinPerPlate(matIndicesToUse,:)),length(find(matIndicesToUse)),1),0,2));
avgWithinBinVar = nanmean(nanvar(matIIPerBinPerPlate(matIndicesToUse,:),0,2));
% between bin variance of the data (ii's)
varBetweenBinData = nanvar(Tensor.InfectedCells(matIndicesToUse) ./ Tensor.TotalCells(matIndicesToUse));
% % between bin variance of the model (ii's)
% Yhat = glmval(b,single(Tensor.Indices),'probit','size',Tensor.TotalCells);
% varBetweenBinModel = nanvar(Yhat(matIndicesToUse) ./ Tensor.TotalCells(matIndicesToUse));
% % estimated % of total variance explained by model
% EstimatedTotalVarianceExplained1 = varBetweenBinModel / (varBetweenBinData + avgWithinBinVar)
PopulationContextDeterminedVariance = varBetweenBinData / (varBetweenBinData + avgWithinBinVar);
% store in model description
% Tensor.Model.Description.EstimatedTotalVarianceExplained1 = sprintf('%.2f',EstimatedTotalVarianceExplained1);
Tensor.Model.Description.PopulationContextDeterminedVariance = sprintf('%.0f%%',(100*PopulationContextDeterminedVariance));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% STORE OUTPUT
save(fullfile(strRootPath,'ProbModel_Tensor.mat'),'Tensor')


% draw infection curve reproduction...
try
    disp(sprintf('%s: starting reproduceTrainingDataCurves_probit',mfilename));
    reproduceTrainingDataCurves_probit(strRootPath,[strrep(getlastdir(strRootPath),'_','\_'),' '])
    reproduceTrainingDataCurves_probit_logtransformed_with_units(strRootPath,[strrep(getlastdir(strRootPath),'_','\_'),' '])
catch foo
    disp(sprintf('%s: failed reproduceTrainingDataCurves_probit',mfilename))
    foo
end

% draw infection curve reproduction...
try
    disp(sprintf('%s: starting reproduceTrainingDataCurves_probit_logtransformed',mfilename));
    reproduceTrainingDataCurves_probit_logtransformed(strRootPath,[strrep(getlastdir(strRootPath),'_','\_'),' '])
catch foo
    disp(sprintf('%s: failed reproduceTrainingDataCurves_probit',mfilename))
    foo
end


% return

%%% Do model correction of plates, store each corrected plate data per
%%% plate individually, so that fuse_basic_data_vx can incorporate the data
%%% correctly.
for i = 1:intNumOfFolders
    try
        disp(sprintf('%s: correct training data on %s',mfilename,cellstrTargetFolderList{i}))
        correctTrainingData4_probit(cellstrTargetFolderList{i}, settings, strRootPath)
    catch foo
        disp(sprintf('%s: failed correct training data per plate',mfilename))
    end
end

% get the probit model parameters per gene and per siRNA.
try
    disp(sprintf('%s: starting getModelParamsPerWell_glmfit_probit',mfilename));
    getModelParamsPerWell_glmfit_probit(strRootPath,settings)
catch foo
    disp(sprintf('%s: failed getModelParamsPerWell_glmfit_probit',mfilename))
end


% plot the heterogeneity distributions per parameter & per well
try
    disp(sprintf('%s: plot data per well data on %s',mfilename,cellstrTargetFolderList{i}))
    plotDataPerWell(strRootPath,strSettingsFile,strRootPath)
catch foo
    disp(sprintf('%s: failed correct training data per plate',mfilename))
end

end