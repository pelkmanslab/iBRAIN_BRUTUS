function [PlateName, PlateNumber, WellName, RowNumber, ColumnNumber, GeneID, OligoNumber] = lookupgenesymbolposition(strGeneSymbol, Oligo)

% Help for lookupgenesymbolposition()
% BS - requires MasterData.mat
% usage:
% 
% [PlateName, PlateNumber, WellName, RowNumber, ColumnNumber, GeneID] = lookupgenesymbolposition(strGeneSymbol, Oligo)
%
% If no oligonumber is given it will return all found positions matching
% the given strGeneSymbol.
% Oligo can either be the letters a, b, or c, or it can be the number 1, 2,
% or 3.

    global cellMasterDataList 
    persistent cellstrLookUpTableGeneSymbol matLookUpTableOligoNumber

    if nargin == 0 || not(ischar(strGeneSymbol))
% 		strGeneSymbol='ABCA1'
        error('lookupgeneposition requires a genesymbol as text input. Type ''help lookupgenesymbolposition'' for more info')
    end  
    
    if isempty(cellMasterDataList)
        disp(sprintf('lookupgenedata: loading master data from ''%s''',which('MasterData.mat')))    
        h = msgbox('Please wait, loading gene data...','Loading gene data','help');
        load('MasterData.mat');
        close(h)
    end

    if isempty(cellstrLookUpTableGeneSymbol) ||  isempty(matLookUpTableOligoNumber)
        cellstrLookUpTableGeneSymbol = cell(size(cellMasterDataList,1),1);
        matLookUpTableOligoNumber = zeros(size(cellMasterDataList,1),1);      
        for i = 1:size(cellMasterDataList,1)
            cellstrLookUpTableGeneSymbol{i,1} = cellMasterDataList{i,8}; % GENE SYMBOL LOOKUP (CHAR)
            
        end
        for i = 1:size(cellMasterDataList,1)
            if not(isempty(cellMasterDataList{i,9}))
                matLookUpTableOligoNumber(i,1) = double(cellMasterDataList{i,9})-64; % OLIGO NUMBER LOOKUP (DOUBLE)
            end
        end        
    end

    
    % if oligo number or letter is passed, include it in the test,
    % otherwise return all oligos matching the query
    if nargin == 2
        if ischar(Oligo)
            Oligo = double(upper(Oligo))-64;
        end        
        intHitIndex = find(strcmpi(cellstrLookUpTableGeneSymbol, char(strGeneSymbol)) & matLookUpTableOligoNumber(:,1) == Oligo);
    else
        intHitIndex = find(strcmpi(cellstrLookUpTableGeneSymbol, char(strGeneSymbol)));
    end

%   master data layout is as follows
%   MP-NAME | MP-NUMBER | MP-CONTENT | MP-DESCRIPTION | WELL | ROW | COLUMN | GENE-SYMBOL | OLIGO-NUMBER | GENE-ID | GENBANK-ID | ACCESSION-NUMBER-HITS | SEQUENCE | DG-VERSION-NUMBER
%    intHitIndex = find(matLookUpTableOligoNumber(:,1) == intMPNUMBER & matLookUpTableOligoNumber(:,2) == intROW & matLookUpTableOligoNumber(:,3) == intCOLUMN);

    PlateName = '';
    PlateNumber = 0;
    WellName = '';
    RowNumber = 0;
    ColumnNumber = 0;
    GeneID = 0;
    OligoNumber = 0;
    
    %intHitIndex
    if length(intHitIndex) == 1
        PlateName = cellMasterDataList{intHitIndex,1};
        PlateNumber = cellMasterDataList{intHitIndex,2};
        WellName = cellMasterDataList{intHitIndex,5};
        RowNumber = cellMasterDataList{intHitIndex,6};
        ColumnNumber = cellMasterDataList{intHitIndex,7};
        GeneID = cellMasterDataList{intHitIndex,10};
        OligoNumber = matLookUpTableOligoNumber(intHitIndex,1);
    elseif length(intHitIndex) > 1
        for i = 1:length(intHitIndex)
            PlateName{i,1} = char(cellMasterDataList{intHitIndex(i),1});
            PlateNumber(i,1) = cellMasterDataList{intHitIndex(i),2};
            WellName{i,1} = char(cellMasterDataList{intHitIndex(i),5});
            RowNumber(i,1) = cellMasterDataList{intHitIndex(i),6};
            ColumnNumber(i,1) = cellMasterDataList{intHitIndex(i),7};
            if not(isempty(cellMasterDataList{intHitIndex(i),10})) && isnumeric(cellMasterDataList{intHitIndex(i),10})
                GeneID(i,1) = cellMasterDataList{intHitIndex(i),10};
            else
                GeneID(i,1) = 0;
            end 
            OligoNumber(i,1) = matLookUpTableOligoNumber(intHitIndex(i),1);
        end
	end

	%%% ADD '0' IF WELLNAME IS LIKE G3
	if ischar(WellName) && length(WellName) == 2
		WellName = strcat(WellName(1),'0',WellName(2));
	elseif iscell(WellName)
		for i = 1:length(WellName)
			if length(WellName{i})==2
				WellName{i} = strcat(WellName{i}(1),'0',WellName{i}(2));
			end
		end
	end
end