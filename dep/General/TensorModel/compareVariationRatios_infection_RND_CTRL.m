strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\DV_KY\';
cellstrTargetFolderList = SearchTargetFolders(strRootPath,'Measurements_Image_FileNames.mat');
cellstrTargetFolderList = getbasedir(cellstrTargetFolderList);
intNumOfFolders = length(cellstrTargetFolderList);

matOrigTCN = single([]);
matOrigInfected = single([]);

disp('ProbMod: merging tensors')
for i = 1:intNumOfFolders

    strLoadedDataPath = strRootPath;
    load(fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat'));

    matOrigTCN = [matOrigTCN,single(Tensor.TotalCells)];
    matOrigInfected = [matOrigInfected, single(Tensor.InfectedCells)];

end



matRatioIIStds = nan(20,1);
matRatioLog2RIIStds = nan(20,1);
matRatioIIVars = nan(20,1);
matRatioLog2RIIVars = nan(20,1);
for iRndControl = 1:20
    
    %%%
    % CALCULATE VARIATIONS
    %%%

    % minimal number of cells per bin to be included
    intMinimalBinSize = 100;

    % minimal number of plates that should be present to calculate infection
    % variance per bin
    intMinimalPlateNumber = 4;

    matOnlyIncludeRows = find(sum(matOrigTCN >= intMinimalBinSize,2) >= intMinimalPlateNumber);

    matTCN = matOrigTCN(matOnlyIncludeRows,:);
    matInfected = matOrigInfected(matOnlyIncludeRows,:);


    %%% RANDOMIZATION AFTER THIS POINT
    % randomize it such that the number of total cells and the number of
    % infected cells is purely randomized over the same amount of bins, with the constraints that the total
    % number of cells and the total number of infected cells are still equal to
    % the original data.
    disp('*** starting randomization of infection indices')
    for iPlate = 1:intNumOfFolders
        matPlateInfected = nansum(matInfected(:,iPlate));
        matPlateTCN = nansum(matTCN(:,iPlate));    
        matPlateII = matPlateInfected ./ matPlateTCN;

        % get randomized infection for each cell
        matRndInfection = rand(matPlateTCN,1) <= matPlateII;
        % correct it such that exact infection indices match
        while sum(matRndInfection) ~= matPlateInfected
            matRndIndexToChange = max(1,round(rand*matPlateTCN));        
            if matPlateInfected > sum(matRndInfection)
                matRndInfection(matRndIndexToChange)=1;
            elseif matPlateInfected < sum(matRndInfection)
                matRndInfection(matRndIndexToChange)=0;            
            end
        end

        % loop over all bins, and recalculate the randomized infection indices
        % - keeping the total cell number per bin equal (! is this a fair
        % assumption?)
        for iBin = 1:size(matTCN,1)
            matTCNInBin = matTCN(iBin,iPlate);
            if isnan(matTCNInBin); matTCNInBin = []; end
            matInfectedInBin = sum(matRndInfection(1:matTCNInBin));
            matInfected(iBin,iPlate) = matInfectedInBin;
            matRndInfection(1:matTCNInBin) = [];
        end
        % throw an error if not all single cells are distributed over all bins
        if ~isempty(matRndInfection)
            error('matRndInfection is not empty!!!')
        end
    end
    disp('*** finished randomization of infection indices')

    matSingleBinIndicesToDiscard = (matTCN<intMinimalBinSize);
    matTCN(matSingleBinIndicesToDiscard)=NaN;
    matInfected(matSingleBinIndicesToDiscard)=NaN;


    % calculate infection index per bin per plate
    matIIPerBinPerPlate = matInfected ./ matTCN;
    % calculate average infection index per bin over all plates
    matIITotal = nanmean(matInfected ./ matTCN,2);

    % calculate log2-relative derivatives of both for comparison
    matAverageIIs = repmat(nansum(matInfected,1) ./ nansum(matTCN,1),size(matIIPerBinPerPlate,1),1);
    matRIIPerBinPerPlate = matIIPerBinPerPlate ./ matAverageIIs;

    % % extra step to prevent infs in data
    % matRIIPerBinPerPlate(matRIIPerBinPerPlate==0) = min(matRIIPerBinPerPlate(matRIIPerBinPerPlate>0));

    % log2 transformation of relative infection indices per bin per plate
    matLog2RIIPerBinPerPlate = log2(matRIIPerBinPerPlate);

    % extra step to remove infs from data
%     disp(sprintf('(removing %d bins with infs from log2 transformed data)',sum(any(isinf(matLog2RIIPerBinPerPlate),2))))
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

    

    matRatioIIStds(iRndControl) = nanstd(matIITotal) / nanmean(nanstd(matIIPerBinPerPlate,0,2));
    matRatioLog2RIIStds(iRndControl) = nanstd(matLog2RIITotal) / nanmean(nanstd(matLog2RIIPerBinPerPlate,0,2));

    matRatioIIVars(iRndControl) = nanvar(matIITotal) / nanmean(nanvar(matIIPerBinPerPlate,0,2))
    matRatioLog2RIIVars(iRndControl) =  nanvar(matLog2RIITotal) / nanmean(nanvar(matLog2RIIPerBinPerPlate,0,2));
  
  
end%iRndControl

save(fullfile(strRootPath,'matVarRatios.mat'),'matRatioIIVars','matRatioLog2RIIVars')