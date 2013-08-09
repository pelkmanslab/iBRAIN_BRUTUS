function addTotalInfectedMeasurement(strRootPath)

    if nargin==0
%         strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\070111_SV40_MZ_MZ_P1_1_1\';
        strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\50K_checkers\060118_EV1_Kyo_CB\BATCH\';            
    end
    
    boolOutputExistsAlready = fileattrib(fullfile(strRootPath,'Measurements_Image_CorrectedTotalInfectedPerWell.mat'));
    if boolOutputExistsAlready
        % output exists already, don't recalculate
        return
    end

    handles=struct();
    handles=LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Image_FileNames.mat'));
    handles=LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Image_ObjectCount.mat'));
    handles=LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Image_OutOfFocus.mat'));    
    handles=LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Nuclei_VirusScreen_ClassicalInfection_Overview2.mat'));        

    %%% OLD CP OUTPUTS HAD 'ObjectCount ' in there objectcountfeatures...
    %%% remove
    handles.Measurements.Image.ObjectCountFeatures = strrep(handles.Measurements.Image.ObjectCountFeatures,'ObjectCount ','');
    
    if ~isempty(find(strcmpi(handles.Measurements.Image.ObjectCountFeatures,'Nuclei')))
        strObjectName = char(handles.Measurements.Image.ObjectCountFeatures(find(strcmpi(handles.Measurements.Image.ObjectCountFeatures,'Nuclei'))));
    elseif ~isempty(find(strcmpi(handles.Measurements.Image.ObjectCountFeatures,'Cells')))
        strObjectName = char(handles.Measurements.Image.ObjectCountFeatures(find(strcmpi(handles.Measurements.Image.ObjectCountFeatures,'Cells'))));
    else
        error('there are no Cells or Nuclei objects in your handles file')
    end
    intObjectCountColumn = find(strcmp(handles.Measurements.Image.ObjectCountFeatures,strObjectName));

    if isfield(handles.Measurements.Image,'OutOfFocus')
       matOutOfFocus = handles.Measurements.Image.OutOfFocus;
    else
        error('there is no out of focus data present')
    end        

    %convert ImageNames to something we can index
    intNumOfImages = length(handles.Measurements.Image.FileNames);
    cellFileNames = cell(intNumOfImages,1);
    matObjectCount = zeros(intNumOfImages,1);
    matImagePosition = zeros(intNumOfImages,1);    
    for l = 1:size(handles.Measurements.Image.FileNames,2)
        cellFileNames{l} = char(handles.Measurements.Image.FileNames{l}(1));
%         matObjectCount(l) = handles.Measurements.Image.ObjectCount{l}(1,intObjectCountColumn);
        matObjectCount(l) = handles.Measurements.Nuclei.VirusScreenInfection_Overview{l}(1,2);% total infected per image
        matImagePosition(l) = check_image_position(char(cellFileNames{l}));        
    end

    matRows = cellstr(regexp(char(65:80),'\w','match'));
    matCols = regexp(sprintf('%.2d',1:24),'\d\d','match');

    if max(matImagePosition(:)) == 9 
        matImageSnake = [0,1,2,2,1,0,0,1,2;2,2,2,1,1,1,0,0,0];
    elseif max(matImagePosition(:)) == 25
        matImageSnake = [0,1,2,3,4,4,3,2,1,0,0,1,2,3,4,4,3,2,1,0,0,1,2,3,4;4,4,4,4,4,3,3,3,3,3,2,2,2,2,2,1,1,1,1,1,0,0,0,0,0];        
    end


    %%% DETERMINE AVERAGE IMAGE WEIGHT PER WELL
    intSquareSize = length(unique(matImageSnake(:)));
    matWellData = [];
    well = 0;
    for rowNum = 1:length(matRows)
        for colNum = 1:(length(matRows))
            str2match = strcat('_',matRows(rowNum), matCols(colNum));
            FileNameMatches = strfind(cellFileNames, char(str2match));
            matFileNameMatchIndices = find(~cellfun('isempty',FileNameMatches));
            if ~isempty(matFileNameMatchIndices) & (sum(matOutOfFocus(matFileNameMatchIndices))==0)
                well = well + 1;
                matWellData(:,:,well) = zeros(intSquareSize,intSquareSize);                
                for i = 1:length(matFileNameMatchIndices)
                    k = matFileNameMatchIndices(i);
                    xPos = matImageSnake(1,matImagePosition(k));
                    yPos = matImageSnake(2,matImagePosition(k));                
                    matWellData(xPos+1,yPos+1,well) = matObjectCount(k);
                end
                matWellData(:,:,well) = matWellData(:,:,well) / sum(sum(matWellData(:,:,well)));
            end
        end
    end
    
    %%% MAP OF WHICH IMAGE CONTRIBUTES ON AVERAGE HOW MANY CELLS TO THE
    %%% WELL TCN.
    matAverageImageWeight = nanmedian(matWellData,3);
    
    %%% FILE handles STRUCTURE WITH CORRECTED TOTAL CELL NUMBER
    handles2 = struct();
    handles2.Measurements.Image.CorrectedTotalCellNumberPerWell = {};
    handles2.Measurements.Image.CorrectedTotalCellNumberPerWellFeatures = {['CorrectedTCNPerWell_',char(strObjectName)]};
    
    for rowNum = 1:length(matRows)
        for colNum = 1:(length(matRows))
            str2match = strcat('_',matRows(rowNum), matCols(colNum));
            FileNameMatches = strfind(cellFileNames, char(str2match));
            matFileNameMatchIndices = find(~cellfun('isempty',FileNameMatches));
            
            if ~isempty(matFileNameMatchIndices)
                matCurrentWellTCNData = zeros(intSquareSize,intSquareSize);
                matCurrentWellOOFData = zeros(intSquareSize,intSquareSize);
                for k = matFileNameMatchIndices';
                    xPos = matImageSnake(1,matImagePosition(k));
                    yPos = matImageSnake(2,matImagePosition(k));                
                    matCurrentWellTCNData(xPos+1,yPos+1) = matObjectCount(k);
                    matCurrentWellOOFData(xPos+1,yPos+1) = matOutOfFocus(k);
                end
                
                if sum(matCurrentWellOOFData(:)) == length(matCurrentWellOOFData(:))
                    %%% WHAT TO DO IF ALL IMAGES FOR THIS WELL ARE OUT OF
                    %%% FOCUS? (NOTE: SHOULD NOT AFFECT ANY POSTANALYSIS,
                    %%% SINCE OOF IMAGES ARE DSCARDED) 
                    
                    % take median cell number per image multiplied times
                    % expected number of images per well:
                    intCorrectedWellTCN = round(median(matObjectCount(:)) * length(matCurrentWellOOFData(:)'));
                else
                    intWellTCNOfNONOOFImages = sum(matCurrentWellTCNData(~matCurrentWellOOFData));
                    intWellTCNWeightNONOOFImages = str2double(sprintf('%.2f',sum(matAverageImageWeight(~matCurrentWellOOFData))));
                    intCorrectedWellTCN = round((1/intWellTCNWeightNONOOFImages)*intWellTCNOfNONOOFImages);
                end
                

                for k = matFileNameMatchIndices';
                    handles2.Measurements.Image.CorrectedTotalInfectedPerWell{k} = intCorrectedWellTCN;
                end
            end
        end
    end
    
    clear handles
    handles = handles2;
    save(fullfile(strRootPath,'Measurements_Image_CorrectedTotalInfectedPerWell.mat'),'handles');    
    
end