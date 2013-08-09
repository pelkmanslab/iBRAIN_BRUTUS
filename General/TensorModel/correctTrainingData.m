function correctTrainingData(strRootPath)

if nargin == 0
    strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\HPV16_MZ_2\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_TDS\';
end

cellstrTargetFolderList = SearchTargetFolders(strRootPath,'Measurements_Image_FileNames.mat');
intNumOfFolders = length(cellstrTargetFolderList);

PlateTensor = cell(intNumOfFolders,1);

MasterTensor = load(fullfile(strRootPath,'ProbModel_Tensor.mat'));
MasterTensor = MasterTensor.Tensor;

matRows = cellstr(regexp(char(65:80),'\w','match'));
matCols = regexp(sprintf('%.2d',1:24),'\d\d','match');

matRawIIs = zeros(intNumOfFolders,50);
matRawTotalCells = zeros(intNumOfFolders,50);
matRawInfectedCells = zeros(intNumOfFolders,50);
matModelExpectedInfectedCells = zeros(intNumOfFolders,50);
matTensorExpectedInfectedCells = zeros(intNumOfFolders,50);


cellstrDataLabels = cell(intNumOfFolders,50);
    
for i = 1:intNumOfFolders
    
    disp(sprintf('processing %s',getlastdir(cellstrTargetFolderList{i})))
    
    PlateTensor{i} = load(fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat'));
    PlateTensor{i} = PlateTensor{i}.Tensor;
    
    if isempty(PlateTensor{i}.TrainingData)
        continue
    end
    
    wellcounter = 0;
    
    for iRows = 3:7
        for iCols = 2:11
            wellcounter = wellcounter + 1;
            matCurWellCellIndices = find(PlateTensor{i}.MetaData(:,1) == iRows & PlateTensor{i}.MetaData(:,2) == iCols);
            
            %%% DATA LABELS: OLIGO NUMBER AND WELL NAME
            cellstrDataLabels{i,wellcounter} = [num2str(PlateTensor{i}.Oligo),'_',matRows{iRows},matCols{iCols}];

            if ~isempty(matCurWellCellIndices)
                
                %%% ORIGINAL INFECTION INDEX                
                intInfectedCells = sum(PlateTensor{i}.TrainingData(matCurWellCellIndices,1)-1);
                intTotalCells = length(matCurWellCellIndices);
                matRawInfectedCells(i,wellcounter) = intInfectedCells;
                matRawTotalCells(i,wellcounter) = intTotalCells;
                matRawIIs(i,wellcounter) = intInfectedCells./intTotalCells;
                
                %%% MODEL EXPECTED INFECTION INDEX            
                X = PlateTensor{i}.TrainingData(matCurWellCellIndices,2:end);
                X = X - 1;
                
%                 X = [X,X.^2];                
%                 X = [X,X.^2,X.^3];
                
                X = [ones(size(X,1),1),X];
                Y = repmat(MasterTensor.Model.Params',size(X,1),1) .* double(X);
                matModelExpectedInfectedCells(i,wellcounter) = round(sum(Y(:)));                
                
            else 
                matRawIIs(i,wellcounter) = NaN;
                matRawInfectedCells(i,wellcounter) = NaN;
                matRawTotalCells(i,wellcounter) = NaN;                
                matModelExpectedInfectedCells(i,wellcounter) = NaN; 
                matTensorExpectedInfectedCells(i,wellcounter) = NaN;
            end

        end
    end
    
end


matModelExpectedIIs = matModelExpectedInfectedCells ./ matRawTotalCells;

matModelExpectedIIs(matModelExpectedIIs<0) == 0;

for i = 1:3

rowIndices = ([1:3]+(3*(i-1)));

matRawLog2RIIs = log2( matRawIIs(rowIndices,:) ./ repmat(nanmedian(matRawIIs(rowIndices,:),2),1,size(matRawIIs(rowIndices,:),2)) );
matRawLog2RIIs(isinf(matRawLog2RIIs)) = NaN;

matModelExpectedRIIs = matModelExpectedIIs(rowIndices,:) ./ repmat(nanmedian(matModelExpectedIIs(rowIndices,:),2),1,size(matModelExpectedIIs(rowIndices,:),2));
matModelExpectedRIIs(matModelExpectedRIIs<0)=0;
matModelExpectedLog2RIIs = log2( matModelExpectedRIIs );
matModelExpectedLog2RIIs(isinf(matModelExpectedLog2RIIs)) = NaN;

matModelCorrectedRII = matRawInfectedCells(rowIndices,:) ./ matModelExpectedInfectedCells(rowIndices,:);
matModelCorrectedRII(matModelCorrectedRII<=0) = NaN;
matModelCorrectedLog2RII = log2(matModelCorrectedRII);
matModelCorrectedLog2RII(isinf(matModelCorrectedLog2RII)) = NaN;

figure()

subplot(3,1,1)
hold on
boxplot(matRawLog2RIIs)
title(['Raw Log2 IIs: std = ',num2str(nanstd(nanmedian(matRawLog2RIIs)))])
ylabel('Raw Log2 IIs')
ylim([-3 3])
hline(0)
hold off

subplot(3,1,2)
hold on
boxplot(matModelExpectedLog2RIIs)
title(['Model Expected Log2 IIs: std = ',num2str(nanstd(nanmedian(matModelExpectedLog2RIIs)))])
ylabel('Model Expected Log2 IIs')
ylim([-3 3])
hline(0)
hold off


subplot(3,1,3)
hold on
boxplot(matModelCorrectedLog2RII)
title(['Model Corrected Log2 IIs: std = ',num2str(nanstd(nanmedian(matModelCorrectedLog2RII)))])
ylabel('Model Corrected Log2 IIs')
ylim([-3 3])
hline(0)
hold off

drawnow

end


