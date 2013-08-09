function handles = iBrainTrackerV1(strRootPath,strSettingsFile)
 
%The call the function use:
%handles = iBrainTrackerV1(strRootPath,strSettingsFile)
%
%
%strRootPath refers to the folder of iBrain containing the BATCH, TIFF and SEGMENTATION subfolders.
%The setting file should be named SetTracker_***.txt, where  *** stands for
%any name, eg. SetTracker_Nuclei01.txt.
%
%
%The seting file should contain the follwing parameters:
%
% structTrackingSettings.TrackingMethod => can take the values 'Distance' or
% 'Overlap'. Default = 'Distance'.
% structTrackingSettings.ObjectName => can take any name corresponding to a
% object eg: 'Nuclei' or 'Cells'. Default = 'Nuclei'.
% structTrackingSettings.PixelRadius => for 'Distance': it corresponds to
% the object expansion in pixels. Default = 10.
% structTrackingSettings.OverlapFactorC => Correspond to the minimum overlap
% allowed to define children. Default = 0.3.
% structTrackingSettings.OverlapFactorP => Correspond to the minimum overlap
% allowed to define parents. Default = 0.3;
% structTrackingSettings.WavelengthID => corresponds to the wavelength ID
% of the segmentation images, eg: '_w1'. Default = 'none', in which case
% asumes the name of the first image in the
% 'Measurements_Image_FileNames.mat' file.
% structTrackingSettings.CreateFrames => 'Yes' or 'yes' or 'y' if you want to create frames
% for a visualization movie. Default =Default = 'Yes'.
% structTrackingSettings.TailTime => Corresponds to the number of
% timepoints the tail of the tracked cell is visualized. Default = 20.
%
% Example of Setting file:
% structTrackingSettings.TrackingMethod = 'Distance';
% structTrackingSettings.ObjectName = 'Nuclei';
% structTrackingSettings.PixelRadius = 10;
% structTrackingSettings.OverlapFactorC = 0.3;
% structTrackingSettings.OverlapFactorP = 0.3;
% structTrackingSettings.WavelengthID = '_w1';
% structTrackingSettings.CreateFrames = 'Yes';
% structTrackingSettings.TailTime = 20;
%
%Aditional files required in the BATCH directory:
% 'Measurements_strObjectToTrack_Location.mat'
% 'Measurements_Image_FileNames.mat'
% 'Measurements_Image_ObjectCount.mat'
% Note: if such files do not exist the tracker will not work.
%
%iBrainTrackerV1 (version 1.0) tracks all wells, does not do tracking over 
%multiple sites. (this are all 
%to consider for version 2.0).
%
% Nico Battich 22-08-2011

strRootPath = npc(strRootPath);
strSettingsFile = npc(strSettingsFile);

% first of all lets get all the images sorted out
strBatchPath = fullfile(strRootPath,'BATCH');

% now get the settings file.
% strSettingsFile = SearchTargetFolders(strRootPath,'SetTracker_*.txt');
if isempty(strSettingsFile)
    error('%s: Setting file not found\n',mfilename)
end



%% Tracking Stage 1. Initialization
fprintf('%s: Tracking Stage 1: initilizing tracking parameters.\n',mfilename);
[handles, strSettingBaseName] = initTrackingSettings(strRootPath,strSettingsFile);
strObjectToTrack = handles.TrackingSettings.ObjectName;
cellAllImages = handles.Measurements.Image.FileNames';
cellAllSegmentedImages = handles.Measurements.Image.SegmentedFileNames';
cellAllTrackedImages = handles.Measurements.Image.TrackedFileNames';
numGetFrames = strncmpi(handles.TrackingSettings.CreateFrames,'y',1);


fprintf('%s: Tracking Stage 1: objects to be tracked: %s.\n',mfilename,strObjectToTrack);


% get the number of wells, the number of timepoints and the number of
% sites.
[matRows, matColumns, strWells, matTimepoints] = cellfun(@filterimagenamedata,cellAllSegmentedImages,'UniformOutput',false);
matRows = cell2mat(matRows);
matColumns = cell2mat(matColumns);
matTimepoints = cell2mat(matTimepoints);

% Check that there is more than one timepoint
if sum(matTimepoints > 1) == 0
    error('%s: There is only one timepoint. Please check that the PATH to the movie is correct. ',mfilename)
end

% Now get the sites!! 
[matSites, ~] = cellfun(@check_image_position,cellAllSegmentedImages,'UniformOutput',false);
matSites = cell2mat(matSites);

% Asign unique ID to sites in the whole plate 
[structUniqueSiteID.matUniqueValues foo structUniqueSiteID.matJ]= unique([matRows, matColumns, matSites],'rows');
clear foo 

fprintf('%s: Tracking Stage 1: initialization completed for %s.\n',mfilename,strRootPath);



