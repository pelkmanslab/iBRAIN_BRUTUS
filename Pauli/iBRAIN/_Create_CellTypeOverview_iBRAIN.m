function Create_CellTypeOverview_iBRAIN(strRootPath)
% default input options (works nice for testing)
if nargin==0
    strRootPath = naspathconv('/BIOL/imsb/fs2/bio3/bio3/Data/Users/SV40_DG/20080419033214_M1_080418_SV40_DG_batch2_CP001-1dh/BATCH/');
end

% checks on input parameters
boolInputPathExists = fileattrib(strRootPath);
if not(boolInputPathExists)
    error('%s: could not read input strRootPath %s',mfilename,strRootPath)    
else
    disp(sprintf('%s: CREATING CELL TYPE OVERVIEW \n  %s \n ',mfilename,strRootPath))
end

% load plate BASICDATA
load(char(SearchTargetFolders(strRootPath,'BASICDATA_*.mat')));
handles = struct();
handles = LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Nuclei_CellTypeClassificationPerColumn.mat'));

BASICDATA_CellType.WellRow=BASICDATA.WellRow;
BASICDATA_CellType.WellCol=BASICDATA.WellCol;
for well=1:size(BASICDATA.WellRow,2)
    Mitotic_number=0;
    Apoptotic_number=0;
    Interphase_number=0;
    Others_number=0;

    for image=1:BASICDATA.RawImages(well)
        Mitotic_number=Mitotic_number+sum(handles.Measurements.Nuclei.Mitotic{BASICDATA.ImageIndices{1,well}(image)});
        Apoptotic_number=Apoptotic_number+sum(handles.Measurements.Nuclei.Apoptotic{BASICDATA.ImageIndices{1,well}(image)});
        Interphase_number=Interphase_number+sum(handles.Measurements.Nuclei.Interphase{BASICDATA.ImageIndices{1,well}(image)});
        Others_number=Others_number+sum(handles.Measurements.Nuclei.Others{BASICDATA.ImageIndices{1,well}(image)});
    end
    Cell_number=Mitotic_number+Apoptotic_number+Interphase_number;
    Total_number=Cell_number+Others_number;

    % Raw number data
    BASICDATA_CellType.Mitotic_number(1,well)=Mitotic_number;
    BASICDATA_CellType.Apoptotic_number(1,well)=Apoptotic_number;
    BASICDATA_CellType.Interphase_number(1,well)=Interphase_number;
    BASICDATA_CellType.Others_number(1,well)=Others_number;
    BASICDATA_CellType.Cell_number(1,well)=Cell_number;
    BASICDATA_CellType.Total_number(1,well)=Total_number;
    
    BASICDATA_CellType.NonOthers_number(1,well)=Total_number - Others_number;    

    % Indices
    BASICDATA_CellType.Others_index(1,well)=Others_number/Total_number;
    BASICDATA_CellType.Mitotic_index(1,well)=Mitotic_number/Cell_number;
    BASICDATA_CellType.Apoptotic_index(1,well)=Apoptotic_number/Cell_number;
    BASICDATA_CellType.NonOthers_index(1,well)=(Total_number - Others_number) / Total_number;
end
indi=BASICDATA.WellCol>2 & BASICDATA.WellCol<23;


ZScore_Others_index=log2(BASICDATA_CellType.Others_index);
ZScore_Others_index(isinf(ZScore_Others_index))=NaN;
ZScore_Others_index=ZScore_Others_index-nanmean(ZScore_Others_index(indi));
ZScore_Others_index=ZScore_Others_index/nanstd(ZScore_Others_index(indi));
BASICDATA_CellType.ZScore_Log2_Others_index=ZScore_Others_index;

ZScore_Mitotic_index=log2(BASICDATA_CellType.Mitotic_index);
ZScore_Mitotic_index(isinf(ZScore_Mitotic_index))=NaN;
ZScore_Mitotic_index=ZScore_Mitotic_index-nanmean(ZScore_Mitotic_index(indi));
ZScore_Mitotic_index=ZScore_Mitotic_index/nanstd(ZScore_Mitotic_index(indi));
BASICDATA_CellType.ZScore_Log2_Mitotic_index=ZScore_Mitotic_index;

ZScore_Apoptotic_index=log2(BASICDATA_CellType.Apoptotic_index);
ZScore_Apoptotic_index(isinf(ZScore_Apoptotic_index))=NaN;
ZScore_Apoptotic_index=ZScore_Apoptotic_index-nanmean(ZScore_Apoptotic_index(indi));
ZScore_Apoptotic_index=ZScore_Apoptotic_index/nanstd(ZScore_Apoptotic_index(indi));
BASICDATA_CellType.ZScore_Log2_Apoptotic_index=ZScore_Apoptotic_index;

%--------------------------------------------------------------------
% PhenoType Gathering.. the second set

% load classification data
handles = struct();
handles = LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Nuclei_CellTypeClassificationPerColumn.mat'));
handles = LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Nuclei_AreaShape.mat'));
handles = LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Nuclei_VirusScreen_ClassicalInfection_With_SVM.mat'));

