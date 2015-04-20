
%% Load data of the Ambion Library

% each directory in endocytome is a project
strRootPath = '\\nas-unizh-imsb1.ethz.ch\share-3-$\Data\Users\Prisca\endocytome_FollowUps';


cellProjectsAndSettings = {
    'Tf_A41',           '111001_A431_w2Tf', 'Settings_Cells_MeanIntensity_RescaledGreen_woDiscarding.txt'
    };




%%%
% parse plate layouts
[cellGeneSymbols,~, cellGeneIDs] = arrayfun(@lookupplatecontent,[82,83,84],'UniformOutput',false);

matAllGeneIDs = cat(3,cellGeneIDs{:});

matGeneIDs = cat(3,cellGeneIDs{:});
matGeneIDs = matGeneIDs(:)';
[matUniqueGeneIDs,m,n] = unique(matGeneIDs);
cellGeneSymbols = cat(3,cellGeneSymbols{:});
cellGeneSymbols = cellGeneSymbols(:)';
% cellUniqueGeneSymbols = cellGeneSymbols(m);
% matMedianResultsPerUniqueGene = nan(intNumOfAssays,size(matUniqueGeneIDs,2));
%%%


intNumOfAssays = size(cellProjectsAndSettings,1);

cellResults = cell(intNumOfAssays,3);

cellPerAssayPerDimReadouts = cell(intNumOfAssays,6);

matAllData = NaN(intNumOfAssays,3*384);
matAllTCNs = NaN(intNumOfAssays,3*384);
matAllLog2IFs = NaN(intNumOfAssays,3*384);
matAllCorrsLCD = NaN(intNumOfAssays,3*384);
matAllCorrsEDGE = NaN(intNumOfAssays,3*384);

cellstrDataPaths = cell(intNumOfAssays,1);

for i = 1:intNumOfAssays

    strLabel = cellProjectsAndSettings{i,1};
    strProjectPath = fullfile(strRootPath,cellProjectsAndSettings{i,2});
    strSettingsFile = fullfile(strRootPath,cellProjectsAndSettings{i,3});

    % load single cell data
    [matData,strColumns,matMetaData, ~, structMiscSettings, cellstrDataPaths{i}] = getRawProbModelData2(strProjectPath, strSettingsFile);

    if ~isequal(cellfun(@filterplatedata,cellstrDataPaths{i}),[82;83;84])
        error('plate order assumption is broken :)')
    end

    % check plate discarding (might be a bit slow...)
%     matIncludedFractionPerWell = NaN(16,24,4);
%     for iPlate = 1:length(cellstrDataPaths{i})
%         strWellIncludeFileName = findfilewithregexpi(cellstrDataPaths{i}{iPlate},'Measurements_Well_.*ObjectsToInclude.mat');
%         foo = load(fullfile(cellstrDataPaths{i}{iPlate},strWellIncludeFileName));
%         % store log2 transformed inclusion data
%         matIncludedFractionPerWell(:,:,iPlate) = log2(foo.matIncludedFractionPerWell ./ nanmedian(foo.matIncludedFractionPerWell(:)));
%     end
    % figure;hist(matIncludedFractionPerWell(~isinf(matIncludedFractionPerWell)),100)

    % log10 transform and remove nans & infs
    matData(:,1) = log10(matData(:,1));
    matBadIX = isinf(matData(:,1)) | isnan(matData(:,1));
    fprintf('%s: removing %d (%d%%) NaNs or Infs',mfilename,sum(matBadIX),round(100*mean(matBadIX)));
    matData(matBadIX,:) = [];
    matMetaData(matBadIX,:) = [];


    % remove some fields...
    % discard both cell size and cell elongation
