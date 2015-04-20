function [vif,r2,bs,cellstats,ps,fStat,fStatPval] = testVIF_glmfit(TrainingData)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% VIF CALCULATIONS TO DETECT MULTICOLLINEARITY IN OUR DATA %%% 

% [vif,r2,bs,ps] = testVIF(PlateTensor.TrainingData)
% vif = variance inflation factor
% r2  = R squared values
% bs  = contains correlation coefficient b

% DOES NOT EXPECT A COLUMN OF ONES IN THE INPUT DATA

warning off all

bs = nan(size(TrainingData,2),size(TrainingData,2)+1);
ps = nan(size(TrainingData,2),size(TrainingData,2)+1);
r2 = nan(1,size(TrainingData,2));
vif = nan(1,size(TrainingData,2));
cellstats = cell(1,size(TrainingData,2));

% regress only output
fStat = nan(1,size(TrainingData,2));
fStatPval = nan(1,size(TrainingData,2));

matAllColumns = 1:size(TrainingData,2);
for iDim = 1:size(TrainingData,2)
    yt = single(TrainingData(:,iDim));
    xt = TrainingData(:,matAllColumns~=iDim);

    %%% using glmfit
    [b,dev,stats]=glmfit(xt,yt,'normal','link','identity');
    bs(iDim, logical([1,matAllColumns~=iDim]))=b';
    ps(iDim, logical([1,matAllColumns~=iDim]))=stats.p';
    cellstats{iDim}=stats;

    %%% using regress
    xt = [ones(size(xt,1),1,'single'),xt];
    [b,bint,r,rint,stats] = regress(yt,xt);
    bs(iDim, logical([1,matAllColumns~=iDim])) = b';
    r2(iDim) = stats(1);
    vif(iDim) = 1/(1-r2(iDim));
    cellstats{iDim}=stats;
    
    fStat(iDim) = stats(2);
    fStatPval(iDim) = stats(3);
    
    
    % calculate the adjusted R2 statistic (as coded in regstats)
%     yhat = [ones(size(xt,1),1,'single'),xt]*b;
    yhat = xt*b;
    residuals = yt - yhat;
    nobs = length(yt);
    p = length(b);
    dfe = nobs-p;
    dft = nobs-1;
    ybar = mean(yt);
    sse = norm(residuals)^2;    % sum of squared errors
    sst = norm(yt - ybar)^2;     % total sum of squares;
    r2(iDim) = 1 - (sse./sst)*(dft./dfe);  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%