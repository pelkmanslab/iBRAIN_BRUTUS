function mainTensorModel(strRootPath)
%%% mainTensorModel.m
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TENSOR MODEL OF CELL POPULATION PROPERTIES %%%
%%%   USING WEIGHTED LEAST SQUARE REGRESSION   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Take the following measurements: lcd, size, edge, class, and optionally
% tcn, and plate-median-ii. 
% Do binning in a low number of bins (say 5, for each measurement.
% Classify all cells according to each bin, and calculate the per
% multi-dimensional bin the infection index. This is the percentage of
% expected infected cells for each bin. 
% Next, classify all cells in a given well and calculate the expected
% number of infected cells as the sum of all the number of expected cells
% per BIN,i,j,k,l,...,n 
% Normalization can be done by taking the log2 of the division of total
% number of infected cells per well over the total number of
% expected-infected cells per well. 

% open questions:
%
% PARAMETERS:
% - should we add total-cell-number as a parameter-dimension?
% - should we add overall-plate-infection level as parameter-dimension?
%
% TRAINING DATA:
% - is using all data for training-data the best option? (seems so for
%   bigger data sets, but does it work for 50K?)
%
% BINNING:
% - optimize binning per data-set? Such that you get ideal bins centered
% around your actual overall distribution? SEEMS SMARTEST...
%
% SCIENTIFIC QUESTIONS:
% - to which extent can lcd/size/edge compensate for total cell number
%   effects?
% - which hits are true hits after correcting with this model?
% - is the correction method stable enough?

% function PlateDataHandles = CollectTrainingData(strDataPath)

if nargin==0
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\50K_checkers\060118_EV1_Kyo_CB\BATCH\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SFV_KY\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_TDS\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\RV_KY\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\50K_checkers\060118_EV1_Kyo_CB\BATCH\';    
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\';    
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\VV_MZ\';    
%     strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\50K_checkers\060811_SFV_KY_checker\';
    strRootPath = 'Z:\Data\Users\Berend\081015_MD_HDMECS_Tfn_pFAK\BATCH\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\50K_final\SV40_CNX\';
%     strRootPath = 'C:\Documents and Settings\imsb\Desktop\070104_RV_50K_KY_P1_1_1\';
end

strRootPath = npc(strRootPath);

%%% LOOK FOR ALL FOLDERS BELOW TARGETFOLDER THAT CONTAIN TARGET FILE
disp('ProbMod: checking target folders')
cellstrTargetFolderList = SearchTargetFolders(strRootPath,'Measurements_Image_FileNames.mat');

intNumOfFolders = length(cellstrTargetFolderList);
disp(sprintf('ProbMod: found %d target folders',intNumOfFolders))

%%% IF NO TARGET FOLDERS ARE FOUND, QUIT
if intNumOfFolders==0
    return
end

%%% ADD MODEL SPECIFIC MEASUREMENTS, LIKE A OUT-OF-FOCUS IMAGE CORRECTED
%%% TOTAL CELL NUMBER AND TOTAL INFECTED NUMBER PER WELL. ALL FUNCTIONS
%%% SHOULD SKIP IF THE MEASUREMENT IS ALREADY PRESENT.
disp('ProbMod: adding tensor specific data structures')
for i = 1:intNumOfFolders
%     try
        addTotalCellNumberMeasurement(cellstrTargetFolderList{i});
%         addTotalInfectedMeasurement(cellstrTargetFolderList{i});
        addCellTypeClassificationPerColumn(cellstrTargetFolderList{i})
        addGridNucleiCountCorrected(cellstrTargetFolderList{i})
%     catch
%         cellstrTargetFolderList{i}
%         rethrow(lasterror)
%     end
end

%%% SIMPLE BINNING OPTIMIZATION: LOOK FOR MINIMA AND MAXIMA PER PLATE PER DIMENSION
disp('ProbMod: checking data distributions')
for i = 1:intNumOfFolders
    createTrainingDataEdges(cellstrTargetFolderList{i});
end



% % % %%%%%%%%%%%%%%%%%%%%%
% % % %%% MY BIG FAT GREEK HACK: GET THE MINIMA AND MAXIMA OF ALL DATASETS, NOT
% % % %%% JUST OF THE CURRENT ONE...
% % % %%% NOTE THAT THIS REQUIRES ALL MINIMA AND MAXIMA DATA TO BE PRESENT!
% % % strRootPath2 = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\';
% % % cellstrTargetFolderList2 = SearchTargetFolders(strRootPath2,'ProbModel_TrainingDataEdges.mat');
% % % intNumOfFolders2 = length(cellstrTargetFolderList);
% % % %%%%
% % % 
% % % %%% SIMPLE BINNING OPTIMIZATION: LOOK FOR MINIMA AND MAXIMA PER DIMENSION
% % % %%% OVER ALL PLATES 
% % % disp('ProbMod: calculating total data distribution')
% % % TrainingData = struct();
% % % for i = 1:intNumOfFolders2
% % %     TrainingData = mergeTrainingDataEdges(cellstrTargetFolderList2{i},TrainingData);
% % % end
% % % save(fullfile(strRootPath,'ProbModel_TrainingDataEdges.mat'),'TrainingData')
% % % 
% % % %%% END OF MY BIG FAT GREEK HACK
% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% SIMPLE BINNING OPTIMIZATION: LOOK FOR MINIMA AND MAXIMA PER DIMENSION
%%% OVER ALL PLATES 
disp('ProbMod: calculating total data distribution')
TrainingData = struct();
for i = 1:intNumOfFolders
    TrainingData = mergeTrainingDataEdges(cellstrTargetFolderList{i},TrainingData);
end
save(fullfile(strRootPath,'ProbModel_TrainingDataEdges.mat'),'TrainingData')


%%% CLASSIFY PER PLATE ALL THE NUCLEI FOR THE GIVEN DIMENSIONS AND FOR THE
%%% GIVEN BINNING AS FOUND IN strRootPath\ProbModel_TrainingDataEdges.mat
%%% DISCARDING OTHER-CLASS NUCLEI AND OUT-OF-FOCUS IMAGES
disp('ProbMod: creating training data')
for i = 1:intNumOfFolders
    createTrainingDataValues(cellstrTargetFolderList{i}, strRootPath);
end


%%% GENERAL APPROACH, FILL THE TENSOR WITH TOTAL CELL NUMBERS AND TOTAL
%%% INFECTED CELLS PER PLATE FIRST, THEN COMBINE FOR ALL PLATES.

%%% CREATING PER PLATE TCN, INFECTEDCELLS & II TENSORS
disp('ProbMod: creating per plate tensor')
for i = 1:intNumOfFolders
	constructTensorFromTrainingDataValues(cellstrTargetFolderList{i})
end


%%% COMBINE TENSORS FROM ALL PLATES
disp('ProbMod: merging tensors')
TensorContainer = cell(intNumOfFolders,1);
Tensor = struct();
Tensor.TrainingData = uint8([]);
Tensor.MetaData = uint16([]);
Tensor.NumberOfPlates = 0;

for i = 1:intNumOfFolders
    try
        TensorContainer{i} = load(fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat'));
    catch
        disp(sprintf('  failed to add tensor %s',fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat')))
        break
    end
    TensorContainer{i} = TensorContainer{i}.Tensor;
    if i==1
        Tensor.TotalCells = TensorContainer{i}.TotalCells;
        Tensor.InfectedCells = TensorContainer{i}.InfectedCells;
    else
        Tensor.TotalCells = Tensor.TotalCells + TensorContainer{i}.TotalCells;
        Tensor.InfectedCells = Tensor.InfectedCells + TensorContainer{i}.InfectedCells;
    end
    Tensor.InfectionIndex = Tensor.InfectedCells ./ Tensor.TotalCells;
    Tensor.InfectionIndexPerPlate(:,i) = TensorContainer{i}.InfectedCells ./ TensorContainer{i}.TotalCells;    
    
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

% MORE ROBUST WAY OF GETTING OVERALL INFECTION INDEX PER TENSOR-BIN?
% Tensor.InfectionIndex = nanmedian(Tensor.InfectionIndexPerPlate,2);

clear TensorContainer


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GETTING TO THE ORIGINAL X-VALUES 
%%%  CALCULATE THE STEPSIZE PER BIN  
%%% WE SHOULD BE DOING THIS IN CREATETRAININGDATAVALUES... 
% structDataColumnsToUse = initStructDataColumnsToUse();
% cellstrTensorDimensions = Tensor.Features';
% cellstrTrainingData = fieldnames(TrainingData);
% cellTrueXValues = cell(1,length(cellstrTensorDimensions)-1);
% Tensor.Indices2Values = [];
% for i = 2:length(cellstrTensorDimensions)% skip first feature: infection
%     if not(isempty(char(regexp(cellstrTensorDimensions{i}, '_\d_\d', 'match'))))% SHOULD MATCH DIMENSIONS WHERE INDEPENDENT COLUMNS WERE SET...
%         intIndex = find(strncmpi(cellstrTrainingData,cellstrTensorDimensions{i},length(cellstrTensorDimensions{i})-2));
%     else
%         intIndex = find(strncmpi(cellstrTrainingData,cellstrTensorDimensions{i},length(cellstrTensorDimensions{i})));
%     end
%     cellTrueXValues{i-1} = linspace(TrainingData.(char(cellstrTrainingData{intIndex})).Min,TrainingData.(char(cellstrTrainingData{intIndex})).Max,Tensor.BinSizes(i));
%     Tensor.Indices2Values(:,i-1) = cellTrueXValues{i-1}(Tensor.Indices(:,i-1))';
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% WEIGHTED LEAST-SQUARES REGRESSION %%%

% INCLUDE ONLY ALL DATAPOINTS BUT 

[rowInd,colInd]=find(Tensor.Indices(:,end)+1);
matTensorColumsToUse = find(~cellfun('isempty',Tensor.Features));

intDatapoints = length(rowInd);
Tensor.Model.Description.LinearRegression='First order polynomial';

Tensor.Model.Description.X='Binned';
X = double(Tensor.Indices(rowInd,:));
% MOVE ALL BIN POSITIONS ONE BACK, SUCH THAT 1,2 BECOMES 0,1, ETC...
X = X - 1; 

% Tensor.Model.Description.X='Measured per Bin';
% X = double(Tensor.Indices2Values(rowInd,:));



%%% ADDING NON-LINEAR PART
% X = [X, X.^2];
% X = [X, X.^2, X.^3];

% ADD FIRST COLUMN WITH 1s FOR FITTING
X = [ones(intDatapoints,1),X]; 

% CREATE MATRIX WITH WEIGHTS AT DIAGONAL
% DO LOG TRANSFORM TO PLAY AROUND WITH WEIGHTS
% W = Tensor.TotalCells(rowInd);
% W = log10(Tensor.TotalCells(rowInd));
W = (Tensor.TotalCells(rowInd)).^(1/3);
W(isinf(W)) = 0;
W(isnan(W)) = 0;
% W = W-1;
W(W<8) = 0;
% W(W>=2) = 1;
% W(W>10) = 1;
W = diag(sparse(W));% - 1;

[foo1,foo2]=find(W);
Tensor.Model.Description.NumOfWeighedIndices = [num2str(length(foo1)), ' out of ', num2str(size(Tensor.Indices,1))];
clear foo1 foo2
Tensor.Model.Description.TotalNumberOfCells=num2str(size(Tensor.TrainingData,1));
Tensor.Model.Description.NumberOfPlates=num2str(Tensor.NumberOfPlates);
Tensor.Model.Description.W='TCN ^1^/^3, W<8 = 0';
% Tensor.Model.Description.W='log10(TCN), W<2 = 0, W>=2 = 1';
% Tensor.Model.Description.W='log10(TCN), W<3 = 0';
% Tensor.Model.Description.W='log10(TCN), W<1 = 0';

% figure()
% [iRow,iCol]=find(W);
% hist(W(iRow,iCol),50)
% title('weight histogram')
% drawnow

% Y MATRIX IS THE MODEL OUTPUT, I.E. INFECTION INDEX
Tensor.Model.Description.Y='Infection index (pooled over all plates)';
Y = Tensor.InfectionIndex(rowInd);
Y(isnan(Y))=0;

% DO MODEL
matModelParams = inv(X'*W*X)*X'*W*Y;% WEIGHED

if sum(isnan(matModelParams)) == length(matModelParams)
    disp('WARNING: MODEL INVERSE STEP FAILED, USING PSEUDO-INVERSE')
    matModelParams = pinv(X'*W*X)*X'*W*Y;% WEIGHED, PSEUDOINVERSE
end

cellstrModelParamFeatures = Tensor.Features(matTensorColumsToUse)';
cellstrModelParamFeatures{1} = 'Constant';

cellstrModelParamFeatures
matModelParams

% STORE MODEL IN TENSOR
Tensor.Model.Params = matModelParams;
Tensor.Model.Features = cellstrModelParamFeatures;
Tensor.Model.X = X;
Tensor.Model.Y = Y;
Tensor.Model.W = W;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ACCORDING TO WIKIPEDIA: LINEAR REGRESSION %%%

n = length(Y);
p = size(X,2)-1; % without constant
u = ones(n,1);
nu = n-p; % degrees of freedom

% RESIDUALS
residuals = Y - X*matModelParams;

Yhat = (X*matModelParams);
Yhat(diag(W)<=0) = [];

%%% also known as ChiSquared
weightedresiduals = W*residuals;
weightedresiduals(diag(W)<=0) = [];

figure()
subplot(2,3,1)
normplot(weightedresiduals)
axis square
title('normal probability plot')

subplot(2,3,2)
scatter(weightedresiduals,Yhat)
xlabel('weighted residuals')
ylabel('model infection index')
axis square

subplot(2,3,3)
scatter(weightedresiduals(1:end-1),weightedresiduals(2:end))
xlabel('weighted residuals')
ylabel('preceding weighted residuals')
axis square


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CONFIDENCE INTERVAL (AS STOLEN FROM FUNCTION REGRESS) %%%
%%% IS IT A PROBLEM THAT THE WEIGHTS ARE NOT INCLUDED???
%%%
alpha = 0.05;
[n,ncolX] = size(X);
% Use the rank-revealing QR to remove dependent columns of X.
[Q,R,perm] = qr(X,0);
p = sum(abs(diag(R)) > max(n,ncolX)*eps(R(1)));
if p < ncolX
    warning('stats:regress:RankDefDesignMat', ...
            'X is rank deficient to within machine precision.');
    R = R(1:p,1:p);
    Q = Q(:,1:p);
    perm = perm(1:p);
end

% Find a confidence interval for each component of x
% Draper and Smith, equation 2.6.15, page 94
RI = R\eye(p);
normr = norm(weightedresiduals); %%% OR USE WEIGHTED RESIDUALS??? (weightedresiduals)
rmse = normr/sqrt(nu);    % Root mean square error.
tval = tinv((1-alpha/2),nu);
s2 = rmse^2;                    % Estimator of error variance.
se = zeros(p,1);
se(perm,:) = rmse*sqrt(sum(abs(RI).^2,2));
ConfidenceIntervals = [matModelParams-tval*se, matModelParams+tval*se];
Tensor.Model.ConfidenceIntervals=ConfidenceIntervals;
Tensor.Model.DiscardParamBasedOnCIs=(ConfidenceIntervals(:,1)<=0 & ConfidenceIntervals(:,2)>=0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% REGRESSION SUM OF SQUARES
intSSR = matModelParams'*X'*Y - (1/n)*(Y'*u*u'*Y);
% ERROR SUM OF SQUARES
intESS = Y'*Y-matModelParams'*X'*Y;
% TOTAL SUM OF SQUARES
intTSS = intSSR + intESS;

% Mean Squared Error
intMSE = intESS/nu;
% Root Mean Squared Error
intRMSE = sqrt(intMSE);

% STANDARD DEVIATION == RMSE
sigma = sqrt( ( Y'*Y - matModelParams'*X'*Y ) / ( n - p - 1 ) );

% Pearson's co-efficient of regression
% Calculate Pearson’s co-efficient of regression. The closer the value is
% to 1; the better the regression is. This co-efficient gives what fraction
% of the observed behaviour can be explained by the given variables.
RSquare = 1 - (intESS/intTSS) % = SSR/TSS

% DEGREES OF FREEDOM ADJUSTED R-SQUARE
intAdjustedRSquared = 1 - ((intESS*(n-1))/(intTSS*nu))


Tensor.Model.Description.PearsonsR2=num2str(RSquare);
Tensor.Model.Description.DegreesOfFreedomAdjustedR2=num2str(intAdjustedRSquared);
Tensor.Model.Description.Sigma=num2str(sigma);
Tensor.Model.Description.RootMeanSquaredError=num2str(intRMSE);


% %%% RIDGE MULTILINEAR REGRESSION FOR CORRELATED COEFFICIENTS
% %%% FROM MATLAB LINEAR REGRESSION HELP PAGES
% 
% X2 = X((Y>0),2:end);
% D = x2fx(X2,'interaction');
% D(:,1) = []; % No constant term
% k = 0:1e-5:5e-3;
% betahat = ridge(Y(Y>0),D,k);
% 
% 
% figure
% plot(k,betahat,'LineWidth',2)
% % ylim([-100 100])
% grid on 
% xlabel('Ridge Parameter') 
% ylabel('Standardized Coefficient') 
% title('{\bf Ridge Trace}') 
% legend('constant','x1','x2','x3','x1x2','x1x3','x2x3')



save(fullfile(strRootPath,'ProbModel_Tensor.mat'),'Tensor')

reproduceTrainingDataCurves(strRootPath,[strrep(getlastdir(strRootPath),'_','\_'),' '])
displayLinearFits(strRootPath)
% plotTotalCellNumberCurves(strRootPath)
% predictTotalCellNumberCurves2(strRootPath)