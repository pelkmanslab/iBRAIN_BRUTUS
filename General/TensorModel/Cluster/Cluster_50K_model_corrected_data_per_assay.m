strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\';
strRootPath = '/Volumes/share-2-$/Data/Users/Berend/BATCH_RESULTS/Data/Users/50K_final/'

cellstrTargetFolderList = SearchTargetFolders(strRootPath,'ProbModel_TensorCorrectedData2.mat');
cellstrTargetFolderList = getbasedir(cellstrTargetFolderList);

intNumOfFolders = length(cellstrTargetFolderList);
disp(sprintf('ProbMod: found %d target folders',intNumOfFolders))

%%% IF NO TARGET FOLDERS ARE FOUND, QUIT
if intNumOfFolders==0
    return
end

cellAssays2Skip = {'SV40_MZ','SV40_CNX','SV40_TDS'};%,'MHV_KY'
% cellAssays2Skip = {'SV40_MZ','MHV_KY'};%

%%% ADD MODEL SPECIFIC MEASUREMENTS, LIKE A OUT-OF-FOCUS IMAGE CORRECTED
%%% TOTAL CELL NUMBER AND TOTAL INFECTED NUMBER PER WELL. ALL FUNCTIONS
%%% SHOULD SKIP IF THE MEASUREMENT IS ALREADY PRESENT.
data=[];
dataColumnLabels = {};

for iAssay = 1:intNumOfFolders

    strFileName = fullfile(cellstrTargetFolderList{iAssay},'ProbModel_TensorCorrectedData2.mat');

    boolSkipAssay = ~isempty(find(strcmpi(getlastdir(cellstrTargetFolderList{iAssay}),cellAssays2Skip), 1));
    
    if not(boolSkipAssay)
        disp(sprintf('loading %s',strFileName))
            
        %%% LOAD TENSOR MODEL CORRECTED DATA PER ASSAY
        load(strFileName);

        %%% PARSE DATA
        matTempOligoData = TensorCorrectedData.OligoNumber;
        matTempIIData = TensorCorrectedData.ModelCorrected.ZSCORELOG2RII;
%        matTempIIData = TensorCorrectedData.Raw.ZSCORELOG2RII;
        matTempColNumbers = TensorCorrectedData.WellColNumber;
        matTempRowNumber = TensorCorrectedData.WellRowNumber;        

        %%% LOOK UP WHICH WELL/DATA-INDICES TO LOAD
        mat50KIndices = find(matTempColNumbers(1,:) > 1 & matTempColNumbers(1,:) < 12 & matTempRowNumber(1,:) > 2 & matTempRowNumber(1,:) < 8);

        %%% COLLECT ALL OLIGO SPECIFIC DATA IN A SINGLE CELL
        cellTempOligoData = cell(3,1);
        for iPlate = 1:size(matTempIIData,1)
            if not(isnan(matTempOligoData(iPlate,1)))
                cellTempOligoData{matTempOligoData(iPlate,1)} = [cellTempOligoData{matTempOligoData(iPlate,1)};matTempIIData(iPlate,mat50KIndices)];
            end
        end
        
        %%% TAKE MEDIAN OF REPLICAS PER OLIGO, AND CONCATENATE ALL TOGETHER
        matMedianOligoData = [];
        for iOligo = 1:3
            matMedianOligoData = [matMedianOligoData,nanmedian(cellTempOligoData{iOligo},1)];
        end
        
