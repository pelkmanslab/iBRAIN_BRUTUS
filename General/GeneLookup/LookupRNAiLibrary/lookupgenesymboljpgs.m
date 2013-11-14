function cellstrJpgPaths = lookupgenesymboljpgs(GeneInput,OligoInput,cellstrProjectDirectories)
%
% Usage:
%
% cellstrJpgPaths = lookupgenesymboljpgs(GeneInput,OligoInput,cellstrProjectDirectories)
%


    if nargin<1
%         GeneInput = 19;%ABCA1
        GeneInput = 'SiSel_NC1';%FOXO3
    end
    if nargin<2
        OligoInput = 1;
    end

    if nargin<3
%     cellstrProjectDirectories = { ...
%         '\\nas-biol-imsb-1.d.ethz.ch\share-2-$\Data\Users\Raphael\070611_Tfn_kinase_screen\',...
%         '\\nas-biol-imsb-1.d.ethz.ch\share-2-$\Data\Users\MHV_DG\',...
%         '\\nas-biol-imsb-1.d.ethz.ch\share-2-$\Data\Users\SV40_DG\',...
%         '\\nas-biol-imsb-1.d.ethz.ch\share-2-$\Data\Users\VV_DG\',...
%         '\\nas-biol-imsb-1.d.ethz.ch\share-2-$\Data\Users\VV_hitscreen\',...
%         '\\nas-biol-imsb-1.d.ethz.ch\share-2-$\Data\Users\YF_DG\',...
%         '\\nas-biol-imsb-1.d.ethz.ch\share-3-$\Data\Users\HPV16_DG\',...
%         '\\nas-biol-imsb-1.d.ethz.ch\share-3-$\Data\Users\HSV1_DG\',...
%         '\\nas-biol-imsb-1.d.ethz.ch\share-3-$\Data\Users\VSV_DG\',...
%         '\\nas-biol-imsb-1.d.ethz.ch\share-3-$\Data\Users\Prisca\090203_Mz_Tf_EEA1\',...
%     };

%         '\\nas-biol-imsb-1.d.ethz.ch\share-3-$\Data\Users\Prisca\090203_Mz_Tf_EEA1\',...
%         '\\nas-biol-imsb-1.d.ethz.ch\share-3-$\Data\Users\Prisca\090203_Mz_Tf_EEA1_vesicles\',...
%         '\\nas-biol-imsb-1.d.ethz.ch\share-3-$\Data\Users\Prisca\090217_A431_Tf_EEA1\',...
    
%     cellstrProjectDirectories = { ...
%         '\\nas-biol-imsb-1.d.ethz.ch\share-2-$\Data\Users\Raphael\070611_Tfn_kinase_screen\',...
%         '\\nas-biol-imsb-1.d.ethz.ch\share-3-$\Data\Users\Prisca\090203_Mz_Tf_EEA1_vesicles\',...
%     };
        
        cellstrProjectDirectories = { ...
%             '\\nas-unizh-imsb1.ethz.ch\share-3-$\Data\Users\Prisca\endocytome',...
            '\\nas-unizh-imsb1.ethz.ch\share-3-$\Data\Users\Prisca\endocytome_FollowUps',...
        };
    else
        if ~iscell(cellstrProjectDirectories)
            cellstrProjectDirectories = {cellstrProjectDirectories};
        end
    end

%     disp(GeneInput)
%     disp(OligoInput)
%     disp(cellstrProjectDirectories)
    
    if iscell(GeneInput)
        GeneInput = GeneInput{1};
    end
    
%     % make sure this is a cell array
%     if ischar(cellstrProjectDirectories)
%         cellstrProjectDirectories = cellstr(cellstrProjectDirectories);
%     end
%     
%     % make sure dir paths end with a filesep
%     for iDir = 1:length(cellstrProjectDirectories)
%         if ~strcmp(cellstrProjectDirectories{iDir}(end),filesep)
%             cellstrProjectDirectories{iDir} = strcat(cellstrProjectDirectories{iDir},filesep);
%         end
%     end

%     % do npc
%     cellstrProjectDirectories = cellfun(@npc,cellstrProjectDirectories,'UniformOutput',false);
% 
%     % get 1st level directory listings for all projects
%     cellstrPlatedirs = cellfun(@CPdir,cellstrProjectDirectories,'UniformOutput',false);
% 
%     % filter out all but directory names
%     cellstrPlatedirs = cellfun(@(x) {x([x.isdir]).name},cellstrPlatedirs,'UniformOutput',false);
% 
%     % concatenate project search paths to first level plate directories
%     cellstrPlatedirs = cellfun(@(x,y) strcat(x,y),cellstrProjectDirectories,cellstrPlatedirs,'UniformOutput',false);
    
    cellstrPlatedirs = cellfun(@findPlates,cellstrProjectDirectories,'UniformOutput',false);
    cellPlateNames = cat(1,cellstrPlatedirs{:});
    cellPlateNames = getbasedir(cellPlateNames);% strip off batch dirs
    
    % look up either GeneId or GeneSymbol
    [PlateNumber, WellName] = lookupgenelocation(GeneInput,OligoInput);
    
    % look up plate numbers for each directory
