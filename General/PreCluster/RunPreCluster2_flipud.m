function RunPreCluster2(strRootPath)

warning off all;

if nargin == 0
    disp('RunPreCluster: 50K MODE')
    if ispc
        strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\50K_final\';
%         strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\VSV_DG\';        
    else
        strRootPath = '/Volumes/share-2-$/Data/Users/50K_final/';        
%         strRootPath = '/Volumes/share-2-$/Data/Users/VSV_DG/';                
    end
end

% strCPOutputFile = strcat(fileparts(which('RunPreCluster2.m')), filesep, 'PreCluster_FULL_ANALYSIS_PIPE_BINNED2X2.mat');
strCPOutputFile = strcat(fileparts(which('RunPreCluster2.m')), filesep, 'PreCluster_FULL_ANALYSIS_50K_PIPEOUT.mat');
strOutputFolder = 'BATCH';
strInputFolder = 'TIFF';

RootPathFolderList = dirc(strRootPath,'de');
RootPathFolderList = flipud(RootPathFolderList);

%disp(sprintf('%s; %g subfolders found', strRootPath, size(RootPathFolderList,1)));

for folderLoop = 1:size(RootPathFolderList,1)

    % do not search for tiff folders inside Input- and Output-Folders
    if ~strcmpi(RootPathFolderList{folderLoop,1}, strOutputFolder) && ...
            ~strcmpi(RootPathFolderList{folderLoop,1}, strInputFolder)

        strSubfolderPath = strcat(strRootPath,RootPathFolderList{folderLoop,1},filesep);
        RunPreCluster2(strSubfolderPath)
        
    elseif strcmpi(RootPathFolderList{folderLoop,1}, strInputFolder)

        strSubfolderPath = strcat(strRootPath,RootPathFolderList{folderLoop,1},filesep);
%         disp(strSubfolderPath)
        
        SubmitPreCluster(strRootPath, strCPOutputFile, strOutputFolder, strInputFolder);

    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SubmitPreCluster(strSubfolderPath, strCPOutputFile, strOutputFolder, strInputFolder)

resultCreateOutputFolder = 0;
cellSubDirlist  = dirc(strcat(strSubfolderPath),'de');        
strInputFolderPath = strcat(strSubfolderPath,strInputFolder,filesep);        
hasOutputFolder = strcmpi(cellSubDirlist(:,1),strOutputFolder);
strOutputFolderPath = strcat(strSubfolderPath,strOutputFolder,filesep);

if not(isempty(find(hasOutputFolder)))
else
    resultCreateOutputFolder = mkdir(strSubfolderPath,strOutputFolder);
    if not(resultCreateOutputFolder)
        disp(sprintf(' - failed to create %s folder', strOutputFolder));
        disp(sprintf(' - continuing to next project folder'));
        return
    end
end

if not(isempty(find(hasOutputFolder))) || resultCreateOutputFolder
    strOutputFolderFileList = dirc(strOutputFolderPath,'f');
    hasMATFilesInOutputFolder = strcmpi('MAT',strOutputFolderFileList(:,3));
    if not(isempty(find(hasMATFilesInOutputFolder)))
        disp(sprintf('%s already has .mat files', strOutputFolderPath))
    else
        try
            disp(sprintf(' - STARTING PreCluster %s %s %s', strCPOutputFile, strInputFolderPath, strOutputFolderPath))            
%             PreCluster(strCPOutputFile, strInputFolderPath, strOutputFolderPath, {'d0.tif','d1.tif'})
            PreCluster(strCPOutputFile, strInputFolderPath, strOutputFolderPath)            
        end
    end
end

