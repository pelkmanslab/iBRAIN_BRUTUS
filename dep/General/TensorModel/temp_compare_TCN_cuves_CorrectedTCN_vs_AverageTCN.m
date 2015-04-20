strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\RV_KY_2\';

load(fullfile(strRootPath,'ProbModel_Tensor.mat'));

intNumOfPlates = max(Tensor.MetaData(:,end));

%lookup corresponding data columns
intTCNColumn = find(strcmpi(Tensor.Features,'Image_CorrectedTotalCellNumberPerWell_1'));
intReadoutColumn = find(strcmpi(Tensor.Features,'Nuclei_VirusScreen_ClassicalInfection_1'));
intWellRowColumn = find(strcmpi(Tensor.MetaDataFeatures,'PlateRow'));
intWellColColumn = find(strcmpi(Tensor.MetaDataFeatures,'PlateCol'));
intPlateColumn = find(strcmpi(Tensor.MetaDataFeatures,'PlateNumber'));

matCorTcn = [];
matAvgReadout = [];    

for iPlate = 1:intNumOfPlates
    iPlate
    for iRow = 2:7
        for iCol = 2:11
            
            if iRow == 4 && iCol == 3
                disp('skipping PLK1')
                continue
            end
            
            matCellIndices = find(Tensor.MetaData(:,intWellRowColumn)==iRow & Tensor.MetaData(:,intWellColColumn)==iCol & Tensor.MetaData(:,intPlateColumn)==iPlate);

            matAvgReadout = [matAvgReadout,nanmean(Tensor.TrainingData(matCellIndices,intReadoutColumn))-1];
            matCorTcn = [matCorTcn,nanmean(Tensor.TrainingData(matCellIndices,intTCNColumn))];
            
            Tensor.MetaData(matCellIndices,:)=[];
            Tensor.TrainingData(matCellIndices,:)=[];
        end
    end    
end

boxplot(matAvgReadout(:),matCorTcn(:))
