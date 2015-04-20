
% strCompleteDataFile = 'C:\Users\pelkmans\Desktop\TFN_figure_data.mat';
% if fileattrib(strCompleteDataFile)
%     fprintf('%s: loading %s\n',mfilename,strCompleteDataFile)
%     load(strCompleteDataFile)
%     return
% end


strDataPath = npc('Z:\Data\Users\Berend\090216_Mz_Tfn_CB\090216_Mz_Tfn_CB\BATCH');
strSegmentationPath = npc('Z:\Data\Users\Berend\090216_Mz_Tfn_CB\090216_Mz_Tfn_CB\SEGMENTATION');

[handles, cellFileNames, matChannelNumber, matImagePositionNumber, cellstrMicroscopeType, matImageWellRow, matImageWellColumn, cellstrImageWellName] = LoadStandardData(strDataPath);

% get segmentation file names
cellSegmentationFiles = CPdir(strSegmentationPath);
%remove dirs
cellSegmentationFiles(cat(1,cellSegmentationFiles.isdir)) = [];
% make cell array
cellSegmentationFiles = cat(1,{cellSegmentationFiles.name});

% get segmentation for one object only file list
strObjectName = 'Nuclei';
cellSegmentationFiles(cellfun(@isempty,strfind(cellSegmentationFiles,['_Segmented',strObjectName]))) = [];
[boolIsPresent, matImageSegmentationCrossRef] = ismember(strrep(cellFileNames,'.png',''),strrep(cellSegmentationFiles,['_Segmented',strObjectName,'.png'],''));

% Let's start by taking the pop-props from the ProbMod data
% handles = LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Nuclei_AreaShape.mat'))
load(fullfile(strDataPath,'ProbModel_Tensor.mat'))
MasterTensor = load(fullfile(getbasedir(strDataPath),'ProbModel_Tensor.mat'));

% Let's calculate model predicted data!
if isequal(MasterTensor.Tensor.TrainingData,Tensor.TrainingData)
    X = MasterTensor.Tensor.TrainingData(:,2:end);
    X = X - 1;
    X = [ones(size(X,1),1),X];
    YHAT = glmval(double(MasterTensor.Tensor.Model.Params),double(X),'identity','constant','off');
else
    warning('BS:Bla','tensors differ, figure it out!')
end


% find cell indices for well C11
matCellIndices = Tensor.MetaData(:,1)==3 & Tensor.MetaData(:,2)==11;
% get all image numbers for corresponding well
matImageIndices = unique(Tensor.MetaData(matCellIndices,3));

% get image snake
[matImageSnake,matStitchDimensions] = get_image_snake(max(matImagePositionNumber(:)), unique(cellstrMicroscopeType));

% get sample segmentation-image size (first image in list)
matImageSize = size(imread(fullfile(strSegmentationPath, cellSegmentationFiles{1})));

% load all segmentation images from well and stitch together resulting in a
% segmentation-map of object-ids, also make a segmentation-map of image-ids
% such that you can find back the segmentation for any object on any image
% with: 
%
%   (PatchObjectID == intObjectNumber && PatchImageID == intImageNumber)
%

matPatchSize = [round(matImageSize(1,1)*matStitchDimensions(1)),round(matImageSize(1,2)*matStitchDimensions(2))];
% object reference maps
PatchObjectID = zeros(matPatchSize, 'uint16');
% PatchImageID = zeros(matPatchSize, 'uint16');
% object featue maps
% PatchObjectDensity = zeros(matPatchSize, 'uint8');
% PatchObjectSize = zeros(matPatchSize, 'uint8');
% PatchObjectEdge = zeros(matPatchSize, 'uint8');
% PatchObjectActivity = zeros(matPatchSize, 'uint8');
PatchObjectPredictedActivity = zeros(matPatchSize, 'uint8');

iCounter = 0;
for k = matImageIndices'
    iCounter = iCounter + 1;
    
    strImageName = cellSegmentationFiles{matImageSegmentationCrossRef(k)};
    strImagePosition = matImagePositionNumber(k,1);
    
    xPos=(matImageSnake(1,strImagePosition)*matImageSize(1,2))+1:((matImageSnake(1,strImagePosition)+1)*matImageSize(1,2));
    yPos=(matImageSnake(2,strImagePosition)*matImageSize(1,1))+1:((matImageSnake(2,strImagePosition)+1)*matImageSize(1,1));
    
    try
        fprintf('%s: parsing image %d of %d: %s\n',mfilename,iCounter,length(matImageIndices),strImageName)
        matImage = imread(fullfile(strSegmentationPath,strImageName));
    catch caughtError
        caughtError.identifier
        caughtError.message
        warning('matlab:bsBla','%s: failed to load image ''%s''',mfilename,fullfile(strTiffPath,strImageName));
        matImage = zeros(matImageSize);
    end
    
