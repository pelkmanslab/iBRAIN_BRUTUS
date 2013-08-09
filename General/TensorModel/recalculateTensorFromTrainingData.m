function [tensor_X, tensor_Y, tensor_TotalCells] = recalculateTensorFromTrainingData(TrainingData)
% BS, 080819: Adjusted recalculateModelFromTrainingData to
% recalculateTensorFromTrainingData, using ismember rather than find to get
% corresponding tensor dimension/bin numbers.

xt = TrainingData(:,2:end)-1;
yt = TrainingData(:,1)-1;

tensor_X = unique(xt,'rows');
tensor_Y = nan(size(tensor_X,1),1);
tensor_TotalCells = nan(size(tensor_X,1),1);

disp('processing trainingdata')

intStepSize = 10000;%optimal for 1500(?)
intNumOfRows = size(xt,1);    
intNumOfSteps = round(intNumOfRows/intStepSize)+1;

for iStep = 0:intNumOfSteps
    if iStep == 0 || mod(iStep,10)==0 || iStep == intNumOfSteps
        disp(sprintf('  step %d of %d',iStep,intNumOfSteps))
    end
    if (intStepSize+(iStep*intStepSize)) > intNumOfRows
        matDataRange = [1+(iStep*intStepSize):intNumOfRows];
    else
        matDataRange = [1+(iStep*intStepSize):intStepSize+(iStep*intStepSize)];
    end

    current_xt = uint8(xt(matDataRange,:));
    current_yt = uint8(yt(matDataRange,:));
%     current_combinations_xt = uint8(unique(current_xt,'rows'));


    % [c, ia] = ismember(matTrainingData,matTensorIndices,'rows');
    % matTensorExpectedInfection = matTensorInfectionIndices(ia);
    [tf,loc]=ismember(current_xt,tensor_X,'rows');

    unique_loc = unique(loc);
    for iLoc = unique_loc'
        tensor_Y(iLoc,1) = nansum([tensor_Y(iLoc,1),nansum(current_yt(loc==iLoc))]);
        tensor_TotalCells(iLoc,1) = nansum([tensor_TotalCells(iLoc,1),size(find(loc==iLoc),1)]);
    end
    
    %%% RE-BIN CELLS TO MATRIX
    %%% SHOULD REALLY BE REDONE WITH ISMEMBER, WILL BE 10X FASTER!!!    
%     for i = 1:size(current_combinations_xt,1)
% 
%         matCurrentRows=find(sum(current_xt == repmat(current_combinations_xt(i,:),size(current_xt,1),1),2) == size(current_xt,2));
%         matTensorRows=find(sum(tensor_X == repmat(current_combinations_xt(i,:),size(tensor_X,1),1),2) == size(tensor_X,2));            
% 
%         tensor_Y(matTensorRows,1) = nansum([tensor_Y(matTensorRows,1),nansum(current_yt(matCurrentRows))]);
%         tensor_TotalCells(matTensorRows,1) = nansum([tensor_TotalCells(matTensorRows,1),size(matCurrentRows,1)]);
%         % delete processed rows from current batch
%         current_xt(matCurrentRows,:)=[];
%         current_yt(matCurrentRows,:)=[];
%     end
%     if ~(isempty(current_xt))
%         disp('***ALERT: current_xt IS NOT EMPTY!')
%         disp(sprintf('number of unclassifyable objects: %d',size(matTrainingData,1)))
%         disp(unique(matTrainingData,'rows'))
%     end



end

if nansum(tensor_TotalCells) ~= intNumOfRows
    disp('***ALERT: NUMBER OF COUNTED CELLS IN tensor_W DOES NOT MATCH NUMBER OF CELLS IN TrainingData')
    disp(sprintf('  num of cells in tensor_W = %d',nansum(tensor_TotalCells)))
    disp(sprintf('  num of cells in trainingdata = %d',intNumOfRows))        
end

tensor_Y = tensor_Y ./ tensor_TotalCells;

tensor_Y=double(tensor_Y);
tensor_X=double(tensor_X);
tensor_TotalCells=double(tensor_TotalCells);