%     cellPlateNames = cat(2,cellstrPlatedirs{:});
    matPlateNumbers = cellfun(@filterplatedata,cellPlateNames);

    % remove non-parseble directory listings
    cellPlateNames(isnan(matPlateNumbers)) = [];
    matPlateNumbers(isnan(matPlateNumbers)) = [];

    boolJpgsShown = false;
    
    % optional output, if requested, we don't show the images, just return
    % the paths
    cellstrJpgPaths = {};
    
    % loop over each plate hit, search for jpg dir, open jpg if present
    for iPlateIX = find(ismember(matPlateNumbers,PlateNumber))'

        % create jpg dir string, take JPG2 if present...
        if fileattrib(fullfile(cellPlateNames{iPlateIX},'JPG_HR'))
            strJpgDir = fullfile(cellPlateNames{iPlateIX},'JPG_HR');
        elseif fileattrib(fullfile(cellPlateNames{iPlateIX},'JPG2'))
            strJpgDir = fullfile(cellPlateNames{iPlateIX},'JPG2');
        else
            strJpgDir = fullfile(cellPlateNames{iPlateIX},'JPG');
        end

        % check if jpg dir exists
        if fileattrib(strJpgDir)

            if ~fileattrib(fullfile(strJpgDir,'cellstrJpgs.mat'))
                % find corresponding JPG file
                cellstrJpgs = CPdir(strJpgDir);

                % filter out directories
                cellstrJpgs = {cellstrJpgs(~[cellstrJpgs.isdir]).name};
                
                % save
                save(fullfile(strJpgDir,'cellstrJpgs.mat'),'cellstrJpgs')
            else
                % load cellstrJpgs
                load(fullfile(strJpgDir,'cellstrJpgs.mat'))
            end

            % format search string for well name corresponding to current plate
            % and directory
            if ~iscell(WellName);WellName={WellName};end
            
            for iWell = find(PlateNumber==matPlateNumbers(iPlateIX))'
                strWellName = sprintf('_%s_',WellName{iWell});

                % find corresponding jpg file name
                strJpgFile = cellstrJpgs(~cellfun(@isempty,strfind(cellstrJpgs,strWellName)));

                % start default system image browser for corresponding jpgs
                if nargout==0
                    cellfun(@(x) go(fullfile(strJpgDir,x)),strJpgFile)
                else
                    cellstrJpgPaths = cat(2,cellstrJpgPaths,cellfun(@(x) fullfile(strJpgDir,x),strJpgFile,'UniformOutput',false));
                end
    %             cellfun(@(x) go(strJpgDir),strJpgFile)

                if ~isempty(strJpgFile)
                    boolJpgsShown = true;
                end
            end

        end

    end
    
    if ~boolJpgsShown
        
        if size(cellstrProjectDirectories,1)==1
            strInfoString = sprintf('No JPGs found in %s for gene %s oligo %d', getlastdir(cellstrProjectDirectories{1}), GeneInput, OligoInput);
        else
            strInfoString = sprintf('No JPGs found in %d projects for gene %s oligo %d\n',size(cellstrProjectDirectories,1), GeneInput, OligoInput);
        end
        
        [ST,I] = dbstack('-completenames');
        if find(strcmpi({ST.name},'OnClick_GeneLabel'))
            helpdlg(strInfoString,'No corresponding JPGs found');
        else
            fprintf('%s: %s\n',mfilename,strInfoString)
        end
        
    end
    
end

function [PlateNumber, WellName] = lookupgenelocation(GeneInput,OligoInput)
    if isempty(OligoInput)
        if ischar(GeneInput)
            % if text, look up gene SYMBOL position
            [~, PlateNumber, WellName] = lookupgenesymbolposition(GeneInput);
        elseif isnumeric(GeneInput)
            % if numeric, look up gene ID position
            [~, PlateNumber, WellName] = lookupgeneidposition(GeneInput);
        end    
    else
        if ischar(GeneInput)
            % if text, look up gene SYMBOL position
            [~, PlateNumber, WellName] = lookupgenesymbolposition(GeneInput,OligoInput);
        elseif isnumeric(GeneInput)
            % if numeric, look up gene ID position
            [~, PlateNumber, WellName] = lookupgeneidposition(GeneInput,OligoInput);
       end    
    end
end