% function mainTensorModel(strRootPath)
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

% if nargin==0
    % strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\';
    % strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SFV_KY\';
    % strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_TDS\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\RV_KY\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\50K_checkers\060118_EV1_Kyo_CB\BATCH\';    
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\';    
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\VV_MZ\';    
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\HRV2_MZ\';    
    strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\RV_KY\';
    
% end

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
disp('ProbMod: adding corrected total cell number & total infected per well')
for i = 1:intNumOfFolders
    addTotalCellNumberMeasurement(cellstrTargetFolderList{i});
    addTotalInfectedMeasurement(cellstrTargetFolderList{i});
end

%%% SIMPLE BINNING OPTIMIZATION: LOOK FOR MINIMA AND MAXIMA PER PLATE PER DIMENSION
disp('ProbMod: checking data distributions')
for i = 1:intNumOfFolders
    createTrainingDataEdges(cellstrTargetFolderList{i});
end

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
Tensor.MetaData = uint8([]);
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
    Tensor.InfectionIndexPerPlate(:,i) = Tensor.InfectedCells ./ Tensor.TotalCells;
    
    Tensor.Indices = TensorContainer{i}.Indices;
    Tensor.BinSizes = TensorContainer{i}.BinSizes;
    Tensor.Features = TensorContainer{i}.Features;        
    Tensor.TrainingData = [Tensor.TrainingData;uint8(TensorContainer{i}.TrainingData)];
    Tensor.MetaData = [Tensor.MetaData;uint8([TensorContainer{i}.MetaData, repmat(i,size(TensorContainer{i}.MetaData,1),1)])];
end

% MORE ROBUST WAY OF GETTING OVERALL INFECTION INDEX PER TENSOR-BIN?
% Tensor.InfectionIndex = nanmedian(Tensor.InfectionIndexPerPlate,2);

clear TensorContainer


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GETTING TO THE ORIGINAL X-VALUES %%%

