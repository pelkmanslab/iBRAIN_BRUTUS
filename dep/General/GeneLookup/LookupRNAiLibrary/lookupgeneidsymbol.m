function [GeneSymbol] = lookupgeneidsymbol(intGeneID)

% Help for lookupgeneidsymbol()
% BS - requires MasterData.mat
% usage:
% 
% [GeneID] = lookupgeneidsymbol(intGeneID)
%
% If no oligonumber is given it will return all found positions matching
% the given intGeneID.
% Oligo can either be the letters a, b, or c, or it can be the number 1, 2,
% or 3.

    if numel(intGeneID)>1
        GeneSymbol = arrayfun(@lookupgeneidsymbol,intGeneID,'UniformOutput',false);
        return
    end

    GeneSymbol = {};

    global genedata
    persistent cellstrLookUpTableGeneSymbol matLookUpTableGeneID

    if nargin == 0 || isempty(intGeneID)
%          return
        intGeneID = 985
    elseif not(isnumeric(intGeneID))
        warning('lookupgeneidsymbol requires a GeneID as numerical input, but was passed ''%s''. Type ''help lookupgeneidsymbol'' for more info',intGeneID)
        return
    end
    
    if isempty(genedata)
        disp(sprintf('lookupgeneidsymbol: loading gene data from ''%s''',which('genedata.mat')))    
        load('genedata.mat');
    end

    if isempty(cellstrLookUpTableGeneSymbol) ||  isempty(matLookUpTableGeneID)
        cellstrLookUpTableGeneSymbol = cell(size(genedata,1),1);
        cellstrLookUpTableGeneSymbol2 = cell(size(genedata,1),1);
        cellstrLookUpTableGeneSymbol3 = cell(size(genedata,1),1);
        matLookUpTableOligoNumber = zeros(size(genedata,1),1);
        for i = 1:size(genedata,1)
            cellstrLookUpTableGeneSymbol{i,1} = genedata{i,2}; % GENE SYMBOL LOOKUP (CHAR)
        end
        for i = 1:size(genedata,1)
            if not(isempty(genedata{i,1}))
                matLookUpTableGeneID(i,1) = double(genedata{i,1}); % GENE ID
            end
        end        
    end

    
    % return all oligos matching the query
    
    intHitIndex = find(matLookUpTableGeneID==intGeneID);

    if isempty(intHitIndex)
        disp(sprintf('lookupgeneidsymbol: couldnt find exact match for ''%d''',intGeneID))
    end
    
    if length(intHitIndex) == 1
        GeneSymbol = cellstrLookUpTableGeneSymbol{intHitIndex,1};
    elseif length(intHitIndex) > 1
        for i = 1:length(intHitIndex)
            if isnumeric(matLookUpTableGeneID(intHitIndex(i),1))
                GeneSymbol{i,1} = cellstrLookUpTableGeneSymbol{intHitIndex(i),1};                
            else
                GeneSymbol{i,1} = cellstrLookUpTableGeneSymbol{intHitIndex(i),1};                
            end            
        end
    end

end