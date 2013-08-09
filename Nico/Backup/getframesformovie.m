function handles = getframesformovie(handles,matOrderedTimePointIdx,strSettingBaseName)

%%%
%[NB] This code is really messy. We need to clean this up. It works
%though...



%cellAllImages = handles.Measurements.Image.BaseMovieFileNames';
cellAllSegmentedImages = handles.Measurements.Image.SegmentedFileNames';
cellAllTrackedImages = handles.Measurements.Image.TrackedFileNames';


SetBeingAnalyzed = 1;
ObjectName = handles.TrackingSettings.ObjectName;
TrackingMeasurementPrefix = strcat('TrackObjects_',strSettingBaseName);
matColorMap = hsv(1500)+0.2;
matColorMap(matColorMap>1) = 1;
matColorMapTail = matColorMap-0.3;
matColorMapTail(matColorMapTail<0) = 0;
[~,n1] = unique(matColorMap,'rows');
[~,n2] = unique(matColorMapTail,'rows');
matColorMap = matColorMap(intersect(n1,n2),:);
matColorMapTail = matColorMapTail(intersect(n1,n2),:);
% matColorMapTail = matColorMapTail(randperm(size(matColorMapTail,1)),:);
% keep track of which colormap indices areavailable
% matRandomColorMapIndices = randperm(size(matColorMap,1))';

% matRandomColorMapIndices = (1:size(matColorMap,1))';

