function [GeneSymbol, OligoNumber, GeneID] = lookupwellcontent(intPlateNumber, intRowNumber, intColumnNumber)

% Help for lookupgenedata()
% BS - requires MasterData.mat
% usage:
% 
% [GeneSymbol, OligoNumber, GeneID] = lookupwellcontent(intPlateNumber, intRowNumber, intColumnNumber)
% all input should be numberical.

    global cellMasterDataList
    persistent matLookUpTable matAllPlateAndWellIx

    if nargin == 0 || not(isnumeric(intPlateNumber)) || not(isnumeric(intRowNumber)) || not(isnumeric(intColumnNumber))
        error('lookupwellcontent requires mp-number, row and column as numbers as input. Type ''help lookupwellcontent'' for more info')
    end
    
    if isempty(cellMasterDataList)
        disp(sprintf('lookupwellcontent: loading master data from ''%s''',which('MasterData.mat')))    
        load('MasterData.mat');
    end

    if isempty(matLookUpTable)
        matLookUpTable = zeros(size(cellMasterDataList,1),3);
        for i = 1:size(cellMasterDataList,1)
            matLookUpTable(i,1) = cellMasterDataList{i,2};
            matLookUpTable(i,2) = cellMasterDataList{i,6};
            matLookUpTable(i,3) = cellMasterDataList{i,7};
        end
        matAllPlateAndWellIx = sub2ind2(max(matLookUpTable),matLookUpTable);
    end
    
    GeneSymbol = '';
    OligoNumber = 0;
    GeneID = [];
    
%   master data layout is as follows
%   MP-NAME | MP-NUMBER | MP-CONTENT | MP-DESCRIPTION | WELL | ROW | COLUMN | GENE-SYMBOL | OLIGO-NUMBER | GENE-ID | GENBANK-ID | ACCESSION-NUMBER-HITS | SEQUENCE | DG-VERSION-NUMBER
%   ------  | --------- | FREE       | FREE           | ---- | --- | ------ | ----------- | ------------ | ------- | FREE       | FREE                  | FREE     | FREE
% (bs: columns indicated by --- are crucial for ibrain and should be filled
% in)

    matTargetPlateAndWellIX = sub2ind2(max(matLookUpTable),[intPlateNumber,intRowNumber,intColumnNumber]);
    intHitIndex = find(matAllPlateAndWellIx==matTargetPlateAndWellIX);
    %intHitIndex = find(matLookUpTable(:,1) == intPlateNumber & matLookUpTable(:,2) == intRowNumber & matLookUpTable(:,3) == intColumnNumber);
    
    if not(isempty(intHitIndex))
        GeneSymbol = char(cellMasterDataList{intHitIndex,8});
        OligoNumber = double(cellMasterDataList{intHitIndex,9})-64;
        GeneID = cellMasterDataList{intHitIndex,10};
    end
end