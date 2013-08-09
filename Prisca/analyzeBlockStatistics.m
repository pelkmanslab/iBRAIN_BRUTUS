%This function computes for blocks num_images starting from offset 
%abundances for all intensities
function [ output_args ] = computeBlockStatistics( input_args )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
NUMIMAGES=150;
if(nargin==0)
   proj_dir= 'Z:\Data\Users\Yanic\bleachtest\120426-yanic_20120426_164040_1000G7';
 
   offset=1;
   
end;
%   num_images=10;
   
batch=strcat(proj_dir,'\','BATCH');
tiff=strcat(proj_dir,'\','TIFF');
%Read settings from directory
[tiffiles,subfile,divfile]=analyseHighspeedDirectory(tiff);
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
all3=squeeze(allmatrix(:,:,1));
lowindices1=NaN(length(lowindices)*7,1);
for(j=1:7)
    lowindices1((1:length(lowindices))+(j-1)*length(lowindices))=j;
end;
figure;
plotquant([(lowindices1),lin(all3(1:7,lowindices)')]);
%Display bleaching with high average in last time chunk
lowindices=find(lin(allmatrix(1,:,1))>quantile(lin(allmatrix(1,:,1)),0.8));
all3=squeeze(allmatrix(:,:,1));
lowindices1=NaN(length(lowindices)*7,1);
for(j=1:7)
    lowindices1((1:length(lowindices))+(j-1)*length(lowindices))=j;
end;
hold on;
plotquant([(lowindices1),lin(all3(1:7,lowindices)')]);
%Display bleaching with high average in first time chunk
title('50 % lowest pixels and 20 % highest pixels in first frame for 5 % live')
xlabel('Time:frame')
ylabel('Average pixel intensity')

end