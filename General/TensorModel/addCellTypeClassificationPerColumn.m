function addCellTypeClassificationPerColumn(strRootPath)

    if nargin==0
        strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\070111_SV40_MZ_MZ_P1_1_1\';
    end
    
    boolOutputExistsAlready = fileattrib(fullfile(strRootPath,'Measurements_Nuclei_CellTypeClassificationPerColumn.mat'));
    if boolOutputExistsAlready
        % output exists already, don't recalculate
        return
    end

    handles=struct();
    handles=LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Nuclei_CellClassification2.mat'));

    handles2=struct();
    handles2.Measurements.Nuclei.CellTypeClassificationPerColumnFeatures = {'Interphase','Mitotic','Apoptotic','Other'};
    for k = 1:length(handles.Measurements.Nuclei.CellClassification)
        matTempData = handles.Measurements.Nuclei.CellClassification{k}(1,:)';
        matTempDataPerColumn = zeros(size(matTempData,1),4);
        for iColumn = 1:4
            [rowInd, colInd] = find(matTempData == iColumn);
            matTempDataPerColumn(rowInd,iColumn)=1;
        end
        handles2.Measurements.Nuclei.CellTypeClassificationPerColumn{k} = matTempDataPerColumn;
    end
    
    clear handles
    handles = handles2;
%     disp(fullfile(strRootPath,'Measurements_Nuclei_CellTypeClassificationPerColumn.mat'));        
    save(fullfile(strRootPath,'Measurements_Nuclei_CellTypeClassificationPerColumn.mat'),'handles');    
    
end