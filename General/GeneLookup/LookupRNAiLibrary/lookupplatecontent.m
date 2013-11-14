function [GeneSymbols, OligoNumbers, GeneIDs] = lookupplatecontent(intPlateNumber)

% help for formatplate()
% BS - requires lookupplatecontent.m
% 
% usage:
% [GeneSymbols, OligoNumbers, GeneIDs] = lookupplatecontent(intPlateNumber)

    if nargin == 0 || not(isnumeric(intPlateNumber))
%         error('lookupplatecontent requires a masterplate number as input. Type ''help lookupplatecontent'' for more info')
        intPlateNumber = 82
    end

    % process array if requested
    if numel(intPlateNumber)>1
        iPlates = numel(intPlateNumber);
        GeneSymbols = cell(16,24,iPlates);
        OligoNumbers = zeros(16,24,iPlates);
        GeneIDs = zeros(16,24,iPlates);    
        for iPlate = 1:iPlates
            [GeneSymbols(:,:,iPlate), OligoNumbers(:,:,iPlate), GeneIDs(:,:,iPlate)] = lookupplatecontent(intPlateNumber(iPlate));
        end
        return
    end
    
    GeneSymbols = cell(16,24);
    OligoNumbers = zeros(16,24);
    GeneIDs = zeros(16,24);    
   
    % let's implement simple caching on PCs...
    strCachePath = '';
    strTargetFile = '';
    if ispc
        strCachePath = fullfile(tempdir,'lookupplatecontent_caching', filesep);

        % create it if the cache directory is not present
        if ~fileattrib(strCachePath)
            [boolMakeDirSucces] = mkdir(strCachePath);
            if ~boolMakeDirSucces
                fprintf('%s: not allowed to create caching directory ''%s''\n',mfilename,strCachePath) 
            else
                fprintf('%s: created caching directory ''%s''.\n',mfilename,strCachePath) 
            end
        else
            % if cache directory exists, see if we can load the file and
            % finish. right now i'm not checking date changed of file
            % versus masterdata. should be done :)
            strTargetFile = fullfile(strCachePath,sprintf('%d.mat',intPlateNumber));
            
            % also check if cachefile is newer than masterdata.mat
            if getDatenumLastModified(which('MASTERDATA.mat')) > getDatenumLastModified(strTargetFile)
                % if cache file is outdated compared to the functions that create it,
                % we should probably delete it!
                fprintf('%s: Masterdata is newer. Removing outdated cache file: ''%s''.\n',mfilename,strTargetFile)
                delete(strTargetFile)
            end
            
            % if it still exists, load it and we're done
            if fileattrib(strTargetFile)
                load(strTargetFile)
                return
            end
        end
    end
    
    % if caching worked, we returned. so we only get here if caching did
    % not work.
    
    
    for row = 1:16
        for col = 1:24
            [strgenename,intoligonum,intgeneid] = lookupwellcontent(intPlateNumber,row, col);
            GeneSymbols{row, col} = strgenename;
            if not(isempty(intoligonum))
                OligoNumbers(row, col) = intoligonum;        
            end
            if not(isempty(intgeneid)) && isnumeric(intgeneid)
                GeneIDs(row, col) = intgeneid;
            end            
        end
    end
    
    % if strTargetFile is not empty, we should store the results, so we can
    % load them next time...
    if ~isempty(strTargetFile)
        save(strTargetFile,'GeneSymbols', 'OligoNumbers', 'GeneIDs')
        fprintf('%s: stored cache file ''%s''\n',mfilename,strTargetFile)
    end