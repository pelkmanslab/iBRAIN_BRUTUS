function mainTensorModel_glmfit(strRootPath, strSettingsFile)
%%% mainTensorModel.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TENSOR MODEL OF CELL POPULATION PROPERTIES %%%
%%%   USING WEIGHTED LEAST SQUARE REGRESSION   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
%     strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\HPV16_MZ_2\';
%     strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\VV_DG\20071022095251_M2_071020_VV_DG_batch1_CP001-1db\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\50K_checkers\060118_EV1_Kyo_CB\BATCH\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\50K_checkers\060118_EV1_MZ_CB\BATCH\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\50K_checkers\060518_HSV1_Ky_checker\BATCH\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\David\Pictures\David_iBRAIN\080312Davidtestplaterescan3\BATCH\'; 
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\David\Pictures\David_iBRAIN\080220davidvirus\BATCH\'; 
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Lilli\070719_A431_Dextran_50k\'; 
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\50K_Tfn\20071130131036_M1_071129_A431_50k_Tfn_P3_2\'; 

%     strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Lilli\070716_ChTxB_A431\'; 
    
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\50K_Tfn\'; 

%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\S6K\'; 

%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\David\080220davidvirus\BATCH'; 

%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\'; 
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\DV_KY\'; 

%     strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\YF_DG\20080425015410_M1_080424_YF_DG_batch2_CP049-1dd\BATCH\\'; 

%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\50K_checkers\061120_SV40_GM1_MZ_checker\BATCH\'; 
    
%     strRootPath = 'Z:\Data\Users\Berend\SV40_MZ\070111_SV40_MZ_MZ_P1_1_2\BATCH\';
    
% strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\50K_copy\SV40_MZ\';
% strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\50K_final_reanalysis\SV40_MZ\';
    
% strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Prisca\Lilli\090210-pAkt\';

%     strRootPath = 'Z:\Data\Users\Berend\David\080220davidvirus\';

%     strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ2\philip_071006_Tfn_MZ_AWaa\';
%     strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ2\philip_071006_Tfn_MZ_AWaa_ALL_CELLS\';
%     strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\EvaBerend\081117_MCF10A_SV40_ChTxBup_pFAK\';

%     strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\EvaBerend\081210_A431_SV40_pFAK_ChtxBuptake\BATCH\';
%     strRootPath = 'Y:\Data\Users\Frank\iBRAIN\081205-timedose-VSV-DYRK3INH-20x\';
    

strRootPath = 'Y:\Data\Users\Berend\090216_Mz_Tfn_CB\090216_Mz_Tfn_CB\';


end

if nargin < 1
%     strSettingsFile = '';
%     strSettingsFile = '\\Nas-biol-imsb-1\share-2-$\Data\Code\Matlab\Berend\TensorModel\initStructDataColumnsToUse.m';
%     strSettingsFile = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Lilli\070719_A431_Dextran_50k\ProbModel_Settings.txt';
%     strSettingsFile = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\50K_Tfn\ProbModel_Settings.txt';
%     strSettingsFile = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\S6K\ProbModel_Settings.txt';

%     strSettingsFile = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\David\080220davidvirus\ProbModel_Settings.txt';
    
%     strSettingsFile = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\ProbModel_Settings_inc_NVC.txt';    

%     strSettingsFile = '\\nas-biol-imsb-1\share-2-$\Data\Berend\SV40_MZ\ProbModel_Settings.txt';

%     strSettingsFile = '\\Nas-biol-imsb-1\share-2-$\Data\Users\50K_checkers\061120_SV40_GM1_MZ_checker\BATCH\ProbModel_Settings.txt';

%     strSettingsFile = '\\nas-biol-imsb-1\share-2-$\Data\Users\Lilli\070716_ChTxB_A431\ProbModel_Settings.txt';
%     strSettingsFile = 'Z:\Data\Users\Berend\David\080220davidvirus\ProbModel_Settings.txt';

