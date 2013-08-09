function [OutputCC] = SourseExtractorDeblend(Image,BaseImageCC,FiltImage,Options)

%[NB] this function is a n implementation of the spots deblendig algorithm
%of source extractor.
%Usage: [OutputCC] = SourseExtractorDeblend(Image,BaseImageCC,FiltImage,Options)
%Where Image is the original image to be segmented. BaseImageCC is the base
%segmentation of the image, FiltImage is the LoG Filter image of Image (the
% third output of ObjByFilter).
%Options is a structutre with the following filds and default values:
%
%Options.ObSize = 6;
%Options.limQuant = [0.05 0.995];
%Options.RescaleThr = [nan nan 166 nan]
%Options.ObjIntensityThr = 98;
%Options.closeHoles = false;
%Options.ObjSizeThr = [];
%Options.ObjThr = 0.02;
%Options.StepNumber = 50;

if nargin < 4
    Options = struct();
end

if ~isfield(Options,'ObSize')
    Options.ObSize = 6;
end

if ~isfield(Options,'limQuant')
    Options.limQuant = [0.05 0.995];
end

if ~isfield(Options,'RescaleThr')
    Options.RescaleThr = [nan nan 166 nan];
end

if ~isfield(Options,'ObjIntensityThr')
    Options.ObjIntensityThr = 98;
end

if ~isfield(Options,'closeHoles')
    Options.closeHoles = false;
end

if ~isfield(Options,'ObjSizeThr')
    Options.ObjSizeThr = [];
end

if ~isfield(Options,'ObjThr')
    Options.ObjThr = 0.02;
end

if ~isfield(Options,'StepNumber')
    Options.StepNumber = 50;
end



% create filter
Options.Filter = fspecialCP3D('2D LoG',Options.ObSize);

%[ObjCount BaseImageCC FiltImage] = ObjByFilter(Image,se.Filter,se.ObjThr,se.limQuant,[],se.ObjIntensityThr,true,se.ObjSizeThr);
%L = labelmatrix(BaseImageCC);
%figure;imagesc(L)


%get the range of thresholds to test
UpLimit = quantile(FiltImage(:),0.999);
matThresToTest = linspace(Options.ObjThr,UpLimit,Options.StepNumber);

fprintf('%s: Calculating all thresholded images. Total Number %d. ',mfilename,Options.StepNumber)
tic
[~, structSegCC] = ObjByFilter(Image,Options.Filter,matThresToTest,...
    Options.limQuant,Options.ObjSizeThr,Options.ObjIntensityThr,false,Options.ObjSizeThr);
toc


fprintf('%s: Calculating all centroids. ',mfilename)
tic
cellAllCentroid = cellfun(@(x) regionprops(x,'Centroid'),structSegCC,'uniformoutput',false);
cellAllCentroid = cellfun(@(x) cat(1,x(:).Centroid), cellAllCentroid,'uniformoutput',false);
cellAllCentroid = cellfun(@(x) round(x), cellAllCentroid,'uniformoutput',false);
cellAllCentroid = cellfun(@(x) sub2ind(size(FiltImage),x(:,2),x(:,1)),cellAllCentroid,'uniformoutput',false);
toc


fprintf('%s: Deblending Images, please wait. ',mfilename)
tic
%go via all images
for i = 1:length(structSegCC)
    
    tempImage = structSegCC{i};
    propsCentroid = cellAllCentroid{i};
    
    
    tempIsMemb = ismember(cat(1,BaseImageCC.PixelIdxList{:}),propsCentroid)';
    LengthVector = cellfun(@length, BaseImageCC.PixelIdxList);
    IxSpotsI = cell2mat(arrayfun(@(a,b) ones(1,a).*b,LengthVector,(1:length(BaseImageCC.PixelIdxList)),'uniformoutput',false));
    IxSpotsJ = cell2mat(arrayfun(@(a) [1:a],LengthVector,'uniformoutput',false));
    matTempSort = zeros(max(IxSpotsI),max(IxSpotsJ));
    IxIJ = sub2ind(size(matTempSort),IxSpotsI,IxSpotsJ);
    matTempSort(IxIJ) = tempIsMemb;
    matBinaryReadout = sum(matTempSort,2)';
    
    
    %matBinaryReadout = cellfun(@(x) sum(ismember(x,propsCentroid)),BaseImageCC.PixelIdxList);
    
    %find spots to be deblended
    matSpottoDebl = find(matBinaryReadout>1);
    
    
    if ~isempty(matSpottoDebl)      
        
        tempBasePixelList = BaseImageCC.PixelIdxList(matSpottoDebl);
        cellCentroidIx = cellfun(@(x) find(ismember(propsCentroid,x)), tempBasePixelList,'uniformoutput',false );
        
        %measure intensities for the new spots
        SumSpotInt = mat2cell(arrayfun(@(k) sum(Image(tempImage.PixelIdxList{k})),cell2mat(cellCentroidIx')),...
            cellfun(@length ,cellCentroidIx)',1);
        
        tempTotalIntOverThre = cellfun(@(x) (x./sum(x))>0.20,SumSpotInt,'uniformoutput',false);
        tempIX = cellfun(@(x) sum(x),tempTotalIntOverThre)>1;
        
        BaseImageCC.PixelIdxList(matSpottoDebl(tempIX)) = [];
        BaseImageCC.PixelIdxList = [BaseImageCC.PixelIdxList tempImage.PixelIdxList(cat(1,cellCentroidIx{tempIX}))];
        BaseImageCC.NumObjects = length(BaseImageCC.PixelIdxList);
      end
    
end
toc

% Reformat output
CentroidsOutput = regionprops(BaseImageCC,'Centroid');
CentroidsOutput = cat(1,CentroidsOutput(:).Centroid);
CentroidsOutput = round(CentroidsOutput);
CentroidsOutput = sub2ind(size(FiltImage),CentroidsOutput(:,2),CentroidsOutput(:,1));

matImageOut = zeros(size(Image));
matImageOut(CentroidsOutput) = 1;

OutputCC = bwconncomp(matImageOut);
        







