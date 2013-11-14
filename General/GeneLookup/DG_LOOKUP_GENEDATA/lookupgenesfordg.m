clear all

strFileNameMasterPlateLayout = 'C:\Documents and Settings\imsb\Desktop\DG_LOOKUP_GENEDATA\070223__Dilution_plate_names.xls';
strPlateName = '070407_VSV_DG_batch3_CP042-1ac';
strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\VSV_DG\';

strFileNameDG_Content_AB = 'C:\Documents and Settings\imsb\Desktop\DG_LOOKUP_GENEDATA\QIAGEN Druggable Genome v2 0_complete annotation_1027586.xls';
strFileNameDG_Content_C = 'C:\Documents and Settings\imsb\Desktop\DG_LOOKUP_GENEDATA\QIAGEN DG3 384 C set ETH custom.xls';

[num, txt1, raw] = xlsread(strFileNameMasterPlateLayout);
[num, txt2, raw] = xlsread(strFileNameDG_Content_AB);
[num, txt3, raw] = xlsread(strFileNameDG_Content_C);

% LOOKUP CORRECT COLUMNS FROM MASTERPLATE LAYOUT EXCEL FILE
[intCellPlateColumn] = lookuptxtcolumn(txt1, 'Cell Plate');
[intPlateSetColumn] = lookuptxtcolumn(txt1, '384-well plate name');
intPlateContentColumn = intPlateSetColumn + 1;

% LOOKUP CORRECT COLUMNS FROM OLIGO SET A+B EXCEL FILE
[intWellColumn_AB, cellstrWellList_AB] = lookuptxtcolumn(txt2, 'Well'); % WELL
[intPlateColumn_AB, cellstrPlateList_AB] = lookuptxtcolumn(txt2, 'Plate name'); % PLATE CONTENT
[intSymbolColumn_AB] = lookuptxtcolumn(txt2, 'Symbol'); % SYMBOL
[intAccessionColumn_AB] = lookuptxtcolumn(txt2, 'GenbankID'); % GENBANK ID
[intSequenceColumn_A] = lookuptxtcolumn(txt3, 'seq1'); % SEQUENCE_A
[intSequenceColumn_B] = lookuptxtcolumn(txt3, 'seq2'); % SEQUENCE_B

cellstrPlateDescriptionList_AB = cell(size(cellstrPlateList_AB));
for i = 1:length(cellstrPlateList_AB) % SHORTENING TO THE FIRST 6 CHARACTERS
    x = strfind(cellstrPlateList_AB{i},'_');
    if size(x,2) > 1
        cellstrPlateDescriptionList_AB{i} = cellstrPlateList_AB{i}(x(1,2):end);        
        cellstrPlateList_AB{i} = cellstrPlateList_AB{i}(1:x(1,2)-1);
    end
end
% disp(cellstrPlateDescriptionList_AB)

% LOOKUP CORRECT COLUMNS FROM OLIGO SET C EXCEL FILE
[cellstrWellList_C, cellstrWellList_C] = lookuptxtcolumn(txt3, 'Well'); % WELL
[cellstrPlateList_C, cellstrPlateList_C] = lookuptxtcolumn(txt3, 'Plate (ABCD)'); % PLATE CONTENT
[intSymbolColumn_C] = lookuptxtcolumn(txt3, 'Symbol'); % GENE SYMBOL
[intAccessionColumn_C] = lookuptxtcolumn(txt3, 'Accns Hit'); % ACCESSION HITS
[intSequenceColumn_C] = lookuptxtcolumn(txt3, 'Target Set C'); % SEQUENCE

cellstrPlateDescriptionList_C = cell(size(cellstrPlateList_C));
for i = 1:length(cellstrPlateList_C) % REMOVING EVERYTHING AFTER SECOND '_' IF PRESENT
    x = strfind(cellstrPlateList_C{i},'_');
    if size(x,2) > 1
        cellstrPlateDescriptionList_C{i} = cellstrPlateList_C{i}(x(1,2):end);        
        cellstrPlateList_C{i} = cellstrPlateList_C{i}(1:x(1,2)-1);
    end
end
% disp(cellstrPlateDescriptionList_C)

return

strFolderList = dirc(strRootPath,'de');
strFolderList = strFolderList(:,1);    
cellTextPlateList = cell(size(strFolderList,1),2);
matNumericalPlateList = zeros(size(strFolderList,1),2);

for i = 1:size(strFolderList,1)
    strPlateName = char(strFolderList(i));
    platenumindx = strfind(strPlateName,'_CP')+3:strfind(strPlateName,'-')-1;
    batchnumindx = strfind(strPlateName,'_batch')+6;

    cellTextPlateList{i,1} = strPlateName(platenumindx);
    cellTextPlateList{i,2} = strPlateName(end);
    cellTextPlateList{i,3} = strPlateName(batchnumindx); 
    
    matNumericalPlateList(i,1) = str2double(strPlateName([platenumindx])); % CP NUMBER
    matNumericalPlateList(i,2) = strPlateName(end) - 96; % CP REPLICATE NUMBER
    matNumericalPlateList(i,3) = str2double(strPlateName(batchnumindx)); % BATCH NUMBER
end

% SORT LIST ACCORDING TO PLATE NUMBER
[B, IX] = sort(matNumericalPlateList(:,1));


cellLibraryPlates = {};