%     strSettingsFile = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ2\philip_071006_Tfn_MZ_AWaa_ALL_CELLS\ProbModel_Settings_all_cells_included.txt';
%     strSettingsFile = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\ProbModel_Settings.txt';

%     strSettingsFile = 'Z:\Data\Users\Berend\081015_MD_HDMECS_Tfn_pFAK\BATCH\ProbModel_Settings_all_cells_included.txt';
%     strSettingsFile = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\EvaBerend\081117_MCF10A_SV40_ChTxBup_pFAK\ProbModel_Settings_all_cells_included.txt';
%     strSettingsFile = 'Y:\Data\Users\Frank\iBRAIN\081205-timedose-VSV-DYRK3INH-20x\ProbModel_Settings_all_cells_included.txt';
    
    
    
%     strSettingsFile = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ2\philip_071006_Tfn_MZ_AWaa\ProbModel_Settings.txt';
%     strSettingsFile = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\ProbModel_Settings_SV40_MZ.txt'; 
%     strSettingsFile = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\ProbModel_Settings.txt'; 
%     strSettingsFile = '\\nas-biol-imsb-1\share-2-$\Data\Users\Lilli\070716_ChTxB_A431\ProbModel_Settings_all_cells_included.txt';
%     strSettingsFile = '\\nas-biol-imsb-1\share-2-$\Data\Users\Lilli\070716_ChTxB_A431\ProbModel_Settings.txt';

%     strSettingsFile = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\50K_copy\ProbModel_Settings.txt';

%     strSettingsFile = '\\nas-biol-imsb-1\share-2-$\Data\Users\Prisca\Lilli\090210-pAkt\ProbModel_Settings_all_cells_included.txt';

    strSettingsFile = 'Y:\Data\Users\Berend\090216_Mz_Tfn_CB\090216_Mz_Tfn_CB\ProbModel_Settings_all_cells_included.txt';

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
disp(sprintf('ProbMod: found %d target folders',intNumOfFolders))

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
%     try
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
for i = 1:intNumOfFolders
    createTrainingDataValues(cellstrTargetFolderList{i}, strRootPath, settings);
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
Tensor.Oligo = [];
Tensor.settings = settings;

