% define data set
%x = [16, 22, 24, 24, 27, 28, 29, 30]';
function [outliersQ1, outliersQ3, Noutliers] = quartile(x, factor)
    Nx = size(x,2);

    % compute mean
    mx = mean(x(1,:),2);

    % compute the standard deviation
    sigma = std(x(1,:),0,2);

    % compute the median
    medianx = median(x(1,:),2);

    % STEP 1 - rank the data
    [y yIndex] = sort(x(1,:),2);

    % compute 25th percentile (first quartile)
    Q(1) = median(y(find(y<median(y))));

    % compute 50th percentile (second quartile)
    Q(2) = median(y);

    % compute 75th percentile (third quartile)
    Q(3) = median(y(find(y>median(y))));

    % compute Interquartile Range (IQR)
    IQR = Q(3)-Q(1);

    % compute Semi Interquartile Deviation (SID)
    % The importance and implication of the SID is that if you 
    % start with the median and go 1 SID unit above it 
    % and 1 SID unit below it, you should (normally) 
    % account for 50% of the data in the original data set
    SID = IQR/2;

    % determine extreme Q1 outliers (e.g., x < Q1 - 3*IQR)
    iy = find(y<Q(1)-factor*IQR);
    if length(iy)>0,
%         outliersQ1 = y(iy);
%         outliersQ1Index = yIndex(iy);
        outliersQ1(1) = y(iy);
        outliersQ1(2) = yIndex(iy);
    else
        outliersQ1 = [];
    end

    % determine extreme Q3 outliers (e.g., x > Q1 + 3*IQR)
    iy = find(y>Q(1)+factor*IQR);
    if length(iy)>0,
        outliersQ3(1,1:length(iy)) = y(iy);
        outliersQ3(2,1:length(iy)) = yIndex(iy);
    else
        outliersQ3 = [];
    end

    % compute total number of outliers
    Noutliers = length(outliersQ1)+length(outliersQ3);

    % display results
    disp(['Mean:                                ',num2str(mx)]);
    disp(['Standard Deviation:                  ',num2str(sigma)]);
    disp(['Median:                              ',num2str(medianx)]);
    disp(['25th Percentile:                     ',num2str(Q(1))]);
    disp(['50th Percentile:                     ',num2str(Q(2))]);
    disp(['75th Percentile:                     ',num2str(Q(3))]);
    disp(['Semi Interquartile Deviation:        ',num2str(SID)]);
    disp(['Number of outliers:                  ',num2str(Noutliers)]);

end