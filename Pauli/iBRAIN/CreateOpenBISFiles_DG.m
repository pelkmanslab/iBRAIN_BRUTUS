function CreateOpenBisFiles_DG(strRootPath)
% Creates OpenBIS data files from BASICDATA and ADVANCEDDATA

if nargin==0
    strRootPath='X:\Data\Users\MHV_DG';
end

strCombinedPath=npc('X:\Data\Users\DG_data_combined\');

% checks on input parameters
boolInputPathExists = fileattrib(strRootPath);
if not(boolInputPathExists)
    error('%s: could not read input strRootPath %s',mfilename,strRootPath)
else
    disp(sprintf('%s: starting on %s',mfilename,strRootPath))
end

strRootPath = [strRootPath,filesep]; 

indi=strfind(strRootPath,filesep);
experiment_code=strRootPath(indi(end-1)+1:indi(end)-1);
strAssayName=strrep(experiment_code,'_DG','');

%--------------------------------------------------------------------------
% Fields to be stored (make this later in a settings file?)
BField{1,1}='WellRow';   % first the BASICDATA name
BField{1,2}='row';                       % second the name to be used in OpenBIS
BField{2,1}='WellCol';
BField{2,2}='col';
BField{3,1}=''; %if empty the barcode is used
BField{3,2}='barcode';

if not(isempty(strfind(strRootPath,'_DG')))
    BField{4,1}='TCN';   % first the BASICDATA name
    BField{4,2}='Cell Number';                       % second the name to be used in OpenBIS
    BField{5,1}='II';
    BField{5,2}='Infection Index';
    BField{6,1}='MI';
    BField{6,2}='Mitotic index';
    BField{7,1}='AI';
    BField{7,2}='Apoptotic index';
    BField{8,1}='LCD';
    BField{8,2}='Local cell density index';
    BField{9,1}='Edge';
    BField{9,2}='Edge index';
    BField{10,1}='Size';
    BField{10,2}='Average cell size';
    BField{11,1}='Single';
    BField{11,2}='Single cell index';
    BField{12,1}='MII';
    BField{12,2}='Mitotic infection index';
    BField{13,1}='AII';
    BField{13,2}='Apoptotic infection index';
end

AField{1,1}='GeneID';                       % first the ADVANCEDDATA2 name
AField{1,2}='geneId';                       % second the name to be used in OpenBIS
AField{2,1}='GeneData';
AField{2,2}='symbol';

if not(isempty(strfind(strRootPath,'_DG')))
    AField{3,1}='TCN';
    AField{3,2}='Cell Number';
    AField{4,1}='II';
    AField{4,2}='Infection Index';
    AField{5,1}='MI';
    AField{5,2}='Mitotic index';
    AField{6,1}='AI';
    AField{6,2}='Apoptotic index';
    AField{7,1}='LCD';
    AField{7,2}='Local cell density index';
    AField{8,1}='Edge';
    AField{8,2}='Edge index';
    AField{9,1}='Size';
    AField{9,2}='Average cell size';
    AField{10,1}='Single';
    AField{10,2}='Single cell index';
    AField{11,1}='MII';
    AField{11,2}='Mitotic infection index';
    AField{12,1}='AII';
    AField{12,2}='Apoptotic infection index';
end


try
    load([strRootPath,'BASICDATA.mat'])
catch
    error(['BASICDATA could not be loaded at ',strPath])  
    return;
end

try
    load([strCombinedPath,'MetaData.mat'])
catch
    error(['MetaData could not be loaded at ',strCombinedPath])  
    return;
end

try
    load([strCombinedPath,'RawData4.mat'])
catch
    error(['RawData4 could not be loaded at ',strCombinedPath])  
    return;
end

try
    load([strCombinedPath,'Data_oligo.mat'])
catch
    error(['Data_oligo could not be loaded at ',strCombinedPath])  
    return;
end

indi=strfind(strRootPath,filesep);
experiment_code=strRootPath(indi(end-1)+1:indi(end)-1);
mkdir(strRootPath,'OpenBIS_DG')
if not(isempty(strfind(strRootPath,'50K'))) 
    strFullPath=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/50K_OpenBIS/');
else
    strFullPath=[strRootPath,'OpenBIS_DG',filesep];
end

mkdir(strFullPath,'well-analysis-results');
mkdir([strFullPath,'well-analysis-results'],experiment_code);
mkdir(strFullPath,'gene-analysis-results');
mkdir(strFullPath,'images');
mkdir([strFullPath,'images'],experiment_code);
mkdir([strFullPath,'plate-overviews'],experiment_code);
mkdir(strFullPath,'libraries');

plates=size(RawData4.(strAssayName).TCN.(MetaData.ReadoutBaselLevel3{1}),1);%length(BASICDATA.Path);
wells=size(RawData4.(strAssayName).TCN.(MetaData.ReadoutBaselLevel3{1}),2);%size(BASICDATA.WellCol,2);

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


for plate=1:plates % HERE ASSUMING THAT THE PLATE ORDER IS THE SAME IN BASICDATA AND IN RAWDATA!!! check this!
    strPlatePath=npc(BASICDATA.Path{plate});
    strPlatePath=strrep(strPlatePath,[filesep,filesep],filesep); %silly bug fix for some plate names with double fileseps
    try 
        plate_code=regexp(strPlatePath,'CP\d{2,}[-_]\d\w\w','match');
        plate_code=plate_code{1};
    catch % some MHV plates have non consistend plate naming
        plate_code=regexp(strPlatePath,'CP\d{2,}[-_]\d\w{1,}','match');
        plate_code=plate_code{1};
    end
    
    mkdir([strFullPath,'images',filesep,experiment_code],plate_code);
    
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
        elseif strcmp(BField{col,1},'WellCol')
            for well=1:wells
                well_table{well+1,col}=num2str(BASICDATA.(BField{col,1})(plate,well));
            end
        else
            for well=1:wells
                try
                    target=find(ismember(MetaData.ReadoutNames,BField{col,1}));
                    value=RawData4.(strAssayName).(BField{col,1}).(MetaData.ReadoutBaselLevel3{target})(plate,well);      
                    well_table{well+1,col}=num2str(value);
                catch
%                     try
%                         well_table{well+1,col}=num2str(BASICDATA.(BField{col,1}){plate,well}(2)); %assuming an intensity measure
%                     catch
%                         well_table{well+1,col}=NaN;
%                     end
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
genes=MetaData.genes;
for col=1:size(AField,1)
    gene_table{1,col}=AField{col,2}; 
    
    for gene=1:genes
        
        if col==1 %geneID
            data=MetaData.GeneID.(strAssayName)(gene);
            gene_table{gene+1,col}=num2str(data);
        elseif col==2 %geneName
            data=MetaData.GeneName.(strAssayName){gene};
            gene_table{gene+1,col}=data;
        else
            target=find(ismember(MetaData.ReadoutNames,AField{col,1}));
            data=nanmean(Data_oligo.(strAssayName).(AField{col,1}).(MetaData.ReadoutBaselLevel3{target})(gene,:));
            gene_table{gene+1,col}=num2str(data);
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








