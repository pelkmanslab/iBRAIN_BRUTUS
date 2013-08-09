function [ mean_values ] =nanmean1(matrix)
mean_values=nanmean(matrix);
for(i=1:size(matrix,2))
    I=find(matrix(:,i)~=matrix(:,i));
    if(length(I)>=2)
        mean_values(i)=NaN;
    end;
end;
end