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

matCorTcn = [];
matAvgReadout = [];    

matCorrectedStd = [];
matCorrectedReadout = [];
matRawStd = [];
matWellSize = [];
matAvgParams = [];

matPlateIntensity = nan(8,12);
matPlateTCN = nan(8,12);

for iPlate = 1:intNumOfPlates
    iPlate
    for iRow = 1:8
        for iCol = 1:12
            
            matCellIndices = find(Tensor.MetaData(:,intWellRowColumn)==iRow & Tensor.MetaData(:,intWellColColumn)==iCol & Tensor.MetaData(:,intPlateColumn)==iPlate);

            [yhat,dylo,dyhi] = glmval(Tensor.Model.Params, single(Tensor.TrainingData(matCellIndices,2:end)-1),'identity',Tensor.Model.Stats);
            
            matCorrectedStd = [matCorrectedStd, nanstd((single(Tensor.TrainingData(matCellIndices,1)-1) - yhat))];
            matCorrectedReadout = [matCorrectedReadout, nanmean((single(Tensor.TrainingData(matCellIndices,1)-1) - yhat))];            
            matRawStd = [matRawStd, nanstd(single(Tensor.TrainingData(matCellIndices,1)-1))];
            matWellSize = [matWellSize,length(matCellIndices)];
            
            matAvgParams = [matAvgParams; nanmean(single(Tensor.TrainingData(matCellIndices,:)-1))];
            
            matPlateIntensity(iRow,iCol) = nanmean(double(Tensor.TrainingData(matCellIndices,1)-1));
            matPlateTCN(iRow,iCol) = nanmean(double(Tensor.TrainingData(matCellIndices,end)-1));
        end
    end    
end

matBScore = nan(8,12);
matColMeds = nanmedian(matPlateIntensity,1);
matRowMeds = nanmedian(matPlateIntensity,2);
for iRow = 1:8
    for iCol = 1:12
        matBScore(iRow,iCol) = (matColMeds(iCol) + matRowMeds(iRow))/2;
    end
end

figure()
subplot(2,2,1)
imagesc(matBScore)
title('bscore')
colorbar

subplot(2,2,2)
imagesc(matPlateIntensity)
title('average intensity')
colorbar

subplot(2,2,3)
imagesc(matPlateTCN)
title('total cell number')
colorbar
drawnow

%%% INTER-WELL STANDARD DEVIATION IMPROVEMENT (IN PERCENTS, %)
100 * ((std(matCorrectedReadout) - std(matAvgParams(:,1))) / std(matAvgParams(:,1)))


% figure()
% scatter(matRawStd,matWellSize)
% 
% figure()
% scatter(matRawStd,(1-(matCorrectedStd ./ matRawStd)))

% figure()
% intNumOfDims = size(Tensor.Model.X,2);
% for i = 1:intNumOfDims
%     subplot(2,3,i)
%     
%     scatter(matAvgParams(:,i),(1-(matCorrectedStd ./ matRawStd)))
%     xlabel(strrep(Tensor.Features{i},'_','\_'))
% %     ylabel('standard deviation')
% end




% figure
% [x1,y1]=hist(matCorrectedStd)
% [x2,y2]=hist(matRawStd)
% subplot(1,2,1)
% hold on
% plot(y1,x1,'-g',...
%     y2,x2,'-r')
% vline(nanmedian(matCorrectedStd),':g')
% vline(nanmedian(matRawStd),':r')
% legend({'corrected','raw'},'fontsize',8)
% hold off
% 
% [x3,y3]=hist((matCorrectedStd ./ matRawStd))
% subplot(1,2,2)
% hold on
% plot(y3,x3,'-b')
% vline(nanmedian(matCorrectedStd ./ matRawStd))
% hold off
% drawnow