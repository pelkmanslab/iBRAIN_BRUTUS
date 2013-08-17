function renameImages(strInputDir, strOutputDir, boolDoCopy)
%RENAMEIMAGES of Nikon camera into iBRAIN suitable format
%
% Starting point function for nikon package (that calls other functions in 
% that packagae). Typical usage scenario requires providing folder
% pathnames to images which needs renaming.
%
% strInputDir Full folder pathname contiaining Nikon camera images.
% strInputDir Full folder pathname to place renamed images. Note that 
%             if 'TIFF' is omitted - it is automatically appended - do not 
%             supply it.
% boolDoCopy  If false, will rename images instead of copying the 
%             files (default)
%
% @author: Gabriele Gut <gabriele.gut@uzh.ch>
% @author: Victoria Green <victoria.green@uzh.ch>
% @author: Katharina Schoenrath <katharina.schoenrath@uzh.ch>
% @author: Yauhen Yakimovich <yauhen.yakimovich@uzh.ch>
%

%% Import aliases from the microscopetool namespace

import microscopetool.flatten
import microscopetool.sort_nat
import microscopetool.findfilewithregexpi


%% Checking settings and parametrization

if nargin == 0
    % Uncomment below for debugging. Please do not commit!
    %%% strInputDir = npc('/share/nas/camelot-share2/Data/Users/Yauhen/nikon/test_dataset/121010TIRFM3');
    %%% strOutputDir = npc('/share/nas/camelot-share2/Data/Users/Yauhen/nikon/test_dataset/121010TIRFM3/TIFF');
    % normally we don't guess but die bravely with exception/error. It is
    % expected user is smart enough to know what he is doing and/or 
    % capabale of reading this comments if he calls this function.
    error('Not enough input arguments')
elseif nargin > 3
    error('Too many input arguments')
elseif nargin == 1
    strOutputDir = strInputDir;
end
if nargin < 3
    boolDoCopy = true;
end
if ~isdir(strInputDir)
    error('%s: Input path was not found: %s', mfilename, strInputDir);
end

   
%% Preparing files for copying

fprintf('%s: processing input directory ''%s''\n',mfilename,strInputDir)

% % checks whether to copy the renamed files or to move
if boolDoCopy
    str2Do = 'copy';
else
    str2Do = 'move';
end

fprintf('%s: you set %s to %s your images to %s''\n', mfilename, mfilename, str2Do, strOutputDir)
if ~boolDoCopy
    fprintf('%s: Warning! old filenames will be overwritten!\n', mfilename)
end

% % makes the Output folder and the corresponding path
fprintf('%s: OutputDir for the unpacked STK images is ''%s''\n',mfilename,strOutputDir)
if ~isdir(strOutputDir)
    mkdir(strOutputDir);
end

% % gives you files and paths of the files in given directory
cellFilenames = findfilewithregexpi(strInputDir, '.*(\.tiff?|\.stk|\.nd)');
if ~iscell(cellFilenames) || numel(cellFilenames) == 0 
    error(['%s: No files found for copying/renaming. Maybe files were '...
           'already processed in:\n''%s'' ?'], mfilename, strInputDir);
end
cellFnOverview = sort_nat(cellFilenames);
cellFpOverview  = sort_nat(findfilewithregexpi(strInputDir, '.*(\.tiff?|\.stk|\.nd)', true));

% checks if there is any .nd file and loads it into a cellarray
[sctNDFile,~, boolDoStage, boolDoTimelapse, boolDoWave, ~] = microscopetool.nikon.readNDFile(strInputDir , 1);


% % gets you the list of all filenames (.nd excluded) which are in a directory
fprintf('%s: inventarising files in given directory %s''\n',mfilename, strInputDir)
cellFnInput = flatten(regexp(cellFnOverview, '.*(\.stk|\.tiff?)$', 'match'))';
cellFpInput = flatten(regexp(cellFpOverview, '.*(\.stk|\.tiff?)$', 'match'))';

% % makes the list of timepoints tetradigital
if boolDoTimelapse
    fprintf('%s: dataset has been recognized as timelapse acquisition''\n', mfilename)
    cellTp2Change = flatten(regexp(cellFnInput, '_t(\d*).\w*$', 'tokens'))';
    cellTpNew = cellfun(@(x) sprintf('_t%04s', x),cellTp2Change, 'UniformOutput', false);
else
    fprintf('%s: dataset has been recognized as single time point acquisition''\n',mfilename)
    cellTpNew = cell(size(cellFnInput));
    cellTpNew(:,1) = {'_t0001'};
