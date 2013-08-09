function [bs, ps, rs] = testModelLeaveOneOut(TrainingData,W_threshold)

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
    
    % RE-BIN CELLS TO MATRIX
    for i = 1:size(tensor_X,1)
        if mod(i,500)==0
            disp(sprintf('re-binning without dimension %d of %d,index %d of %d',iDim,intNumOfDims,i,size(tensor_X,1)))
        end
        matRows=find(sum(xt == repmat(tensor_X(i,:),size(xt,1),1),2) == size(xt,2));
        tensor_Y(i,1) = nanmean(yt(matRows));
        tensor_W(i,1) = size(matRows,1);   
    end
    
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