%         if size(matMedianOligoData,2) == 50
%             matMedianOligoData = repmat(matMedianOligoData,1,3);
%         end
        
        %%% FUSE OLIGO-MEDIANS TO DATA CONTAINER AND ADD DATACOLUMNLABEL
        if isempty(data) || size(matMedianOligoData,2) == size(data,1)
            data = [data,matMedianOligoData'];
            dataColumnLabels = [dataColumnLabels,getlastdir(cellstrTargetFolderList{iAssay})];
            disp(sprintf('loaded %s',cellstrTargetFolderList{iAssay}))
        else
            disp(sprintf('something funny with %s',cellstrTargetFolderList{iAssay}))            
        end
    else
        disp(sprintf('skipping %s',cellstrTargetFolderList{iAssay}))        
        continue
    end
end

dataRowLabels = {};

[f1,f2]=xlsread('gene_labels3.xls');
labels0=f2(2:end,1);
dataGeneLabels=labels0;
for i=1:3
	dataRowLabels=[dataRowLabels;strcat([num2str(i),'_'],labels0)];
end

%%% REMOVE PLK
disp('REMOVING PLK FROM DATA')
matPLKIndices2remove = find(~cellfun('isempty',strfind(dataRowLabels,'_PLK')));
data(matPLKIndices2remove,:)=[];
dataRowLabels(matPLKIndices2remove)=[];


%%% REMOVING OUTLIERS
% [lower,upper]=Detect_Outlier_levels(data(:));
% data1 = data;
% intTotalDataPoints = length(data1(:));
% matOutlierIndices = (data1>upper*2 | data1<lower*2);
% intTotalOutliersPoints = length(find(matOutlierIndices));
% disp(sprintf('REMOVING %d (%.2f%%) OUTLIERS FROM DATA', intTotalOutliersPoints,100*(intTotalOutliersPoints/intTotalDataPoints)))
% data1(matOutlierIndices) = nanmean(data1(~matOutlierIndices));


data2=data;

% for ii = 1:100
% data2=data2-repmat(nanmean(data2),size(data2,1),1);
% data2=data2./repmat(nanstd(data2),size(data2,1),1);
% data2=data2';
% data2=data2-repmat(nanmedian(data2),size(data2,1),1);
% data2=data2./repmat(nanstd(data2),size(data2,1),1);
% data2=data2';
% end

%%% REMOVING COLUMNS AND ROWS WHICH EXIST ENTIRELY OF ZEROS
disp(sprintf('REMOVING %d NaN DATAPOINTS', length(find(isnan(data2)))))
data2(isnan(data2)) = 0;
% matRowIndices2Remove = find(sum(data2,2) == 0);
% matColIndices2Remove = find(sum(data2,1) == 0);
% data2(matRowIndices2Remove,:)=[];
% dataRowLabels(matRowIndices2Remove)=[];
% data2(:,matColIndices2Remove)=[];
% dataColumnLabels(matColIndices2Remove)=[];
% disp(sprintf('REMOVING %d ROWS AND %d COLUMNS FROM DATA', length(matRowIndices2Remove), length(matColIndices2Remove)))

disp('STARTING NON-BOOTSTRAPPED CLUSTERING')

% map=[ [linspace(1,0,32)',zeros(32,1),zeros(32,1)] ; [zeros(32,1),(linspace(0,1,32)'),zeros(32,1)]];
map=[ [sqrt(linspace(1,0,32)'),zeros(32,1),zeros(32,1)] ; [zeros(32,1),sqrt(linspace(0,1,32)'),zeros(32,1)]];

figure
% clustergram_Pauli(data2,'dimension',2,'LINKAGE','average','COLUMNLABELS',dataColumnLabels,'ROWLABELS',dataRowLabels,'PDIST','cosine','Dendrogram',{'colorthreshold',7}) % 
clustergram_Pauli(data2,'dimension',2,'LINKAGE','average','COLUMNLABELS',dataColumnLabels,'ROWLABELS',dataRowLabels,'PDIST','correlation','Dendrogram',{'colorthreshold',7}) % 
drawnow

% strPrintName = gcf2pdf('','Clustergram')

% return

save('/Users/berendsnijder/Desktop/080820_50K_ModelCorrected.mat','data2','dataRowLabels','dataColumnLabels', 'dataGeneLabels')

return
% % save('\\Nas-biol-imsb-1\share-2-$\Data\Code\Matlab\Berend\results\50K_PhyTree_raw_bootstrap_pca_zscore.mat','data','Tree','datalabels4bootstrap')

%%% CLUSTER VIRUSES
data4bootstrap = data2';
datalabels4bootstrap = dataColumnLabels;

%%% CLUSTER GENES
% data4bootstrap = data2;
% datalabels4bootstrap = dataRowLabels;


