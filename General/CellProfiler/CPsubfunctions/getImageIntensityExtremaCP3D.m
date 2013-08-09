function [minIntensity, maxIntensity] = getImageIntensityExtremaCP3D(Image,minQuantile, maxQuantile, downsamplingFactor,varargin)
% obtains minimum and maximum of an image. Note that minimum and maximum
% are given by the quantile, e.g. minQuantile of 0 is the real minimum of the
% image, wheareas 0.01 would discard the lowest 1%.
%
% To speed up processing of large images (such as sCMOS 10megapixel) images,
% downsamplingFactor can downsample the image prior to quantile
%
% Image can either be a matrix with the 2D or 3D image or a path to a 2D
% image

% Determine if illumination correction should be done (note that this will
% be done on the downsampled image to safe computational time)

if nargin== 6
    if ~any([isempty(varargin{1}),isempty(varargin{2})])
        bnDoIlluminationCorrection = true;
        IllMean = varargin{1};
        IllStd = varargin{2};
    else
        bnDoIlluminationCorrection = false;
    end
else
    bnDoIlluminationCorrection = false;
end


% Load Data
if isnumeric(Image)
    OrigImage = Image;
elseif ischar(Image);
    if any(fileattrib(Image))
        try
            OrigImage = imread(Image);
        catch notLoaded
            error(['Could not load Image with file path/name ' Image '.'])
        end
    else
        error(['Could not find file with file path/name ' Image '.'])
    end
else
    error('Could not identify format of input Image')
end

% Downsample by takeing discrete rows/columns. Note that this will prevent
% masking of small intensity peaks (such as RNA spots) below sampling
% scale (which might occur with classical image downsampling involving
% interpolation). Also use discrete steps of rows instead of randomly
% chosen subset of image for reproducibility (assumption that there
% is no repetitive pattern of the intensities)
rowIndices= 1:downsamplingFactor:size(OrigImage,1);
columnIndices =  1:downsamplingFactor:size(OrigImage,2);


ImagesDS = OrigImage(rowIndices,columnIndices);

if bnDoIlluminationCorrection == true  % if requested, do illumination correction
   % downsample template for illumantion correction
   IllMeanDS =  IllMean(rowIndices,columnIndices); 
   IllStdDS =  IllStd(rowIndices,columnIndices);     
   ImagesDS = applyNBBSIllumCorrCP3D(ImagesDS,IllMeanDS,IllStdDS); 
end

minIntensity = quantile(ImagesDS(:),minQuantile);
maxIntensity = quantile(ImagesDS(:),maxQuantile);

end