try
    handles = LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Nuclei_GridNucleiEdges.mat'));
    handles = LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Nuclei_GridNucleiCount.mat'));
catch
    handles = LoadMeasurements(handles,fullfile(strRootPath,'Measurements_OrigNuclei_GridNucleiEdges.mat'));
    handles = LoadMeasurements(handles,fullfile(strRootPath,'Measurements_OrigNuclei_GridNucleiCount.mat'));
end

load(char(SearchTargetFolders(strRootPath,'BASICDATA_*.mat')));

for well=1:size(BASICDATA.WellRow,2)

    SizeMean=0;
    SizeStd=0;
    LocalCellDensityMean=0;
    LocalCellDensityStd=0;
    EdgeNumber=0;
    NonEdgeNumber=0;
    MitoticInfected=0;
    ApoptoticInfected=0;
    EdgeInfected=0;
    NonEdgeInfected=0;
    
    NonOthers_number=0;
    NonOthersInfected=0;
    
    Mitotic_number=0;
    Apoptotic_number=0;
    
    for image=1:BASICDATA.RawImages(well)
        imageIndex=BASICDATA.ImageIndices{1,well}(image);

        Interphase=handles.Measurements.Nuclei.Interphase{imageIndex};
        Mitotic=handles.Measurements.Nuclei.Mitotic{imageIndex};
        Apoptotic=handles.Measurements.Nuclei.Apoptotic{imageIndex};
        Others=handles.Measurements.Nuclei.Others{imageIndex};
        
        Size=handles.Measurements.Nuclei.AreaShape{imageIndex}(:,1);
        Density = [];
        Edge = [];

        % BS: code to get which object has the edge and density
        % measurements
        strDensityEdgeObject = '';
        if isfield(handles.Measurements,'Nuclei') && isfield(handles.Measurements.Nuclei,'GridNucleiCount')
            strDensityEdgeObject = 'Nuclei';
        elseif isfield(handles.Measurements,'OrigNuclei') && isfield(handles.Measurements.OrigNuclei,'GridNucleiCount')
            strDensityEdgeObject = 'OrigNuclei';
        end            
        
        Density=handles.Measurements.(strDensityEdgeObject).GridNucleiCount{imageIndex};
        Edge=handles.Measurements.(strDensityEdgeObject).GridNucleiEdges{imageIndex};
            
%         try
%             Density=handles.Measurements.Nuclei.GridNucleiCount{imageIndex};
%             Edge=handles.Measurements.Nuclei.GridNucleiEdges{imageIndex};
%         catch
%             Density=handles.Measurements.OrigNuclei.GridNucleiCount{imageIndex};
%             Edge=handles.Measurements.OrigNuclei.GridNucleiEdges{imageIndex};
%         end
        Infected=handles.Measurements.Nuclei.VirusScreen_ClassicalInfection{imageIndex};
        
        if isempty(Interphase)
            Interphase=[];
        end
        if isempty(Mitotic)
            Mitotic=[];
        end
        if isempty(Apoptotic)
            Apoptotic=[];
        end
        if isempty(Size)
            Size=[];
        end
        if isempty(Density)
            Density=[];
        end
        if isempty(Edge)
            Edge=[];
        end
        if isempty(Infected)
            Infected=[];
        end
        if isempty(Others)
            Others=[];
        end        

        Mitotic_number=Mitotic_number+nansum(Mitotic);
        Apoptotic_number=Apoptotic_number+nansum(Apoptotic);
        NonOthers_number=NonOthers_number+nansum(~Others);
        

        SizeMean=SizeMean+nanmean(Size(boolean(Interphase)));
        SizeStd=SizeStd+nanstd(Size(boolean(Interphase)));

        LocalCellDensityMean=LocalCellDensityMean+nanmean(Density);
        LocalCellDensityStd=LocalCellDensityStd+nanstd(Density);

        EdgeNumber=EdgeNumber+nansum(Edge);
        EdgeInfected=EdgeInfected+nansum(Edge & Infected);
        NonEdgeNumber=NonEdgeNumber+nansum(1-Edge);
        NonEdgeInfected=EdgeInfected+nansum(~Edge & Infected);

        MitoticInfected=MitoticInfected+nansum(Mitotic & Infected);
        ApoptoticInfected=ApoptoticInfected+nansum(Apoptotic & Infected);
        
        NonOthersInfected=NonOthersInfected+nansum(~Others & Infected);        

    end

    % Raw number data
    BASICDATA_CellType.SizeMean(1,well)=SizeMean/BASICDATA.RawImages(well);
    BASICDATA_CellType.SizeStd(1,well)=SizeStd/BASICDATA.RawImages(well);
    
    BASICDATA_CellType.LocalCellDensityMean(1,well)=LocalCellDensityMean/BASICDATA.RawImages(well);
    BASICDATA_CellType.LocalCellDensityStd(1,well)=LocalCellDensityStd/BASICDATA.RawImages(well);
    
    BASICDATA_CellType.EdgeNumber(1,well)=EdgeNumber;
    BASICDATA_CellType.NonEdgeNumber(1,well)=NonEdgeNumber;
    BASICDATA_CellType.MitoticInfected(1,well)=MitoticInfected;
    BASICDATA_CellType.ApoptoticInfected(1,well)=ApoptoticInfected;
    
    BASICDATA_CellType.NonOthersInfected(1,well)=NonOthersInfected;    


    
    % Infection Indices (normalized later)
    BASICDATA_CellType.ZScoreLog2MitoticII(1,well)=MitoticInfected/Mitotic_number;
    BASICDATA_CellType.ZScoreLog2ApoptoticII(1,well)=ApoptoticInfected/Apoptotic_number;
    BASICDATA_CellType.ZScoreLog2EdgeII(1,well)=EdgeInfected/EdgeNumber;
    BASICDATA_CellType.ZScoreLog2NonEdgeII(1,well)=NonEdgeInfected/NonEdgeNumber;
    BASICDATA_CellType.ZScoreLog2NonOthersII(1,well)=NonOthersInfected/NonOthers_number;

    % Ratio
    BASICDATA_CellType.EdgeRatio(1,well)=NonEdgeNumber/EdgeNumber;

