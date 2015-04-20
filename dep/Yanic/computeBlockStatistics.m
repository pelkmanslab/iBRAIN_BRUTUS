%This function computes for blocks num_images starting from offset 
%abundances for all intensities
function [ output_args ] = computeBlockStatistics( proj_dir,offset,num_images)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if(nargin==0)
   proj_dir= 'Z:\Data\Users\Yanic\120405yanic15epi';
   num_images=10;
   offset=1;
   
end;
level=25;
   tiff_dir=strcat(proj_dir,'/','TIFF');
   batch=strcat(proj_dir,'/','BATCH');
%Read settings from directory
[tiffiles,subfile,divfile]=analyseHighspeedDirectory(tiff_dir);

datadiv=double(imread(npc(divfile)));
datasub=double(imread(npc(subfile)));
%Read first time point
firstimage=(double(imread(npc(tiffiles{1})))-datasub)./datadiv;
%Allocate 3D matrix with the number of third dimension elements
%corresponding to level levels

storematrix=uint16(NaN([size(datadiv),num_images]));
for(i=offset:offset+num_images-1)
    storematrix(:,:,i-offset+1)=(imread(npc(tiffiles{i})));

%=(data-datasub)./datadiv;
end;
outputmatrix=single(NaN([length(lin((datadiv))),4]));
%Process storematrix by taking a historgram for every pixel
count=1;
for(i=1:size(datadiv,1))
for(j=1:size(datadiv,2))  
    tempj=(double(squeeze(storematrix(i,j,:)))-datasub(i,j))./datadiv(i,j);
    tempi=tempj-firstimage(i,j);
    outputmatrix(count,1:4)=single([mean(tempj),std(tempj),quantile(tempj,0.9),std(tempi)]);
    count=count+1;
end;
end;
save(npc(strcat(batch,'/PixelStatistic',sprintf('%d',offset),'.mat')),'outputmatrix','-v7.3');
end

