function alignImage( TiffPaths, TiffFiles, varargin )

% ALIGNIMAGE aligns images from different multiplexing cycles relative to
% each other and saves them to disk.
%
% Images are shifted and cropped based on pre-calculated shift and overlay
% descriptors. The shift descriptors are stored as json files within the
% ALIGNCYCLES iBrain folders. The cropped images (output) are saved in the
% ALIGNCYCLES iBrain folders as well and can then be used to visualize
% channels from different cycles in a merged RGB image, for example.
%
% Input:
%   TiffPaths       cell array of strings with the absolute path names
%   TiffFiles       cell array of strings specifying image file names
%   
% A full file specification would be: fullfile(TiffPaths{n},TiffFiles{n})
%
% Author:
%   Markus Herrmann <markus.herrmann@imls.uzh.ch>


%%% load descriptor variable from json file for each cycle
% check whether json package is installed
if ~exist('loadjson')
    % Please install JSONlab package from
    % http://www.mathworks.com/matlabcentral/fileexchange/33381
    error('unable to load settings file, ''loadjson'' not on path')
end
% define path to json files
AlignCyclesPaths = cellfun(@(x)strrep(x,'TIFF','ALIGNCYCLES'),TiffPaths,'UniformOutput',false);
jsonDescriptorFiles = cell(size(AlignCyclesPaths));
% fieldNames = cell(size(AlignCyclesPath));
for cycle = 1:length(AlignCyclesPaths)
    jsonDescriptorFiles{cycle} = fullfile(AlignCyclesPaths{cycle},'shiftDescriptor.json');
end
clear cycle;
% load json file
% shiftDescriptor = cell2struct(cellfun(@loadjson,jsonDescriptorFiles,'UniformOutput',false),fieldNames,2);
shiftDescriptors = cellfun(@loadjson,jsonDescriptorFiles,'UniformOutput',false);

%%% load illumination correction files of each channel from each cycle
channelsPerCycle = cellfun(@(x)x.channelId,shiftDescriptors,'UniformOutput',false);
if strcmpi(varargin,'Illumcorr')
    BatchPaths = cellfun(@(x)strrep(x,'TIFF','BATCH'),TiffPaths,'UniformOutput',false);
    meanImages = cell(size(channelsPerCycle));
    stdImages = cell(size(channelsPerCycle));
    correctYesNo = cell(size(channelsPerCycle));
    for cycle = 1:length(channelsPerCycle)
        meanImages{cycle} = cell(1,length(channelsPerCycle{cycle}));
        stdImages{cycle} = cell(1,length(channelsPerCycle{cycle}));
        correctYesNo{cycle} = cell(1,length(channelsPerCycle{cycle}));
        for channel = channelsPerCycle{cycle}
            [meanImages{cycle}{channel}, stdImages{cycle}{channel}, correctYesNo{cycle}{channel}] = getIlluminationReference(BatchPaths{cycle},channel);
        end
    end
    clear cycle;
    clear channel;
end

%%% align images of each channel at each site
for site = 1:length(shiftDescriptors{1}.siteNum)
    selectSite = unique(cellfun(@(x)x.siteNum(site),shiftDescriptors));% make sure the right image is picked
    selectWellRow = unique(cellfun(@(x)x.wellRowNum(site),shiftDescriptors));
    selectWellCol = unique(cellfun(@(x)x.wellColNum(site),shiftDescriptors));
    selectWellStr = sprintf('%s%02d',char(selectWellRow+64),selectWellCol);
    for cycle = 1:length(shiftDescriptors)
        for channel = 1:length(channelsPerCycle{cycle})
            selectChannel = channelsPerCycle{cycle}(channel);
%                 searchFile = sprintf('NIKON.*_t\\d{1,}(_z\\d{1,}_|_)[A-Z]\\d{2,3}_s%03d_w%02d[^\\.]*\\.(tiff?|png)',selectSite,selectChannel);
            searchFileExp = sprintf('.*_%s_(T\\d{4})F%03d(L\\d{2})(A\\d{2})(Z\\d{2})C%02d*\\.(tiff?|png)',selectWellStr,selectSite,selectChannel);
            index = ~cellfun(@isempty,regexp(TiffFiles{cycle},searchFileExp,'once'));
            SelectTiffFile = TiffFiles{cycle}{index};
            % load and selected image
            origImage = double(imread(fullfile(TiffPaths{cycle},SelectTiffFile)));
            % optional: correct for illumination
            if strcmpi(varargin,'Illumcorr')
                correctedImage = IllumCorrect(origImage,meanImages{cycle}{channel},stdImages{cycle}{channel},correctYesNo{cycle}{channel});
            else
                correctedImage = origImage;
            end
            % align (and crop) selected image according to pre-calculated shift and overlap
            shift = shiftDescriptors{cycle};
            if abs(shift.yShift(site))>100 || abs(shift.xShift(site))>100 % don't shift images if shift values are very high (reflects empty images)
                alignedImage = correctedImage(1+shift.lowerOverlap : end-shift.upperOverlap, 1+shift.rightOverlap : end-shift.leftOverlap);
            else
                alignedImage = correctedImage(1+shift.lowerOverlap-shift.yShift(site) : end-(shift.upperOverlap+shift.yShift(site)), 1+shift.rightOverlap-shift.xShift(site) : end-(shift.leftOverlap+shift.xShift(site)));            
            end
            % save aligned image
            AlignedFilename = strrep(SelectTiffFile,'.png','_aligned.png');
            imwrite(uint16(alignedImage),fullfile(AlignCyclesPaths{cycle},AlignedFilename))
        end
    end
end
clear cycle;
clear site;
clear channel:
end


