function [lower,upper] = Detect_Outlier_levels(matInput, factor)
% [matOutput, matDiscardedValues, matDiscardedIndices] = DiscardOutliers(matInput, factor)
% 
%   DiscardOutliers does simple outlier discarding dependent on the inter
%   quartile range of the data. Values lower and higher then 1.5 times the
%   IQR from the median are discarded, and filtered data is returned in
%   matOutput. The discarded values are returned in matDiscarded.
% 
%   BS, 070511 bugfix for matDiscardedIndices and NaN handling...
%   Edited for detecting levels forhit selection by Pauli 6.6.2007

    if nargin == 1
        factor = 1.5;
    end

    matOutput = [];
    matDiscardedValues = [];
    matDiscardedIndices = [];    

    matSize = size(matInput);
    if matSize(1,1) == 1
        matInput = matInput';
    end

%     [y,IX] = sort(matInput(find(~isnan(matInput))))
    [y,IX] = sort(matInput);

    % compute 25th percentile (first quartile)
    Q(1) = nanmedian(y(find(y<nanmedian(y))));

    % compute 50th percentile (second quartile)
    Q(2) = nanmedian(y);

    % compute 75th percentile (third quartile)
    Q(3) = nanmedian(y(find(y>nanmedian(y))));

    % compute Interquartile Range (IQR)
    IQR = Q(3)-Q(1);
    lower=Q(1)-factor*IQR;
    upper=Q(3)+factor*IQR;

end