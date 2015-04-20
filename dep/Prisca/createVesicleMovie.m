%This function computes for blocks num_images starting from offset 
%abundances for all intensities
function [ output_args ] = createVesicleMovie( proj_dir,offset,num_images,site)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if(nargin==0)
   proj_dir= 'Z:\Data\Users\Yanic\120405yanic15epi';
 proj_dir='Z:\Data\Users\Yanic\antioxidant\120508-antioxidant_20120508_165216';
   offset=1;
   site=1;
end;
level=25;
%      num_images=10;
   tiff_dir=strcat(proj_dir,'/','TIFF');
   batch=strcat(proj_dir,'/','natch');
%    mkdir(batch);
%Read settings from directory
[tiffiles,subfile,divfile]=analyseHighspeedDirectory(proj_dir,site);

datadiv=double(imread(npc(divfile)));
datasub=double(imread(npc(subfile)));
%Read first time point
firstimage=(double(imread(npc(tiffiles{1})))-datasub)./datadiv;
%Allocate 3D matrix with the number of third dimension elements
%corresponding to level levels


 redm=zeros([size(datadiv),3]);
redscaled=zeros([size(datadiv)*0.25,3]);

aviobj=avifile(strcat(batch,'/',sprintf('movie-site%d-%d.avi',site,offset)),'fps',5);
redm=zeros([size(datadiv),3]);

if(length(tiffiles)<offset)
    %No files to process
    return;
end;
for(i=offset:min(length(tiffiles),offset+num_images-1))
    newimage=double(imread(npc(tiffiles{i})));

newimage=(newimage-datasub)./datadiv;
newimage(newimage<0)=0;
redm(:,:,2)=(newimage-quantile(lin(newimage),0.3))*20;
redscaled=imresize(redm,0.25);
aviobj=addFrame(aviobj,redscaled);
end;
aviobj=close(aviobj);
sprintf('convert -quality 100 %s/movie%d.avi %s/movie%d.mpeg',batch,offset,batch,offset)
% system(sprintf('convert -quality 100 %s/movie%d.avi %s/movie%d.mpeg',batch,offset,batch,offset),'-echo');
% delete(strcat(batch,'/',sprintf('movie%d.avi',offset)));
end

