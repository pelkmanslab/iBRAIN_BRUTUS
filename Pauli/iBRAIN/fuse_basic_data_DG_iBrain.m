function [BASICDATA] = fuse_basic_data_DG(strRootPath, BASICDATA)

warning off all;

if nargin == 0
    
    strRootPath = npc('X:\Data\Users\YF_DG\');
end

if nargin < 2
    % INITIALIZE BASICDATA
    BASICDATA = struct();
end

% LOOK FOR TARGET FOLDERS
disp(sprintf('Looking for target folders in %s',strRootPath))
tic
[cellstrFolderList] = getPlateDirectoriesFromiBRAINDB(strRootPath,'basicdata');%SearchTargetFolders(strRootPath,'BASICDATA_*.mat');
toc

% CHECK TO PREVENT LOADING BASICDATA_...MAT FILES FROM strRootPath
% REMOVE THEM FROM THE LIST
matRootBasicdataIndices = strcmpi(getlastdir(strRootPath),getlastdir(getbasedir(cellstrFolderList)));
disp(sprintf('Excluding %d BASICDATA_*.mat files in root from project',length(find(matRootBasicdataIndices))))
% matRootBasicdataIndices = strcmpi(strRootPath,getbasedir(cellstrFolderList));
cellstrFolderList = cellstrFolderList(~matRootBasicdataIndices);

% check number of basicdatas found
intNumOfFolders = size(cellstrFolderList,1);
disp(sprintf('Found %d target folders',intNumOfFolders))

for iDir = 1:intNumOfFolders

    % CHECK TO PREVENT LOADING BASICDATA_...MAT FILES FROM strRootPath
    % DIRECTLY
    if strcmpi(getlastdir(strRootPath),getlastdir(getbasedir(cellstrFolderList{iDir})))
       continue 
    end
    
    %%% LOAD BASICDATA
    disp(sprintf('Loading %s',cellstrFolderList{iDir}))
    PLATE_BASICDATA = load(cellstrFolderList{iDir});
    PLATE_BASICDATA = PLATE_BASICDATA.BASICDATA;

    strPlateDirectory = strrep(getbasedir(cellstrFolderList{iDir}),[filesep,'BATCH'],'');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
   

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% CHECK IF THERE IS Measurements_Nuclei_CellType_Overview_DG DATA PER WELL, AND ADD TO PLATE_BASICDATA IF SO
    %%% Measurements_Nuclei_CellType_Overview.mat
    try
        [cellstrFolderList4] = SearchTargetFolders(strPlateDirectory,'Measurements_Nuclei_CellType_Overview_DG.mat');
        if ~(isempty(cellstrFolderList4))

            % LOAD THE ONE WITH THE LEAST FILESEPS IN THE PATH, I.E. THE
            % HIGHEST IN THE FILESYSTEM
            [foo,bar]=sort(cellfun(@numel,strfind(cellstrFolderList4,filesep)));
            disp(sprintf('        %s',cellstrFolderList4{bar(1)}));
            PLATE_CellTypeData = load(cellstrFolderList4{bar(1)});

            if sum(PLATE_BASICDATA.WellCol == PLATE_CellTypeData.BASICDATA_CellType.WellCol) ~= 384 || ...
                    sum(PLATE_BASICDATA.WellRow == PLATE_CellTypeData.BASICDATA_CellType.WellRow) ~= 384
                error('Measurements_Nuclei_CellType_Overview plate layouts does not match BASICDATA plate layout!!!')
            end

            %%% automatically add all fieldnames (fieldnames slightly renamed),
            %%% they are all numerical matrices (double)
            cellFieldNames = fieldnames(PLATE_CellTypeData.BASICDATA_CellType);
            for iFieldName = cellFieldNames'
                % Skip WellRow, WellCol fields
                strFieldName = char(iFieldName);
                if ~strcmpi(strFieldName,'wellrow') && ~strcmpi(strFieldName,'wellcol')
                    % remove underscores, capitalize "index" and "number"
                    strNewFieldName = strrep(strFieldName,'_','');
                    strNewFieldName = strrep(strNewFieldName,'index','Index');
                    strNewFieldName = strrep(strNewFieldName,'number','Number');                
                    strNewFieldName = ['CellTypeOverview',strNewFieldName]; %#ok<AGROW>
                    PLATE_BASICDATA.(strNewFieldName) = PLATE_CellTypeData.BASICDATA_CellType.(strFieldName);
                end
            end

        end
    catch caughtError
        caughtError.identifier        
        caughtError.message
       disp(sprintf('error while adding %s from %s','Measurements_Nuclei_CellType_Overview_DG',strPlateDirectory))
    end
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% CHECK IF THERE IS ControlLayout per plate or per screen, AND ADD TO PLATE_BASICDATA IF SO

    % check the per plate controllayout file
    try
        [cellstrFolderList5] = SearchTargetFolders(strPlateDirectory,'ControlLayout.mat');
        if (isempty(cellstrFolderList5))
            % if there is no control layout file per plate, load the default
            % one from the rootpath
            p=[strRootPath,'ControlLayout.mat'];
            if fileattrib(p)
                cellstrFolderList5{1} = p;
            end
        end

        % if there is a control layout file in either the plate dir or in the
        % project dir, proces it.
        if ~(isempty(cellstrFolderList5))
            % LOAD THE ONE WITH THE LEAST FILESEPS IN THE PATH, I.E. THE
            % HIGHEST IN THE FILESYSTEM
            [foo,bar]=sort(cellfun(@numel,strfind(cellstrFolderList5,filesep)));
            disp(sprintf('        %s',cellstrFolderList5{bar(1)}));
            PLATE_ControlLayout = load(cellstrFolderList5{bar(1)});

            if sum(PLATE_BASICDATA.WellCol == PLATE_ControlLayout.BASICDATA_controls.WellCol) ~= 384 || ...
                    sum(PLATE_BASICDATA.WellRow == PLATE_ControlLayout.BASICDATA_controls.WellRow) ~= 384
                error('ControlLayout plate layouts does not match BASICDATA plate layout!!!')
            end

            for row=1:16
                for col=1:24
                    index=find(PLATE_BASICDATA.WellRow==row & PLATE_BASICDATA.WellCol==col);
                    control=PLATE_ControlLayout.BASICDATA_controls.Control{1,index};
                    if ~isempty(control)
                        PLATE_BASICDATA.GeneData{1,index}=control;
                        PLATE_BASICDATA.GeneID{1,index}=PLATE_ControlLayout.BASICDATA_controls.GeneID(1,index);
                    end
                end
            end
        end
    catch caughtError
        caughtError.identifier        
        caughtError.message
       disp(sprintf('error while adding %s from %s','ControlLayout plate layout',strPlateDirectory))
    end     

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% MERGE ALL FIELDS IN PLATE_BASICDATA TO BASICDATA %%%

    % LIST ALL FIELDNAMES IN PLATE_BASICDATA
    cellstrCurrentFieldNames = fieldnames(PLATE_BASICDATA);

    % LOOP OVER ALL FIELDNAMES, AND MERGE TO BASICDATA
    for sField = cellstrCurrentFieldNames'
        strFieldName = char(sField);

        intNumOfColumns = size(PLATE_BASICDATA.(strFieldName),2);
        intNumOfRows = size(PLATE_BASICDATA.(strFieldName),1);

        % CHECK IF FIELD IS ALREADY PRESENT, IF NOT, INITIALIZE IT
        % ACCORDING TO CLASS IN BASICDATA
        if ~isfield(BASICDATA,strFieldName)

            if isa(PLATE_BASICDATA.(strFieldName), 'char')
                BASICDATA.(strFieldName) = cell(intNumOfFolders,1);
            elseif isa(PLATE_BASICDATA.(strFieldName), 'numeric') && (intNumOfRows == 1)
                BASICDATA.(strFieldName) = NaN(intNumOfFolders,intNumOfColumns);
            elseif isa(PLATE_BASICDATA.(strFieldName), 'numeric') && (intNumOfRows > 1)
                BASICDATA.(strFieldName) = cell(intNumOfFolders,1);
            elseif isa(PLATE_BASICDATA.(strFieldName), 'cell')
                BASICDATA.(strFieldName) = cell(intNumOfFolders,intNumOfColumns);
            elseif isa(PLATE_BASICDATA.(strFieldName), 'struct')
                BASICDATA.(strFieldName) = cell(intNumOfFolders,intNumOfColumns);
            end
        end

        if isa(PLATE_BASICDATA.(strFieldName), 'char')
            BASICDATA.(strFieldName){iDir,:} = PLATE_BASICDATA.(strFieldName);
        elseif isa(PLATE_BASICDATA.(strFieldName), 'numeric') && (intNumOfRows > 1)
            BASICDATA.(strFieldName){iDir,:} = PLATE_BASICDATA.(strFieldName);
        else
            BASICDATA.(strFieldName)(iDir,:) = PLATE_BASICDATA.(strFieldName);
        end
    end
end


try
    disp(sprintf('\n%d plates gathered',size(BASICDATA.TotalCells,1)))
    disp(sprintf('Saving %s',fullfile(strRootPath,'BASICDATA_DG.mat')))
    save(fullfile(strRootPath,'BASICDATA_DG.mat'),'BASICDATA');
catch
    err1 = lasterror
    msg = err1.message;
    disp(sprintf('   !!! Saving BASICDATA_DG failed on %s. \n\n%s',strRootPath, msg))
end

end%end of function