matRandomColorMapIndices = lin(reshape(1:1056,[176,6])');

%matRandomColorMapIndices(1:2:end) = flipud(matRandomColorMapIndices(1:2:end));
%figure;bar(matRandomColorMapIndices(1:70))
% matRandomColorMapIndices(1:3:end) = flipud(matRandomColorMapIndices(1:3:end));
% matRandomColorMapIndices(1:4:end) = flipud(matRandomColorMapIndices(1:4:end));

%matRandomColorMapIndices(1:2:end) = flipud(matRandomColorMapIndices(1:2:end));

numTail = handles.TrackingSettings.TailTime;

for i =  1:size(matOrderedTimePointIdx,1)    %NumberOfImageSets
    
    %matCurrentImage = single(imread(char(cellAllImages(matOrderedTimePointIdx(i)))));
    matCurrentImage = single(imread(char(cellAllSegmentedImages(matOrderedTimePointIdx(i)))));
    cellTrackObjectParentIDs{1} = handles.Measurements.(ObjectName).(TrackingMeasurementPrefix){matOrderedTimePointIdx(i)}(:,[1 2]);
    cellTrackLocations{1} = round(handles.Measurements.(ObjectName).Location{matOrderedTimePointIdx(i)});
    
    matCurrentParentID = cellTrackObjectParentIDs{1}(:,2);
    matCurrentObjectID = cellTrackObjectParentIDs{1}(:,1);
    
    if i == 1
        % Asign colors
        
        matColorInds =  matRandomColorMapIndices(1:size(matCurrentParentID,1));
        matRandomColorMapIndices(1:size(matCurrentParentID,1)) = [];
        % remove indices from pool of available colors
        
        % matColorInds =  round(1 + (size(matColorMap,1)-1).*rand(size(matCurrentParentID,1),1));
        matCurrentObjectColor = matColorMap(matColorInds,:);
        matObjectIDColorIdxMap = [matCurrentParentID matColorInds];
    end
    
    
    %%%
    %[NB] the movies did not look good for a whole well so we will get rid
    % of the original movies and use only the segmentation images
    %get the coordinates for the cell outline
    %get the last image
    %     maxImage = quantile(matCurrentImage(:),.999);
    %     minImage = quantile(matCurrentImage(:),.5);
    %     matMaxImageInx = (matCurrentImage > maxImage);
    %     matCurrentImage(matMaxImageInx) = (matMaxImageInx(matMaxImageInx)).*maxImage;
    %     matMinImageInx = (matCurrentImage < minImage);
    %     matCurrentImage(matMinImageInx) = (matMinImageInx(matMinImageInx)).*minImage;
    %     %matCurrentImage = abs(matCurrentImage - minImage - maxImage);
    %     matCurrentImage = abs(matCurrentImage - minImage);
    %     matCurrentImage = matCurrentImage./max(matCurrentImage(:));
    
    %     matCurrentImage_1 = matCurrentImage;
    %     matCurrentImage_2 = matCurrentImage;
    %     matCurrentImage_3 = matCurrentImage;
    %
    
    %matPreviousParentID = matCurrentParentID;
    
    % if the objecs ID are already counted do not re calculate the map.
    
    matNewObjectsIndx = ~ismember(matCurrentObjectID,matObjectIDColorIdxMap(:,1));
    
    if sum(matNewObjectsIndx) > 0
        %Check the parent of the object and asing it the same color as the
        %parent. I object has no parent then asig a new ranmom color.
        matNewObjectsIndx2 = find(matNewObjectsIndx);
        for iParents = 1:size(matNewObjectsIndx2,1)
            numParentID = cellTrackObjectParentIDs{1}(matNewObjectsIndx2(iParents),2);
            numObjectID = cellTrackObjectParentIDs{1}(matNewObjectsIndx2(iParents),1);
            numIndxParentID = find(matObjectIDColorIdxMap(:,1) == numParentID);
            
            if isempty(numIndxParentID)
                %intRandIX = floor(rand*(size(matRandomColorMapIndices,1)))+1;
                matColorInds = matRandomColorMapIndices(1);
                matRandomColorMapIndices(1) = [];
                
                if isempty(matRandomColorMapIndices)
                    matRandomColorMapIndices = lin(reshape(1:1000,[100,10])');
                end
                
                matObjectIDColorIdxMap = [matObjectIDColorIdxMap;[numObjectID matColorInds]];
            else
                matObjectIDColorIdxMap = [matObjectIDColorIdxMap;[numObjectID matObjectIDColorIdxMap(numIndxParentID,2)]];
            end
        end
    end
    
    %generate the image containing the indexes for the diamonds colors
    if numTail > 0
        matCentroidIndx = cell2mat(arrayfun(@(x,y) sub2ind(size(matCurrentImage),x,y),...
            cellTrackLocations{1}(:,2),cellTrackLocations{1}(:,1),'uniformoutput',false));
        matDiamondImageIdx = zeros(size(matCurrentImage));
        matTempIndexParent = cell2mat(arrayfun(@(x) find(matObjectIDColorIdxMap(:,1) == x),matCurrentParentID,'uniformoutput',false));
        matDiamondImageIdx(matCentroidIndx) = matObjectIDColorIdxMap(matTempIndexParent,2);
        sel = strel('diamond',4);
        matDiamondImageIdx = imdilate(matDiamondImageIdx,sel); clear sel;
    end
    
    % generate image containing the indexes for the nuclei
    % First generate an image containing the Objects ID
    matNucleiImageIdx = zeros(size(matCurrentImage));
    matNucleiImageIdx(matCurrentImage>0) = cellTrackObjectParentIDs{1}(matCurrentImage(matCurrentImage>0),1);
    % Now convert the object indexes into color indexes. This is a temp
    % folution as it is quite slow
    
    matNucleiImageIdx(matNucleiImageIdx>0) = cell2mat(arrayfun(@(x) find(matObjectIDColorIdxMap(:,1) == x),matNucleiImageIdx(matNucleiImageIdx>0),'uniformoutput',false));
    matNucleiImageIdx(matNucleiImageIdx>0) = matObjectIDColorIdxMap(matNucleiImageIdx(matNucleiImageIdx>0),2);
    % matBorderImageIdx = edge(matNucleiImageIdx).*matNucleiImageIdx;
    se = strel('disk',2,0);
    matBorderImageIdx = imdilate(edge_bs(matNucleiImageIdx),se) .* imdilate(matNucleiImageIdx,se);
    % figure;imagesc(matBorderImageIdx)
    
    %%%
    %[NB] the movies did not look good for a whole well so we will get rid
    % of the original movies and use only the segmentation images
    %get the coordinates for the cell outline
    %     matCurrentOutline = single(imread(char(cellAllSegmentedImages(matOrderedTimePointIdx(i)))));
    %     [cellBoundaryImage matLabel] = bwboundaries(matCurrentOutline);
    %     cellOutlineInx = cellfun(@(w) cell2mat(arrayfun(@(x,y) sub2ind(size(matCurrentOutline),x,y),w(:,1),w(:,2),'uniformoutput',false)),cellBoundaryImage,'uniformoutput',false);
    %     matOutlineImageIdx = zeros(size(matCurrentImage));
    %
    %     if size(cellOutlineInx,1) == size(matCentroidIndx,1)
    %         for iOutline = 1:size(cellOutlineInx,1)
    %             numTempObjectIndx = (matObjectIDColorIdxMap(:,1) == cellTrackObjectParentIDs{1}(iOutline,1));
    %             matOutlineImageIdx(cellOutlineInx{iOutline}) = ones(size(cellOutlineInx{iOutline})).*matObjectIDColorIdxMap(numTempObjectIndx,2);
    %             matOutlineImageIdx(cellOutlineInx{iOutline}+1) = ones(size(cellOutlineInx{iOutline})).*matObjectIDColorIdxMap(numTempObjectIndx,2);
    %         end
    %         matCurrentImage_1(matOutlineImageIdx> 0) = matColorMap(matOutlineImageIdx(matOutlineImageIdx> 0),1);
    %         matCurrentImage_2(matOutlineImageIdx > 0) = matColorMap(matOutlineImageIdx(matOutlineImageIdx> 0),2);
    %         matCurrentImage_3(matOutlineImageIdx > 0) = matColorMap(matOutlineImageIdx(matOutlineImageIdx> 0),3);
    %     else
    %         fprintf('%s: outline drawing skipped for site of coordinate $d.\n',mfilename,matOrderedTimePointIdx(i))
    %     end
    
    
    if i == 1 && numTail > 0
        for iCell = 1:numTail
            cellRemDiamImIdx{iCell} = matDiamondImageIdx;
        end
    end
    
    matCurrentImage_1 = zeros(size(matCurrentImage));
    matCurrentImage_2 = zeros(size(matCurrentImage));
    matCurrentImage_3 = zeros(size(matCurrentImage));
    
    matCurrentImage_1( matNucleiImageIdx> 0) = matColorMap(  matNucleiImageIdx( matNucleiImageIdx> 0),1);
    matCurrentImage_2( matNucleiImageIdx> 0) = matColorMap(  matNucleiImageIdx( matNucleiImageIdx> 0),2);
    matCurrentImage_3( matNucleiImageIdx> 0) = matColorMap(  matNucleiImageIdx( matNucleiImageIdx> 0),3);
    
    matCurrentImage_1( matBorderImageIdx> 0) = matColorMapTail(  matBorderImageIdx( matBorderImageIdx> 0),1);
    matCurrentImage_2( matBorderImageIdx> 0) = matColorMapTail(  matBorderImageIdx( matBorderImageIdx> 0),2);
    matCurrentImage_3( matBorderImageIdx> 0) = matColorMapTail(  matBorderImageIdx( matBorderImageIdx> 0),3);
    
    
    if numTail > 0
        cellRemDiamImIdx{1} = matDiamondImageIdx;
        for iTime = 1:length(cellRemDiamImIdx)
            matCurrentImage_1(cellRemDiamImIdx{iTime} > 0) = matColorMapTail(cellRemDiamImIdx{iTime}(cellRemDiamImIdx{iTime} > 0),1);
            matCurrentImage_2(cellRemDiamImIdx{iTime} > 0) = matColorMapTail(cellRemDiamImIdx{iTime}(cellRemDiamImIdx{iTime} > 0),2);
            matCurrentImage_3(cellRemDiamImIdx{iTime} > 0) = matColorMapTail(cellRemDiamImIdx{iTime}(cellRemDiamImIdx{iTime} > 0),3);
        end
    end
    
    
    
    
    clear finalImage
    finalImage(:,:,1) = matCurrentImage_1;
    finalImage(:,:,2) = matCurrentImage_2;
    finalImage(:,:,3) = matCurrentImage_3;
    
    % figure;imshow(finalImage)
    
    finalImage = imresize(finalImage, 0.75);
    imwrite(finalImage,cellAllTrackedImages{matOrderedTimePointIdx(i)},'png');
    %imwrite(finalImage,strcat('Z:\Data\Users\mRNAmes\Code\Movies\TEST\',num2str(i),'.png'),'png');
    
    for iCell = length(cellRemDiamImIdx):-1:2
        cellRemDiamImIdx{iCell} = cellRemDiamImIdx{iCell-1};
    end
    
end
