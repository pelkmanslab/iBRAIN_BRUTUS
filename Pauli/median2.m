function out=median2(in);
good=find(not(isnan(in)).*not(isinf(in)));
if isempty(good)
	out=NaN;
else
	out=median(in(good));
end