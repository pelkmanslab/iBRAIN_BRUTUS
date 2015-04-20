function [ out ] = testfun( a)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

out=nanmean(lin(arrayfun(@(x) x+1,a)));
% out1=NaN(1000,1000);
% for(i=1:1000000)
%  out1(i)=a(i)+1;
% end;
% 
 clear('a');
% out=nanmean(lin(out1));
% clear('out1');
end

