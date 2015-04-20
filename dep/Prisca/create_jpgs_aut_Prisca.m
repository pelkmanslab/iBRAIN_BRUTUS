function create_jpgs_aut_Prisca(strTiffPath, strOutputPath)

    if nargin == 0
        
%         strTiffPath = 'Y:\Data\Users\50K_final_reanalysis\YF_KY\070115_YF_50K_KY_P2_1_3_CP072-1ac\TIFF';
%         strOutputPath = 'Y:\Data\Users\50K_final_reanalysis\YF_KY\070115_YF_50K_KY_P2_1_3_CP072-1ac\JPG2';
       
%         strTiffPath = 'Y:\Data\Users\50K_final_reanalysis\YF_KY\070115_YF_50K_KY_P3_1_1_CP073-1aa\TIFF';
%         strOutputPath = 'Y:\Data\Users\50K_final_reanalysis\YF_KY\070115_YF_50K_KY_P3_1_1_CP073-1aa\JPG2';        


         strTiffPath = '\\nas-unizh-imsb1.ethz.ch\share-3-$\Data\Users\Prisca\Serena\120118-U2OS-5000\TIFF';
         strOutputPath = '\\nas-unizh-imsb1.ethz.ch\share-3-$\Data\Users\Prisca\Serena\120118-U2OS-5000\JPG';
%         % F03
% 
%         strTiffPath = 'Y:\Data\Users\50K_final_reanalysis\Ad5_KY\061210_Ad5_50K_Ky_2_1_CP072-1aa\TIFF';
%         strOutputPath = 'Y:\Data\Users\50K_final_reanalysis\Ad5_KY\061210_Ad5_50K_Ky_2_1_CP072-1aa\JPG2';                
%         % B10

%         strTiffPath = '\\nas-biol-imsb-1.d.ethz.ch\share-3-$\Data\Users\Prisca\100402_A431_Macropinocytosis\100402_A431_Macropinocytosis_CP393-1bd\TIFF';
%         strOutputPath = '\\nas-biol-imsb-1.d.ethz.ch\share-3-$\Data\Users\Prisca\100402_A431_Macropinocytosis\100402_A431_Macropinocytosis_CP393-1bd\JPG_HR';
%     
    %     strTiffPath = '\\nas-unizh-imsb1.ethz.ch\share-3-$\Data\Users\Prisca\110918-A431_Checkerboard_EGF_Chtx_Lamp1\CheckerBoard_EGF\TIFF';

    %    strOutputPath = '\\nas-unizh-imsb1.ethz.ch\share-3-$\Data\Users\Prisca\110918-A431_Checkerboard_EGF_Chtx_Lamp1\CheckerBoard_EGF\JPG_HR';
     
    elseif nargin == 1
        strOutputPath = strrep(strTiffPath,'TIFF','JPG_HR');
    end

    % change paths
    strTiffPath = npc(strTiffPath);
    strOutputPath = npc(strOutputPath);
        
    %%%%%%%%%%%%%%%%
    %%% Settings %%%
    
    % how much the images shold be shrunk for JPGs
    intShrinkFactor = 3;
    
    % maximum number of images to sample for rescale settings
    intMaxNumImagesPerChannel = 500;
    
    % quantile values for rescale lower and upper rescale settings
    matQuantileSettings = [0.0, 0.9999  9];
    
    % fraction of images to sample for rescaling
    intImageSampleFractionPerChannel = 0.15;
    
    % jpg quality (scale of 1 to 100)
    intJpgQuality = 80;
    
    %%% Settings %%%
    %%%%%%%%%%%%%%%%
    
    
    
    fprintf('%s: analyzing %s\n',mfilename,strTiffPath);

    % create output directory if it doesn't exist.
    if ~fileattrib(strOutputPath)
        disp(sprintf('%s:  creating %s',mfilename,strOutputPath));
        mkdir(strOutputPath)
    end

%     % let's try to do it in parallel
     try
         matlabpool(3)
     end    
    
    
    % get list of files in tiff directory
    cellFileList = CPdir(strTiffPath);
    cellFileList = {cellFileList(~[cellFileList.isdir]).name};
    