%% Tracking Stage 2. Tracking & Images Creation 
numTotalSites = size(structUniqueSiteID.matUniqueValues,1);
fprintf('%s: Tracking Stage 2: Tracking will be strated for a total of %d sites.\n',mfilename,numTotalSites);

% here I have all the information to run the Tracker. 
%%%
%[NB]perhaps this code can be reduced to a cellfun rathe than a for loop. 
for iSites = 1:numTotalSites

    % find all the images that belong to iSites and put them in the correct
    % order
    matIndexSite = find(structUniqueSiteID.matJ == iSites);
    strCurrentWell = strWells(matIndexSite); strCurrentWell = char(strCurrentWell(1));
    fprintf('%s: Tracking Stage 2: Tracking site %d of %d. Well %s.\n',mfilename,structUniqueSiteID.matUniqueValues(iSites,3),numTotalSites,strCurrentWell);

    [foo matOrderedTimePointIdx] = sort(matTimepoints(matIndexSite));
    clear foo
    matOrderedTimePointIdx = matIndexSite(matOrderedTimePointIdx);
    
    % Initialize values for the tracker 
    if iSites == 1
        handles.Current.SetBeingAnalyzed = 1;
        handles.Current.NumberOfImageSets = size(matOrderedTimePointIdx,1);
        handles.Current.StartingImageSet = 1;
    else
        handles.Current.NumberOfImageSets = handles.Current.NumberOfImageSets + size(matOrderedTimePointIdx,1);
    end
    
    handles = BasicTrackerV1(handles,cellAllSegmentedImages,matOrderedTimePointIdx,[matRows, matColumns, matSites ,matTimepoints],strSettingBaseName);
    
    
    %%%
    %[NB] Here the Visualization hapens. It will save the images
    %of frames in a TRACKING folder in the IBrain directory. Note it is the
    %slower step of the tracker!! imwrite == BAD!!
    
    if numGetFrames
        fprintf('%s: Tracking Stage 2: Creating site frames for movie visualization. Find this files in the DUMPSITES directory. Site %d of %d. Well %s.\n',mfilename,structUniqueSiteID.matUniqueValues(iSites,3),numTotalSites,strCurrentWell);
        handles = getframesformovie(handles,matOrderedTimePointIdx,strSettingBaseName);
    else
        fprintf('%s: Tracking Stage 2: Skipping frame creation.\n',mfilename,structUniqueSiteID.matUniqueValues(iSites,3),numTotalSites,strCurrentWell);
    end
    
    
end
fprintf('%s: Tracking Stage 2: Tracking of %s completed.\n',mfilename,strObjectToTrack);

%%% 
%[NB] Here we can adapt MF's code for global trajectoies and tracking
%over multiple sites. we need a function like this: 
%handles=getglobalidandtarckconnection(handles,matWellID)




%% Tracking Stage 3. Movies Creation
if numGetFrames
    fprintf('%s: Tracking Stage 3: Starting movie creation for setting file SetTracker_%s.txt.\n',mfilename,strSettingBaseName);
    
    % get the current tracking path
    strTrackingPath = fullfile(strRootPath,'TRACKING',strSettingBaseName);
    % check if directory exist
    if ~fileattrib(strTrackingPath)
        error('%s: Tracking Stage 3: Directory %s does not exist. Imposible to create well frames if site frames do not exist',mfilename,strTrackingPath)
    end
    mergepngmovieV1(strTrackingPath);
else
    fprintf('%s: Tracking Stage 3: Skipping movie creation for setting file %s.\n',mfilename,strSettingBaseName);
end

% Now create the movies, two formats per each movie so that we can up load
% them to any browser
generatemoviesV1(strTrackingPath);
fprintf('%s: Tracking Stage 3: Movie creation completed.\n',mfilename);

%% Tracking Stage 4. Post-analystis & Statistics
%%%[NB] this option is buggy so we remove it for the moment =============== 
% fprintf('%s: Tracking Stage 4: Generating post-analysis matrices.\n',mfilename,strBatchPath);
% handles = IBT1postanalysis(handles,strSettingBaseName);
% fprintf('%s: Tracking Stage 4: Post-analysis matrices generated.\n',mfilename);
%%%========================================================================




%% Tracking Stage 5. Saving Results Files
fprintf('%s: Tracking Stage 5: Saving files to %s.\n',mfilename,strBatchPath);
% reorganize files to be saved
PreviousHandles = handles;

% save the measurements
handles = struct();
TrackingMeasurementPrefix = strcat('TrackObjects_',strSettingBaseName);
handles.Measurements.(strObjectToTrack).(TrackingMeasurementPrefix) = PreviousHandles.Measurements.(strObjectToTrack).(TrackingMeasurementPrefix);
handles.Measurements.(strObjectToTrack).(strcat(TrackingMeasurementPrefix,'Features')) = PreviousHandles.Measurements.(strObjectToTrack).(strcat(TrackingMeasurementPrefix,'Features'));

