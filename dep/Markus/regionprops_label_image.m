function imLabel = regionprops_label_image(imLogical, imIntensity, strProperty, logarithm)

%REGIONPROPS_LABEL_IMAGE creates a label image based on a measurement of
%the regionprops function.
%
%   L = REGIONPROPS_LABEL_IMAGE(BW,I,PROPERTY,LOGARITHM) calls the
%   regionprops function using the input images BW and I and the input
%   property PROPERTY. It returns a matrix L, of the same size as BW,
%   containing labels of the measured PROPERTY for the connected objects in
%   BW. Optionally, output is given in logarithmic form.
%   
%   Input: 
%   - BW: binary image
%   - I: intensity image, if you don't want to measure intensities provide
%     empty matrix [] as second input
%   - PROPERTY: string, e.g. 'Area', 'Eccentricity', 'MeanIntensity', etc.
%   - LOGARITHM (optional): string, either 'two' for log2, 'ten' for log10,
%     or 'nat' for log

if isempty(imIntensity)
    imIntensity = zeros(size(imLogical));
end

if nargin == 3
    useLog = false;
elseif nargin == 4
    useLog = true;
end
    

props = regionprops(imLogical,imIntensity,strProperty);
Property = cat(1,props.(sprintf('%s',strProperty)));
imLabel = bwlabel(imLogical);
Index = unique(imLabel);
Index(Index==0) = [];
for t = 1:length(Index)
    if useLog
        if strcmp(logarithm,'two')
            imLabel(imLabel==Index(t)) = log2(Property(t));
        elseif strcmp(logarithm,'ten')
            imLabel(imLabel==Index(t)) = log10(Property(t));
        elseif strcmp(logarithm,'nat')
            imLabel(imLabel==Index(t)) = log(Property(t));
        end
    else
        imLabel(imLabel==Index(t)) = Property(t);
    end
end