%     % temporary hack. only process certain columns at a time...
%     [matRow, matColumn] = cellfun(@filterimagenamedata,cellFileList);
%     matOkIX = matRow==2 & matColumn==10; % (6,4) or (4,10)
%     cellFileList = cellFileList(matOkIX);
   
    
    % only look at .png or .tif
    matNonImageIX = cellfun(@isempty,regexpi(cellFileList,'.*(\.png|\.tif)$','once'));
    cellFileList(matNonImageIX) = [];
    fprintf('%s:  found %d images\n',mfilename,length(cellFileList));
    
    % parse channel number and position number
    fprintf('%s:  parsing channel & position information\n',mfilename);
    matChannelNumber = cellfun(@check_image_channel,cellFileList);
    matPositionNumber = cellfun(@check_image_position,cellFileList);

    % find unparsable images and remove them from list
    matBadImageIX = find(matChannelNumber==0 | isnan(matChannelNumber) | matPositionNumber==0 | isnan(matPositionNumber));
    if any(matBadImageIX)
        fprintf('%s:  removing %d unrecognized image formats\n',mfilename,sum(matBadImageIX));
        cellFileList(matBadImageIX) = [];
        matChannelNumber(matBadImageIX) = [];
        matPositionNumber(matBadImageIX) = [];
    end
    
    % get image well row and column numbers
    [matImageRowNumber,matImageColumnNumber, matFoo, matTimePoints]=cellfun(@filterimagenamedata,cellFileList,'UniformOutput',false);
    clear matFoo
    matImageRowNumber = cell2mat(matImageRowNumber);
    matImageColumnNumber = cell2mat(matImageColumnNumber);
    matTimePoints = cell2mat(matTimePoints);
    
    % boolean to see if there is time resolved data
    boolTimeData = false;
    if length(unique(matTimePoints))>1
        boolTimeData = true;
    end
    
    % get all channel numbers present
    matChannelsPresent = unique(matChannelNumber);
    
    % get plate/project directory name
    strProjectName = getlastdir(strrep(strTiffPath,[filesep,'TIFF'],''));    

    % get microscope type
    [foo,strMicroscopeType] = check_image_position(cellFileList{1});
    clear foo;
    
    % get image snake. special case if images come from Safia (thaminys).
    if ~isempty(strfind(strTiffPath,'thaminys'))
        [matImageSnake,matStitchDimensions] = get_image_snake_safia(max(matPositionNumber), strMicroscopeType);
    else
        [matImageSnake,matStitchDimensions] = get_image_snake(max(matPositionNumber), strMicroscopeType);
    end
        
   
    fprintf('%s:  microscope type "%s"\n',mfilename,strMicroscopeType);
    fprintf('%s:  %d images per well\n',mfilename,max(matPositionNumber));
    fprintf('\t \t \t \t channel %d present\n',matChannelsPresent);    
    
    % containing the rescaling settings
    matChannelIntensities = NaN(max(matChannelsPresent),2);
    
    % sample a test image outside the parfor loop
    tempImage = imread(fullfile(strTiffPath,cellFileList{1}));
    
    for iChannel = matChannelsPresent
        
        intCurrentChannelIX = find(matChannelNumber==iChannel);
        
        intNumberofimages = length(intCurrentChannelIX);
        
        intNumOfSamplesPerChannel = min(ceil(intNumberofimages*intImageSampleFractionPerChannel),intMaxNumImagesPerChannel);
        
        fprintf('%s: sampling %d random images from channel %d...',mfilename,intNumOfSamplesPerChannel,iChannel);
        
        % get randomized indices for all images coming from current
        % channel.
        matRandomIndices = randperm(intNumberofimages);
        matRandomIndices = intCurrentChannelIX(matRandomIndices);
        
        % contains lower and upper quantile intensity per image
        matQuantiles= NaN(intNumOfSamplesPerChannel,2);
        
% % %         fprintf('%s: \tprogress 0%%',mfilename)
        for i = 1:intNumOfSamplesPerChannel; 
            strImageName = cellFileList{matRandomIndices(i)}; %#ok<PFBNS>

