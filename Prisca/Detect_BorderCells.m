 function Detect_BorderCells(strRootPath)

    if nargin==0
        strRootPath = 'Y:\Data\Users\Prisca\090403_A431_Dextran_GM1_harlink1\090403_A431_Dextran_GM1-CP395-1ag\BATCH';
    end

    strRootPath = npc(strRootPath);

    strImagePath = fullfile(getbasedir(strRootPath),'SEGMENTATION');
    strImagePath = npc(strImagePath);


    handles = struct();
    handles = LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Image_ObjectCount.mat'));
    handles = LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Image_FileNames.mat'));

    % don't need this, can parse it from filenames directly.
    % SegmentedImages = SearchTargetFolders(strImagePath,'*Cell*');
    matImageObjectCount = cat(1,handles.Measurements.Image.ObjectCount{:});

    %  otherwise, look for "Nuclei" containing object names, take that
    %  column
    matIX = find(~cellfun(@isempty,strfind(handles.Measurements.Image.ObjectCountFeatures,'Cell')));
    matImageObjectCount = matImageObjectCount(:,1);
    clear matIX


    cellBorderCell = cell(1,size(handles.Measurements.Image.ObjectCount,2));

    for i=1:size(handles.Measurements.Image.ObjectCount,2)
        % current image name
        strFileName = handles.Measurements.Image.FileNames{i}(1,1);
        % reformat into segmentation image name
        strSegmentationFileName = strrep(strFileName,'.png','_SegmentedCells.png');
        % load image segmentation for current object Cells
        matImageSegmentation = imread(fullfile(strImagePath,strSegmentationFileName{1,:}));

        matBorderCellsIx = unique(cat(1,unique(matImageSegmentation(:,1)),unique(matImageSegmentation(:,end)),unique(matImageSegmentation(1,:))',unique(matImageSegmentation(end,:))'));

        %Double check that the Feature column match the object Image
        %BEREND SAYS: DO NOT DO THIS!!! MATCH WHICH COLUMN IN OBJECTCOUNT HAS
        %CELLS INFORMATION, TAKE THAT ONE!!!

        CellNumber = matImageObjectCount(i);
        %CellNumber = handles.Measurements.Image.ObjectCount{i}(:,2);

        cellBorderCell{1,i} = zeros(CellNumber,1);

        cellBorderCell{1,i}(matBorderCellsIx(matBorderCellsIx>0),:)=1;

    end

    Measurements = struct();
    Measurements.Cells.BorderCells = cellBorderCell;
    save(fullfile(strRootPath,'Measurements_Cells_BorderCells.mat'),'Measurements')
    fprintf('%s: stored %s\n',mfilename,fullfile(strRootPath,'Measurements_Cells_BorderCells.mat'))

end