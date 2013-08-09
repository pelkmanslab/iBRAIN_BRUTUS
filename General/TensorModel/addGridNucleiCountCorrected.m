function addGridNucleiCountCorrected(strRootPath)

    if nargin==0
        strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\070111_SV40_MZ_MZ_P1_1_1\';
    end
    
    boolOutputExistsAlready = fileattrib(fullfile(strRootPath,'Measurements_Nuclei_GridNucleiCountCorrected.mat'));
    if boolOutputExistsAlready
        % output exists already, don't recalculate
        return
    end

    handles=struct();
    handles=LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Nuclei_GridNucleiCount.mat'));

    intCellsCorrected = 0;
    handles2=struct();
    handles2.Measurements.Nuclei.GridNucleiCountCorrected = {'GridNucleiCount_zerocorrected'};
    for k = 1:length(handles.Measurements.Nuclei.GridNucleiCount)
        matTempData = handles.Measurements.Nuclei.GridNucleiCount{k};
        intCellsCorrected = intCellsCorrected + length(find(matTempData == 0));
        matTempData(find(matTempData == 0)) = round(nanmedian(matTempData(:)));
        handles2.Measurements.Nuclei.GridNucleiCountCorrected{k} = matTempData;
    end
    
    disp(sprintf('  corrected %d single cell densities',intCellsCorrected))
    
    clear handles
    handles = handles2;
    disp(fullfile(strRootPath,'Measurements_Nuclei_GridNucleiCountCorrected.mat'));        
    save(fullfile(strRootPath,'Measurements_Nuclei_GridNucleiCountCorrected.mat'),'handles');    
end