function filtTiffFiles = filterImageFiles( TiffPaths, TiffFiles, varargin )
% FILTERIMAGEFILES filters images in a TIFF folder for cycles, wells,
% sites, and channels. Filter can be defined by user via variable input.
%
% Input:
%   TiffPaths       cell array of strings with the absolute path names
%   TiffFiles       cell array of strings with the image file names
%   
% Variable input:
%   Descriptors:
%   'cycles'        1-by-n matrix, where n is the number of cycles
%   'wells'         m-by-2 matrix, where m is the number of wells
%                   (wells: in row and column format)
%   'sites'         1-by-n matrix, where n is the number of sites
%   'channels'      1-by-n matrix, where n is the number of channels
%
% Output:
%   filtTiffFiles   cell array of strings with the image file names
%   
%
% Author:
%   Markus Herrmann

%%% handle variable input
if any(strcmpi(varargin,'cycles'))
    defCycles = cell2mat(varargin(find(strcmpi(varargin,'cycles'))+1));
else
    defCycles = 1:length(TiffPaths);
end

if any(strcmpi(varargin,'wells'))
    defWellsRowCol = cell2mat(varargin(find(strcmpi(varargin,'wells'))+1));
    defWells = cell(size(defWellsRowCol,1),1);
    for i = 1:size(defWells,1)
        defWells{i} = sprintf('%s%02d',char(defWellsRowCol(i,1)+64),defWellsRowCol(i,2));
    end
else
    defWells = cell(size(TiffFiles{1},2),1);
    for j = 1:size(TiffFiles{1},2)
        [~,~,defWells{j},~] = filterimagenamedata(TiffFiles{1}{j});
    end
    defWells = unique(defWells);
end

if any(strcmpi(varargin,'sites'))
    defSites = num2cell(cell2mat(varargin(find(strcmpi(varargin,'sites'))+1)));
    defSites = cellfun(@num2str,defSites,'UniformOutput',false);
else
    defSites = num2cell(unique(cellfun(@check_image_position,TiffFiles{1})));
    defSites = cellfun(@num2str,defSites,'UniformOutput',false);
end

if any(strcmpi(varargin,'channels'))
    defChannels = num2cell(cell2mat(varargin(find(strcmpi(varargin,'channels'))+1)));
    defChannels = cellfun(@num2str,defChannels,'UniformOutput',false);
else
    defChannels = num2cell(unique(cellfun(@check_image_channel,TiffFiles{1})));
    defChannels = cellfun(@num2str,defChannels,'UniformOutput',false);
end

%%% create regexp
searchStr = expfun(defWells,defSites,defChannels);

%%% filter image file using regexp
filtTiffFiles = cellfun(@(x)flatten(regexpi(x,searchStr,'match')),TiffFiles(defCycles),'UniformOutput',false);

end

