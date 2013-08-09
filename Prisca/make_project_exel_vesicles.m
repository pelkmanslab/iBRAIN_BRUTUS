
%Projectlist = {'100224_A431_EGF_Cav1','100215_A431_Actin_LDL','100402_A431_Macropinocytosis','090203_Mz_Tf_EEA1_harlink_03_1ad','090217_A431_Tf_EEA1','090309_A431-Chtx-GM130','090403_A431_Dextran_GM1','090928_A431_Chtx_Lamp1','091113_A431_GPIGFP','091127_A431_Chtx_Golgi_AcidWash'};
Projectlist = {'090203_Mz_Tf_EEA1_harlink_03_1ad'};

%test = {'Mz_Tf','Mz_EEA1','A431_Tf','A431_EEA1','A431_Chtx','A431_GM130','A431_GM1','A431_Dextran','090928_A431_Chtx_Lamp1','091113_A431_GPIGFP','091127_A431_Chtx_Golgi_AcidWash'};

%Load project directory   
strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Prisca';
strRootPath = npc(strRootPath);

cellProjectsMahalanobis = cell(1,7);
cellProjectsMeanIntensity = cell(384,10);

for iProject =1:size(Projectlist,2)
 
    strProjectPath = fullfile(strRootPath,Projectlist{iProject});  
    
    % list of paths to load
    cellPlateNames = CPdir(strProjectPath);
    cellPlateNames = {cellPlateNames([cellPlateNames(:).isdir]).name}';
    matHasBATCHDirectory = cellfun(@(x) fileattrib2(fullfile(strProjectPath, x, 'BATCH')),cellPlateNames);
    cellPlateNames(~matHasBATCHDirectory) = [];


    matPlateMeanRescaledRedInTfVesicle = [];
    matPlateTotRescaledRedInTfVesicle = [];

%     matPlateMeanRescaledRed = [];
%     
%     matPlateTotalRescaledGreen = [];
%     matPlateTotalRescaledRed = [];
%     
%     matPlateMeanCorrGreen = [];
%     matPlateMeanCorrRed = [];
%     
%     matPlateTotalCorrGreen = [];
%     matPlateTotalCorrRed = [];
%    
%     
    matPlateTotalCellNumber = [];
    matTotalGeneNames =[];
    
    for iPlate = 1:size(cellPlateNames,1)

        % current plate path
        strPlatePath = fullfile(strRootPath,Projectlist{iProject},cellPlateNames{iPlate},'BATCH');
        
        cellstrPlateBasicData = SearchTargetFolders(strPlatePath,'BASICDATA_*.mat','rootonly');
            if ~isempty(cellstrPlateBasicData)
                load(cellstrPlateBasicData{1});
            else
                error('%s: could not find BASICDATA_*.mat in %s',mfilename,strPlatePath)
            end
            
            
        matPlateCellNumber = BASICDATA.Log2RelativeCellNumber';
        matBASICBASICDATA(:,2) = BASICDATA.WellCol';
        matBASICBASICDATA(:,1) = BASICDATA.WellRow';
        

        handles = struct();
        handles = LoadMeasurements(handles,fullfile(strPlatePath,'Measurements_Well_GeneName.mat'));
        handles = LoadMeasurements(handles,fullfile(strPlatePath,'Measurements_Well_WellName.mat'));
        %handles = LoadMeasurements(handles,fullfile(strPlatePath,'Measurements_Well_MahalDistanceTotalCellQuantile_OrigGreen.mat'));
        %handles = LoadMeasurements(handles,fullfile(strPlatePath,'Measurements_Well_MahalDistanceTotalCellQuantile_OrigRed.mat'));