% [BS] Store handles as measurement file in strBatchPath
strMeasurementFileName = sprintf('Measurements_%s_%s.mat',strObjectToTrack,TrackingMeasurementPrefix);
save(fullfile(strBatchPath, strMeasurementFileName), 'handles')


% save the MetaData
handles = struct();
TrackingMeasurementPrefix = strcat('TrackObjectsMetaData_',strSettingBaseName);
handles.Measurements.(strObjectToTrack).(TrackingMeasurementPrefix) = PreviousHandles.Measurements.(strObjectToTrack).(TrackingMeasurementPrefix);
handles.Measurements.(strObjectToTrack).(strcat(TrackingMeasurementPrefix,'Features')) = PreviousHandles.Measurements.(strObjectToTrack).(strcat(TrackingMeasurementPrefix,'Features'));

% [BS] Store handles as measurement file in strBatchPath
strMeasurementFileName = sprintf('Measurements_%s_%s.mat',strObjectToTrack,TrackingMeasurementPrefix);
save(fullfile(strBatchPath, strMeasurementFileName), 'handles')

% save the Image 
handles = struct();
TrackingMeasurementPrefix = strcat('TrackObjects_',strSettingBaseName);
handles.Measurements.Image.(TrackingMeasurementPrefix) = PreviousHandles.Measurements.Image.(TrackingMeasurementPrefix);
handles.Measurements.Image.(strcat(TrackingMeasurementPrefix,'Features')) = PreviousHandles.Measurements.Image.(strcat(TrackingMeasurementPrefix,'Features'));

% [BS] Store handles as measurement file in strBatchPath
strMeasurementFileName = sprintf('Measurements_Image_%s.mat',TrackingMeasurementPrefix);
save(fullfile(strBatchPath, strMeasurementFileName), 'handles')
fprintf('%s: Tracking Stage 5: Output files saved to %s.\n',mfilename,strBatchPath);

% Save the PostAnalysis results
%%%[NB] I disable this for the moment =====================================
% handles = struct();
% TrackingMeasurementPrefix = strcat('TrackObjectsLineage_',strSettingBaseName);
% handles.Measurements.(strObjectToTrack).(TrackingMeasurementPrefix) = PreviousHandles.Measurements.(strObjectToTrack).cellLineageFinal;
% %handles.Measurements.(strObjectToTrack).(strcat(TrackingMeasurementPrefix,'Features')) = PreviousHandles.Measurements.(strObjectToTrack).(strcat(TrackingMeasurementPrefix,'Features'));
% 
% % [BS] Store handles as measurement file in strBatchPath
% strMeasurementFileName = sprintf('Measurements_%s_%s.mat',strObjectToTrack,TrackingMeasurementPrefix);
% save(fullfile(strBatchPath, strMeasurementFileName), 'handles')
% 
% 
% handles = struct();
% TrackingMeasurementPrefix = strcat('TrackObjectsMoveGenLastFrame_',strSettingBaseName);
% handles.Measurements.(strObjectToTrack).(TrackingMeasurementPrefix) = PreviousHandles.Measurements.(strObjectToTrack).cellMoveGen;
% handles.Measurements.(strObjectToTrack).(strcat(TrackingMeasurementPrefix,'Features')) = {'Belongs_to_Last_Frame','1sTrackID','2ndTrackID','Tree_Move_Up','Tree_Move_Down'};
% 
% % [BS] Store handles as measurement file in strBatchPath
% strMeasurementFileName = sprintf('Measurements_%s_%s.mat',strObjectToTrack,TrackingMeasurementPrefix);
% save(fullfile(strBatchPath, strMeasurementFileName), 'handles')
% 
% handles = struct();
% TrackingMeasurementPrefix = strcat('TrackObjectsLineageMetaData_',strSettingBaseName);
% handles.Measurements.(strObjectToTrack).(TrackingMeasurementPrefix) = PreviousHandles.Measurements.(strObjectToTrack).cellLineageMetaDataFinal;
% handles.Measurements.(strObjectToTrack).(strcat(TrackingMeasurementPrefix,'Features')) = {'Plate_Row','Plate_Column','Well_Site'};
% 
% % [BS] Store handles as measurement file in strBatchPath
% strMeasurementFileName = sprintf('Measurements_%s_%s.mat',strObjectToTrack,TrackingMeasurementPrefix);
% save(fullfile(strBatchPath, strMeasurementFileName), 'handles')
%%%========================================================================

%%%
%[NB] could also save this guys, though they are not so usefull. 
% handles.Measurements.(handles.TrackingSettings.ObjectName).cellDividersFinal = cellDividersFinal;
% handles.Measurements.(handles.TrackingSettings.ObjectName).cellChildrenFinal = cellChildrenFinal;
% handles.Measurements.(handles.TrackingSettings.ObjectName).cellLin = cellLin;


fprintf('%s: Tracking completed for data in %s\n',mfilename,strRootPath)
