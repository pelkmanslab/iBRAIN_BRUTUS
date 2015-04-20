function [PlateName, PlateNumber, WellName, RowNumber, ColumnNumber] = lookupgeneposition(strGeneSymbol, Oligo)

% Help for lookupgeneposition()
% BS - requires MasterData.mat
% usage:
% 
% [PlateName, PlateNumber, WellName, RowNumber, ColumnNumber] = lookupgeneposition(strGeneSymbol, Oligo)
%
% If no oligonumber is given it will return all found positions matching
% the given strGeneSymbol.
% Oligo can either be the letters a, b, or c, or it can be the number 1, 2,
% or 3.

    global cellMasterDataList 
    persistent cellstrLookUpTable matLookUpTable

    if nargin == 0 || not(ischar(strGeneSymbol))
        error('lookupgeneposition requires a genesymbol as text input. Type ''help lookupgeneposition'' for more info')
    end  
    
    if isempty(cellMasterDataList)
        disp(sprintf('lookupgenedata: loading master data from ''%s''',which('MasterData.mat')))    
        load('MasterData.mat');
    end

    if isempty(cellstrLookUpTable) ||  isempty(matLookUpTable)
        cellstrLookUpTable = cell(size(cellMasterDataList,1),1);
        matLookUpTable = zeros(size(cellMasterDataList,1),1);      
        for i = 1:size(cellMasterDataList,1)
            cellstrLookUpTable{i,1} = cellMasterDataList{i,8}; % GENE SYMBOL LOOKUP (CHAR)
            
        end
        for i = 1:size(cellMasterDataList,1)
            if not(isempty(cellMasterDataList{i,9}))
                matLookUpTable(i,1) = double(cellMasterDataList{i,9})-64; % OLIGO NUMBER LOOKUP (DOUBLE)
            end
        end        
    end

    
    % if oligo number or letter is passed, include it in the test,
    % otherwise return all oligos matching the query
    if nargin == 2
        if ischar(Oligo)
            Oligo = double(upper(Oligo))-64;
        end        
        intHitIndex = find(strcmpi(cellstrLookUpTable, char(strGeneSymbol)) & matLookUpTable(:,1) == Oligo);
    else
        intHitIndex = find(strcmpi(cellstrLookUpTable, char(strGeneSymbol)));
    end

%   master data layout is as follows
%   MP-NAME | MP-NUMBER | MP-CONTENT | MP-DESCRIPTION | WELL | ROW | COLUMN | GENE-SYMBOL | OLIGO-NUMBER | GENE-ID | GENBANK-ID | ACCESSION-NUMBER-HITS | SEQUENCE | DG-VERSION-NUMBER
%    intHitIndex = find(matLookUpTable(:,1) == intMPNUMBER & matLookUpTable(:,2) == intROW & matLookUpTable(:,3) == intCOLUMN);

    PlateName = '';
    PlateNumber = 0;
    WellName = '';
    RowNumber = 0;
    ColumnNumber = 0;

    %intHitIndex
    if length(intHitIndex) == 1
        PlateName = cellMasterDataList{intHitIndex,1};
        PlateNumber = cellMasterDataList{intHitIndex,2};
        WellName = cellMasterDataList{intHitIndex,5};
        RowNumber = cellMasterDataList{intHitIndex,6};
        ColumnNumber = cellMasterDataList{intHitIndex,7};
    elseif length(intHitIndex) > 1
        for i = 1:length(intHitIndex)
            PlateName{i,1} = char(cellMasterDataList{intHitIndex(i),1});
            PlateNumber(i,1) = cellMasterDataList{intHitIndex(i),2};
            WellName{i,1} = char(cellMasterDataList{intHitIndex(i),5});
            RowNumber(i,1) = cellMasterDataList{intHitIndex(i),6};
            ColumnNumber(i,1) = cellMasterDataList{intHitIndex(i),7};
        end
    end

end