end

% % makes the list of stagepositions
if boolDoStage
    cellSp2Change = flatten(regexp(cellFnInput, '_s(\d*)', 'tokens'))';
    cellSp2Access = cellfun(@(x) ['Stage' num2str(x)], cellSp2Change, 'UniformOutput', false);
    if findstr(sctNDFile.Stage1, 'row:')
        fprintf('%s: dataset has been recognized as acquisition in plate design''\n',mfilename)
        cellSpNew = cellfun(@(x) regexp(sctNDFile.(x),'row:(.*),column:(.*),site:(.*)$', 'tokens'), cellSp2Access, 'UniformOutput', false);
        cellSpNew = cellfun(@(x) x{1,1}, cellSpNew, 'UniformOutput', false);
        cellSpNew = cat(1,cellSpNew{:});
        cellSpNew(:,2) = cellfun(@(x) sprintf('%02s', x), cellSpNew(:,2), 'UniformOutput', false);
        cellSpNew(:,3) = cellfun(@(x) sprintf('_s%03s', x), cellSpNew(:,3), 'UniformOutput', false);
        cellSpNew = strcat('_', cellSpNew(:,1), cellSpNew(:,2), cellSpNew(:,3));
    else
        fprintf('%s: dataset has been recognized a multiple site acquisition''\n',mfilename)
        cellSpNew = cellfun(@(x) sprintf('_s%03s', sctNDFile.(x)), cellSp2Access, 'UniformOutput', false);
    end
    
else
    fprintf('%s: dataset has been recognized as a singe site acquisition''\n',mfilename)
    cellSpNew = cell(size(cellFnInput));
    cellSpNew(:,1) = {'_s001'};
end


% % makes the list of the wavelengths
if boolDoWave
    fprintf('%s: dataset has been recognized as an acquisition with multiple wavelengths''\n',mfilename)
    cellWl2Access = flatten(regexp(cellFnInput, '_w(\d).*', 'tokens'))';
    cellWlNew = cellfun(@(x) sprintf('_w%02s',x), cellWl2Access, 'UniformOutput', false);
else
    fprintf('%s: dataset has been recognized as an acquisition with a single wavelength''\n',mfilename)
    cellWlNew = cell(size(cellFnInput));
    cellWlNew(:,1) = {'_w01'};
end

% % makes the final names and paths
%cellFnND = flatten(regexp(cellFnOverview, '(.*)\.nd', 'tokens'))';
cellFnND = flatten(regexp(cellFnOverview, '(.*)\.nd', 'tokens'))';
cellFnEndings = flatten(regexp(cellFnInput, '.*\.(\w*)$', 'tokens'))';
cellFnOutput = cellfun(@(x,y,z,w)sprintf('%s_NIKON%s%s%s.%s', cellFnND{1,1},x,y,z,w),cellTpNew, cellSpNew, cellWlNew, cellFnEndings, 'UniformOutput', false);
cellFpOutput = cellfun(@(x) fullfile(strOutputDir, x), cellFnOutput, 'UniformOutput', false);


%% Bulk copying/moving of files

copyOrMoveFiles(str2Do, cellFpInput, cellFpOutput);

%% Unstack

microscopetool.nikon.unpackStack(strOutputDir, strInputDir, strOutputDir);

end

function copyOrMoveFiles(operation, fullPathSrc, fullPathDst)
%COPYORMOVEFILES Move or copy and rename files
% 
% Bulk moving or copying for multiple files.
%
% operation   a string to indicate usage one of {'copy', 'move'}
%
% fullPathSrc a cell array with full pathanmae strings to take as a source
%             of the procedure
% fullPathDst a cell array with full pathanmae strings to use for 
%             destenation of the procedure
%
if length(fullPathSrc) == length(fullPathDst)
    for i = 1:length(fullPathDst)
        if ispc
            % On Windows (PC).
            eval(sprintf('!powershell -inputformat none %s %s %s',...
                         operation, fullPathSrc{i,1}, fullPathDst{i,1}));
        else
            % Assume Mac or unix.
            op = 'cp';
            if operation == 'move'
                op = 'mv';
            end
            eval(sprintf('!%s -v %s %s',...
                         op, fullPathSrc{i,1}, fullPathDst{i,1}));
        end
    end
else
    error(['%s: failed to copy/rename files. Source and target '...
           'pathname lists have different dimensions'], mfilename);
end
    fprintf('%s: (%d) files have been processed (using bulk %s operation)''\n',...
            mfilename, numel(fullPathSrc), operation);
end

