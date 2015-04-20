%a function that finds a peak from a histogram
function peak=peak_estimator(data);

if isempty(data)
	peak=0;
else

bb=6; %8%smaller this is more iterations are needed 
C=1; %1.5
bins=linspace(min(data),max(data),bb);
for iterations=1:20
	interval=C*(bins(2)-bins(1));
	[bars,bar_centers] = hist(data,bins);
	[foo,index]=max(bars);
	bins=linspace(bar_centers(index)-interval,bar_centers(index)+interval,bb);
	data=data(find(data>bins(1)& data<bins(bb)));
	if length(data)<20
		break;
	end
end
peak=bar_centers(index);
iterations;
end

%
% [bars,bar_centers] = hist(data,bins);
% [foo,index]=max(bars);
% maxvalue=bar_centers(index);
% 
% bins=(maxvalue-1):0.25:(maxvalue+1);
% data=data(find(data>bins(1)&data<bins(end)));
% [bars,bar_centers] = hist(data,bins);
% [foo,index]=max(bars);
% maxvalue=bar_centers(index);
% 
% bins=(maxvalue-0.25):0.1250:(maxvalue+0.25);
% data=data(find(data>bins(1)&data<bins(end)));
% [bars,bar_centers] = hist(data,bins);
% [foo,index]=max(bars);
% maxvalue=bar_centers(index);
% 
% bins=(maxvalue-0.125):0.050:(maxvalue+0.125);
% data=data(find(data>bins(1)&data<bins(end)));
% [bars,bar_centers] = hist(data,bins);
% [foo,index]=max(bars);
% maxvalue=bar_centers(index);
% 
% peak=maxvalue;


% bins=-4:1:4;
% [bars,bar_centers] = hist(data,bins);
% [foo,index]=max(bars);
% maxvalue=bar_centers(index);
% 
% bins=(maxvalue-2):0.5:(maxvalue+2);
% data=data(find(data>bins(1)&data<bins(end)));
% [bars,bar_centers] = hist(data,bins);
% [foo,index]=max(bars);
% maxvalue=bar_centers(index);
% 
% bins=(maxvalue-1):0.25:(maxvalue+1);
% data=data(find(data>bins(1)&data<bins(end)));
% [bars,bar_centers] = hist(data,bins);
% [foo,index]=max(bars);
% maxvalue=bar_centers(index);
% 
% bins=(maxvalue-0.25):0.1250:(maxvalue+0.25);
% data=data(find(data>bins(1)&data<bins(end)));
% [bars,bar_centers] = hist(data,bins);
% [foo,index]=max(bars);
% maxvalue=bar_centers(index);
% 
% bins=(maxvalue-0.125):0.050:(maxvalue+0.125);
% data=data(find(data>bins(1)&data<bins(end)));
% [bars,bar_centers] = hist(data,bins);
% [foo,index]=max(bars);
% maxvalue=bar_centers(index);
% 
% peak=maxvalue;