%         matColIXToRemove = ismember(strColumns,{'AreaShape_Cells_6','AreaShape_Cells_1','CorrectedTotalCellNumberPerWell_Image_1'});
%     matColIXToRemove = ismember(strColumns,{'AreaShape_Cells_6','AreaShape_Cells_1'});
%     matData(:,matColIXToRemove) = []; 
%     strColumns(matColIXToRemove) = [];

    % init corrected values
    matCorrectedValues = NaN(size(matData,1),1);

    % plate wise z-score normalization
    for iPlate = unique(matMetaData(:,3))'
        matPlateIX = matMetaData(:,3)==iPlate;

        % z-score everything plate-wise but EDGE & LCD
        matData(matPlateIX,[1,4,5]) = nanzscore_median(matData(matPlateIX,[1,4,5]));

        % do tensor projection clustering per plate
        matPredictedValues = doBinCorrection(matData(matPlateIX,:), strColumns,9,@nanmedian);%,'display'

        % do correction (substraction)
        matCorrectedValues(matPlateIX,1) = matData(matPlateIX,1) - matPredictedValues;

%             % z-score first column
%             matCorrectedValues(matPlateIX,1) = nanzscore_median(matCorrectedValues(matPlateIX,1));
    end



    % calculate well median values
    [matWellMedians, matOutputTCN] = wellfun(@nanmedian, matCorrectedValues, matMetaData, false);

    % make add trailing empty plate rows and columns
    matWellMedians = pushDatain384(matWellMedians);
    matOutputTCN = pushDatain384(matOutputTCN);

    % discard low cell number
    matWellMedians(matOutputTCN < 150) = NaN;

    % discard wells with too many discarded cells
  %  matWellMedians(matIncludedFractionPerWell < -1) = NaN;

    % look at plate effect correction using bscore
%         h=figure();
    for iPlate = 1:3
        [~, ~, ~, ~, matBScore, ~] = bscore2(matWellMedians(:,:,iPlate));
        % let's apply, and give it a shot
        matWellMedians(:,:,iPlate) = matWellMedians(:,:,iPlate) - matBScore;

%             subplot(2,2,iPlate)
%             imagesc(matWellMedians(:,:,iPlate))
%             imagesc(matBScore,[-1 1])
%             title(getplatenames(cellstrDataPaths{i}{iPlate}))
    end
%         suptitle(sprintf('%s: plate effects [-1, 1]',strLabel))
%         drawnow
%         gcf2pdf('D:\Endocytome\results\plate_effects',strLabel,'overwrite')
%         close(h)

   
    
    % store all well data, z-score normalized.
    matAllData(i,:) = nanzscore_median(matWellMedians(:))';
    matAllTCNs(i,:)= matOutputTCN(:)';
    %matAllLog2IFs(i,:) = matIncludedFractionPerWell(:);
end



% calculate value per plate
cellGeneSymbols

DataPlate1=matAllData(:,1:384);
cellGeneSymbolsPlates=cellGeneSymbols(:,1:384);
DataPlate2=matAllData(:,385:768);

DataPlate3=matAllData(:,769:1152);


DataMedian=median([DataPlate1;DataPlate2;DataPlate3],1);
DataMean=mean([DataPlate1;DataPlate2;DataPlate3],1);

%Calculate correlations between siRNAs

corr(DataPlate1',DataPlate2','rows','pairwise')

corr(DataPlate1',DataPlate3','rows','pairwise')

corr(DataPlate2',DataPlate3','rows','pairwise')



%% Load Data from Pool screen

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load Data of Tf screen 

% each directory in endocytome is a project
strRootPath = '\\nas-unizh-imsb1.ethz.ch\share-3-$\Data\Users\Prisca\endocytome';

cellProjectsAndSettings = {
    'Tfn_A431',         '090217_A431_w2Tf_w3EEA1',          'Settings_Cells_MeanIntensity_RescaledGreen.txt';...
   };


% parse plate layouts
[cellGeneSymbols,~, cellGeneIDs] = arrayfun(@lookupplatecontent,[392,393,394,395],'UniformOutput',false);

matAllGeneIDs = cat(3,cellGeneIDs{:});