end
indi=BASICDATA.WellCol>2 & BASICDATA.WellCol<23;

% ZScore Log2 normalizations

BASICDATA_CellType.ZScoreLog2MitoticII=log2(BASICDATA_CellType.ZScoreLog2MitoticII);
BASICDATA_CellType.ZScoreLog2MitoticII(isinf(BASICDATA_CellType.ZScoreLog2MitoticII))=NaN;
BASICDATA_CellType.ZScoreLog2MitoticII=BASICDATA_CellType.ZScoreLog2MitoticII-nanmean(BASICDATA_CellType.ZScoreLog2MitoticII(indi));
BASICDATA_CellType.ZScoreLog2MitoticII=BASICDATA_CellType.ZScoreLog2MitoticII/nanstd(BASICDATA_CellType.ZScoreLog2MitoticII(indi));

BASICDATA_CellType.ZScoreLog2ApoptoticII=log2(BASICDATA_CellType.ZScoreLog2ApoptoticII);
BASICDATA_CellType.ZScoreLog2ApoptoticII(isinf(BASICDATA_CellType.ZScoreLog2ApoptoticII))=NaN;
BASICDATA_CellType.ZScoreLog2ApoptoticII=BASICDATA_CellType.ZScoreLog2ApoptoticII-nanmean(BASICDATA_CellType.ZScoreLog2ApoptoticII(indi));
BASICDATA_CellType.ZScoreLog2ApoptoticII=BASICDATA_CellType.ZScoreLog2ApoptoticII/nanstd(BASICDATA_CellType.ZScoreLog2ApoptoticII(indi));

BASICDATA_CellType.ZScoreLog2EdgeII=log2(BASICDATA_CellType.ZScoreLog2EdgeII);
BASICDATA_CellType.ZScoreLog2EdgeII(isinf(BASICDATA_CellType.ZScoreLog2EdgeII))=NaN;
BASICDATA_CellType.ZScoreLog2EdgeII=BASICDATA_CellType.ZScoreLog2EdgeII-nanmean(BASICDATA_CellType.ZScoreLog2EdgeII(indi));
BASICDATA_CellType.ZScoreLog2EdgeII=BASICDATA_CellType.ZScoreLog2EdgeII/nanstd(BASICDATA_CellType.ZScoreLog2EdgeII(indi));

BASICDATA_CellType.ZScoreLog2NonEdgeII=log2(BASICDATA_CellType.ZScoreLog2NonEdgeII);
BASICDATA_CellType.ZScoreLog2NonEdgeII(isinf(BASICDATA_CellType.ZScoreLog2NonEdgeII))=NaN;
BASICDATA_CellType.ZScoreLog2NonEdgeII=BASICDATA_CellType.ZScoreLog2NonEdgeII-nanmean(BASICDATA_CellType.ZScoreLog2NonEdgeII(indi));
BASICDATA_CellType.ZScoreLog2NonEdgeII=BASICDATA_CellType.ZScoreLog2NonEdgeII/nanstd(BASICDATA_CellType.ZScoreLog2NonEdgeII(indi));

BASICDATA_CellType.ZScoreLog2NonOthersII=log2(BASICDATA_CellType.ZScoreLog2NonOthersII);
BASICDATA_CellType.ZScoreLog2NonOthersII(isinf(BASICDATA_CellType.ZScoreLog2NonOthersII))=NaN;
BASICDATA_CellType.ZScoreLog2NonOthersII=BASICDATA_CellType.ZScoreLog2NonOthersII-nanmean(BASICDATA_CellType.ZScoreLog2NonOthersII(indi));
BASICDATA_CellType.ZScoreLog2NonOthersII=BASICDATA_CellType.ZScoreLog2NonOthersII/nanstd(BASICDATA_CellType.ZScoreLog2NonOthersII(indi));


% saving data
disp(sprintf('SAVING %s',fullfile(strRootPath,'Measurements_Nuclei_CellType_Overview.mat')))
save(fullfile(strRootPath,'Measurements_Nuclei_CellType_Overview.mat'),'BASICDATA_CellType')




		