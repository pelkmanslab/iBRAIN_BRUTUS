% strDataPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\50K_Tfn\';
strDataPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ\philip_071006_Tfn_MZ_AWaa\';

if ~exist('Tensor','var')
    disp(sprintf('LOADING %s',fullfile(strDataPath,'ProbModel_Tensor.mat')))
    load(fullfile(strDataPath,'ProbModel_Tensor.mat'))
end

intNumOfPlates = max(Tensor.MetaData(:,find(strcmpi(Tensor.MetaDataFeatures,'PlateNumber'))));

%lookup corresponding data columns
intTCNColumn = find(strcmpi(Tensor.Features,'Image_CorrectedTotalCellNumberPerWell_1'));
intReadoutColumn = find(strcmpi(Tensor.Features,'Nuclei_VirusScreen_ClassicalInfection_1'));
intWellRowColumn = find(strcmpi(Tensor.MetaDataFeatures,'PlateRow'));
intWellColColumn = find(strcmpi(Tensor.MetaDataFeatures,'PlateCol'));
intPlateColumn = find(strcmpi(Tensor.MetaDataFeatures,'PlateNumber'));

matSTDs = [];
matCount = [];
matMeans = [];
matVars = [];

matWellVars = [];
matWellCount = [];

matWellCount = nan(8,12);
matPerWellVarRatios = nan(8,12);
matWellNumOfBins = nan(8,12);

for iPlate = 1:intNumOfPlates
    for iRow = 1:8
        for iCol = 1:12
            
            matCellIndices = find(Tensor.MetaData(:,intWellRowColumn)==iRow & Tensor.MetaData(:,intWellColColumn)==iCol & Tensor.MetaData(:,intPlateColumn)==iPlate);

            matCurrentWellTrainingData = Tensor.TrainingData(matCellIndices,:);

            matWellMeans = [];
            matWellVars = [];            
            matWellCountsPerBin = [];
            
            matWellCount(iRow,iCol) = size(matCurrentWellTrainingData,1);
            matWellNumOfBins(iRow,iCol) = length(unique(Tensor.TrainingData(matCellIndices,2)));

            
            for iDensityBin = unique(Tensor.TrainingData(matCellIndices,2))'

                
                matVars = [matVars; nanvar(single(matCurrentWellTrainingData(matCurrentWellTrainingData(:,2) == iDensityBin,1)-1))];                
                
                matSTDs = [matSTDs; nanstd(single(matCurrentWellTrainingData(matCurrentWellTrainingData(:,2) == iDensityBin,1)-1))];
                matMeans = [matMeans; nanmean(single(matCurrentWellTrainingData(matCurrentWellTrainingData(:,2) == iDensityBin,1)-1))];                
                matCount = [matCount; sum(matCurrentWellTrainingData(:,2) == iDensityBin)];
                
                matWellVars = [matWellVars; nanvar(single(matCurrentWellTrainingData(matCurrentWellTrainingData(:,2) == iDensityBin,1)-1))];                
                matWellMeans = [matWellMeans; nanmean(single(matCurrentWellTrainingData(matCurrentWellTrainingData(:,2) == iDensityBin,1)-1))];
                matWellCountsPerBin = [matWellCountsPerBin; sum(matCurrentWellTrainingData(:,2) == iDensityBin)];
            end
            
            matPerWellVarRatios(iRow,iCol)=nanvar(matWellMeans(matWellCountsPerBin>50))/nanmean(matWellVars(matWellCountsPerBin>50));

        end
    end    
end

% scatter(matPerWellVarRatios(:),matWellCount(:))
% corrcoef(matPerWellVarRatios(~isnan(matPerWellVarRatios)),matWellCount(~isnan(matPerWellVarRatios)))

figure();
subplot(2,5,[1:4,6:9])
hold on
imagesc(flipud(matPerWellVarRatios))
axis tight
title(sprintf('average ( variance of mean values per bin / mean variance within bins) : %.3f',nanmean(matPerWellVarRatios(:))))
colorbar('location','southoutside')
hold off

subplot(2,5,5)
hist(matPerWellVarRatios(:))
title('histogram of variance ratio''s')

subplot(2,5,10)
scatter(matCount,matSTDs)
vline(50,':r','minimum')
hline(nanmean(matSTDs(matCount>200)),'-b')
title('scatter of bin-variance and bin-cellcount')
xlabel('number of cells per bin')
ylabel('variance per bin')
drawnow



figure()
subplot(1,3,1:2)
scatter(matCount,matSTDs)
vline(200,':k')
vline(50,':r')
hline(nanmean(matSTDs(matCount>200)),'-b')
hline(max(matMeans(matCount>200)) - min(matMeans(matCount>200)),'-g')
subplot(1,3,3)
boxplot(matMeans(matCount>200))
drawnow

nanstd(matMeans(matCount>200)) / nanmean(matSTDs(matCount>200))

nanvar(matMeans)/nanmean(matVars)

nanmean(matWellVars)/nanmean(matVars)



matOutp1=[];
matOutp2=[];
for i = matCount'
    if i < max(matCount)
    matOutp1 = [matOutp1;max(matMeans(matCount>i))-min(matMeans(matCount>i))];
    matOutp2 = [matOutp2;max(matSTDs(matCount>i))];
    end
end

[x,nx] = sort(matCount(1:end-1));

figure()
plot(x,matOutp1(nx),'-g',...
    x,matOutp2(nx),'-b'...
    )
legend({'max difference','max stdev'})
xlabel('minimal amount of cells per bin')