matGeneIDs = cat(3,cellGeneIDs{:});
matGeneIDs = matGeneIDs(:)';
[matUniqueGeneIDs,m,n] = unique(matGeneIDs);
cellGeneSymbols = cat(3,cellGeneSymbols{:});
cellGeneSymbols = cellGeneSymbols(:)';
% cellUniqueGeneSymbols = cellGeneSymbols(m);
% matMedianResultsPerUniqueGene = nan(intNumOfAssays,size(matUniqueGeneIDs,2));
%%%



cellResults = cell(intNumOfAssays,3);

cellPerAssayPerDimReadouts = cell(intNumOfAssays,6);

matAllData = NaN(intNumOfAssays,4*384);
matAllTCNs = NaN(intNumOfAssays,4*384);
matAllLog2IFs = NaN(intNumOfAssays,4*384);
matAllCorrsLCD = NaN(intNumOfAssays,4*384);
matAllCorrsEDGE = NaN(intNumOfAssays,4*384);
matAllDataNonCorrected =  NaN(intNumOfAssays,4*384);
cellstrDataPaths = cell(intNumOfAssays,1);



    strLabel = cellProjectsAndSettings{1,1};
    strProjectPath = fullfile(strRootPath,cellProjectsAndSettings{1,2});
    strSettingsFile = fullfile(strRootPath,cellProjectsAndSettings{1,3});

    % load single cell data
    [matData,strColumns,matMetaData, ~, structMiscSettings, cellstrDataPaths{1}] = getRawProbModelData2(strProjectPath, strSettingsFile);

    if ~isequal(cellfun(@filterplatedata,cellstrDataPaths{1}),[392;393;394;395])
        error('plate order assumption is broken :)')
    end

    % check plate discarding (might be a bit slow...)
%     matIncludedFractionPerWell = NaN(16,24,4);
%     for iPlate = 1:length(cellstrDataPaths{i})
%         strWellIncludeFileName = findfilewithregexpi(cellstrDataPaths{i}{iPlate},'Measurements_Well_.*ObjectsToInclude.mat');
%         foo = load(fullfile(cellstrDataPaths{i}{iPlate},strWellIncludeFileName));
%         % store log2 transformed inclusion data
%         matIncludedFractionPerWell(:,:,iPlate) = log2(foo.matIncludedFractionPerWell ./ nanmedian(foo.matIncludedFractionPerWell(:)));
%     end
    % figure;hist(matIncludedFractionPerWell(~isinf(matIncludedFractionPerWell)),100)

    % log10 transform and remove nans & infs
    matData(:,1) = log10(matData(:,1));
    matBadIX = isinf(matData(:,1)) | isnan(matData(:,1));
    fprintf('%s: removing %d (%d%%) NaNs or Infs',mfilename,sum(matBadIX),round(100*mean(matBadIX)));
    matData(matBadIX,:) = [];
    matMetaData(matBadIX,:) = [];


    % remove some fields...
    % discard both cell size and cell elongation
%         matColIXToRemove = ismember(strColumns,{'AreaShape_Cells_6','AreaShape_Cells_1','CorrectedTotalCellNumberPerWell_Image_1'});
    matColIXToRemove = ismember(strColumns,{'AreaShape_Cells_6','AreaShape_Cells_1'});
    matData(:,matColIXToRemove) = []; 
    strColumns(matColIXToRemove) = [];

    % init corrected values
    matCorrectedValues = NaN(size(matData,1),1);

    % plate wise z-score normalization
    for iPlate = unique(matMetaData(:,3))'
        matPlateIX = matMetaData(:,3)==iPlate;

        % z-score everything plate-wise but EDGE & LCD
        matData(matPlateIX,[1,4,5]) = nanzscore_median(matData(matPlateIX,[1,4,5]));

        % do tensor projection clustering per plate
        matPredictedValues = doBinCorrection(matData(matPlateIX,:), strColumns,9,@nanmedian);%,'display'

        % do correction (substraction)
        matCorrectedValues(matPlateIX,1) = matData(matPlateIX,1) - matPredictedValues;