%     % fill in object reference maps
%     PatchObjectID(yPos,xPos) = matImage;
%     PatchImageID(yPos,xPos) = uint16(matImage>0)*uint16(k);
    
    % get object-id's for current image, fill in object property maps

    for iX = unique(matImage(matImage>0))'
        
        % find position in Tensor.TrainingData
        iTensorIx = find(Tensor.MetaData(:,3)==k & Tensor.MetaData(:,4)==iX);
        % if object is present in tensor.trainingdata, process it.
        if ~isempty(iTensorIx)

            % find position on current map
            matObjectSegmentation = uint8(matImage == iX);

            % fill in object features on object feature maps
%             PatchObjectActivity(yPos,xPos) = PatchObjectActivity(yPos,xPos) + (matObjectSegmentation * Tensor.TrainingData(iTensorIx,1));            
            PatchObjectPredictedActivity(yPos,xPos) = PatchObjectPredictedActivity(yPos,xPos) + (matObjectSegmentation * YHAT(iTensorIx,1));
%             PatchObjectDensity(yPos,xPos) = PatchObjectDensity(yPos,xPos) + (matObjectSegmentation * Tensor.TrainingData(iTensorIx,2));
%             PatchObjectSize(yPos,xPos) = PatchObjectSize(yPos,xPos) + (matObjectSegmentation * Tensor.TrainingData(iTensorIx,3));
%             PatchObjectEdge(yPos,xPos) = PatchObjectEdge(yPos,xPos) + (matObjectSegmentation * Tensor.TrainingData(iTensorIx,4));
        end
    end
    
%     keyboard
    
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% let's redo edge detection on fused image! %

% shrink figure for speed
matBWImage = imresize(logical(PatchObjectID),0.1,'nearest');
% expand each nucleus to fill up space between cells
ExpandedSegmentedImage = bwmorph(matBWImage, 'thicken', 8);
clear matBWImage
% remove small gaps
ExpandedSegmentedImage = bwmorph(ExpandedSegmentedImage, 'dilate');
% remove small gaps some more
ExpandedSegmentedImage = bwmorph(ExpandedSegmentedImage, 'majority');

% invert the expanded-segmentation map to get the holes in the cell-colony
matBWLabelsOfGapsImage = bwlabel(1-ExpandedSegmentedImage);
clear ExpandedSegmentedImage

% get area-size of all gaps
props = regionprops(logical(matBWLabelsOfGapsImage),'Area');
% filter all holes smaller than a certain size
matHoleSizes = cat(1,props.Area);
for i = find(matHoleSizes<50)'
    matBWLabelsOfGapsImage(matBWLabelsOfGapsImage == i) = 0;
end

% expand edges, see which nuclei overlap with the expanded gaps, those nuclei are edge-nuclei! 
ExpandedHoleSegmentedImage = bwmorph(matBWLabelsOfGapsImage~=0, 'thicken', 11);
clear matBWLabelsOfGapsImage

% reset original PatchObjectEdge, to include only edge-detection from the
% stitched image
% get unique Id for each object in image
PatchObjectBWLabel = bwlabel(logical(PatchObjectID));
% get the unique Ids for all objects touching the edge
PatchObjectBWLabelEdge = PatchObjectBWLabel;
% set all non-hole area to zero (remaining IDs are edge ids)
PatchObjectBWLabelEdge(imresize(ExpandedHoleSegmentedImage,10,'nearest')==0)=0;
clear ExpandedHoleSegmentedImage 
% get list of edge-ids
matEdgeObjectIDs = unique(PatchObjectBWLabelEdge(PatchObjectBWLabelEdge>0));
clear PatchObjectBWLabelEdge
% make map of all object segmentation of edge ids
PatchObjectEdge = ismember(PatchObjectBWLabel,matEdgeObjectIDs);
PatchObjectEdge = uint8(PatchObjectEdge);
% set non-edge cells to 1, edge cells to 2!
PatchObjectEdge = PatchObjectEdge + uint8(PatchObjectID>0);
figure()
imagesc(PatchObjectEdge)

clear PatchObjectBWLabel

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% let's redo size measurement on fused image! %
% what's the advantage you ask? dunno :-)     %

matBWLabel = bwlabel(logical(PatchObjectID));
props = regionprops(logical(matBWLabel),'Area','Centroid');
matObjectSize = cat(1,props.Area);
matObjectPosition = cat(1,props.Centroid);
[n,bin]=histc(matObjectSize,linspace(min(matObjectSize),quantile(matObjectSize,0.97),100));
PatchObjectSize = zeros(size(matBWLabel), 'uint16');
for iSizeBin = find(n)'
    fprintf('%d ...',iSizeBin)
    PatchObjectSize(ismember(matBWLabel,find(bin==iSizeBin))) = iSizeBin;
