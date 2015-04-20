% strDataPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\50K_Tfn\';
strDataPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ\philip_071006_Tfn_MZ_AWaa\';

if ~exist('Tensor','var')
    disp(sprintf('LOADING %s',fullfile(strDataPath,'ProbModel_Tensor.mat')))
    load(fullfile(strDataPath,'ProbModel_Tensor.mat'))
end

matTrainingData = Tensor.TrainingData(1:end,:);

% matTrainingData = Tensor.TrainingData;

intMinBinSize = 200;
matOkBinIndices = find(Tensor.Model.TotalCells>intMinBinSize);
intNumOfOkBins = length(matOkBinIndices);

matBinII = nan(1,intNumOfOkBins);

for iBin = 1:intNumOfOkBins
    disp(sprintf('bin %d of %d',iBin,intNumOfOkBins))
    matBinDims = Tensor.Model.X(matOkBinIndices(iBin),2:end)+1;

    matCellsInCurrentBin=ismember(matTrainingData(:,2:end),matBinDims,'rows');
    matCellsInCurrentBinIndices = find(matCellsInCurrentBin);

    matBinII(iBin) = nanstd(single(matTrainingData(matCellsInCurrentBinIndices,1)-1));

end    
    
nanmean(matBinII)
matDiff = [];
for iMinBinSize = 1:max(Tensor.Model.TotalCells)
    matOkBinIndices = find(Tensor.Model.TotalCells>iMinBinSize);
    matDiff = [matDiff;max(Tensor.Model.Y(matOkBinIndices)) - min(Tensor.Model.Y(matOkBinIndices))];
end

figure();hist(matBinII)
figure(); plot(matDiff)