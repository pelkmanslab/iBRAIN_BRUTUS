% load('\\Nas-biol-imsb-1\share-2-$\Data\Code\Matlab\General\DG_LOOKUP_GENEDATA\MasterData.mat')

strFilename = 'C:\Documents and Settings\imsb\Desktop\lilli_plate_randomization\080228_FlexiQiagen_adhesome_Lilli.xls';
[num, txt, raw] = xlsread(strFilename);


raw(1,:)

cellstrNewEntries = cell(size(raw,1)-1,13);

for iRow = 2:size(raw,1)
    
    
    %%% PLATE NAME, NUMBER, OLIGO-LETTER
    if strcmpi(raw{iRow,2},'P01')
        strPlateName = 'MP074';
        intPlateNumber = 74;
        strOligoNumber = 'A';
    elseif strcmpi(raw{iRow,2},'P02')
        strPlateName = 'MP075';
        intPlateNumber = 75;        
        strOligoNumber = 'B';
    elseif strcmpi(raw{iRow,2},'P03')
        strPlateName = 'MP076';
        intPlateNumber = 76;        
        strOligoNumber = 'C';
    elseif strcmpi(raw{iRow,2},'P04')
        strPlateName = 'MP077';
        intPlateNumber = 77;        
        strOligoNumber = 'D';
    else
        error('unknown plate description!!!')
    end        
        
    %%% PLATE DESCRIPTION
    strPlateDescription = ['Adhesome_',raw{iRow,2}];

    if ~isnan(double(raw{iRow,4})-64)%row number
        intRowNumber = double(raw{iRow,4})-64;
    else
        error('unknown row number!!!')        
    end

    if isnumeric(raw{iRow,5})%column number
        intColumnNumber = raw{iRow,5};
    else
        error('unknown column number!!!')        
    end
    
    %col
    strWellName = sprintf('%s%d',raw{iRow,4},intColumnNumber);
    
    if isnan(raw{iRow,6})%gene-id
        intGeneID = 'Blank';
        strGeneSymbol = raw{iRow,12};
        strMulipleAccession = 'Blank';        
    else
        intGeneID = raw{iRow,6};
        strGeneSymbol = raw{iRow,7};
        strMulipleAccession = raw{iRow,9};
    end
    
    strAccession = 'Blank';

    if isnan(raw{iRow,10})
        strSequence = 'Blank';        
    else
        strSequence = raw{iRow,10};
    end
    strDGVersion = 'Blank';
   
    
    %%% CREATE MASTERDATA STRUCTURE CONTAINING NEW ENTRIES TO APPEND TO OLD
    %%% MASTERDATA.MAT/cellMasterDataList
    
    % 'PLATE NAME'	'PLATE #'	'PLATE CONTENT' 'PLATE DESCRIPTION'		'WELL NAME'	'ROW'	'COL'	'GENE-SYMBOL'	'OLIGO'	'GENE-ID'	'ACCESSION'	'ACCESSION'	'SEQUENCE'	'DG-VERSION'
    cellstrNewEntries{iRow-1,1} = strPlateName;
    cellstrNewEntries{iRow-1,2} = intPlateNumber;
    cellstrNewEntries{iRow-1,3} = strPlateDescription;
    cellstrNewEntries{iRow-1,4} = 'Blank';
    cellstrNewEntries{iRow-1,5} = strWellName; 
    cellstrNewEntries{iRow-1,6} = intRowNumber;
    cellstrNewEntries{iRow-1,7} = intColumnNumber;
    cellstrNewEntries{iRow-1,8} = strGeneSymbol;
    cellstrNewEntries{iRow-1,9} = strOligoNumber;
    cellstrNewEntries{iRow-1,10} = intGeneID;
    cellstrNewEntries{iRow-1,11} = strAccession;
    cellstrNewEntries{iRow-1,12} = strMulipleAccession;
    cellstrNewEntries{iRow-1,13} = strSequence;
    cellstrNewEntries{iRow-1,14} = strDGVersion;
    
end


cellMasterDataList = [cellMasterDataList;cellstrNewEntries]

%save('\\Nas-biol-imsb-1\share-2-$\Data\Code\Matlab\General\DG_LOOKUP_GENEDATA\MasterData.mat','cellMasterDataList')