end
figure()
imagesc(PatchObjectSize)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% let's redo density measurement on fused image! %
% what's the advantage you ask? dunno :-)        %
mat2DHistEdges = [1,matPatchSize(1),80; ...
                  1,matPatchSize(2),80];
[RESULT,matBin,DESCRIPTOR] = histogram2(matObjectPosition(:,2)',matObjectPosition(:,1)',mat2DHistEdges);

PatchObjectDensity = zeros(size(matBWLabel), 'uint16');
for iSizeBin = unique(RESULT)'
    fprintf('%d ...',iSizeBin)
    PatchObjectDensity(ismember(matBWLabel,find(RESULT(matBin)'==iSizeBin))) = iSizeBin;
end
figure()
imagesc(PatchObjectDensity)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Make the final multicolor figure, rescale and store it %

% put together a multi-color (RGB, CMYK?) figure, wich is properly
% rescaled, and show it 
intResizeFactore = 8;

matImage = zeros([matPatchSize/intResizeFactore,3]);

matImage(:,:,1) = double(imresize(PatchObjectDensity,1/intResizeFactore)) / double(max(PatchObjectDensity(:)));
matImage(:,:,2) = double(imresize(PatchObjectSize,1/intResizeFactore)) / double(max(PatchObjectSize(:)));
matImage(:,:,3) = double(imresize(PatchObjectEdge-1,1/intResizeFactore)) / double(max(PatchObjectEdge(:)-1));

% % set gackground (all-black-pixels) to white for improved printing
% for iRow = 1:size(matImage,1)
%     matImage(iRow,max(matImage(iRow,:,:),[],3)==0,:) = 0;
% end

figure()
imshow(matImage)

imwrite(matImage,fullfile(strDataPath,'test.bmp'),'bmp')

figure()
subplot(2,2,1)
imagesc(imresize(PatchObjectDensity,0.2,'nearest'))
% imagesc((PatchObjectDensity) - min(PatchObjectDensity(:))) / max(PatchObjectDensity(:)))
subplot(2,2,2)
imagesc(imresize(PatchObjectSize,0.2,'nearest'))
% imagesc((PatchObjectSize - min(PatchObjectSize(:))) / max(PatchObjectSize(:)))
subplot(2,2,3)
imagesc(imresize(PatchObjectEdge,0.2,'nearest'))
% imagesc((PatchObjectEdge - min(PatchObjectEdge(:))) / max(PatchObjectEdge(:)))
subplot(2,2,4)
imagesc(imresize(PatchObjectActivity,0.2,'nearest'))
% imagesc((PatchObjectActivity - min(PatchObjectActivity(:))) / max(PatchObjectActivity(:)))

imagesc(imresize(PatchObjectPredictedActivity,0.2,'nearest'))



% orig = double(imresize(PatchObjectActivity,0.25,'nearest'));
orig = PatchObjectPredictedActivity;
clim = get(gca, 'clim');
levels = 255; % 8-bit
% levels = 65535; % 16-bit
target = grayslice(orig, linspace(clim(1), clim(2), levels));
map = hot(levels);

% % if you've adjusted the colormap (away from a basic one) and want to make
% % it 255-color, use this:
% map2 = colormap;
% figure(); imagesc(map2)
% size(map2)
% map2 = imresize(map2,[255,3]);
% map2(map2>1)=1;map2(map2<0)=0;

imwrite(target, map, 'D:\Heterogeneity\090826_Extra_Figure_ETHLife_NRMCB\PatchObjectPredictedActivity.bmp')


% xlin = linspace(1,matPatchSize(1),matPatchSize(1));
% ylin = linspace(1,matPatchSize(2),matPatchSize(2));
% [X,Y] = meshgrid(xlin,ylin);
% figure()
% contourf(X,Y,PatchObjectEdge)


% perhaps plot it as a surface? or overlay contour on image?
matObjectDensity = NaN(size(matObjectSize));
matObjectEdge = NaN(size(matObjectSize));
for i = 1:length(matObjectSize)
    matObjectDensity(i) = PatchObjectDensity(round(matObjectPosition(i,2)),round(matObjectPosition(i,1)));
    matObjectEdge(i) = PatchObjectEdge(round(matObjectPosition(i,2)),round(matObjectPosition(i,1)));
end

x = matObjectPosition(:,2);
y = matObjectPosition(:,1);
z = double(matObjectDensity);

xlin = linspace(min(x),max(x),20);
ylin = linspace(min(y),max(y),20);

[X,Y] = meshgrid(xlin,ylin);

Z = griddata(x,y,z,X,Y,'cubic');

surf(X,Y,Z) %interpolated
mesh(X,Y,Z) %interpolated

% contourf(X,Y,Z) %interpolated
mesh(X,Y,Z) %interpolated
axis tight; hold on
% plot3(x,y,z,'.','MarkerSize',1) %nonuniform
% plot(x,y,'.','MarkerSize',1) %nonuniform
% scatter(x,y,z) %nonuniform
drawnow