%         handles = LoadMeasurements(handles,fullfile(strPlatePath,'Measurements_Well_ModelMeanIntensity_CorrGreen'));
%         handles = LoadMeasurements(handles,fullfile(strPlatePath,'Measurements_Well_ModelMeanIntensity_CorrRed'));
%          handles = LoadMeasurements(handles,fullfile(strPlatePath,'Measurements_Well_ModelIntegratedIntensity_CorrGreen'));
%          handles = LoadMeasurements(handles,fullfile(strPlatePath,'Measurements_Well_ModelIntegratedIntensity_CorrRed'));
%           handles = LoadMeasurements(handles,fullfile(strPlatePath,'Measurements_Well_ModelIntegratedIntensity_RescaledGreen'));
%          handles = LoadMeasurements(handles,fullfile(strPlatePath,'Measurements_Well_ModelIntegratedIntensity_RescaledRed'));
%           handles = LoadMeasurements(handles,fullfile(strPlatePath,'Measurements_Well_ModelMeanIntensity_RescaledGreen'));
%          handles = LoadMeasurements(handles,fullfile(strPlatePath,'Measurements_Well_ModelMeanIntensity_RescaledRed'));
          handles = LoadMeasurements(handles,fullfile(strPlatePath,'Measurements_Well_ModelMeanIntensity_RescaledGreen'));
          handles = LoadMeasurements(handles,fullfile(strPlatePath,'Measurements_Well_ModelMeanIntensity_RescaledRed'));
 
        
        if ~isequal(matBASICBASICDATA,handles.Measurements.Well.Number)
            error ('BASICDATA structure')
        end
        
        
        matPlateTotalCellNumber = [matPlateTotalCellNumber;matPlateCellNumber];
        matTotalGeneNames = [matTotalGeneNames;handles.Measurements.Well.GeneName];
        
       
          matMeanRescaledRedInTfVesicle =[];
          matTotRescaledRedInTfVesicle =[];
%           matMeanRescaledGreen =[];
%           matMeanCorrRed =[];
%           matMeanCorrGreen =[];
%           
%           matTotRescaledRed =[];
%           matTotRescaledGreen =[];
%           matTotCorrRed =[];
%           matTotCorrGreen =[];
       
            for iGene =1:384
           matMeanRescaledRedInTfVesicle = [matMeanRescaledRedInTfVesicle;handles.Measurements.Well.ModelMeanIntensity_RescaledGreenCells{iGene}(1,3)];
           matTotRescaledRedInTfVesicle = [matTotRescaledRedInTfVesicle;handles.Measurements.Well.ModelMeanIntensity_RescaledRedCells{iGene}(1,3)];

%                 matMeanRescaledGreen = [matMeanRescaledGreen;handles.Measurements.Well.ModelMeanIntensity_RescaledGreenCells{iGene}(1,3)];
%                 matMeanRescaledRed = [matMeanRescaledRed;handles.Measurements.Well.ModelMeanIntensity_RescaledRedCells{iGene}(1,3)];
%                 matMeanCorrGreen = [matMeanCorrGreen;handles.Measurements.Well.ModelMeanIntensity_CorrGreenCells{iGene}(1,3)];
%                 matMeanCorrRed = [matMeanCorrRed;handles.Measurements.Well.ModelMeanIntensity_CorrRedCells{iGene}(1,3)];
%                 
%                 matTotRescaledRed = [matTotRescaledRed;handles.Measurements.Well.ModelIntegratedIntensity_RescaledRedCells{iGene}(1,3)];
%                 matTotRescaledGreen = [matTotRescaledGreen;handles.Measurements.Well.ModelIntegratedIntensity_RescaledGreenCells{iGene}(1,3)];
%                 matTotCorrRed = [matTotCorrRed;handles.Measurements.Well.ModelIntegratedIntensity_CorrRedCells{iGene}(1,3)];
%                 matTotCorrGreen = [matTotCorrGreen;handles.Measurements.Well.ModelIntegratedIntensity_CorrGreenCells{iGene}(1,3)];
%                 
%  
            end
            matPlateMeanRescaledRedInTfVesicle = [matPlateMeanRescaledRedInTfVesicle;matMeanRescaledRedInTfVesicle];
            matPlateTotRescaledRedInTfVesicle = [matPlateTotRescaledRedInTfVesicle;matTotRescaledRedInTfVesicle];
            
            
