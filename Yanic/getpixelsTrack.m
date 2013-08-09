
   proj_dir= 'Z:\Data\Users\Yanic\120405yanic15epi';
 proj_dir='/cluster/home/biol/heery/2NAS/Data/Users/Yanic/antioxidant/120508-antioxidant_20120508_165216';
   offset=1;
site=1;
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


 redm=(zeros([size(datadiv),100]));
%Filter the image with a median filter to remove isolataed high pixels
for(i=offset:100)
    newimage=double((imread(npc(tiffiles{i}))));


redm(:,:,i)=newimage;
i

end;

mean1=mean(redm,3);
std1=std(redm,0,3);
save('/cluster/home/biol/heery/2NAS/Data/Users/Yanic/antioxidant/120508-antioxidant_20120508_165216/natch/pixels.mat','mean1','std1','-v7.3');
i