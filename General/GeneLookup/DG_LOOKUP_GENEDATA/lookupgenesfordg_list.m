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
intPlateDescriptionColumn = intPlateContentColumn + 1;

% LOOKUP CORRECT COLUMNS FROM OLIGO SET A+B EXCEL FILE
[intWellColumn_AB, cellstrWellList_AB] = lookuptxtcolumn(txt2, 'Well'); % WELL
[intPlateColumn_AB, cellstrPlateList_AB] = lookuptxtcolumn(txt2, 'Plate name'); % PLATE CONTENT
[intSymbolColumn_AB] = lookuptxtcolumn(txt2, 'Symbol'); % SYMBOL
[intGENBANKIDColumn_AB] = lookuptxtcolumn(txt2, 'GenbankID'); % GENBANK ID
[intSequenceColumn_A] = lookuptxtcolumn(txt2, 'seq1'); % SEQUENCE_A
[intSequenceColumn_B] = lookuptxtcolumn(txt2, 'seq2'); % SEQUENCE_B

cellstrPlateDescriptionList_AB = cell(size(cellstrPlateList_AB));
for i = 1:length(cellstrPlateList_AB) % SHORTENING TO THE FIRST 6 CHARACTERS
    x = strfind(cellstrPlateList_AB{i},'_');
    if size(x,2) > 1
        cellstrPlateDescriptionList_AB{i} = cellstrPlateList_AB{i}(x(1,2):end);        
        cellstrPlateList_AB{i} = cellstrPlateList_AB{i}(1:x(1,2)-1);
    end
end

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

cellLibraryPlates = {};
cellMasterDataList = {};
platecounter = 0;


%
% LOOP OVER THE MASTERPLATE LIST, NOT THE VSV_DG FOLDER LIST!
%
%

for i = 1:70%size(matNumericalPlateList,1)

%     strCPSearchString = sprintf('CP%.3d-',matNumericalPlateList(i,1));
%     strMPFileName = sprintf('MP%.3d',matNumericalPlateList(i,1));
    strCPSearchString = sprintf('CP%.3d-',i);    
    strMPFileName = sprintf('MP%.3d',i);    

    [a, foo] = find(~cellfun('isempty',strfind(cellstr(txt1(:,intCellPlateColumn)), strCPSearchString)));
    if not(isempty(a))
        
        strPlateContent = txt1(a(1),intPlateContentColumn);
        strPlateDescription = txt1(a(1),intPlateDescriptionColumn);        
        
        cellLibraryPlates = regexp(strPlateContent, '\d*\w', 'match');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % LOGICS FOR OLIGO SET A AND B %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if not(strcmp(cellLibraryPlates{1}{1}(end),'C'))
           
            % LOOP OVER ALL PLATES
            cellstrGeneSymbol = cell(4,96);
            cellstrGeneAccessionNumber = cell(4,96);
            for plate = 1:size(cellLibraryPlates{1,1},2)
                intLibraryPlateNumber = regexp(cellLibraryPlates{1,1}(plate), '\d*', 'match');
                intLibraryPlateLetter = regexp(cellLibraryPlates{1,1}(plate), '\D', 'match');            
                intLibraryPlateNumber = str2double(intLibraryPlateNumber{1,1});
                strPlateSearchString = sprintf('DG2_%.2dA',intLibraryPlateNumber);                
                y = strcmp(cellstrPlateList_AB, strPlateSearchString); % Lookup matching plates