%             % z-score first column
%             matCorrectedValues(matPlateIX,1) = nanzscore_median(matCorrectedValues(matPlateIX,1));
    end



    % calculate well median values
    [matWellMedians, matOutputTCN] = wellfun(@nanmedian, matCorrectedValues, matMetaData, false);

    %calculate well median for uncorrected data
    [matWellMediansNonCorrected, matOutputTCN] = wellfun(@nanmedian, matData(:,1), matMetaData, false);

    
    
    
    
    % make add trailing empty plate rows and columns
    matWellMedians = pushDatain384(matWellMedians);
    matOutputTCN = pushDatain384(matOutputTCN);
    matWellMediansNonCorrected= pushDatain384(matWellMediansNonCorrected);
    % discard low cell number
    matWellMedians(matOutputTCN < 150) = NaN;
    matWellMediansNonCorrected(matOutputTCN < 150) = NaN;
    % discard wells with too many discarded cells
  %  matWellMedians(matIncludedFractionPerWell < -1) = NaN;

    % look at plate effect correction using bscore
%         h=figure();
    for iPlate = 1:4
        [~, ~, ~, ~, matBScore, ~] = bscore2(matWellMedians(:,:,iPlate));
        % let's apply, and give it a shot
        matWellMedians(:,:,iPlate) = matWellMedians(:,:,iPlate) - matBScore;
       
        [~, ~, ~, ~, matBScore, ~] = bscore2(matWellMediansNonCorrected(:,:,iPlate));
        matWellMediansNonCorrected(:,:,iPlate) = matWellMediansNonCorrected(:,:,iPlate) - matBScore;
%             subplot(2,2,iPlate)
%             imagesc(matWellMedians(:,:,iPlate))
%             imagesc(matBScore,[-1 1])
%             title(getplatenames(cellstrDataPaths{i}{iPlate}))
    end
%         suptitle(sprintf('%s: plate effects [-1, 1]',strLabel))
%         drawnow
%         gcf2pdf('D:\Endocytome\results\plate_effects',strLabel,'overwrite')
%         close(h)

   
    
    % store all well data, z-score normalized.
    matAllData(1,:) = nanzscore_median(matWellMedians(:));
    matAllTCNs(1,:) = matOutputTCN(:);
    %matAllLog2IFs(i,:) = matIncludedFractionPerWell(:);
    matAllDataNonCorrected(1,:)= nanzscore_median(matWellMediansNonCorrected(:));


% calculate median score per potential replicates of each entrez_gene_id
cellUniqueGeneSymbols = cellGeneSymbols(m);
cellUniqueGeneSymbols{1} = 'control';% first entry GeneID 0
% matUniqueGeneIDs
matMedianResultsPerUniqueGene = nan(intNumOfAssays,size(matUniqueGeneIDs,2));
matMedianTCNPerUniqueGene = nan(intNumOfAssays,size(matUniqueGeneIDs,2));
matMedianIFPerUniqueGene = nan(intNumOfAssays,size(matUniqueGeneIDs,2));
matMedianCorrScorePerUniqueGene = nan(intNumOfAssays,size(matUniqueGeneIDs,2));
matMedianResultForAllGeneNonCorrected = nan(intNumOfAssays,size(matUniqueGeneIDs,2));
for i = 1:length(matUniqueGeneIDs)
    if sum(n==i)>1
        fprintf('%s: collapsing results for gene id %d: %s\n',mfilename,matUniqueGeneIDs(i),cellUniqueGeneSymbols{i})
    end
    matMedianResultForAllGeneNonCorrected(:,i) = nanmedian(matAllDataNonCorrected(:,n==i),2);
    matMedianResultsPerUniqueGene(:,i) = nanmedian(matAllData(:,n==i),2);
    matMedianTCNPerUniqueGene(:,i) = nanmedian(matAllTCNs(:,n==i),2);
    matMedianIFPerUniqueGene(:,i) = nanmedian(matAllLog2IFs(:,n==i),2);
    matMedianCorrScorePerUniqueGene(:,i) = nanmedian(matAllLog2IFs(:,n==i),2);
end

