function [vif,r2,bs,cellstats] = testVIF_robustfit(TrainingData)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% VIF CALCULATIONS TO DETECT MULTICOLLINEARITY IN OUR DATA %%% 

% [vif,r2,bs,ps] = testVIF(PlateTensor.TrainingData)
% vif = variance inflation factor
% r2  = R squared values
% bs  = contains correlation coefficient b

% DOES NOT EXPECT A COLUMN OF ONES IN THE INPUT DATA

warning off all

bs = nan(size(TrainingData,2),size(TrainingData,2)+1);
r2 = nan(1,size(TrainingData,2));
vif = nan(1,size(TrainingData,2));
cellstats = cell(1,size(TrainingData,2));

matAllColumns = 1:size(TrainingData,2);
for iDim = 1:size(TrainingData,2)
    yt = single(TrainingData(:,iDim));
    xt = TrainingData(:,matAllColumns~=iDim);

%     [b,dev,stats]=glmfit(xt,yt,'normal','link','identity')
    
    [b,stats] = robustfit(xt,yt);
    
    bs(iDim, logical([1,matAllColumns~=iDim]))=b';
    cellstats{iDim}=stats;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%