function [GeneID, GeneSymbol] = lookupgenesymbolid(strGeneSymbol)

% Help for lookupgenesymbolid()
% BS - requires MasterData.mat
% usage:
% 
% [GeneID] = lookupgenesymbolid(strGeneSymbol)
%
% If no oligonumber is given it will return all found positions matching
% the given strGeneSymbol.
% Oligo can either be the letters a, b, or c, or it can be the number 1, 2,
% or 3.

    GeneSymbol = {};
    GeneID = 0;
    
    global genedata
    persistent cellstrLookUpTableGeneSymbol cellstrLookUpTableGeneSymbol2 cellstrLookUpTableGeneSymbol3 matLookUpTableGeneID

    if nargin == 0 || isempty(strGeneSymbol)
        return
%         strGeneSymbol = 'CD98'
    elseif not(ischar(strGeneSymbol))        
        warning('lookupgenesymbolid requires a genesymbol as text input, but was passed ''%s''. Type ''help lookupgenesymbolid'' for more info',char(strGeneSymbol))
        return
    else
        strGeneSymbol = strtrim(strGeneSymbol);
    end  
    
    if isempty(genedata)
        disp(sprintf('lookupgenesymbolid: loading gene data from ''%s''',which('genedata.mat')))    
        load('genedata.mat');
    end

    if isempty(cellstrLookUpTableGeneSymbol) ||  isempty(matLookUpTableGeneID)
        cellstrLookUpTableGeneSymbol = cell(size(genedata,1),1);
        cellstrLookUpTableGeneSymbol2 = cell(size(genedata,1),1);
        cellstrLookUpTableGeneSymbol3 = cell(size(genedata,1),1);
        matLookUpTableOligoNumber = zeros(size(genedata,1),1);      
        for i = 1:size(genedata,1)
            cellstrLookUpTableGeneSymbol{i,1} = genedata{i,2}; % GENE SYMBOL LOOKUP (CHAR)
            cellstrLookUpTableGeneSymbol2{i,1} = genedata{i,3}; % GENE ALIASES LOOKUP (CHAR)            
            cellstrLookUpTableGeneSymbol3{i,1} = genedata{i,4}; % FULL GENE NAME (CHAR)                        
        end
        for i = 1:size(genedata,1)
            if not(isempty(genedata{i,1}))
                matLookUpTableGeneID(i,1) = double(genedata{i,1}); % OLIGO NUMBER LOOKUP (DOUBLE)
            end
        end        
    end

    
    % return all oligos matching the query
    intHitIndex = find(strcmpi(cellstrLookUpTableGeneSymbol, char(strGeneSymbol)));

    if isempty(intHitIndex)
        disp(sprintf('lookupgenesymbolid: couldnt find exact match for ''%s'', looking in aliases',strGeneSymbol))
        intPossibleHitIndex = find(~cellfun('isempty',strfind(cellstrLookUpTableGeneSymbol2,strGeneSymbol)));
        for i  = 1:length(intPossibleHitIndex)
            cellstrAliases = strread(cellstrLookUpTableGeneSymbol2{intPossibleHitIndex(i)},'%s','delimiter','|');
            if find(strcmpi(cellstrAliases,char(strGeneSymbol)))
                intHitIndex = [intHitIndex, intPossibleHitIndex(i)];
            end
        end
    end
    
    if isempty(intHitIndex)
        disp(sprintf('lookupgenesymbolid: couldnt find exact match for ''%s'' in aliases, looking in full names',strGeneSymbol))
        intHitIndex = find(~cellfun('isempty',strfind(cellstrLookUpTableGeneSymbol3,strGeneSymbol)));
%         for i  = 1:length(intPossibleHitIndex)
%             cellstrAliases = strread(cellstrLookUpTableGeneSymbol2{intPossibleHitIndex(i)},'%s','delimiter','|');
%             if find(strcmpi(cellstrAliases,char(strGeneSymbol)))
%                 intHitIndex = [intHitIndex, intPossibleHitIndex(i)];
%             end
%         end
    end
    
    
    
    
%   master data layout is as follows
%   MP-NAME | MP-NUMBER | MP-CONTENT | MP-DESCRIPTION | WELL | ROW | COLUMN | GENE-SYMBOL | OLIGO-NUMBER | GENE-ID | GENBANK-ID | ACCESSION-NUMBER-HITS | SEQUENCE | DG-VERSION-NUMBER
%    intHitIndex = find(matLookUpTableOligoNumber(:,1) == intMPNUMBER & matLookUpTableOligoNumber(:,2) == intROW & matLookUpTableOligoNumber(:,3) == intCOLUMN);

    %intHitIndex
    if length(intHitIndex) == 1
        GeneID = matLookUpTableGeneID(intHitIndex,1);
        GeneSymbol = cellstrLookUpTableGeneSymbol{intHitIndex,1};
    elseif length(intHitIndex) > 1
        for i = 1:length(intHitIndex)
            if isnumeric(matLookUpTableGeneID(intHitIndex(i),1))
                GeneID(i,1) = matLookUpTableGeneID(intHitIndex(i),1);
                GeneSymbol{i,1} = cellstrLookUpTableGeneSymbol{intHitIndex(i),1};                
            else
                GeneID(i,1) = 0;
                GeneSymbol{i,1} = cellstrLookUpTableGeneSymbol{intHitIndex(i),1};                
            end            
        end
    end

%     disp(sprintf('%s = %d',strGeneSymbol,GeneID))
end