for i = 1:intNumOfFolders
    try
        TensorContainer{i} = load(fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat'));
        disp(sprintf('%s:  merging %s',mfilename,fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat')))
    catch
        disp(sprintf('%s:  failed to add tensor %s',mfilename,fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat')))
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

clear TensorContainer


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

% intWeightThreshold = 4;
intWeightThreshold = 4;

% test if there is a display connected, if not, set WeightThreshold to 8,
% otherwise confirm with user.
screenSize = get(0,'ScreenSize');
if (screenSize(3) > 1)
    % There is a display connected
    prompt={'Enter the minimal weight threshold:'};
    name='Weight?';
    numlines=1;
    defaultanswer={'8'};
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='tex';
    answer=inputdlg(prompt,name,numlines,defaultanswer,options);
    if ~isempty(answer) && isnumeric(str2double(answer)) && str2double(answer)>0 && str2double(answer)<10
        intWeightThreshold = str2double(answer);
        disp(sprintf('setting weight threshold to %d',intWeightThreshold))
    else
        intWeightThreshold = 8;
        disp(sprintf('invalid input, setting weight threshold to %d',intWeightThreshold))
    end
    drawnow
else
    disp(sprintf('%s: No display detected, assuming Weight Threshold should be 8',mfilename))
end

W(W<intWeightThreshold) = 0;
% W(W>=2) = 1;
% W(W>10) = 1;
W = diag(sparse(W));% - 1;

[foo1,foo2]=find(W);
Tensor.Model.Description.NumOfWeighedIndices = [num2str(length(foo1)), ' out of ', num2str(size(Tensor.Indices,1))];
clear foo1 foo2
Tensor.Model.Description.TotalNumberOfCells=num2str(size(Tensor.TrainingData,1));
Tensor.Model.Description.NumberOfPlates=num2str(Tensor.NumberOfPlates);
Tensor.Model.Description.W=['TCN ^1^/^3, W<',num2str(intWeightThreshold),' = 0'];

% Y MATRIX IS THE MODEL OUTPUT, I.E. INFECTION INDEX
Tensor.Model.Description.Y='Infection index (pooled over all plates)';
Y = Tensor.InfectionIndex(rowInd);


% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %%% VIF CALCULATIONS TO DETECT MULTICOLLINEARITY IN OUR DATA %%%
% % % 
% % % x_vif_test = Tensor.TrainingData(:,2:end)-1;
% % % vif = testVIF(x_vif_test);
% % % 
% % % disp('Variance Inflation Factors of original model')
% % % disp(sprintf('\t%.3g',vif))
% % % 
% % % matSubsetRowIndices = randperm(size(Tensor.TrainingData,1));
% % % matSubsetRowIndices = matSubsetRowIndices(1:round(size(Tensor.TrainingData,1)/1));
% % % % [bs, ps, rs] = testModelLeaveOneOut   (Tensor.TrainingData(matSubsetRowIndices,:)-1,3);
% % % [bs, ps, rs] = testModelLeaveOneOut_v2(Tensor.TrainingData(matSubsetRowIndices,:)-1,2);
% % % 
% % % cellstrLabels = Tensor.Features';
% % % cellstrLabels{1} = 'constant';
% % % figure();
% % % subplot(2,2,1);bar(rs);title('R-squared values');set(gca,'XTickLabel',cellstrLabels,'fontsize',6)
% % % subplot(2,2,3);bar([nan,vif]);title('Variance Inflation Factors');set(gca,'XTickLabel',cellstrLabels,'fontsize',6)
% % % subplot(2,2,2);bar(bs');title('model parameters');set(gca,'XTickLabel',cellstrLabels,'fontsize',6)
% % % subplot(2,2,4);bar((((ps>0.01)*2)-1)');title('p-value>0.01');set(gca,'XTickLabel',cellstrLabels,'fontsize',6)
% % % 
% % % 
% % % % % % [bs, ps, rs, matAllCombis] = testModelAllCombinations(Tensor.TrainingData(matSubsetRowIndices,:)-1,2);
% % % % % % for i = find(rs==max(rs))
% % % % % %     Tensor.Features(logical(matAllCombis(i,:)))
% % % % % % end
% % % % % % figure();
% % % % % % bar(rs);
% % % 
% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %%% PCA ANALYSIS ON INPUT PARAMETERS %%%
% % % matSubsetRowIndices = randperm(size(Tensor.TrainingData,1));
% % % matSubsetRowIndices = matSubsetRowIndices(1:500000);
% % % X_sample = double(Tensor.TrainingData(matSubsetRowIndices,2:end)-1);
% % % X_sample = nanzscore(X_sample);
% % % 
% % % [COEFF,SCORE,latent,tsquare] = princomp(X_sample); %,'econ'
% % % 
% % % figure();bar(abs(COEFF)');
% % % 
% % % figure();
% % % pareto(100*latent/sum(latent));
% % % xlabel('Principal Component');
% % % ylabel('Variance Explained (%)');
% % % 
% % % return
% % % 
% % % %%% HOW TO GO FROM ANY X-VALUE TO PCA SPACE
% % % %%% X_sample(1,:) * COEFF
% % % %%% SCORE(1,:)
% % % %%% X_sample * COEFF
% % % 
% % % % figure(); bar(latent)
% % % 
% % % %%% DO BINNING OF ZSCORED PCA-SCORES AND REDO MODEL
% % % X_pca = nanzscore(SCORE(:,1:6));
% % % % X_pca = SCORE(:,1:6);
% % % Y_sample = double(Tensor.TrainingData(matSubsetRowIndices,1)-1);
% % % 
% % % 
% % % 
% % % 
% % % %%% COLLINEARITY TESTS ON PCA DATA
% % % vif = testVIF(X_pca)
% % % [bs, ps, rs] = testModelLeaveOneOut([Y_sample(1:50000),X_pca(1:50000,:)],3)
% % % figure();
% % % subplot(2,2,1);bar(rs);title('R-squared values')
% % % subplot(2,2,3);bar([nan,vif]);title('Variance Inflation Factors')
% % % subplot(2,2,2);bar(bs');title('model parameters')
% % % subplot(2,2,4);bar((((ps>0.01)*2)-1)');title('p-value>0.01')
% % % 
% % % 
% % % %%% COLLINEARITY TESTS ON SUBSET OF REAL DATA
% % % matSubsetRowIndices = randperm(size(Tensor.TrainingData,1));
% % % matSubsetRowIndices = matSubsetRowIndices(1:10000);
% % % 
% % % vif = testVIF(Tensor.TrainingData(matSubsetRowIndices,2:end)-1)
% % % [bs, ps, rs] = testModelLeaveOneOut(Tensor.TrainingData(matSubsetRowIndices,:)-1,3)
% % % cellstrLabels = Tensor.Features';
% % % cellstrLabels{1} = 'constant';
% % % figure();
% % % subplot(2,2,1);bar(rs);title('R-squared values');set(gca,'XTickLabel',cellstrLabels,'fontsize',6)
% % % subplot(2,2,3);bar([nan,vif]);title('Variance Inflation Factors');set(gca,'XTickLabel',cellstrLabels,'fontsize',6)
% % % subplot(2,2,2);bar(bs');title('model parameters');set(gca,'XTickLabel',cellstrLabels,'fontsize',6)
% % % subplot(2,2,4);bar((((ps>0.01)*2)-1)');title('p-value>0.01');set(gca,'XTickLabel',cellstrLabels,'fontsize',6)
% % % 
% % % 
% % % %%% REDO BINNING OF PCA DATA FOR PCA-MODEL
% % % [foo, histcount]=histc(X_pca,-6:6);
% % % histcount=uint8(histcount);
% % % X_pca_sample_binned = unique(histcount,'rows');
% % % Y_pca_sample_binned = nan(size(X_pca_sample_binned,1),1);
% % % W_pca_sample_binned = nan(size(X_pca_sample_binned,1),1);
% % % for i = 1:size(X_pca_sample_binned,1)
% % %     disp(sprintf('re-binning orthogonalized matrix index %d of %d',i,size(X_pca_sample_binned,1)))
% % %     matRows=find(sum(histcount == repmat(X_pca_sample_binned(i,:),size(histcount,1),1),2) == size(histcount,2));
% % %     Y_pca_sample_binned(i,1) = nanmean(Y_sample(matRows));
% % %     W_pca_sample_binned(i,1) = size(matRows,1);   
% % % end
% % % 
% % % %%% CALCULATE PCA-MODEL
% % % W_pca_sample_binned = W_pca_sample_binned.^(1/3);
% % % W_pca_sample_binned(W_pca_sample_binned<5)=0;
% % % [b,dev,stats] = glmfit(double(X_pca_sample_binned),double(Y_pca_sample_binned),'normal','weights',double(W_pca_sample_binned),'link','identity');
% % % 
% % % SSE = nansum(W_pca_sample_binned .* (stats.resid .^ 2));
% % % SST = nansum(W_pca_sample_binned .* ((Y_pca_sample_binned - nanmean(Y_pca_sample_binned)).^2));
% % % RSquare = 1-(SSE/SST)



[b,dev,stats] = glmfit(X,Y,'normal','weights',full(diag(W)),'link','identity','constant','off');


% % % cellstrDiscardedDimensions = {};
% % % Xnew = X;
% % % Ynew = Y;
% % % Wnew = W;
% % % TensorFeaturesNew = Tensor.Features;
% % % TrainingDataNew = Tensor.TrainingData;
% % % % while 1
% % %     [bNew,devNew,statsNew] = glmfit(Xnew,Ynew,'normal','weights',full(diag(Wnew)),'link','identity','constant','off');
% % %     
% % %     SSE = nansum(full(diag(Wnew)) .* (statsNew.resid .^ 2));
% % %     SST = nansum(full(diag(Wnew)) .* ((Ynew - nanmean(Ynew)).^2));
% % %     RSquareNew = 1-(SSE/SST)
% % %     sprintf('\t%.2g',bNew)
% % %     
% % %     matInsignificantIndices = find(statsNew.p>=0.01 | isnan(statsNew.p));
% % %     matInsignificantIndices(matInsignificantIndices==1)= []; %never remove the constant term
% % %     
% % %     if isempty(matInsignificantIndices)
% % %         break
% % %     else
% % %         disp(sprintf('  NOTE: SKIPPING %d UNSIGNIFICANT DIMENSIONS!',length(matInsignificantIndices)))
% % %         for i = matInsignificantIndices'
% % %             disp(sprintf('    p-value = %g for %s',statsNew.p(i),TensorFeaturesNew{i}))
% % %         end
% % %         cellstrDiscardedDimensions = [cellstrDiscardedDimensions,TensorFeaturesNew{matInsignificantIndices}];        
% % %         Xnew(:,matInsignificantIndices) = [];
% % %         TensorFeaturesNew(matInsignificantIndices) = [];
% % %         
% % %         TrainingDataNew(:,matInsignificantIndices) = [];
% % %         
% % %         [Xnew, Ynew, tensor_TotalCells2] = recalculateModelFromTrainingData(TrainingDataNew);
% % %         Wnew = (tensor_TotalCells2.^3);
% % %         Wnew(Wnew<intWeightThreshold)=0;
% % %         Wnew=diag(sparse(Wnew));
% % % 
% % %         [bNew,devNew,statsNew] = glmfit(Xnew,Ynew,'normal','weights',full(diag(Wnew)),'link','identity','constant','off');
% % %         SSE = nansum(full(diag(Wnew)) .* (statsNew.resid .^ 2));
% % %         SST = nansum(full(diag(Wnew)) .* ((Ynew - nanmean(Ynew)).^2));
% % %         RSquareNew = 1-(SSE/SST)
% % %         sprintf('\t%.2g',bNew)        
% % %     end
% % % % end
% % % 
% % % %%% STORE MINIMALMODEL
% % % Tensor.MinimalModel.Params = bNew;
% % % TensorFeaturesNew{1} = 'Constant';
% % % Tensor.MinimalModel.Features = TensorFeaturesNew;
% % % Tensor.MinimalModel.X = Xnew;
% % % Tensor.MinimalModel.Y = Ynew;
% % % Tensor.MinimalModel.W = Wnew;
% % % % Tensor.MinimalModel.TotalCells = Tensor.TotalCells;
% % % Tensor.MinimalModel.DiscardParamBasedOnCIs=(statsNew.p>0.01) | isnan(statsNew.p);%(ConfidenceIntervals(:,1)<=0 & ConfidenceIntervals(:,2)>=0);
% % % Tensor.MinimalModel.p=statsNew.p;%(ConfidenceIntervals(:,1)<=0 & ConfidenceIntervals(:,2)>=0);
% % % Tensor.MinimalModel.Stats = statsNew;
% % % Tensor.MinimalModel.Description.PearsonsR2=num2str(RSquareNew);
% % % 
% % % % return



cellstrModelParamFeatures = Tensor.Features(matTensorColumsToUse)';
cellstrModelParamFeatures{1} = 'Constant';

matModelParams = b;


% STORE MODEL IN TENSOR
Tensor.Model.Params = matModelParams;
Tensor.Model.Features = cellstrModelParamFeatures;
Tensor.Model.X = X;
Tensor.Model.Y = Y;
Tensor.Model.W = W;
Tensor.Model.TotalCells = Tensor.TotalCells;

Tensor.Model.DiscardParamBasedOnCIs=(stats.p>0.01) | isnan(stats.p);%(ConfidenceIntervals(:,1)<=0 & ConfidenceIntervals(:,2)>=0);
Tensor.Model.p=stats.p;%(ConfidenceIntervals(:,1)<=0 & ConfidenceIntervals(:,2)>=0);
Tensor.Model.Stats = stats;

%%% FROM THE MATLAB HELP: Curve Fitting Toolbox™ --> Residual Analysis
matWeights = full(diag(W));
SSE = nansum(matWeights .* (stats.resid .^ 2));
SST = nansum(matWeights .* ((Y - nanmean(Y)).^2));
RSquare = 1-(SSE/SST);
Tensor.Model.Description.PearsonsR2=num2str(RSquare);


% Calculate the proportional variation reduction per parameter
Tensor.Model.ExplainatoryPowerPerParameter = nan(1,length(b));
for iDim = 2:length(b)
    yhat = glmval(b([1,iDim],1),X(:,[1,iDim]),'identity','constant','off');
    Tensor.Model.ExplainatoryPowerPerParameter(1,iDim) = 1 - (nanvar(yhat - Y) / nanvar(Y));
end




save(fullfile(strRootPath,'ProbModel_Tensor.mat'),'Tensor')

for i = 1:intNumOfFolders
    try
        disp(sprintf('%s: correct training data on %s',mfilename,cellstrTargetFolderList{i}))
        correctTrainingData4(cellstrTargetFolderList{i}, settings, strRootPath)
    catch foo
        disp(sprintf('%s: failed correct training data per plate',mfilename))
    end
end


try
    disp(sprintf('%s: correct training data',mfilename))
    correctTrainingData3(strRootPath,settings)
catch
    disp(sprintf('%s: failed: correctTrainingData3',mfilename))    
end

try
    disp(sprintf('%s: correct training data with Tensor only',mfilename))
    correctTrainingData_with_tensor(strRootPath)
catch
    disp(sprintf('%s: failed: correctTrainingData3',mfilename))    
end


try
    disp(sprintf('%s: get model parameters per well',mfilename))
    getModelParamsPerWell_glmfit(strRootPath)
catch
    disp(sprintf('%s: failed: getModelParamsPerWell_glmfit',mfilename))        
end

try
    disp(sprintf('%s: display linear fits',mfilename))
    displayLinearFits(strRootPath)
catch
    disp(sprintf('%s: failed: displayLinearFits',mfilename))        
end

try
    disp(sprintf('%s: display fits from tensor',mfilename))
    displayFitsFromTensor(strRootPath)
catch
    disp(sprintf('%s: failed: displayFitsFromTensor',mfilename))        
end


try
    disp(sprintf('%s: reproduce training data curves',mfilename))    
    if Tensor.BinSizes(1,1)==2
    % binary readout, i.e. infection index
        reproduceTrainingDataCurves(strRootPath,[strrep(getlastdir(strRootPath),'_','\_'),' '])
    else
        reproduceTrainingDataCurves(strRootPath,[strrep(getlastdir(strRootPath),'_','\_'),' '])
        reproduceTrainingDataCurves_intensities(strRootPath)
    end
catch
    disp(sprintf('%s: failed: reproduceTrainingDataCurves',mfilename))        
end


% reproduceTrainingDataCurves(strRootPath,[strrep(getlastdir(strRootPath),'_','\_'),' '])
% correctTrainingData2(strRootPath)
% plotTotalCellNumberCurves(strRootPath)
% predictTotalCellNumberCurves2(strRootPath)