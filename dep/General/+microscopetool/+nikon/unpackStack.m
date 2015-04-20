function [] = unpackStack(strInputDirSTK, strInputDirND, strOutputDirSTK, XY2Crop);
%UNPACKSTACK unpacks the .stk files and saves them in a given dir
%(strOutputDir). This function is used for files coming from the VisiTirf
%and the Visiscope
%   Provide InpuDir to the Nd File and input and output directory for the
%   unstacking

% Import aliases from the microscopetool namespace

import microscopetool.flatten
import microscopetool.sort_nat
import microscopetool.findfilewithregexpi
import microscopetool.nikon.readNDFile

if nargin == 0
    %%%strInputDirND = npc('/share/nas/camelot-share2/Data/Users/Yauhen/nikon/test_dataset/121010TIRFM3');
    %%%strInputDirSTK = npc('/share/nas/camelot-share2/Data/Users/Yauhen/nikon/test_dataset/121010TIRFM3/TIFF');
    % normally we don't guess but die bravely with exception/error. It is
    % expected user is smart enough to know what he is doing and/or 
    % capabale of reading this comments if he calls this function.
    error('Not enough input arguments')
end

boolCrop = 0;

if nargin == 1
    strInputDirND = strInputDirSTK;
    
end

if nargin < 3
    % Makes the Output folder and the corresponding pat. Avoid situation of
    % appending 'TIFF' after 'TIFF'.
    if strcmp(strInputDirSTK(numel(strInputDirSTK)-3:numel(strInputDirSTK)),'TIFF') % ends with 'TIFF'
        strOutputDirSTK = strInputDirSTK;
    else
        strOutputDirSTK = fullfile(strInputDirSTK, 'TIFF');
    end
end

if nargin == 4
    if ismatrix (XY2Crop)
        sprintf('Images will be cropped at column %d to %d and at row %d to %d', XY2Crop(1,1), XY2Crop(1,2), XY2Crop(2,1), XY2Crop(2,2))
        
    elseif iscell (XY2Crop)
        XY2Crop = cell2mat(XY2Crop);
        sprintf('Images will be cropped at column %d to %d and at row %d to %d', XY2Crop(1,1), XY2Crop(1,2), XY2Crop(2,1), XY2Crop(2,2))
    else
        error('You have to provide the margins to crop the images in a cell or in a matrice.')
    end
    boolCrop = 1;
end

if nargin > 4
    error('You provided to many input arguments')
end


fprintf('%s: OutputDir for the unpacked STK images is ''%s''\n',mfilename,strOutputDirSTK)
if ~isdir(strOutputDirSTK)
    mkdir(strOutputDirSTK);
end


% % importing ND file and checks if Unstacking is needed
[sctNDFile, ~, ~, ~, ~, boolDoZSeries ] = readNDFile(strInputDirND,1);


% % Unstacking
if boolDoZSeries
    fprintf('%s: dataset has been recognized as an acquisition with ZDimension''\n',mfilename)
    fprintf('%s: inventarising .stk files in provided directory (strOutputDir)''\n',mfilename)
        cellFn2Unstack = sort_nat(findfilewithregexpi(strInputDirSTK, '.*\.stk'));
        cellFp2Unstack = sort_nat(findfilewithregexpi(strInputDirSTK, '.*\.stk', true));
        for i = 1:length(cellFp2Unstack)
            sprintf('%s: unpacking the %d. of %d stk files''\n',mfilename,i, length(cellFp2Unstack))
            sctSTKFile = tiffread(cellFp2Unstack{i,1})';
            cellSTK2Access = num2cell((1:length(sctSTKFile))');
            cellZsNew = strcat(regexpi(cellFn2Unstack{i,1}, 'NIKON_t(\d*)', 'match'),(cellfun(@(x) sprintf('_z%04d', x),cellSTK2Access, 'UniformOutput', false)));
            cellPreFnOutput = cellfun(@(x) regexprep(cellFn2Unstack{i,1}, 'NIKON_t(\d*)', x), cellZsNew, 'UniformOutput', false );
            cellFnOutput = regexprep(cellPreFnOutput, '.stk$', '.tif');
            cellFpOutput = cellfun(@(x) fullfile(strOutputDirSTK, x), cellFnOutput, 'UniformOutput', false);
            if boolCrop == 0
                cellfun(@(x,y) imwrite(sctSTKFile(x).data, y, 'tif'), cellSTK2Access, cellFpOutput, 'UniformOutput', false);
            else
                cellfun(@(x,y) imwrite(sctSTKFile(x).data(XY2Crop(1,1):XY2Crop(1,2), XY2Crop(2,2):XY2Crop(2,2)), y, 'tif'), cellSTK2Access, cellFpOutput, 'UniformOutput', false);
            end
            fprintf('%s: all provided .stk files have been unpacked''\n',mfilename)
        end
else
    fprintf('%s: no .stk files in provided directory: %s''\n',mfilename,strInputDirSTK )
end

% TODO: potentially add MIP (max intensity projection) at this point. But
% also take care nto to make MIP for time dimension which makes noe sense.
% You can put _mip instead of _z into a filename for this type of images.

end