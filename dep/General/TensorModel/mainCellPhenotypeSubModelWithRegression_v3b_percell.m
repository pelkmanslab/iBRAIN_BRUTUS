
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\070111_SV40_MZ_MZ_P1_1_1\';
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\';
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\Ad5_MZ\061117_Ad5_50K_MZ_2_1\';
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\Ad3_MZ\070313_Ad3_MZ_P1_1\';
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\';

% strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\EvaBerend\081210_A431_SV40_pFAK_ChtxBuptake\BATCH\';
% strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ2\philip_071006_Tfn_MZ_AWaa\BATCH\';
% strRootPath = '\\Nas-biol-imsb-1\share-3-$\Data\Users\50K_final_reanalysis\SV40_MZ\070111_SV40_MZ_MZ_P1_1_1_CP071-1aa\BATCH\';

% strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\50K_copy\SV40_MZ\';
% strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\50K_copy\DV_KY2\';
% strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\50K_copy\MHV_KY\';
% strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\50K_copy\RV_KY_2\';

strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\EvaBerend\081117_MCF10A_SV40_ChTxBup_pFAK\081117_MCF10A_SV40_ChTxBup_pFAK\BATCH\';
strSettingsFile = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\EvaBerend\081117_MCF10A_SV40_ChTxBup_pFAK\081117_MCF10A_SV40_ChTxBup_pFAK\ProbModel_Settings_all_cells_included.txt';

% strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\EvaBerend\090128_A431new_SV40_pFAK_ChtxB\090128_A431new_SV40_pFAK_ChtxB\BATCH\';
% strSettingsFile = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\EvaBerend\090128_A431new_SV40_pFAK_ChtxB\090128_A431new_SV40_pFAK_ChtxB\ProbModel_Settings_all_cells_included.txt';

% strRootPath = 'Y:\Data\Users\Berend\Lilli\090129_A431_ChTxB_pAKT_AKT\090129_A431_ChTxB_pAKT_AKT\BATCH\';
% strSettingsFile = 'Y:\Data\Users\Berend\Lilli\090129_A431_ChTxB_pAKT_AKT\090129_A431_ChTxB_pAKT_AKT\ProbModel_Settings_all_cells_included.txt';

% well G10 of MHV, with MHV-green-intensity
% strRootPath = 'Y:\Data\Users\Berend\50K_copy\MHV_KY\061102_MHV_KY_GFP_50K_GFP_P1_1_CP071-1aa\BATCH\';
% strSettingsFile = 'Y:\Data\Users\Berend\50K_copy\MHV_KY\061102_MHV_KY_GFP_50K_GFP_P1_1_CP071-1aa\ProbModel_Settings.txt';

% strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\50K_copy\DV_KY2\061224_YD_50K_KY_P1_1_1_CP071-1aa\BATCH\';


% strSettingsFile = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\ProbModel_Settings.txt';        
% strSettingsFile = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\EvaBerend\081210_A431_SV40_pFAK_ChtxBuptake\ProbModel_Settings_all_cells_included.txt';
% strSettingsFile = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ2\philip_071006_Tfn_MZ_AWaa\ProbModel_Settings.txt';
% strSettingsFile = '\\nas-biol-imsb-1\share-3-$\Data\Users\50K_final_reanalysis\ProbModel_Settings.txt';
% strSettingsFile = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\50K_copy\ProbModel_Settings.txt';



[matCompleteData, strFinalFieldName] = getRawProbModelData(strRootPath,strSettingsFile);

% matCompleteDataOrig = matCompleteData;
% matCompleteData = matCompleteDataOrig;

% matCompleteData = nanzscore(matCompleteData(1:5:end,:))';
matCompleteData = nanzscore(matCompleteData)';


