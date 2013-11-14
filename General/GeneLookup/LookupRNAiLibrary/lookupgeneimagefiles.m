function [cellTiffFiles, cellPlatePaths, matOligoNumber, matPlateNumber, matWellRow, matWellCol] = lookupgeneimagefiles(GeneInput,cellstrProjectDirectories,OligoInput)
%
% Usage:
%
% [cellstrTifPaths, matOligoNumber, matReplicaNumber, matPlateNumber] = lookupgeneimagefiles(GeneInput,cellstrProjectDirectories,OligoInput)
%
% GeneInput can be either a gene-ymbol, or gene-id.
%
% OligoInput can be left empty ([]) or left out, in which case all present
% oligo numbers will be returned.
%
%

    if nargin<1
        % can be either a Gene-ID or Gene-Symbol.
        GeneInput = 'CUL3';
    end

    if nargin<2
        % must be given as well... list of directories to look into.
        cellstrProjectDirectories = {...
            '\\nas-biol-imsb-1.d.ethz.ch\share-2-$\Data\Users\VV_DG', ...
            '\\nas-biol-imsb-1.d.ethz.ch\share-2-$\Data\Users\VV_hitscreen' ...
            };
    else
        % if it's a single string, convert to cell array anyway, as we do
        % cellfun on it...
        if ~iscell(cellstrProjectDirectories)
            cellstrProjectDirectories = {cellstrProjectDirectories};
        end
    end

    if nargin<3
        % by default, make this empty, in which case all oligo's will be
        % returned
        OligoInput = [];
    end
    
    % yeah, we don't really handle cells..
    if iscell(GeneInput)
        GeneInput = GeneInput{1};
    end
    
    %%%%%%%%%%
    % get a list of plates present in our search path, as defined by
    % cellstrProjectDirectories
    
    % make sure dir paths end with a filesep
    for iDir = 1:length(cellstrProjectDirectories)
        if ~strcmp(cellstrProjectDirectories{iDir}(end),filesep)
            cellstrProjectDirectories{iDir} = strcat(cellstrProjectDirectories{iDir},filesep);
        end
    end

    % do npc
    cellstrProjectDirectories = cellfun(@npc,cellstrProjectDirectories,'UniformOutput',false);
    
    % we can get the iBRAIN plate directory listing, usually the fastest
    cellstrPlatedirs = cellfun(@getPlateDirectoriesFromiBRAINDB,cellstrProjectDirectories,'UniformOutput',false);

    % look up plate numbers for each plate directory in search path
    cellAvailablePlateNames = cat(1,cellstrPlatedirs{:});
    matAvailablePlateNumbers = cellfun(@filterplatedata,cellAvailablePlateNames);

    % remove non-parseble directory listings
    cellAvailablePlateNames(isnan(matAvailablePlateNumbers)) = [];
    matAvailablePlateNumbers(isnan(matAvailablePlateNumbers)) = [];
    
    
    %%%%%%%%%
    % let's see what iBRAIN has for info on the requested gene id or
    % symbol.
    
    % look up either GeneId or GeneSymbol
    [matTargetPlateNumbers, ~, ~, matTargetWellRow, matTargetWellCol] = lookupgenelocation(GeneInput,OligoInput);

    % ok, let's get a list of unique wells, just to be sure we parse them
    % all...
    matUniquePositions = unique([matTargetPlateNumbers, matTargetWellRow, matTargetWellCol],'rows');
    
    % internal check for correctness, and to get oligo numbers and gene
    % symbols and gene ids conclusively.
    cellGeneSymbols = cell(size(matUniquePositions,1),1);
    matOligoNumbers = NaN(size(matUniquePositions,1),1);
    matGeneIDs = NaN(size(matUniquePositions,1),1);
    for i = 1:size(matUniquePositions,1)
        [cellGeneSymbols{i}, matOligoNumbers(i), matGeneIDs(i)] = lookupwellcontent(matUniquePositions(i,1), matUniquePositions(i,2), matUniquePositions(i,3));
    end
    

    %%%%%%%%%
    % Now we need to get a full list of the intersection between the two,
    % search list and target list. Work on making sure plates with multiple
    % hit-wells get output once for each well entry.
    
    % find overlap between available list of plates, and the list of plates
    % containing our target genes
    [matPlateHasTargetGeneAtleastOnce, matSecondIX] = ismember(matAvailablePlateNumbers,matUniquePositions(:,1));
    
    % init output
    cellTiffFiles = {};
    cellPlatePaths = {};
    matOligoNumber = [];
    matPlateNumber = [];
    matWellRow = [];
    matWellCol = [];
    
    % loop over each plate, and add (multiple) entries to list if present.
    iCounter = 0;
    for iX = find(matPlateHasTargetGeneAtleastOnce)'
        iCounter = iCounter + 1;

        % look up tif/png files corresponding to the selected well..
        strTargetPath = cellAvailablePlateNames{iX};
        strTargetPath = strrep(strTargetPath,'\BATCH','\TIFF');
        strTargetWell = sprintf('%s%02d',char(64+matUniquePositions(matSecondIX(iX),2)),matUniquePositions(matSecondIX(iX),3));
        cellTiffFiles(iCounter) = {findfilewithregexpi(strTargetPath, ['^.*_', strTargetWell,'_.*\.[png|tif]'])};
        
        % fill in other details...
        cellPlatePaths(iCounter) = cellAvailablePlateNames(iX);
        matOligoNumber(iCounter) = matOligoNumbers(matSecondIX(iX),1);
        matPlateNumber(iCounter) = matUniquePositions(matSecondIX(iX),1);
        matWellRow(iCounter) = matUniquePositions(matSecondIX(iX),2);
        matWellCol(iCounter) = matUniquePositions(matSecondIX(iX),3);
    end
    
    
    
    
    
end

function [PlateNumber, WellName, OligoNumber, RowNumber, ColumnNumber, PlateName] = lookupgenelocation(GeneInput,OligoInput)
    if isempty(OligoInput)
        if ischar(GeneInput)
            % if text, look up gene SYMBOL position
            [PlateName, PlateNumber, WellName, RowNumber, ColumnNumber, ~, OligoNumber] = lookupgenesymbolposition(GeneInput);
        elseif isnumeric(GeneInput)
            % if numeric, look up gene ID position
            [PlateName, PlateNumber, WellName, RowNumber, ColumnNumber, ~, OligoNumber] = lookupgeneidposition(GeneInput);
        end    
    else
        if ischar(GeneInput)
            % if text, look up gene SYMBOL position
            [PlateName, PlateNumber, WellName, RowNumber, ColumnNumber, ~, OligoNumber] = lookupgenesymbolposition(GeneInput,OligoInput);
        elseif isnumeric(GeneInput)
            % if numeric, look up gene ID position
            [PlateName, PlateNumber, WellName, RowNumber, ColumnNumber, ~, OligoNumber] = lookupgeneidposition(GeneInput,OligoInput);
       end    
    end
end