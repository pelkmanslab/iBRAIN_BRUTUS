function [fileNames formatNum sNums] = imDir(imDirectory,returnAll)
%IMDIR is a wrapper for the dir command designed for finding only image files
% 
% fileNames = imDir(directory);
% 
% fileNames = imDir(directory,returnAll);
%
% [fileNames formatNum] = imDir(...);
%
% This function will find all files in the specified directory with common
% file extensions for images. Additionally, the images will be re-ordered,
% if necessary, so that the last number before the file extension is in
% increasing order. This fixes the problem with the dir command returning
% numbered images which are not zero-padded in the wrong order.
%
% For example, if a folder contains img1.tif, img2.tif ... img10.tif, the
% dir command will return img1.tif, img10.tif, img2.tif ..., whereas this
% function will return them in the correct order, with img10.tif last. This
% only works with files where the image number is the last element of the
% name before the file extension.
% 
% Input:
% 
%   directory - the directory to search for files in. (non-recursive);
%   Optional. If not input, current directory is used.
%
%   returnAll - If true, all images of any file extension will be returned.
%   If false, only the first matching set of files found will be returned,
%   in this order:
% 
%       1 - .tif 
%       2 - .TIF 
%       3 - .STK 
%       4 - .bmp 
%       5 - .BMP 
%       6 - .jpg
%       7 - .JPG
%
%   This input is optional. Default is false.
%
% Output:
%
%   fileNames - a structure containing the names and statistics for all the
%   images found. This is the same as the output of the dir function.
%
%   formatNum - If returnAll was enabled, this is the number of different
%   image file extensions found in the directory 
%
%   sNums - an array containing the number at the end of each file 
%
% Hunter Elliott, 2/2010
%

%The list of supported file extensions. Feel free to add! (just update the
%help also!)
if ispc
    %On PC, the dir command is non case-sensitive 
    fExt = {'tif', 'stk', 'bmp', 'jpg','png'};
else
    fExt = {'tif','TIF','stk','STK','bmp','BMP','jpg','JPG'};
end


if nargin < 1 || isempty(imDirectory)
    imDirectory = pwd;
end

if nargin < 2 || isempty(returnAll)
    returnAll = false;
end

fileNames = [];
formatNum = 0;

% ---- Get the file names by checking each extension.  ---- %
for i = 1:length(fExt)
    
    tempfileNames = dir([imDirectory filesep '*.' fExt{i}]);
    if ~isempty(tempfileNames)
        formatNum = formatNum +1;
    end
    
    fileNames = vertcat(fileNames, tempfileNames);
    if ~returnAll && ~isempty(fileNames);
        break
    end
end

%  ---- Fix the order of the files if they are numbered.  ---- %

%First, extract the number from the end of the file, if present
fNums = arrayfun(@(x)(str2double(...
    x.name(max(regexp(x.name(1:end-4),'\D'))+1:end-4))),fileNames);

%The sort function handles NaNs, and will not re-order if the images are
%not numbered.
[sNums,iX] = sort(fNums);

fileNames = fileNames(iX);

