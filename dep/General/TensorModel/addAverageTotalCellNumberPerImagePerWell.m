function addAverageTotalCellNumberPerImagePerWell(strRootPath)

    if nargin==0
        strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\YF_MZ\061213_YF_MZ_P1_1_3\';
    end
    
    boolOutputExistsAlready = fileattrib(fullfile(strRootPath,'Measurements_Image_AverageTotalCellNumberPerImagePerWell.mat'));
    if boolOutputExistsAlready
        % output exists already, don't recalculate
        return
    end

    handles=struct();
    handles=LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Image_FileNames.mat'));
    handles=LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Image_ObjectCount.mat'));
    handles=LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Image_OutOfFocus.mat'));    

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

    if isfield(handles.Measurements.Image,'OutOfFocus')
       matOutOfFocus = handles.Measurements.Image.OutOfFocus;
    else
        error('there is no out of focus data present')
    end        

    %convert ImageNames to something we can index
    intNumOfImages = length(handles.Measurements.Image.FileNames);
    
    [matImageWellRow, matImageWellCols] = cellfun(@filterimagenamedata, [handles.Measurements.Image.FileNames{:,:}],'UniformOutput',1);
    [matImageChannel] = cellfun(@check_image_channel, [handles.Measurements.Image.FileNames{:,:}],'UniformOutput',1);

    matImageWellRow = matImageWellRow(matImageChannel==1);
    matImageWellCols = matImageWellCols(matImageChannel==1);

    matObjectCountPerImage = [handles.Measurements.Image.ObjectCount{:}];
    matObjectCountPerImage = matObjectCountPerImage(matImageChannel==1);    
    
    %%% FILE handles STRUCTURE WITH CORRECTED TOTAL CELL NUMBER
    handles2 = struct();
    handles2.Measurements.Image.AverageTotalCellNumberPerImagePerWell = {};
    handles2.Measurements.Image.AverageTotalCellNumberPerImagePerWellFeatures = {['AverageTCNPerImagePerWell_',char(strObjectName)]};
    
    for iImage = 1:intNumOfImages
        % find image indices with the same row and well as the current image
        matCurWelIndices = find(matImageWellRow == matImageWellRow(iImage) & matImageWellCols == matImageWellCols(iImage));
        % discard from those indices the out-of-focus images
        matCurWelIndices(matOutOfFocus(matCurWelIndices) == 1) = [];
        % take the average of the leftover images and store this value
        handles2.Measurements.Image.AverageTotalCellNumberPerImagePerWell{iImage} = round(mean(matObjectCountPerImage(matCurWelIndices)));
    end
    
    clear handles
    handles = handles2;
    disp(sprintf('saving %s',fullfile(strRootPath,'Measurements_Image_AverageTotalCellNumberPerImagePerWell.mat')));
    save(fullfile(strRootPath,'Measurements_Image_AverageTotalCellNumberPerImagePerWell.mat'),'handles');    
    
end