%                 disp(sprintf('%s \t %s \t %s \t plate %s',char(strFolderList(i)), strCPSearchString, char(strPlateContent), strPlateSearchString))                
                disp(sprintf('%s \t %s \t %s \t plate %s',char(strMPFileName), strCPSearchString, char(strPlateContent), strPlateSearchString))                                

                %LOOP OVER ALL WELLS (96 WELL FORMAT)
                wellcounter = 0;
                for row = 65:72 % ASCII A-H
                     for col = 1:12
                         % WELL TO LOOK FOR
                        strWellSearchString = sprintf('%s%d',char(row),col);
                        x = strcmp(cellstrWellList_AB, strWellSearchString); % Lookup matching wells
                        wellcounter = wellcounter + 1;
                        
                        %%% DATA ITEMS
                        cellcontent = cell(1,12);
                        cellcontent{1} = char(strMPFileName); % MP ID
                        cellcontent{2} = char(strPlateContent); % PLATE CONTENT
                        cellcontent{3} = char(strPlateDescription); % PLATE DESCRIPTION
                        cellcontent{4} = char(strWellSearchString); % WELL
                        cellcontent{5} = row - 64; % ROW -- !!!! NOT YET REARRAYED!!!
                        cellcontent{6} = col; % COLUMN -- !!!! NOT YET REARRAYED!!!
                        cellcontent{7} = char(txt2(x & y,intSymbolColumn_AB)); % GENE SYMBOL
                        cellcontent{8} = char(intLibraryPlateLetter{1}); % OLIGO #
                        cellcontent{9} = char(txt2(x & y,intGENBANKIDColumn_AB)); % GENBANKID
                        if strmatch(char(intLibraryPlateLetter{1}),'A')
                            cellcontent{11} = char(txt2(x & y,intSequenceColumn_A)); % SEQUENCE
                        elseif strmatch(char(intLibraryPlateLetter{1}),'B')
                            cellcontent{11} = char(txt2(x & y,intSequenceColumn_B)); % SEQUENCE
                        end
                        cellcontent{12} = 2; % DG_VERSION
                        cellstrGeneSymbol{plate,wellcounter} = cellcontent;
                    end
                end
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
            
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % LOGICS FOR OLIGO SET C %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        else
            strPlateSearchString = sprintf('DG2_%s',char(strPlateContent));
            
            y = strcmp(cellstrPlateList_C, strPlateSearchString); % Lookup matching plates

%             disp(sprintf('%s \t %s \t %s \t plate %s',char(strFolderList(i)), strCPSearchString, char(strPlateContent), strPlateSearchString))                            
            disp(sprintf('%s \t %s \t %s \t plate %s',char(strMPFileName), strCPSearchString, char(strPlateContent), strPlateSearchString))                                            
                
            %LOOP OVER ALL WELLS (384 WELL FORMAT)
            wellcounter = 0;
            cellReArrayedPlate = cell(16,24);            
            for row = 65:80 % ASCII A-P
                 for col = 1:24
                     % WELL TO LOOK FOR
                    strWellSearchString = sprintf('%s%d',char(row),col);
                    x = strcmp(cellstrWellList_C, strWellSearchString); % Lookup matching wells
                    wellcounter = wellcounter + 1;

                    %%% DATA ITEMS
                    cellcontent = cell(1,12);
                    cellcontent{1} = char(strMPFileName); % MP ID
                    cellcontent{2} = char(strPlateContent); % PLATE CONTENT
                    cellcontent{3} = char(strPlateDescription); % PLATE DESCRIPTION
                    cellcontent{4} = char(strWellSearchString); % WELL
                    cellcontent{5} = row - 64; % ROW
                    cellcontent{6} = col; % COLUMN
                    cellcontent{7} = char(txt3(x & y,intSymbolColumn_C)); % GENE SYMBOL
                    cellcontent{8} = 'C'; % OLIGO
                    cellcontent{10} = char(txt3(x & y,intAccessionColumn_C)); % ACCESSION# HITS
                    cellcontent{11} = char(txt3(x & y,intSequenceColumn_C)); % SEQUENCE
                    cellcontent{12} = 3; % DG_VERSION

                    cellReArrayedPlate{row-64, col} = cellcontent;                    
                end
            end
        end


    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % STORING OVERALL DATA %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    cellReArrayedPlate = cellReArrayedPlate';
    
    if not(length(cellReArrayedPlate(:)) == 384) 
        error('wrong plate size!!! %s %s %s ',char(strFolderList(i)), char(strMPFileName), char(strCPSearchString))
    end
    
    platecounter = platecounter + 1;
    cellMasterDataList = vertcat(cellMasterDataList, cellReArrayedPlate{:});
%     disp(size(cellMasterDataList))
%     disp(platecounter)

    else
        disp(sprintf('%s \t not found',char(strFolderList(i))))                
    end

    
end

save('C:\Documents and Settings\imsb\Desktop\DG_LOOKUP_GENEDATA\MasterData.mat','cellMasterDataList','-v7.3')