%%% CHECK HOW MANY PRINCIPLE COMPONENTS SHOULD BE USED
[pc, zscores, pcvars] = princomp(data4bootstrap);
percent_explained = 100*pcvars/sum(pcvars);
pareto(percent_explained);
xlim([0, 25])
xlabel('Principal Component');
ylabel('Variance Explained (%)');





D = pdist(data4bootstrap,'correlation');
numofremovals = round(.1 * size(data4bootstrap,2));% 10% replacement
if numofremovals < 1
    disp('SKIPPING BOOTSTRAP, NOT ENOUGH DATAPOINTS')
else
    disp(sprintf('STARTING BOOTSTRAPPING, RANDOMLY REPLACING %d COLUMN(S) 5000 TIMES',numofremovals))
    for b = 1:1000
        % BOOTSTRAPPING:

        % WITH REPLACEMENT
        % replace column with other column (single oligo)
        % assuming 10% replacement
        % SINGLE OLIGOS (SINGLE COLUMNS)
        randomindices = randperm(size(data4bootstrap,2));
        removedindices = randomindices(1:numofremovals);
        leftindices = randomindices(numofremovals+1:end);
        % WITH REPLACEMENT
        replacedindices = [leftindices(1:numofremovals),leftindices]; % replace the removed first 15 random indices, with the next random 15 indices...
        bootstrapdata = data4bootstrap(:,replacedindices);
        
%         %%% WITH PRINCIPLE COMPONENT
        [pc, zscores, pcvars] = princomp(bootstrapdata);
        bootstrapdata=zscores(:,1:9);
        
        distancematrix = pdist(bootstrapdata,'correlation');
        D=D+distancematrix;
    end % for b

    % AVERAGE DISTANCE MATRIX
    D=D/(b+1);
end

t=linkage(D,'average');
Tree=phytree(t,datalabels4bootstrap');
%phytreetool_hack(Tree);
phytreetool(Tree);

drawnow

% strPrintName = gcf2pdf('','BootstrapVirusTree')


% save('\\Nas-biol-imsb-1\share-2-$\Data\Code\Matlab\Berend\results\080229_50K_PhyTree_raw_bootstrap_pca_zscore_correlation.mat','t','Tree','datalabels4bootstrap')


return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ANALYZE THE AVERAGE DISTANCE BETWEEN OLIGO'S PER GENE
matSquareD=squareform(D);
cellBootStrappedLeafNames = get(Tree,'LeafNames');

intNumOfGenes=length(dataRowLabels)/3;
matOligoDistances=NaN(3,intNumOfGenes);
for i=1:intNumOfGenes
    cellCurrentOligos = [dataRowLabels{i};...
        dataRowLabels{i+intNumOfGenes};...
        dataRowLabels{i+(2*intNumOfGenes)}];
    [a,b]=ismember(cellCurrentOligos,cellBootStrappedLeafNames);
    
    if sum(a)==3
        
        matOligoDistances(:,i) = [matSquareD(b(1), b(2));...
            matSquareD(b(1), b(3));...
            matSquareD(b(2), b(3))];

    else
        error('not all oligos are found in tree!')
    end
end

figure()
subplot(1,3,1)
hold on
hist(min(matOligoDistances),10)
title('minimal oligo per gene distance')
vline(mean(min(matOligoDistances)),'r',num2str(mean(min(matOligoDistances))))
hold off
subplot(1,3,2)
hist(median(matOligoDistances),10)
vline(mean(median(matOligoDistances)),'r',num2str(mean(median(matOligoDistances))))
title('median oligo per gene distance')
subplot(1,3,3)
hist(mean(matOligoDistances),10)
vline(mean(mean(matOligoDistances)),'r',num2str(mean(mean(matOligoDistances))))
title('mean oligo per gene distance')


% figure()
% hold on
% plot(cumsum(min(matOligoDistancesCorrected)),'g')
% plot(cumsum(min(matOligoDistances)),'r')
% hold off
% drawnow
return



[pc, zscores, pcvars] = princomp(data2);
data3=zscores(:,1:10); %selecting the 10 first principal components
Dpc = pdist(data3,'cosine'); % correlation is the best
t=linkage(Dpc,'average');
Tree=phytree(t,datalabels4bootstrap');
phytreetool(Tree);