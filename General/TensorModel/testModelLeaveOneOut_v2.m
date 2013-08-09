function [bs, ps, rs] = testModelLeaveOneOut_v2(TrainingData,W_threshold)

if nargin<2
    W_threshold = 3;
end

intNumOfDims = size(TrainingData,2);

matAllColumns = 1:intNumOfDims;
bs = nan(intNumOfDims); %model-params
ps = nan(intNumOfDims); %p-values
rs = nan(1,intNumOfDims); %r-squared values
yt = TrainingData(:,1); %model readout

for iDim = matAllColumns
    matCurrentColumns = matAllColumns;
    if iDim>1
        % first round do complete model, then, skip current dimension
        matCurrentColumns(iDim)=[];
    end
    matCurrentColumns(1)=[];%skip first column, is infection data    
    xt = TrainingData(:,matCurrentColumns);
    
    tensor_X = unique(xt,'rows');
    tensor_Y = nan(size(tensor_X,1),1);
    tensor_W = nan(size(tensor_X,1),1);    
    
    
    disp(sprintf('processing dimension %d',iDim))
    
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
            tensor_W(matTensorRows,1) = nansum([tensor_W(matTensorRows,1),size(matCurrentRows,1)]);
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
    
    tensor_Y = tensor_Y ./ tensor_W;
    
    % DO LINEAR REGRESSION ON MATRIX
    tensor_W = tensor_W.^(1/3);
    tensor_W(tensor_W<W_threshold)=0;
    
    [b,dev,stats] = glmfit(double(tensor_X),double(tensor_Y),'normal','weights',double(tensor_W),'link','identity');
    
    % GET RSQUARED VALUE
    SSE = nansum(double(tensor_W) .* (stats.resid .^ 2));
    SST = nansum(double(tensor_W) .* ((double(tensor_Y) - nanmean(double(tensor_Y))).^2));
    rs(iDim) = 1-(SSE/SST);
    
    % STORE RESULTS
    bs(iDim,[1,matCurrentColumns]) = b';
    ps(iDim,[1,matCurrentColumns]) = stats.p';
end

%%% END OF 'LEAVE-ONE-OUT'-TEST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%