clear all

% strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ2\philip_071006_Tfn_MZ_AWaa\BATCH\';
%     strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Lilli\070716_ChTxB_A431\070717ChTxB_50K_P2_1\BATCH\';
%     strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\RV_KY\070104_RV_50K_KY_P3_1_1\';
%     strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\061102_MHV_KY_GFP_50K_GFP_P1_2\';
%     strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\070111_SV40_MZ_MZ_P3_1_1\';
    strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\DV_KY\070902_50K_DV_KY_2_1_3\';
    
    handles=struct();
    handles=LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Image_FileNames.mat'));
    handles=LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Image_ObjectCount.mat'));

    if ~isempty(find(strcmpi(handles.Measurements.Image.ObjectCountFeatures,'Nuclei')))
        strObjectName = char(handles.Measurements.Image.ObjectCountFeatures(find(strcmpi(handles.Measurements.Image.ObjectCountFeatures,'Nuclei'))));
    elseif ~isempty(find(strcmpi(handles.Measurements.Image.ObjectCountFeatures,'OrigNuclei')))
        strObjectName = char(handles.Measurements.Image.ObjectCountFeatures(find(strcmpi(handles.Measurements.Image.ObjectCountFeatures,'OrigNuclei'))));
    elseif ~isempty(find(strcmpi(handles.Measurements.Image.ObjectCountFeatures,'Cells')))
        strObjectName = char(handles.Measurements.Image.ObjectCountFeatures(find(strcmpi(handles.Measurements.Image.ObjectCountFeatures,'Cells'))));
    else
        error('there are no Cells or Nuclei or OrigNuclei objects in your handles file')
    end
    intObjectCountColumn = find(strcmp(handles.Measurements.Image.ObjectCountFeatures,strObjectName));

    %convert ImageNames to something we can index
    intNumOfImages = length(handles.Measurements.Image.FileNames);
    cellFileNames = cell(intNumOfImages,1);
    matObjectCount = zeros(intNumOfImages,1);
    matImagePosition = zeros(intNumOfImages,1);    
    for l = 1:size(handles.Measurements.Image.FileNames,2)
        cellFileNames{l} = char(handles.Measurements.Image.FileNames{l}(1));
        matObjectCount(l) = handles.Measurements.Image.ObjectCount{l}(1,intObjectCountColumn);
        matImagePosition(l) = check_image_position(char(cellFileNames{l}));        
    end

    matRows = cellstr(regexp(char(65:80),'\w','match'));
    matCols = regexp(sprintf('%.2d',1:24),'\d\d','match');


    for rowNum = 2
        for colNum = 2
            str2match = strcat('_',matRows(rowNum), matCols(colNum));
            FileNameMatches = strfind(cellFileNames, char(str2match));
            matFileNameMatchIndices = find(~cellfun('isempty',FileNameMatches));
            
            disp(sprintf('WELL %s%s, TCN = %d',matRows{rowNum},matCols{colNum},nansum(matObjectCount(matFileNameMatchIndices))))
        end
    end
