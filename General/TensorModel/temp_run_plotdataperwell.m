
if ispc
%     strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\';

    strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Jean-Philippe\p53Hitvalidation_Restained+Rewashed\';
    RootPathFolderList = dirc(strRootPath,'de');    
else
    
    strRootPath = '/Volumes/share-2-\$/Data/Users/Jean-Philippe/p53Hitvalidation_Restained+Rewashed/';    

    [a,b]=system(sprintf('find %s -type d -maxdepth 1 -mindepth 1',strRootPath));
    if a==0
        b = regexpi(b,'\s{1,}','split')';    
        b(cellfun(@isempty,b))=[];
        RootPathFolderList = getlastdir(b)
    end

end
   


for iProject = 1:size(RootPathFolderList,1)
    strProjectPath = fullfile(strRootPath,RootPathFolderList{iProject});
%         plotDataPerWell(strProjectPath);
    CropBDImages(strProjectPath)
end