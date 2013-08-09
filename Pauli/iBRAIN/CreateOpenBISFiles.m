function CreateOpenBisFiles_50K(strRootPath)
% Creates OpenBIS data files from BASICDATA and ADVANCEDDATA

if nargin==0
    strPath='Z:\Data\Users\HSV1_DG';
end

% checks on input parameters
boolInputPathExists = fileattrib(strRootPath);
if not(boolInputPathExists)
    error('%s: could not read input strRootPath %s',mfilename,strRootPath)
else
    disp(sprintf('%s: starting on %s',mfilename,strRootPath))
end

strRootPath = [strRootPath,filesep]; 

%--------------------------------------------------------------------------
% Fields to be stored (make this later in a settings file?)
BField{1,1}='WellRow';   % first the BASICDATA name
BField{1,2}='row';                       % second the name to be used in OpenBIS
BField{2,1}='WellCol';
BField{2,2}='col';
BField{3,1}=''; %if empty the barcode is used
BField{3,2}='barcode';

if not(isempty(strfind(strRootPath,'_DG')))
    BField{4,1}='CellTypeOverviewCellsnormalized';   % first the BASICDATA name
    BField{4,2}='Cell Number';                       % second the name to be used in OpenBIS
    BField{5,1}='CellTypeOverviewInfectedSVMIndex';
    BField{5,2}='Infection Index (normalized)';
    BField{6,1}='CellTypeOverviewMitoticIndex';
    BField{6,2}='Mitotic index (normalized)';
    BField{7,1}='CellTypeOverviewApoptoticIndex';
    BField{7,2}='Apoptotic index (normalized)';
end

AField{1,1}='GeneID';                       % first the ADVANCEDDATA2 name
AField{1,2}='geneId';                       % second the name to be used in OpenBIS
AField{2,1}='GeneData';
AField{2,2}='symbol';

if not(isempty(strfind(strRootPath,'_DG')))
    AField{3,1}='CellTypeOverviewCellNumber';
    AField{3,2}='Cell Number';
    AField{4,1}='CellTypeOverviewInfectedSVMIndex';
    AField{4,2}='Infection Index (normalized)';
    AField{5,1}='CellTypeOverviewMitoticIndex';
    AField{5,2}='Mitotic index (normalized)';
    AField{6,1}='CellTypeOverviewApoptoticIndex';
    AField{6,2}='Apoptotic index (normalized)';
end

try
    load([strRootPath,'BASICDATA.mat'])
catch
    error(['BASICDATA could not be loaded at ',strRootPath,'BASICDATA.mat'])  
    return;
end


try
    load([strRootPath,'ADVANCEDDATA2.mat'])
catch
    error('ADVANCEDDATA2 could not be loaded!')
    return;
end

indi=strfind(strRootPath,filesep);
experiment_code=strRootPath(indi(end-1)+1:indi(end)-1);
mkdir(strRootPath,'OpenBIS')
if not(isempty(strfind(strRootPath,'50K'))) 
    strFullPath=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/50K_OpenBIS/');
else
    strFullPath=[strRootPath,'OpenBIS',filesep];
end

mkdir(strFullPath,'well-analysis-results');
mkdir([strFullPath,'well-analysis-results'],experiment_code);
mkdir(strFullPath,'gene-analysis-results');
mkdir(strFullPath,'images');
mkdir([strFullPath,'images'],experiment_code);
mkdir([strFullPath,'plate-overviews'],experiment_code);
mkdir(strFullPath,'libraries');

plates=length(BASICDATA.Path);
wells=size(BASICDATA.WellCol,2);

% well-analysis-results (Plate wise results)
well_index=1;
master_data=cell(plates*wells+1,8);
master_data{1,1}='barcode'; 
master_data{1,2}='row';
master_data{1,3}='col';
master_data{1,4}='sirna';
master_data{1,5}='productId';
master_data{1,6}='geneId';
master_data{1,7}='symbol';
master_data{1,8}='description';


