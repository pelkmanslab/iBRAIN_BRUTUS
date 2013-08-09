function m=block_mean(x)
x(x==0)=NaN;
m=nanstd(x(:));


