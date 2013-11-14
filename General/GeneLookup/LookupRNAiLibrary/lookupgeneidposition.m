function [PlateName, PlateNumber, WellName, RowNumber, ColumnNumber, GeneSymbol, OligoNumber] = lookupgeneidposition(intGeneId, Oligo)

% Help for lookupgeneidposition()
% BS - requires MasterData.mat
% usage:
% 
% [PlateName, PlateNumber, WellName, RowNumber, ColumnNumber, GeneSymbol] = lookupgeneidposition(intGeneId, Oligo)
%
% If no oligonumber is given it will return all found positions matching
% the given intGeneID.
% Oligo can either be the letters a, b, or c, or it can be the number 1, 2,
% or 3.

    global cellMasterDataList 
    persistent matLookUpTableGeneID matLookUpTableOligoNumber

    if nargin == 0 || not(isnumeric(intGeneId))
%         intGeneId = 1
        error('lookupgeneposition requires a gene ID as numerical input. Type ''help lookupgeneidposition'' for more info')
    end  
    
    if ~exist('cellMasterDataList','var') || isempty(cellMasterDataList)
        disp(sprintf('lookupgenedata: loading master data from ''%s''',which('MasterData.mat')))    
        load('MasterData.mat');
    end

    if ~exist('matLookUpTableGeneID','var') || ~exist('matLookUpTableOligoNumber','var') || isempty(matLookUpTableGeneID) ||  isempty(matLookUpTableOligoNumber)
        matLookUpTableGeneID = zeros(size(cellMasterDataList,1),1);
        matLookUpTableOligoNumber = zeros(size(cellMasterDataList,1),1);      
        for i = 1:size(cellMasterDataList,1)
%             cellstrLookUpTable{i,1} = cellMasterDataList{i,8}; % GENE SYMBOL LOOKUP (CHAR)
            if isnumeric(cellMasterDataList{i,10}) && not(isempty(cellMasterDataList{i,10}))
                matLookUpTableGeneID(i,1) = double(cellMasterDataList{i,10}); % GENE ID LOOKUP (DOUBLE)            
            else
                matLookUpTableGeneID(i,1) = NaN;
            end
        end

        for i = 1:size(cellMasterDataList,1)
            if not(isempty(cellMasterDataList{i,9}))
                matLookUpTableOligoNumber(i,1) = double(cellMasterDataList{i,9})-64; % OLIGO NUMBER LOOKUP (DOUBLE)
            end
        end        
    end

    matRows = cellstr(regexp(char(65:80),'\w','match'));
    matCols = regexp(sprintf('%.2d',1:24),'\d\d','match');    
    
    % if oligo number or letter is passed, include it in the test,
    % otherwise return all oligos matching the query
    if nargin == 2
        if ischar(Oligo)
            Oligo = double(upper(Oligo))-64;
        end        
        intHitIndex = find(matLookUpTableGeneID(:,1) == intGeneId & matLookUpTableOligoNumber(:,1) == Oligo);
    else
        intHitIndex = find(matLookUpTableGeneID(:,1) == intGeneId);
    end

%   master data layout is as follows
%   MP-NAME | MP-NUMBER | MP-CONTENT | MP-DESCRIPTION | WELL | ROW | COLUMN | GENE-SYMBOL | OLIGO-NUMBER | GENE-ID | GENBANK-ID | ACCESSION-NUMBER-HITS | SEQUENCE | DG-VERSION-NUMBER
%    intHitIndex = find(matLookUpTable(:,1) == intMPNUMBER & matLookUpTable(:,2) == intROW & matLookUpTable(:,3) == intCOLUMN);

    PlateName = '';
    PlateNumber = 0;
    WellName = '';
    RowNumber = 0;
    ColumnNumber = 0;
    GeneSymbol = '';
    OligoNumber = 0;

    %intHitIndex
    if length(intHitIndex) == 1
        PlateName = cellMasterDataList{intHitIndex,1};
        PlateNumber = cellMasterDataList{intHitIndex,2};
        RowNumber = cellMasterDataList{intHitIndex,6};
        ColumnNumber = cellMasterDataList{intHitIndex,7};
%         WellName = cellMasterDataList{intHitIndex,5};
        WellName = [matRows{RowNumber},matCols{ColumnNumber}];		        
        GeneSymbol = cellMasterDataList{intHitIndex,8};
        OligoNumber = matLookUpTableOligoNumber(intHitIndex,1);
    elseif length(intHitIndex) > 1
        for i = 1:length(intHitIndex)
            PlateName{i,1} = char(cellMasterDataList{intHitIndex(i),1});
            PlateNumber(i,1) = cellMasterDataList{intHitIndex(i),2};
            RowNumber(i,1) = cellMasterDataList{intHitIndex(i),6};
            ColumnNumber(i,1) = cellMasterDataList{intHitIndex(i),7};
%             WellName{i,1} = char(cellMasterDataList{intHitIndex(i),5});
            WellName{i,1} = [matRows{RowNumber(i,1)},matCols{ColumnNumber(i,1)}];
            GeneSymbol{i,1} = cellMasterDataList{intHitIndex(i),8};
            OligoNumber(i,1) = matLookUpTableOligoNumber(intHitIndex(i),1);
        end
    end

end