for plate=1:plates
    strPlatePath=npc(BASICDATA.Path{plate});
    plate_code=regexp(strPlatePath,'CP\d{2,}[-_]\d\w\w','match');
    plate_code=plate_code{1};
    
    mkdir([strFullPath,'images',filesep,experiment_code],plate_code);
    % How to create soft/hard link to the images in these folders?
    
    for col=1:size(BField,1)
        well_table{1,col}=BField{col,2};
        if isempty(BField{col,1})
            for well=1:wells
                well_table{well+1,col}=plate_code;
            end
        elseif strcmp(BField{col,1},'WellRow')
            for well=1:wells
                well_table{well+1,col}=char(BASICDATA.(BField{col,1})(plate,well)+64);
            end
        else
            for well=1:wells
                try
                    well_table{well+1,col}=num2str(BASICDATA.(BField{col,1})(plate,well));
                catch
                    try
                        well_table{well+1,col}=num2str(BASICDATA.(BField{col,1}){plate,well}(2)); %assuming an intensity measure
                    catch
                        well_table{well+1,col}=NaN;
                    end
                end
            end
        end
        
    end
    filename=[strFullPath,'well-analysis-results',filesep,experiment_code,filesep,plate_code,'.csv'];
    try
        writelists(well_table,filename);
    catch
        disp(['SAVING ',filename,' FAILED!!!!!'])
    end
    
    % Generating the library file
    for well=1:wells
        well_index=well_index+1;
        
        intRowNumber=BASICDATA.WellRow(plate,well);
        intColumnNumber=BASICDATA.WellCol(plate,well);
        intPlateNumber = BASICDATA.PlateNumber(plate,well);
        
        master_data{well_index,1}=plate_code;                              % barcode
        master_data{well_index,2}=char(intRowNumber+64);                   % row
        master_data{well_index,3}=num2str(intColumnNumber);                % col
        [foo1,foo2,foo3,siRNA]=lookupwellcontent(intPlateNumber, intRowNumber, intColumnNumber); % THIS GIVES BLANK TO ALL 50K oligos!!!
        master_data{well_index,4}=siRNA;                                   % sirna
        if isempty(BASICDATA.GeneData{plate,well})
            master_data{well_index,5}='';
        else
            master_data{well_index,5}=[BASICDATA.GeneData{plate,well},'_',num2str(BASICDATA.OligoNumber(plate,well))];       % productId
        end
        master_data{well_index,6}=num2str(BASICDATA.GeneID{plate,well});   % geneId
        master_data{well_index,6}=strrep(master_data{well_index,6},'*','_');master_data{well_index,6}=strrep(master_data{well_index,6},'/','_');
        master_data{well_index,7}=BASICDATA.GeneData{plate,well};          % symbol
        master_data{well_index,7}=strrep(master_data{well_index,7},'*','_');master_data{well_index,7}=strrep(master_data{well_index,7},'/','_');
        master_data{well_index,8}='-';                                     % description
    end
       
    % Making hardlink copies of JPGs to correct folders using system calls
    if isunix    
       indi=strfind(strPlatePath,filesep);
       strSourcePath=[strPlatePath(1:indi(end-1)-1),filesep,'JPG',filesep];
       strTargetPath=[strFullPath,'images',filesep,experiment_code,filesep,plate_code];
       strSystemCall=['ln ',strSourcePath,'*RGB*.jpg ',strTargetPath]; % copying all images
       system(strSystemCall);
       
       strTargetPath=[strFullPath,'plate-overviews',filesep,experiment_code];
       strSystemCall=['ln ',strSourcePath,'*PlateOverview*.jpg ',strTargetPath,filesep,plate_code,'.jpg'];
       system(strSystemCall);
    end
end

filename=[strFullPath,'libraries',filesep,experiment_code,'.csv'];
try
    disp(['Saving: ',filename]);
    writelists(master_data,filename)
catch
    disp(['SAVING ',filename,' FAILED!!!!!'])
end

% gene-analysis-results (Gene wise results)
genes=length(ADVANCEDDATA.GeneID);
for col=1:size(AField,1)
    gene_table{1,col}=AField{col,2}; 
    
    
    for gene=1:genes
        data=ADVANCEDDATA.(AField{col,1}){gene};
        if strcmp(class(data),'cell')
            if not(isnumeric(data{1}))
                gene_table{gene+1,col}=data{1};
            else %Assuming an intensity readout here
                data2=cell2mat(data);
                if size(data2,2)==1
                    gene_table{gene+1,col}=data2(1);
                else
                    data2=data2(:,2); % taking the mean intensity
                    oligos=ADVANCEDDATA.OligoNumber{gene};
                    oligo_data=NaN(1,3);
                    for oligo=1:3
                        oligo_data(oligo)=nanmedian(data2(oligos==oligo));
                    end
                    gene_table{gene+1,col}=nanmean(oligo_data);
                    
                end
            end
        else
            oligos=ADVANCEDDATA.OligoNumber{gene};
            oligo_data=NaN(1,3);
            for oligo=1:3
                oligo_data(oligo)=nanmedian(data(oligos==oligo));
            end
            gene_table{gene+1,col}=nanmean(oligo_data);
        end
    end  
end

filename=[strFullPath,'gene-analysis-results',filesep,experiment_code,'.csv'];
try
    disp(['Saving: ',filename]);
    writelists(gene_table,filename)
catch
    disp(['SAVING ',filename,' FAILED!!!!!'])
end