% % % structDataColumnsToUse = initStructDataColumnsToUse();
% % % cellstrTensorDimensions = Tensor.Features';
% % % cellstrTrainingData = fieldnames(TrainingData);
% % % cellTrueXValues = cell(1,length(cellstrTensorDimensions)-1);
% % % for i = 2:length(cellstrTensorDimensions)% skip first feature: infection
% % %     
% % %     if not(isempty(char(regexp(cellstrTensorDimensions{i}, '_\d_\d', 'match'))))% SHOULD MATCH DIMENSIONS WHERE INDEPENDENT COLUMNS WERE SET...
% % %         intIndex = find(strncmpi(cellstrTrainingData,cellstrTensorDimensions{i},length(cellstrTensorDimensions{i})-2));
% % %     else
% % %         intIndex = find(strncmpi(cellstrTrainingData,cellstrTensorDimensions{i},length(cellstrTensorDimensions{i})));
% % %     end
% % %     
% % %     if isempty(strfind(cellstrTensorDimensions{i},'CellClassification')) && ...
% % %             isempty(strfind(cellstrTensorDimensions{i},'GridNucleiEdges'))
% % %     
% % %         cellTrueXValues{i} = linspace(TrainingData.(char(cellstrTrainingData{intIndex})).Min,TrainingData.(char(cellstrTrainingData{intIndex})).Max,Tensor.BinSizes(i));
% % % 
% % %         % DIFFERENCES BETWEEN BINS SHOULD BE UNIQUE UP TO THE 4th DECIMAL...
% % %         % (UGLY? YOU TELL ME WHY THE UNIQUE OF DIFF OF A LINSPACE RESULT
% % %         % DOESN'T RETURN A SINGLE VALUE! :) 
% % %         intStepSize = unique(eval(['[',sprintf('%.4f, ',diff(cellTrueXValues{i})),']']));
% % %         cellTrueXValues{i} = cellTrueXValues{i} + intStepSize/2;
% % %     else
% % %         % INDEPENDENT COLUMNS
% % %         [0,1]
% % %         cellTrueXValues{i} = [0,1];
% % %     end
% % %     
% % % end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% WEIGHTED LEAST-SQUARES REGRESSION %%%

% INCLUDE ONLY ALL DATAPOINTS BUT 

[rowInd,colInd]=find(Tensor.Indices(:,end) == 1);

Tensor.Model.UsedIndices=rowInd;

matTensorColumsToUse = ...
    find( ...
     (cellfun('isempty',strfind(Tensor.Features,'CellClassification_1_1')) & ...
     cellfun('isempty',strfind(Tensor.Features,'CellClassification_1_4'))) ...
    )

Tensor.Model.UsedColumns=matTensorColumsToUse;


% disp(sprintf('%s - ',Tensor.Features{:}))
% [rowInd,colInd]=find(Tensor.Indices(:,5) == 1);
% [rowInd,colInd]=find(Tensor.Indices(:,1)+1); % just take all

intDatapoints = length(rowInd);
Tensor.Model.Description.X='Binned';
X = double(Tensor.Indices(rowInd,matTensorColumsToUse));
% X = matAllPossibleCombinations(rowInd,1:2); 
% MOVE ALL BIN POSITIONS ONE BACK, SUCH THAT 1,2 BECOMES 0,1, ETC...
Tensor.Model.Description.LinearRegression='First order polynomial';
X = X - 1; 

%%% ADDING NON-LINEAR PART
% X = [X, X.^2];
% X = [X, X.^2, X.^3];

% ADD FIRST COLUMN WITH 1s FOR FITTING
X = [ones(intDatapoints,1),X]; 

% CREATE MATRIX WITH WEIGHTS AT DIAGONAL
% DO LOG TRANSFORM TO PLAY AROUND WITH WEIGHTS
% W = Tensor.TotalCells(rowInd);
W = log10(Tensor.TotalCells(rowInd));
% W = (Tensor.TotalCells(rowInd)).^(1/3);
W(isinf(W)) = 0;
W(isnan(W)) = 0;
% W = W-1;
W(W<1) = 0;
% W(W>=2) = 1;
% W(W>10) = 1;
W = diag(sparse(W));% - 1;

[foo1,foo2]=find(W);
Tensor.Model.Description.NumOfWeighedIndices = num2str(length(foo1));
clear foo1 foo2

% Tensor.Model.Description.W='TCN ^1^/^3';
% Tensor.Model.Description.W='log10(TCN), W<2 = 0, W>=2 = 1';
% Tensor.Model.Description.W='log10(TCN), W<3 = 0';
Tensor.Model.Description.W='log10(TCN), W<1 = 0';

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

save(fullfile(strRootPath,'ProbModel_Tensor.mat'),'Tensor')

% reproduceTrainingDataCurves(strRootPath,[strrep(getlastdir(strRootPath),'_','\_'),' '])
% reproduceTrainingDataCurvesFromMasterTensor(strRootPath,[strrep(getlastdir(strRootPath),'_','\_'),' '])

return


% correctTrainingData(strRootPath)

%%% MATLABs ROBUST FIT (NOT WEIGHTED!)
% matModelParams2=robustfit(X(:,2:end),Y)
% [B,STATS] = ROBUSTFIT(X(:,2:end),Y)

%%% ANOTHER MATLAB FIT METHOD... (does it do multiple linear least squares?)
% options = fitoptions('Method','LinearLeastSquares','Robust','Bisquare','Weights',diag(W))
% cfun = fit('',X(:,2),Y,options)


% matModelParams = inv(X'*X)*X'*Y;% NOT WEIGHED

%STORE MODEL



% LINEAR FORM AND SUMMARIZE
matModelInfectionIndex = repmat(matModelParams',intDatapoints,1) .* X;
matModelInfectionIndex = sum(matModelInfectionIndex,2);

matDiff = (Y-matModelInfectionIndex);
matErrorWeights = Tensor.TotalCells(rowInd);
intWeightedErrorFunc = round(sum(abs(matDiff).*matErrorWeights))/sum(matErrorWeights)
intTotalErrorFunc = sum(abs(matDiff))


figure()
subplot(3,1,1)
bar(Y)
ylim([0 1])
subplot(3,1,2)
matModIIs=matModelInfectionIndex;
matModIIs(Tensor.TotalCells(rowInd)==0)=NaN;
bar(matModIIs)
ylim([0 1])
subplot(3,1,3)
bar(matDiff)
ylim([-1 1])

return

% PLOT MODEL NEXT TO ORIGINAL DATA
[rowInd,colInd]=find(Tensor.Indices(:,3) == 1 & Tensor.Indices(:,4) == 1 & Tensor.Indices(:,5) == 3);

figure();

% DON'T PLOT ENTIRE MODEL, JUST THE AVAILABLE DATA
matIIs=Tensor.InfectionIndex(rowInd);
matModIIs = matModelInfectionIndex;
matModIIs(isnan(matIIs)) = NaN;
matDiffIIs = abs(matModIIs-matIIs);
matWeights = diag(W);
matWeights(isnan(matIIs)) = NaN;

subplot(2,2,1)
title('Model')
imagesc(reshape(matModIIs,8,8),[0,1])
xlabel('GridNucleiCount-1')
ylabel('AreaShape-1')
zlabel('II')
colorbar

subplot(2,2,2)
title('Data')
imagesc(reshape(matIIs,8,8),[0,1])
xlabel('GridNucleiCount-1')
ylabel('AreaShape-1')
zlabel('II')
colorbar

subplot(2,2,3)
title('Difference')
imagesc(reshape(matDiffIIs,8,8),[0,1])
xlabel('GridNucleiCount-1')
ylabel('AreaShape-1')
zlabel('II difference')
colorbar

subplot(2,2,4)
title('Weights')
imagesc(reshape(matWeights,8,8),[0,1])
xlabel('GridNucleiCount-1')
ylabel('AreaShape-1')
colorbar


figure()
subplot(2,2,1)
surface(reshape(X(:,2),8,8),reshape(X(:,3),8,8),reshape(matModIIs,8,8),'CData',reshape(matModIIs,8,8))
xlabel('GridNucleiCount-1')
ylabel('AreaShape-1')
zlabel('II')
colorbar

subplot(2,2,2)
title('Data')
surface(reshape(X(:,2),8,8),reshape(X(:,3),8,8),reshape(matIIs,8,8),'CData',reshape(matIIs,8,8))
xlabel('GridNucleiCount-1')
ylabel('AreaShape-1')
zlabel('II')
colorbar

subplot(2,2,3)
title('Difference')
surface(reshape(X(:,2),8,8),reshape(X(:,3),8,8),reshape(matDiffIIs,8,8),'CData',reshape(matDiffIIs,8,8))
xlabel('GridNucleiCount-1')
ylabel('AreaShape-1')
zlabel('II difference')
colorbar

subplot(2,2,4)
title('Weights')
surface(reshape(X(:,2),8,8),reshape(X(:,3),8,8),reshape(matWeights,8,8),'CData',reshape(matWeights,8,8))
xlabel('GridNucleiCount-1')
ylabel('AreaShape-1')
zlabel('Weights')
colorbar


% matIIs=matClassInfectionIndex(rowInd);
% subplot(2,2,2)
% surface(reshape(X(:,2),8,8),reshape(X(:,3),16,16),reshape(matIIs,16,16),'CData',reshape(matIIs,16,16))
% xlabel('GridNucleiCount-1')
% ylabel('AreaShape-1')
% zlabel('Infection Index')

figure()
[rowInd2,colInd2]=find(Tensor.Indices(:,3) == 1 & Tensor.Indices(:,4) == 1);
matIIs = Tensor.InfectionIndex(rowInd2);
matIIs(isnan(matIIs)) = 0;

X = Tensor.Indices(rowInd2,1);
Y = Tensor.Indices(rowInd2,2);
Z = Tensor.Indices(rowInd2,5);
S = (matIIs*1000)+1;
C = round(matIIs*100)+1;
% C = repmat(1,length(rowInd),1);
scatter3(X(:),Y(:),Z(:),S(:),C(:),'filled'), view(-60,60)


return












%%% display bin usage
h0 = figure()
subplot(4,1,1)
bar(matClassTotalCells>0)
ylabel('filled tensor')
subplot(4,1,2)
bar(matClassTotalCells)
ylabel('total cell number')
subplot(4,1,3)
bar(matClassInfectedCells)
ylabel('total infected')
subplot(4,1,4)
bar(matClassInfectionIndex)
ylabel('infection index')

sum(matClassTotalCells(:))
size(matTrainingData,1)

% display original histograms
h0a = figure();
intNumOfPlots=round(sqrt(length(matTrainingDataFeatures)))+1;
for i = 1:length(matTrainingDataFeatures)
    subplot(intNumOfPlots,intNumOfPlots,i)
    bar(TrainingData.(char(matTrainingDataFeatures(i))).Histogram)
end


%%% display size/density surfaces/heatmaps at class & edge slices
uLimit=64;
colormapThingy3 = [linspace(0,1,uLimit);repmat(0,1,uLimit);repmat(0,1,uLimit);]';            

h1 = figure();
h2 = figure();
plotcounter = 0;
intDims = length(TrainingData.GridNucleiCount_1.BinEdges);
for i = 1:2%edge/dim-#3
    for j = 1:4%class/dim-#4
        plotcounter = plotcounter + 1;
        matSliceClasses = find(matAllPossibleCombinations(:,3) == i & matAllPossibleCombinations(:,4) == j);

        x = matAllPossibleCombinations(matSliceClasses,1);
        y = matAllPossibleCombinations(matSliceClasses,2);
        matIIs = matClassInfectionIndex(matSliceClasses);
        matTCNs = matClassTotalCells(matSliceClasses);

        matSurface1 = reshape(matIIs,intDims,intDims);
        matSurface2 = reshape(matTCNs,intDims,intDims);        
        
        figure(h1)
        subplot(2,4,plotcounter)
%         matColorIndices = round(matSurface1(:)*64);
%         matColorIndices(find(isnan(matColorIndices))) = -Inf;
%         matColorIndices = matColorIndices + 1;        
        surface(reshape(x,intDims,intDims),reshape(y,intDims,intDims),matSurface1) %,reshape(colormapThingy3(matColorIndices),8,8)
        zlim([0 1])
        xlabel('GridNucleiCount_1')
        ylabel('AreaShape_1')
        zlabel('Infection Index')
        view(35,45)
        
        figure(h2)
        subplot(2,4,plotcounter)
        imagesc(matSurface1)
        xlabel('GridNucleiCount_1')
        ylabel('AreaShape_1')
%         subplot(1,2,2)
%         imagesc(matSurface2)
%         xlabel('GridNucleiCount_1')
%         ylabel('AreaShape_1')
        
%         load clown
%         surface(peaks,flipud(X),...
%             'FaceColor','texturemap',...
%             'EdgeColor','none',...
%             'CDataMapping','direct')
%         colormap(map)
      
        
    end
end

