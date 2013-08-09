%This function computes for blocks num_images starting from offset 
%abundances for all intensities
function [ output_args ] = computeBlockStatistics( input_args )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
NUMIMAGES=150;
batch='Z:\Data\Users\Yanic\120405yanic50epi\BATCH';
%Read settings from directory
[tiffiles,subfile,divfile]=analyseHighspeedDirectory('Z:\Data\Users\Yanic\120405yanic50epi\TIFF');
%Loop over blocks
load(strcat(batch,'\PixelStatistic',sprintf('%d',1),'.mat'));
%Allocate space to hold all results
allmatrix=single(NaN([floor(length(tiffiles)/NUMIMAGES-1),size(outputmatrix)]));
indices=NaN([floor(length(tiffiles)/NUMIMAGES-1)*length(lin(outputmatrix))/4],1);
count=1;
for(i=1:7)
    load(strcat(batch,'\PixelStatistic',sprintf('%d',(i-1)*NUMIMAGES+1),'.mat'));
    allmatrix(count,:,:)=(outputmatrix(:,:));
    indices((i-1)*length(lin(outputmatrix))/4+1:i*length(lin(outputmatrix))/4)=i;
    count=count+1;
end

%Display bleaching across all pixels
figure
plotquant([indices,lin(squeeze(allmatrix(1:7,:,1))')]);
figure
plotquant([indices,lin(squeeze(allmatrix(1:7,:,3))')]);
%Display bleaching with low average intesnity in first time chunk
lowindices=find(lin(allmatrix(1,:,1))<quantile(lin(allmatrix(1,:,1)),0.5));
all3=squeeze(allmatrix(:,:,2));
lowindices1=NaN(length(lowindices)*7,1);
for(j=1:7)
    lowindices1((1:length(lowindices))+(j-1)*length(lowindices))=j;
end;
figure;
plotquant([(lowindices1),lin(all3(1:7,lowindices)')]);
%Display bleaching with high average in last time chunk
lowindices=find(lin(allmatrix(1,:,1))>quantile(lin(allmatrix(1,:,1)),0.99));
all3=squeeze(allmatrix(:,:,2));
lowindices1=NaN(length(lowindices)*7,1);
for(j=1:7)
    lowindices1((1:length(lowindices))+(j-1)*length(lowindices))=j;
end;
figure;
plotquant([(lowindices1),lin(all3(1:7,lowindices)')]);
%Display bleaching with high average in first time chunk


end