% An error (?) in the iBRAIN plate layouts suggests there are two geneids
% for the gene symbol SEPT2, namely 1731 and 4735. However, 1731 = SEPT1,
% and 4735 = SEPT2. Correct this!
% matUniqueGeneIDs(ismember(cellUniqueGeneSymbols,'SEPT2'))
cellUniqueGeneSymbols{matUniqueGeneIDs==1731} = 'SEPT1';

% set remaining NaNs to zero
fprintf('%s: setting %d (%.2g%%) NaNs to 0\n',mfilename,sum(isnan(matMedianResultsPerUniqueGene(:))),100*mean(isnan(matMedianResultsPerUniqueGene(:))))
matNanIX = isnan(matMedianResultsPerUniqueGene);
matMedianResultsPerUniqueGene(matNanIX) = 0;
matMedianResultForAllGeneNonCorrected(matNanIX) = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Compare Ambion Tf with the pool screen

%Select Genes that are in the follow up library

matInterestingIX = ismember(cellUniqueGeneSymbols,cellGeneSymbolsPlates);
matDataofInterest = matMedianResultsPerUniqueGene(:,matInterestingIX);
matGenesOverlap = cellUniqueGeneSymbols(:,matInterestingIX);

[geneList,IndexSorting]=sort(matGenesOverlap);
matDataofInterestSoreted = matDataofInterest(:,IndexSorting)

%cHECK ALSO FOR NON CORRECTED DATA

matInterestingIX = ismember(cellUniqueGeneSymbols,cellGeneSymbolsPlates);
matDataofInterestNonCorrected = matMedianResultForAllGeneNonCorrected(:,matInterestingIX);
matGenesOverlap = cellUniqueGeneSymbols(:,matInterestingIX);

[geneList,IndexSorting]=sort(matGenesOverlap);
matDataofInterestSoretedNonCorrected = matDataofInterestNonCorrected(:,IndexSorting)





matInterestingIXFollowUp = ismember(cellGeneSymbolsPlates,cellUniqueGeneSymbols);
matGenesOverlapPlate = cellGeneSymbolsPlates(:,matInterestingIXFollowUp);
matDataOverlapPlate = DataMean(:,matInterestingIXFollowUp);

[geneListFolowUp,IndexSortingFollowUp]=sort(matGenesOverlapPlate);
matDataofInterestSoretedFollowUp = matDataOverlapPlate(:,IndexSortingFollowUp)



corr(matDataofInterestSoreted',matDataofInterestSoretedFollowUp','rows','pairwise')
figure;scatter(matDataofInterestSoreted',matDataofInterestSoretedFollowUp')



%the correlation is sensitive to outlayers...:(
matData = [matDataofInterestSoreted',matDataofInterestSoretedFollowUp'];
corr(matData(matData(:, 1)>-5,:))
sum(~(matData(:,1)>-5))









%Look at the hit list overlap 




%Overlap=mean(ismember(matTop100genesPool,matTop100genesFollowUp))
intMax = 10;
intBoot = 100;
matOverlap = nan(intMax,intBoot);
for ii = 1:intBoot
    [~,B]=sort(matDataofInterest' + (0.25*randn(size(matDataofInterest'))));
    [~,D]=sort(matDataOverlapPlate' + (0.25*randn(size(matDataOverlapPlate'))));
    for i = 1:intMax
        matTop100genesPool = matGenesOverlap(B(1:i));
        matTop100genesFollowUp = matGenesOverlapPlate(D(1:i));
        matOverlap(i,ii)=numel(intersect(matTop100genesPool,matTop100genesFollowUp)) / i;
    end
end
figure
plot(mean(matOverlap,2))
%colorbar







[~,B]=sort(matMedianResultsPerUniqueGene);
[~,D]=sort(matDataOverlapPlate);

matTop100genesPool = cellUniqueGeneSymbols(B(1:400));
matTop100genesFollowUp = matGenesOverlapPlate(D(1:80));
         


%Overlap=mean(ismember(matTop100genesFollowUp,matTop100genesPool))

Overlap=size(intersect(matTop100genesFollowUp,matTop100genesPool),2)



