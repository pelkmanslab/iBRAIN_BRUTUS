function [tensor_X, tensor_Y, tensor_TotalCells] = recalculateModelWithDimensions(TrainingData,matCurrentColumns)

intNumOfDims = size(TrainingData,2);

matAllColumns = 1:intNumOfDims;

matCurrentColumns = logical([0,matAllCombis(iDim,:)]);

xt = TrainingData(:,matCurrentColumns);

tensor_X = unique(xt,'rows');
tensor_Y = nan(size(tensor_X,1),1);
tensor_TotalCells = nan(size(tensor_X,1),1);

disp(sprintf('processing dimension-combination %d of %d',iDim,intNumOfCombis))

intStepSize = 40000;%optimal for 1500(?)
intNumOfRows = size(xt,1);    
intNumOfSteps = round(intNumOfRows/intStepSize)+1;

for iStep = 0:intNumOfSteps
    disp(sprintf('  step %d of %d',iStep,intNumOfSteps))
    if (intStepSize+(iStep*intStepSize)) > intNumOfRows
        matDataRange = [1+(iStep*intStepSize):intNumOfRows];
    else
        matDataRange = [1+(iStep*intStepSize):intStepSize+(iStep*intStepSize)];
    end

    current_xt = uint8(xt(matDataRange,:));
    current_yt = uint8(yt(matDataRange,:));
    current_combinations_xt = uint8(unique(current_xt,'rows'));

    % RE-BIN CELLS TO MATRIX
    for i = 1:size(current_combinations_xt,1)
%             if mod(i,500)==0
%                 disp(sprintf('re-binning without dimension %d of %d,index %d of %d',iDim,intNumOfDims,i,size(tensor_X,1)))
%             end
        matCurrentRows=find(sum(current_xt == repmat(current_combinations_xt(i,:),size(current_xt,1),1),2) == size(current_xt,2));
        matTensorRows=find(sum(tensor_X == repmat(current_combinations_xt(i,:),size(tensor_X,1),1),2) == size(tensor_X,2));            

        tensor_Y(matTensorRows,1) = nansum([tensor_Y(matTensorRows,1),nansum(current_yt(matCurrentRows))]);
        tensor_TotalCells(matTensorRows,1) = nansum([tensor_W(matTensorRows,1),size(matCurrentRows,1)]);
        % delete processed rows from current batch
        current_xt(matCurrentRows,:)=[];
        current_yt(matCurrentRows,:)=[];
    end

    if ~(isempty(current_xt))
        disp('***ALERT: current_xt IS NOT EMPTY!')
        disp(sprintf('number of unclassifyable objects: %d',size(matTrainingData,1)))
        disp(unique(matTrainingData,'rows'))
    end

end

if nansum(tensor_W) ~= intNumOfRows
    disp('***ALERT: NUMBER OF COUNTED CELLS IN tensor_W DOES NOT MATCH NUMBER OF CELLS IN TrainingData')
    disp(sprintf('  num of cells in tensor_W = %d',nansum(tensor_W)))
    disp(sprintf('  num of cells in trainingdata = %d',intNumOfRows))        
end        

tensor_Y = tensor_Y ./ tensor_TotalCells;