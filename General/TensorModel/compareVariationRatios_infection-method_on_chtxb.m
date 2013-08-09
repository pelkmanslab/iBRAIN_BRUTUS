strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Lilli\070716_ChTxB_A431\';
cellstrTargetFolderList = SearchTargetFolders(strRootPath,'Measurements_Image_FileNames.mat');
cellstrTargetFolderList = getbasedir(cellstrTargetFolderList);
intNumOfFolders = length(cellstrTargetFolderList);

matOrigTCN = single([]);
matOrigInfected = single([]);
matOrigReadout = single([]);

disp('ProbMod: merging tensors')
for i = 1:intNumOfFolders

    strLoadedDataPath = strRootPath;
    load(fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat'));

    matOrigTCN = [matOrigTCN,single(Tensor.TotalCells)];
    matOrigInfected = [matOrigInfected, single(Tensor.InfectedCells)];
    matOrigReadout = [matOrigReadout, single(Tensor.InfectionIndex)];
end


%%%
% CALCULATE VARIATIONS
%%%

% minimal number of cells per bin to be included
intMinimalBinSize = 100;

% minimal number of plates that should be present to calculate infection
% variance per bin
intMinimalPlateNumber = 3;

matOnlyIncludeRows = find(sum(matOrigTCN >= intMinimalBinSize,2) >= intMinimalPlateNumber);

matTCN = matOrigTCN(matOnlyIncludeRows,:);
matInfected = matOrigInfected(matOnlyIncludeRows,:);
matReadout = matOrigReadout(matOnlyIncludeRows,:);

matSingleBinIndicesToDiscard = (matTCN<intMinimalBinSize);
matTCN(matSingleBinIndicesToDiscard)=NaN;
matInfected(matSingleBinIndicesToDiscard)=NaN;
matReadout(matSingleBinIndicesToDiscard)=NaN;

% disp('*** RANDOMIZING')
% for i = 1:size(matInfected,2)
%     disp(sprintf('    RND PLATE %d',i))
%     matRndIndices = randperm(size(matInfected,1));
%     matInfected(:,i) = matInfected(matRndIndices,i);
%     matTCN(:,i) = matTCN(matRndIndices,i);    
% end
% disp('*** RANDOMIZATION COMPLETED')


% calculate infection index per bin per plate
matIIPerBinPerPlate = matReadout;
% calculate average infection index per bin over all plates
matIITotal = nanmean(matReadout,2);

% calculate log2-relative derivatives of both for comparison
matAverageIIs = repmat(nanmean(matReadout,1),size(matIIPerBinPerPlate,1),1);
matRIIPerBinPerPlate = matIIPerBinPerPlate ./ matAverageIIs;

% % extra step to prevent infs in data
% matRIIPerBinPerPlate(matRIIPerBinPerPlate==0) = min(matRIIPerBinPerPlate(matRIIPerBinPerPlate>0));

% log2 transformation of relative infection indices per bin per plate
matLog2RIIPerBinPerPlate = log2(matRIIPerBinPerPlate);

% extra step to remove infs from data
disp(sprintf('(removing %d bins with infs from log2 transformed data)',sum(any(isinf(matLog2RIIPerBinPerPlate),2))))
matLog2RIIPerBinPerPlate(any(isinf(matLog2RIIPerBinPerPlate),2),:)=[];
% alternative, set infs to the lowest log2 value observed
% matLog2RIIPerBinPerPlate(isinf(matLog2RIIPerBinPerPlate))=nanmin(matLog2RIIPerBinPerPlate(~isinf(matLog2RIIPerBinPerPlate)));
matLog2RIITotal = nanmean(matLog2RIIPerBinPerPlate,2);


% size(matIIPerBinPerPlate)
% size(matIITotal)
disp(sprintf('\n%s:\n%d bins have at least %d plates with at least %d cells per bin, excluding infs from data\n',getlastdir(strRootPath),length(matLog2RIITotal),intMinimalPlateNumber,intMinimalBinSize))

% nanvar(matIITotal) / nanmean(nanvar(matIIPerBinPerPlate,0,2))
% nanvar(matLog2RIITotal) / nanmean(nanvar(matLog2RIIPerBinPerPlate,0,2))
% 

nanvar(matIITotal) / nanmean(nanvar(matIIPerBinPerPlate,0,2))
nanvar(matLog2RIITotal) / nanmean(nanvar(matLog2RIIPerBinPerPlate,0,2))

% nanstd(matIITotal) / nanmean(nanstd(matIIPerBinPerPlate,0,2))
% nanstd(matLog2RIITotal) / nanmean(nanstd(matLog2RIIPerBinPerPlate,0,2))