matCompleteData(:,any(isnan(matCompleteData'),2)) = [];

node_labels = strFinalFieldName';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%% TRY ALL PAIRWISE REGRESSIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% bootstrapped, of course
nodes=size(matCompleteData,1);
intNumOfRounds = 30;
intNumOfCells = size(matCompleteData,2);
matBs = zeros(nodes,nodes+1,intNumOfRounds);
matPs = zeros(nodes,nodes+1,intNumOfRounds);
matPartialVarianceExplained = zeros(nodes,nodes,intNumOfRounds);
for i = 1:intNumOfRounds
    disp(sprintf('%s: bootstrapping, round %d of %d',mfilename,i,intNumOfRounds))
    matRndSubsetData = matCompleteData(:,randperm(size(matCompleteData,2)));
    matRndSubsetData = matRndSubsetData(:,1:round(intNumOfCells * 0.5));
    [vif,r2,matBs(:,:,i),cellstats,matPs(:,:,i),foo,foo,matPartialVarianceExplained(:,:,i)] = testVIF_glmfit(zscore(matRndSubsetData'));
end

% % draw the network of partial variances explained
% matPartialVarianceExplained = nanmedian(matPartialVarianceExplained,3);
% matPartialVarianceExplained(abs(matPartialVarianceExplained) < 0.01) = 0
% for i = 1:7; for ii = 1:7; if i == ii; matPartialVarianceExplained(i,ii)=0; end;end;end
% handleGraph = drawGraph(double(matPartialVarianceExplained),node_labels);


% dag3 = bs(:,2:end)'
dag3 = nanmedian(matBs(:,2:end,:),3)';
dag4 = nanmedian(matBs(:,2:end,:),3)';

figure(); hist(dag4(:),25); vline(-0.1,':r'); vline(0.1,':r'); title('multilinear regression coefficient distribution'); drawnow
figure(); heatmaptext(dag4); colormap('jet'); title('full coefficient diagram'); drawnow

dag3Ps = nanmedian(matPs(:,2:end,:),3)';
figure(); heatmaptext(dag3Ps); colormap('jet'); title('log_1_0 P-values'); drawnow



% ratio of two-way explaining coeficients
matLog2Dag3Ratios = log2( dag3 ./ dag3' );
intRatioThreshold = -0;
dag3(matLog2Dag3Ratios < intRatioThreshold) = 0;

% figure(); hist(matLog2Dag3Ratios(:),18); vline(intRatioThreshold,':r'); title('log2 ratio histogram and minimal threshold'); drawnow

%%% DISCARD NON-SIGNIFICANT CONNECTIONS
numPThreshold = 0;
dag3(dag3Ps>numPThreshold) = 0;

%%% DISCARD WEAK CORRELATIONS
numThreshold = 0.1;
for i = 1:size(dag3,2)
    for ii = 1:size(dag3,1)
        if i == ii; continue; end
        if abs(dag3(ii,i)) < numThreshold &  abs(dag3(i,ii)) < numThreshold
            dag3(i,ii) = 0;
            dag3(ii,i) = 0;
        end
    end
end

% dag3(find(abs(dag3)<numThreshold | isnan(dag3)))=0;
dag3(find(isnan(dag3)))=0;

handleGraph = drawGraph(dag3,node_labels,15,0);


return



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TRY GRAPHICAL GAUSSIAN MODEL %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

intNumOfNodes=size(matCompleteData,1);
intNumOfRounds = 10;
matWeightsBootstrp = zeros(intNumOfNodes,intNumOfNodes,intNumOfRounds);
matDirectionalityBootstrp = zeros(intNumOfNodes,intNumOfNodes,intNumOfRounds);
matPartialVariancesBootstrp = zeros(1,intNumOfNodes,intNumOfRounds);
intNumOfCells = size(matCompleteData,2);
for i = 1:intNumOfRounds
    disp(sprintf('%s: bootstrapping, round %d of %d',mfilename,i,intNumOfRounds))
    matRndSubsetData = matCompleteData(:,randperm(intNumOfCells));
    matRndSubsetData = nanzscore(matRndSubsetData(:,1:round(intNumOfCells * 0.9))');
    [matWeightsBootstrp(:,:,i), matDirectionalityBootstrp(:,:,i), matPartialVariancesBootstrp(:,:,i)] = GGM(matRndSubsetData);
end

matWeights = nanmedian(matWeightsBootstrp,3);
matDirectionality = nanmedian(matDirectionalityBootstrp,3);
matPartialVariances = nanmedian(matPartialVariancesBootstrp,3);

% [matWeights, matDirectionality] = GGM(matCompleteData')

dag3 = zeros(intNumOfNodes);
for i = 1:intNumOfNodes
    for ii = 1:intNumOfNodes
        if i == ii;continue;end
        if (abs(matWeights(i,ii)) > 0.1) & (matDirectionality(i,ii) > -0.1)
            dag3(i,ii) = matWeights(i,ii);
        end
    end
end
dag3 = real(dag3)';
handleGraph = drawGraph(dag3,node_labels,1);
return





