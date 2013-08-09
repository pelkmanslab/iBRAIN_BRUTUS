
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\070111_SV40_MZ_MZ_P1_1_1\';
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\';
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\Ad5_MZ\061117_Ad5_50K_MZ_2_1\';
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\Ad3_MZ\070313_Ad3_MZ_P1_1\';

strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\RV_KY_2\';

load(fullfile(strRootPath,'ProbModel_Tensor.mat'))


matPlatesApop = nan(8,12);
matPlatesMit = nan(8,12);
iPlotCounter = 0;
for iPlate = 1:8
    for iRow = 1:8
        for iCol = 1:12

       
            matCurWellIndices = find(Tensor.MetaData(:,1) == iRow & Tensor.MetaData(:,2) == iCol & Tensor.MetaData(:,6) == iPlate);

            % mitotic index
            matPlatesApop(iRow,iCol)=nanmean(Tensor.TrainingData(matCurWellIndices,6))-1;

            % apoptotic index
            matPlatesMit(iRow,iCol)=nanmean(Tensor.TrainingData(matCurWellIndices,7))-1;



            
        end
    end
            iPlotCounter = iPlotCounter + 1;
            subplot(2,8,iPlotCounter)
            imagesc(matPlatesApop)
            title('apop')
            colorbar
            iPlotCounter = iPlotCounter + 1;
            subplot(2,8,iPlotCounter)
            imagesc(matPlatesMit)
            title('mit')
            colorbar    
end



%%% CONCLUSION, DISCARD D03, D04, G05