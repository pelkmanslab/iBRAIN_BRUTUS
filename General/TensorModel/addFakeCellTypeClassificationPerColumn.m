function addFakeCellTypeClassificationPerColumn(strRootPath)

    if nargin==0
%         strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\David\Pictures\David_iBRAIN\080312Davidtestplaterescan3\BATCH\';
%         strRootPath = 'Z:\Data\Users\50K_final\SV40_MZ_NEW\20080506200519_M1_080429_50k_SV4-_GM1rmed_MZ_p1_1_1\BATCH';         
        strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ2\philip_071006_Tfn_MZ_AWaa\BATCH\';
    end
    
    boolOutputExistsAlready = fileattrib(fullfile(strRootPath,'Measurements_Nuclei_FakeCellTypeClassificationPerColumn.mat'));
    if boolOutputExistsAlready
        % output exists already, don't recalculate
        return
    end

    handles=struct();
    handles=LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Image_ObjectCount.mat'));

    handles2=struct();
    handles2.Measurements.Nuclei.CellTypeClassificationPerColumnFeatures = {'Interphase','Mitotic','Apoptotic','Other'};
    for k = 1:length(handles.Measurements.Image.ObjectCount)
        matTempData = handles.Measurements.Image.ObjectCount{k}(1,1);
        matTempDataPerColumn = zeros(matTempData,4);
        matTempDataPerColumn(:,1) = ones(matTempData,1);        
        handles2.Measurements.Nuclei.CellTypeClassificationPerColumn{k} = matTempDataPerColumn;
    end
    
    clear handles
    handles = handles2;
    disp(sprintf('saving %s',fullfile(strRootPath,'Measurements_Nuclei_FakeCellTypeClassificationPerColumn.mat')));        
    save(fullfile(strRootPath,'Measurements_Nuclei_FakeCellTypeClassificationPerColumn.mat'),'handles');    
    
end