function [vif,r2,bs,cellstats] = testVIF(TrainingData)
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
    xt = single([ones(size(xt,1),1),xt]); % add column of ones
    [b,bint,r,rint,stats]=regress(yt,xt);
    bs(iDim, logical([1,matAllColumns~=iDim]))=b';
    r2(iDim)=stats(1);
    vif(iDim)=1/(1-r2(iDim));
    cellstats{iDim}=stats;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%