function CreateOpenBisFiles_50K(assayIndex)
% Creates OpenBIS data files from BASICDATA and ADVANCEDDATA

StrRoot=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/50K_final_reanalysis/');
D=dir(StrRoot);
files=size(D,1);
index=0;
for file=1:files
    if D(file).isdir && isempty(strfind(D(file).name,'.'))
        index=index+1;
        file
        D(file).name
        assays{index}=D(file).name;
    end
end
strRootPath=[StrRoot,assays{assayIndex}];

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
    
elseif not(isempty(strfind(strRootPath,'50K')))  % 50K data only:
    BField{4,1}='TotalCells';
    BField{4,2}='TotalCells';
    BField{5,1}='InfectedCells';
    BField{5,2}='InfectedCells';
    BField{6,1}='InfectionIndex';
    BField{6,2}='InfectionIndex';
    BField{7,1}='RelativeInfectionIndex';
    BField{7,2}='RelativeInfectionIndex';
    BField{8,1}='Log2RelativeInfectionIndex';
    BField{8,2}='Log2RelativeInfectionIndex';
    BField{9,1}='Log2RelativeCellNumber';
    BField{9,2}='Log2RelativeCellNumber';
    BField{10,1}='ZScore';
    BField{10,2}='ZScore';
    BField{11,1}='MAD';
    BField{11,2}='MAD';
    BField{12,1}='Mean_Cells_Intensity_RescaledBlue';
    BField{12,2}='Mean_Cells_Intensity_RescaledBlue';
    BField{13,1}='Mean_Cells_Intensity_RescaledGreen';
    BField{13,2}='Mean_Cells_Intensity_RescaledGreen';
    BField{14,1}='Mean_Image_Intensity_RescaledGreen';
    BField{14,2}='Mean_Image_Intensity_RescaledGreen';
    BField{15,1}='Mean_Nuclei_BinCorrectedInfection';
    BField{15,2}='Mean_Nuclei_BinCorrectedInfection';
    BField{16,1}='Mean_Nuclei_Intensity_RescaledBlue';
    BField{16,2}='Mean_Nuclei_Intensity_RescaledBlue';
    BField{17,1}='Mean_Nuclei_Intensity_RescaledGreen';
    BField{17,2}='Mean_Nuclei_Intensity_RescaledGreen';
    BField{18,1}='ModelRawII';
    BField{18,2}='ModelRawII';
    BField{19,1}='ModelRawInfected';
    BField{19,2}='ModelRawInfected';
    BField{20,1}='ModelRawLOG2RII';
    BField{20,2}='ModelRawLOG2RII';
    BField{21,1}='ModelRawRII';
    BField{21,2}='ModelRawRII';
    BField{22,1}='ModelRawTotalCellNumber';
    BField{22,2}='ModelRawTotalCellNumber';
    BField{23,1}='ModelRawZSCORELOG2RII';
    BField{23,2}='ModelRawZSCORELOG2RII';
    BField{24,1}='ModelCorrectedLOG2RII';
    BField{24,2}='ModelCorrectedLOG2RII';
    BField{25,1}='ModelCorrectedZSCORELOG2RII';
    BField{25,2}='ModelCorrectedZSCORELOG2RII';
    BField{26,1}='ProjectTensorCorrectedLOG2RII';
    BField{26,2}='ProjectTensorCorrectedLOG2RII';
    BField{27,1}='ProjectTensorCorrectedZSCORELOG2RII';
    BField{27,2}='ProjectTensorCorrectedZSCORELOG2RII';
    BField{28,1}='PlateTensorCorrectedLOG2RII';
    BField{28,2}='PlateTensorCorrectedLOG2RII';
    BField{29,1}='PlateTensorCorrectedZSCORELOG2RII';
    BField{29,2}='PlateTensorCorrectedZSCORELOG2RII';
    BField{30,1}='ModelPredictedII';
    BField{30,2}='ModelPredictedII';
    BField{31,1}='ModelPredictedInfected';
    BField{31,2}='ModelPredictedInfected';
    BField{32,1}='ModelPredictedLOG2RII';
    BField{32,2}='ModelPredictedLOG2RII';
    BField{33,1}='ModelPredictedRII';
    BField{33,2}='ModelPredictedRII';
    BField{34,1}='ModelPredictedZSCORELOG2RII';
    BField{34,2}='ModelPredictedZSCORELOG2RII';
    BField{35,1}='CellTypeOverviewCellSizeMean';
    BField{35,2}='CellTypeOverviewCellSizeMean';
    BField{36,1}='CellTypeOverviewLocalCellDensityMean';
    BField{36,2}='CellTypeOverviewLocalCellDensityMean';
    BField{37,1}='CellTypeOverviewEdgeIndex';
    BField{37,2}='CellTypeOverviewEdgeIndex';
    BField{38,1}='CellTypeOverviewOutoffocusimages';
    BField{38,2}='CellTypeOverviewOutoffocusimages';
    BField{39,1}='CellTypeOverviewMitoticNumber';
    BField{39,2}='CellTypeOverviewMitoticNumber';
    BField{40,1}='CellTypeOverviewApoptoticNumber';
    BField{40,2}='CellTypeOverviewApoptoticNumber';
    BField{41,1}='CellTypeOverviewInterphaseNumber';
    BField{41,2}='CellTypeOverviewInterphaseNumber';
    BField{42,1}='CellTypeOverviewInfectedSVMNumber';
    BField{42,2}='CellTypeOverviewInfectedSVMNumber';
    BField{43,1}='CellTypeOverviewOthersNumber';
    BField{43,2}='CellTypeOverviewOthersNumber';
    BField{44,1}='CellTypeOverviewCellsgood';
    BField{44,2}='CellTypeOverviewCellsgood';
    BField{45,1}='CellTypeOverviewCellsnormalized';
    BField{45,2}='CellTypeOverviewCellsnormalized';
    BField{46,1}='CellTypeOverviewCellsallobjects';
    BField{46,2}='CellTypeOverviewCellsallobjects';
    BField{47,1}='CellTypeOverviewOthersIndex';
    BField{47,2}='CellTypeOverviewOthersIndex';
    BField{48,1}='CellTypeOverviewMitoticIndex';
    BField{48,2}='CellTypeOverviewMitoticIndex';
    BField{49,1}='CellTypeOverviewApoptoticIndex';
    BField{49,2}='CellTypeOverviewApoptoticIndex';
    BField{50,1}='CellTypeOverviewInterphaseIndex';
    BField{50,2}='CellTypeOverviewInterphaseIndex';
    BField{51,1}='CellTypeOverviewInfectedSVMIndex';
    BField{51,2}='CellTypeOverviewInfectedSVMIndex';
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
elseif not(isempty(strfind(strRootPath,'50K')))  % 50K data only:
    AField{4-1,1}='TotalCells';
    AField{4-1,2}='TotalCells';
    AField{5-1,1}='InfectedCells';
    AField{5-1,2}='InfectedCells';
    AField{6-1,1}='InfectionIndex';
    AField{6-1,2}='InfectionIndex';
    AField{7-1,1}='RelativeInfectionIndex';
    AField{7-1,2}='RelativeInfectionIndex';
    AField{8-1,1}='Log2RelativeInfectionIndex';
    AField{8-1,2}='Log2RelativeInfectionIndex';
    AField{9-1,1}='Log2RelativeCellNumber';
    AField{9-1,2}='Log2RelativeCellNumber';
    AField{10-1,1}='ZScore';
    AField{10-1,2}='ZScore';
    AField{11-1,1}='MAD';
    AField{11-1,2}='MAD';
    AField{12-1,1}='Mean_Cells_Intensity_RescaledBlue';
    AField{12-1,2}='Mean_Cells_Intensity_RescaledBlue';
    AField{13-1,1}='Mean_Cells_Intensity_RescaledGreen';
    AField{13-1,2}='Mean_Cells_Intensity_RescaledGreen';
    AField{14-1,1}='Mean_Image_Intensity_RescaledGreen';
    AField{14-1,2}='Mean_Image_Intensity_RescaledGreen';
    AField{15-1,1}='Mean_Nuclei_BinCorrectedInfection';
    AField{15-1,2}='Mean_Nuclei_BinCorrectedInfection';
    AField{16-1,1}='Mean_Nuclei_Intensity_RescaledBlue';
    AField{16-1,2}='Mean_Nuclei_Intensity_RescaledBlue';
    AField{17-1,1}='Mean_Nuclei_Intensity_RescaledGreen';
    AField{17-1,2}='Mean_Nuclei_Intensity_RescaledGreen';
    AField{18-1,1}='ModelRawII';
    AField{18-1,2}='ModelRawII';
    AField{19-1,1}='ModelRawInfected';
    AField{19-1,2}='ModelRawInfected';
    AField{20-1,1}='ModelRawLOG2RII';
    AField{20-1,2}='ModelRawLOG2RII';
    AField{21-1,1}='ModelRawRII';
    AField{21-1,2}='ModelRawRII';
    AField{22-1,1}='ModelRawTotalCellNumber';
    AField{22-1,2}='ModelRawTotalCellNumber';
    AField{23-1,1}='ModelRawZSCORELOG2RII';
    AField{23-1,2}='ModelRawZSCORELOG2RII';
    AField{24-1,1}='ModelCorrectedLOG2RII';
    AField{24-1,2}='ModelCorrectedLOG2RII';
    AField{25-1,1}='ModelCorrectedZSCORELOG2RII';
    AField{25-1,2}='ModelCorrectedZSCORELOG2RII';
    AField{26-1,1}='ProjectTensorCorrectedLOG2RII';
    AField{26-1,2}='ProjectTensorCorrectedLOG2RII';
    AField{27-1,1}='ProjectTensorCorrectedZSCORELOG2RII';
    AField{27-1,2}='ProjectTensorCorrectedZSCORELOG2RII';
    AField{28-1,1}='PlateTensorCorrectedLOG2RII';
    AField{28-1,2}='PlateTensorCorrectedLOG2RII';
    AField{29-1,1}='PlateTensorCorrectedZSCORELOG2RII';
    AField{29-1,2}='PlateTensorCorrectedZSCORELOG2RII';
    AField{30-1,1}='ModelPredictedII';
    AField{30-1,2}='ModelPredictedII';
    AField{31-1,1}='ModelPredictedInfected';
    AField{31-1,2}='ModelPredictedInfected';
    AField{32-1,1}='ModelPredictedLOG2RII';
    AField{32-1,2}='ModelPredictedLOG2RII';
    AField{33-1,1}='ModelPredictedRII';
    AField{33-1,2}='ModelPredictedRII';
    AField{34-1,1}='ModelPredictedZSCORELOG2RII';
    AField{34-1,2}='ModelPredictedZSCORELOG2RII';
    AField{35-1,1}='CellTypeOverviewCellSizeMean';
    AField{35-1,2}='CellTypeOverviewCellSizeMean';
    AField{36-1,1}='CellTypeOverviewLocalCellDensityMean';
    AField{36-1,2}='CellTypeOverviewLocalCellDensityMean';
    AField{37-1,1}='CellTypeOverviewEdgeIndex';
    AField{37-1,2}='CellTypeOverviewEdgeIndex';
    AField{38-1,1}='CellTypeOverviewOutoffocusimages';
    AField{38-1,2}='CellTypeOverviewOutoffocusimages';
    AField{39-1,1}='CellTypeOverviewMitoticNumber';
    AField{39-1,2}='CellTypeOverviewMitoticNumber';
    AField{40-1,1}='CellTypeOverviewApoptoticNumber';
    AField{40-1,2}='CellTypeOverviewApoptoticNumber';
    AField{41-1,1}='CellTypeOverviewInterphaseNumber';
    AField{41-1,2}='CellTypeOverviewInterphaseNumber';
    AField{42-1,1}='CellTypeOverviewInfectedSVMNumber';
    AField{42-1,2}='CellTypeOverviewInfectedSVMNumber';
    AField{43-1,1}='CellTypeOverviewOthersNumber';
    AField{43-1,2}='CellTypeOverviewOthersNumber';
    AField{44-1,1}='CellTypeOverviewCellsgood';
    AField{44-1,2}='CellTypeOverviewCellsgood';
    AField{45-1,1}='CellTypeOverviewCellsnormalized';
    AField{45-1,2}='CellTypeOverviewCellsnormalized';
    AField{46-1,1}='CellTypeOverviewCellsallobjects';
    AField{46-1,2}='CellTypeOverviewCellsallobjects';
    AField{47-1,1}='CellTypeOverviewOthersIndex';
    AField{47-1,2}='CellTypeOverviewOthersIndex';
    AField{48-1,1}='CellTypeOverviewMitoticIndex';
    AField{48-1,2}='CellTypeOverviewMitoticIndex';
    AField{49-1,1}='CellTypeOverviewApoptoticIndex';
    AField{49-1,2}='CellTypeOverviewApoptoticIndex';
    AField{50-1,1}='CellTypeOverviewInterphaseIndex';
    AField{50-1,2}='CellTypeOverviewInterphaseIndex';
    AField{51-1,1}='CellTypeOverviewInfectedSVMIndex';
    AField{51-1,2}='CellTypeOverviewInfectedSVMIndex';
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








