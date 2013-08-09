function [ output_args ] = memtest( input_args )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
results=NaN(100,1);
for(i=1:100)
    a=NaN(1000,1000);
    results(i)=testfun(a);

    
end
end