for i = 1:size(matNumericalPlateList,1)

    strCPSearchString = sprintf('CP%.3d-',matNumericalPlateList(i,1));
    
    [a, foo] = find(~cellfun('isempty',strfind(cellstr(txt1(:,intCellPlateColumn)), strCPSearchString)));
    if not(isempty(a))
        strPlateContent = txt1(a(1),intPlateContentColumn);
        cellLibraryPlates = regexp(strPlateContent, '\d*\w', 'match');
        
        % LOGICS FOR OLIGO SET A AND B
        if not(strcmp(cellLibraryPlates{1}{1}(end),'C'))
            strMPFileName = sprintf('MP%.3d_DG_V2',matNumericalPlateList(i,1));
            
            % LOOP OVER ALL PLATES
            cellstrGeneSymbol = cell(4,96);
            cellstrGeneAccessionNumber = cell(4,96);
            for plate = 1:size(cellLibraryPlates{1,1},2)
%                 cellstrGeneSymbol{plate} = cell(96,1);
                intLibraryPlateNumber = regexp(cellLibraryPlates{1,1}(plate), '\d*', 'match');
                intLibraryPlateNumber = str2double(intLibraryPlateNumber{1,1});
                %intLibraryPlateLetter = char(regexp(cellLibraryPlates{1}{1}, '\D', 'match'));
                strPlateSearchString = sprintf('DG2_%.2d',intLibraryPlateNumber);                
                y = strcmp(cellstrPlateList_AB, strPlateSearchString); % Lookup matching plates

                disp(sprintf('%s \t %s \t %s \t plate %s',char(strFolderList(i)), strCPSearchString, char(strPlateContent), strPlateSearchString))                
                
                %LOOP OVER ALL WELLS (96 WELL FORMAT)
                wellcounter = 0;
                for row = 65:72 % ASCII A-H
                     for column = 1:12
                         % WELL TO LOOK FOR
                        strWellSearchString = sprintf('%s%d',char(row),column);
                        x = strcmp(cellstrWellList_AB, strWellSearchString); % Lookup matching wells
                        wellcounter = wellcounter + 1;
%                         cellstrGeneSymbol{plate,wellcounter} = char(txt2(x & y,4)); % HARDCODED COLUMN 4, 'Symbol'                        
                        cellstrGeneSymbol{plate,wellcounter} = char(txt2(x & y,intSymbolColumn_AB));
%                         cellstrGeneAccessionNumber{plate,wellcounter} = char(txt2(x & y,intAccessionColumn_AB));
                    end
                end
                % DISPLAY GENE SYMBOLS IN 96 WELL FORMAT PER LIBRARY PLATE
%                 disp(reshape(cellstrGeneSymbol{plate},8,12))
            end

            wellcounter = 0;
            cellReArrayedPlate = cell(16,24);
            for row = [1:2:15]            
                for col = [1:2:23]
                    wellcounter = wellcounter + 1;                   
%                     size(cellstrGeneSymbol)
                    cellReArrayedPlate{row, col} = cellstrGeneSymbol{1,wellcounter}; %reshape(cellstrGeneSymbol{1},8,12)
                    cellReArrayedPlate{row, col+1} = cellstrGeneSymbol{2,wellcounter};% [] % reshape(cellstrGeneSymbol{2},8,12)
                    cellReArrayedPlate{row+1, col} = cellstrGeneSymbol{3,wellcounter};% [] %reshape(cellstrGeneSymbol{3},8,12)
                    cellReArrayedPlate{row+1, col+1} = cellstrGeneSymbol{4,wellcounter};% [] %reshape(cellstrGeneSymbol{4},8,12)            
                end
            end
            disp(cellReArrayedPlate)
        else
        % LOGICS FOR OLIGO SET C
            strMPFileName = sprintf('MP%.3d_DG_V2',matNumericalPlateList(i,1));
            strPlateSearchString = sprintf('DG2_%s',char(strPlateContent));
            y = strcmp(cellstrPlateList_C, strPlateSearchString); % Lookup matching plates

            disp(sprintf('%s \t %s \t %s \t plate %s',char(strFolderList(i)), strCPSearchString, char(strPlateContent), strPlateSearchString))                            
                
            %LOOP OVER ALL WELLS (384 WELL FORMAT)
            wellcounter = 0;
            cellReArrayedPlate = cell(16,24);            
            for row = 65:80 % ASCII A-P
                 for col = 1:24
                     % WELL TO LOOK FOR
                    strWellSearchString = sprintf('%s%d',char(row),col);
                    x = strcmp(cellstrWellList_C, strWellSearchString); % Lookup matching wells
                    wellcounter = wellcounter + 1;
%                     cellReArrayedPlate{row-64, col} = char(txt3(x & y,6)); % HARDCODED COLUMN 6, 'Symbol'
                    cellReArrayedPlate{row-64, col} = char(txt3(x & y,intSymbolColumn_C));
%                     cellReArrayedPlate{row-64, col} = char(txt3(x & y,[intSymbolColumn_C, intAccessionColumn_C]));
                    
                end
            end
            disp(cellReArrayedPlate)
%             pause(1)
        end

%         disp(sprintf('%s \t %s',char(strFolderList(i)), char(strPlateContent)))        
    else
        disp(sprintf('%s \t not found',char(strFolderList(i))))                
    end
end


