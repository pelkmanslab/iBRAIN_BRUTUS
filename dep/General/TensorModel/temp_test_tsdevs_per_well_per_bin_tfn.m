strDataPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\50K_Tfn\';
% strDataPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ\philip_071006_Tfn_MZ_AWaa\';

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

matCorTcn = [];
matAvgReadout = [];    

matCorrectedStd = [];
matRawStd = [];

for iPlate = 1:intNumOfPlates
    iPlate
    for iRow = 3:7
        for iCol = 2:11
            
            matCellIndices = find(Tensor.MetaData(:,intWellRowColumn)==iRow & Tensor.MetaData(:,intWellColColumn)==iCol & Tensor.MetaData(:,intPlateColumn)==iPlate);

            [yhat,dylo,dyhi] = glmval(Tensor.Model.Params, single(Tensor.TrainingData(matCellIndices,2:end)-1),'identity',Tensor.Model.Stats);
            
            matCorrectedStd = [matCorrectedStd, nanstd((single(Tensor.TrainingData(matCellIndices,1)-1) - yhat))];
            matRawStd = [matRawStd, nanstd(single(Tensor.TrainingData(matCellIndices,1)-1))];

        end
    end   
    
    
    
    
    for iBin = 1:intNumOfOkBins

        matBinDims = Tensor.Model.X(matOkBinIndices(iBin),2:end)+1;

        matCellsInCurrentBin=ismember(matTrainingData(:,2:end),matBinDims,'rows');
        matCellsInCurrentBinIndices = find(matCellsInCurrentBin);

        if length(matCellsInCurrentBinIndices)>intMinBinSize
            disp(sprintf('%d of %d: checked',iBin,intNumOfOkBins))
        else
            disp(sprintf('%d of %d: skipped',iBin,intNumOfOkBins))        
            continue
        end


        for iBoot = 1:intNumOfRuns

    %         rndIndicesFromBin = randperm(length(matCellsInCurrentBinIndices));

            intSampleSize = length(matCellsInCurrentBinIndices);

    %         rndIndicesFromBin = rndIndicesFromBin(1:intSampleSize);
    %         rndIndicesFromBin = matCellsInCurrentBinIndices(rndIndicesFromBin);

    %         matBinII(iBin,iBoot) = nanmean(matTrainingData(rndIndicesFromBin,1)-1);
            matBinII(iBin,iBoot) = nanstd(single(matTrainingData(matCellsInCurrentBinIndices,1)-1));

    %         iRndPick = round((rand*(intNumOfAllCells-intSampleSize)) / intSampleSize);
    %         if iRndPick < 1; iRndPick=1; end
    %         if iRndPick*intSampleSize > intNumOfAllCells; iRndPick = iRndPick - 1; end
    %         matCurrentRndIndicesFromAll = rndIndicesFromAll(((iRndPick-1)*intSampleSize)+1:iRndPick*intSampleSize);

    %         rndIndicesFromAll = randperm(intNumOfAllCells);
    %         matCurrentRndIndicesFromAll = rndIndicesFromAll(1:intSampleSize);

    %         matAllII(iBin,iBoot) = nanmean(matTrainingData(matCurrentRndIndicesFromAll,1)-1);    
    %         matAllII(iBin,iBoot) = nanstd(single(matTrainingData(matCurrentRndIndicesFromAll,1)-1));

        end
    end    
    
    
    
end

figure
[x1,y1]=hist(matCorrectedStd)
[x2,y2]=hist(matRawStd)
subplot(1,2,1)
hold on
plot(y1,x1,'-g',...
    y2,x2,'-r')
vline(nanmedian(matCorrectedStd),':g')
vline(nanmedian(matRawStd),':r')
legend({'corrected','raw'},'fontsize',8)
hold off

[x3,y3]=hist((matCorrectedStd ./ matRawStd))
subplot(1,2,2)
hold on
plot(y3,x3,'-b')
vline(nanmedian(matCorrectedStd ./ matRawStd))
hold off
drawnow