% % %             % report progress in %
% % %             if ~mod(i,floor(intNumOfSamplesPerChannel/10))
% % %                 fprintf(' %d%%',round(100*(i/intNumOfSamplesPerChannel)))
% % %             end
            
            try
                tempImage = imread(fullfile(strTiffPath,strImageName)); %#ok<PFTIN,PFTUS>
            catch %#ok<CTCH>
                warning('matlab:bsBla','%s:  failed to load image %s',mfilename,strImageName)
            end

            % get average lower and upper 5% quantiles per sampled image
            matQuantiles(i,:) = quantile(single(tempImage(:)),matQuantileSettings)';

        end
        fprintf(' done\n')
        
        % make medians of those quantiles the new lower and upper bounds
        matChannelIntensities(iChannel,:) = nanmedian(matQuantiles,1);
    end
    

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% START MERGE AND STITCH AND JPG CONVERSION %%%
    
    matImageSize = round(size(tempImage)/intShrinkFactor);
    
    %if length(matChannelsPresent) == 4
        matChannelOrder = [3,2,1,0];
         %   ; ... % BLUE, GREEN, RED, nothing
          %                 3,0,2,0]; % BLUE, GREEN, nothing, RED
        fprintf('%s: four channels found, producing two different JPGs\n',mfilename);
    %else
        %matChannelOrder = [3,2,1,1]; % BLUE, GREEN, RED, RED (this usually works)
        %if length(matChannelsPresent)>4
            %matChannelOrder = [matChannelOrder,zeros(1,length(matChannelsPresent)-4)];
        %end
    %end
        
    fprintf('%s: start saving JPG''s in %s\n',mfilename,strOutputPath);
    for iPos = unique([matImageRowNumber',matImageColumnNumber', matTimePoints'],'rows')'

        % lookup which images belong to current well
        matCurrentWellIX = ismember([matImageRowNumber',matImageColumnNumber',matTimePoints'],iPos','rows');

        cellChannelPatch = cell(1,4);
        
        % init matPatch
        matPatch = zeros(round(matImageSize(1,1)*matStitchDimensions(1)),round(matImageSize(1,2)*matStitchDimensions(2)), 'single');
        
        for intChannel = matChannelsPresent

            % initialize current channel image
            matPatch = zeros(round(matImageSize(1,1)*matStitchDimensions(1)),round(matImageSize(1,2)*matStitchDimensions(2)), 'single');

            % look for current well and current channel information
            matCurrentWellAndChannelIX = (matCurrentWellIX & matChannelNumber'==intChannel);

            for k = find(matCurrentWellAndChannelIX)'

                % get current image name
                strImageName = cellFileList{k};
                
                % get current image subindices in whole well matPatch 
                xPos=(matImageSnake(1,matPositionNumber(k))*matImageSize(1,2))+1:((matImageSnake(1,matPositionNumber(k))+1)*matImageSize(1,2));
                yPos=(matImageSnake(2,matPositionNumber(k))*matImageSize(1,1))+1:((matImageSnake(2,matPositionNumber(k))+1)*matImageSize(1,1));

                try
                    matImage = imresize(imread(fullfile(strTiffPath,strImageName)),(1/intShrinkFactor));
                catch caughtError
                    caughtError.identifier
                    caughtError.message
                    warning('matlab:bsBla','%s: failed to load image ''%s''',mfilename,fullfile(strTiffPath,strImageName));
                    matImage = zeros(matImageSize,'single');
                end
                % do image rescaling
                matPatch(yPos,xPos) = (matImage - matChannelIntensities(intChannel,1)) * (2^16/(matChannelIntensities(intChannel,2)-matChannelIntensities(intChannel,1)));
            end
            matPatch(matPatch<0) = 0;
            matPatch(matPatch>2^16) = 2^16;                
            cellChannelPatch{intChannel} = matPatch/2^16;
        end

        for intChannelCombination = 1:size(matChannelOrder,1)            
            % make sure different channel combinations do not overwrite
            % eachother
            if ~boolTimeData
                if size(matChannelOrder,1)>1
                    strFileName = sprintf('%s_%s%02d_RGB%d.png',strProjectName,char(iPos(1)+64),iPos(2),intChannelCombination);
                else
                    strFileName = sprintf('%s_%s%02d_RGB.png',strProjectName,char(iPos(1)+64),iPos(2));
                end
            else
                if size(matChannelOrder,1)>1
                    strFileName = sprintf('%s_%s%02d_t%04d_RGB%d.png',strProjectName,char(iPos(1)+64),iPos(2),iPos(3),intChannelCombination);
                else
                    strFileName = sprintf('%s_%s%02d_t%04d_RGB.png',strProjectName,char(iPos(1)+64),iPos(2),iPos(3));
                end
            end
            
            strFileName = fullfile(strOutputPath,strFileName);
            
            % final RGB image
            Overlay = zeros(size(matPatch,1),size(matPatch,2),3, 'single');
            for iChannel = matChannelsPresent
                % skip empty channels or channels that are not in the
                % current RRGB set.
                if ~matChannelOrder(intChannelCombination,iChannel), continue, end
                % put ChannelPatch in Overlay in the right position
                Overlay(:,:,matChannelOrder(intChannelCombination,iChannel)) = cellChannelPatch{iChannel};
            end
            
            fprintf('%s: storing %s\n',mfilename,strFileName)
            
           % imwrite(Overlay,strFileName,'png','Quality',intJpgQuality);        
            imwrite(Overlay,strFileName,'png');        

            %drawnow

        end % intChannelCombination
       
    end % iPos
    
    
     merge_jpgs_per_plate(strOutputPath)