%             matPlateMeanRescaledGreen = [matPlateMeanRescaledGreen;matMeanRescaledGreen];
%             matPlateMeanRescaledRed = [matPlateMeanRescaledRed;matMeanRescaledRed];
%         
%             matPlateTotalRescaledGreen = [matPlateTotalRescaledGreen;matTotRescaledGreen];
%             matPlateTotalRescaledRed = [matPlateTotalRescaledRed;matTotRescaledRed];
%     
%             matPlateMeanCorrGreen = [matPlateMeanCorrGreen;matMeanCorrGreen];
%             matPlateMeanCorrRed = [matPlateMeanCorrRed;matMeanCorrRed];
%     
%             matPlateTotalCorrGreen = [matPlateTotalCorrGreen;matTotCorrGreen];
%             matPlateTotalCorrRed = [matPlateTotalCorrRed;matTotCorrRed];

       
        
        
        
    end
        
          cellProjectsMeanIntensity{iProject}(:,1)=matPlateMeanRescaledRedInTfVesicle;
          cellProjectsMeanIntensity{iProject}(:,2)=matPlateTotRescaledRedInTfVesicle;
%           cellProjectsMeanIntensity{iProject}(:,3)=matPlateTotalRescaledGreen;
%           cellProjectsMeanIntensity{iProject}(:,4)=matPlateTotalCorrGreen;
%           cellProjectsMeanIntensity{iProject}(:,5)=matPlateMeanRescaledRed;
%          cellProjectsMeanIntensity{iProject}(:,6)=matPlateMeanCorrRed;
%           cellProjectsMeanIntensity{iProject}(:,7)=matPlateTotalRescaledRed;
%          cellProjectsMeanIntensity{iProject}(:,8)=matPlateTotalCorrRed;
         
         
         
         matProjectsTotalCellNumber{iProject}=matPlateTotalCellNumber;
         cellGeneNames{iProject} = matTotalGeneNames;
        
         %cellQuantileZscoredMahalanobis = cellfun(@nanzscore,cellQuantileMahalanobis,'UniformOutput',false);
         %cellQuantileZscoredMahalanobis{iPlate}(:,5) = matPlateCellNumber;
         %cellProjectsMahalanobis{iProject} = [cellQuantileMahalanobis{1};cellQuantileMahalanobis{2};cellQuantileMahalanobis{3};cellQuantileMahalanobis{4}];
         
         
end

% %matProjectsMahalanobisQuantile = [cellProjectsMahalanobis{1},cellProjectsMahalanobis{2},cellProjectsMahalanobis{3},cellProjectsMahalanobis{4},cellProjectsMahalanobis{5},cellProjectsMahalanobis{6},cellProjectsMahalanobis{7}];
% cellProjectsMeanIntensity = [cellProjectsMeanIntensity{1},cellProjectsMeanIntensity{2},cellProjectsMeanIntensity{3},cellProjectsMeanIntensity{4},cellProjectsMeanIntensity{5},cellProjectsMeanIntensity{6},cellProjectsMeanIntensity{7},cellProjectsMeanIntensity{8},cellProjectsMeanIntensity{9},cellProjectsMeanIntensity{10}];
% matTotalCellNumber = [matProjectsTotalCellNumber{1},matProjectsTotalCellNumber{2},matProjectsTotalCellNumber{3},matProjectsTotalCellNumber{4},matProjectsTotalCellNumber{5},matProjectsTotalCellNumber{6},matProjectsTotalCellNumber{7},matProjectsTotalCellNumber{8},matProjectsTotalCellNumber{9},matProjectsTotalCellNumber{10}];
% cellGeneNames = [cellGeneNames{1},cellGeneNames{2},cellGeneNames{3},cellGeneNames{4},cellGeneNames{5},cellGeneNames{6},cellGeneNames{7},cellGeneNames{8},cellGeneNames{9},cellGeneNames{10}];

