

%strPlatePath=npc('\\nas-unizh-imsb1.ethz.ch\share-3-$\Data\Users\Prisca\endocytome_FollowUps\111001_A431_w2Tf\111001_A431_w2Tf_CP84-1aa\BATCH');

strRoothPath=npc('\\nas-unizh-imsb1.ethz.ch\share-2-$\Data\Users\110920_A431_w2Tf');



 % list of paths to load
 cellPlateNames = CPdir(strRoothPath);
 cellPlateNames = {cellPlateNames([cellPlateNames(:).isdir]).name}';
 matHasBATCHDirectory = cellfun(@(x) fileattrib2(fullfile(strRoothPath, x, 'BATCH')),cellPlateNames);
 cellPlateNames(~matHasBATCHDirectory) = [];

 

for i=1:size(cellPlateNames,1)
    strPlatePath=fullfile(strRoothPath,cellPlateNames{i},'BATCH')
    addTotalCellNumberMeasurement(strPlatePath);
end