function createMeanMeasurmentForChildren(strRootPath)

    if nargin==0
       strRootPath = 'Z:\Data\Users\Prisca\090203_Mz_Tf_EEA1_harlink_03_1ad\090203_Mz_Tf_EEA1_CP392-1ad\BATCH';
    end
    
    strRootPath = npc(strRootPath);
    
    fprintf('Analyzing %s\n',strRootPath)
    
     % load plate information and Cell children information
    handles = struct();
    handles = LoadMeasurements (handles, fullfile(strRootPath,'Measurements_Cells_Children.mat'));
    handles = LoadMeasurements(handles, fullfile(strRootPath,'Measurements_Image_ObjectCount.mat'));
    handles = LoadMeasurements(handles, fullfile(strRootPath,'Measurements_Image_FileNames.mat'));
    % load intensity measurment for each children and average pervalue per
    % cell
    
    %for i=1:size(handles.Measurements.Cells.ChildrenFeatures,2)
    for i=1:2
        SubObjectName = handles.Measurements.Cells.ChildrenFeatures{i};
        SubObjectName = strrep(SubObjectName,'Count','');
        handles = LoadMeasurements(handles,fullfile(strRootPath,(strcat('Measurements_',SubObjectName,'_Parent.mat'))));
        strMeasurement = strcat('Measurements_',SubObjectName,'_Intensity_RescaledGreen.mat');
        strMeasurement2 = strcat('Measurements_',SubObjectName,'_Intensity_RescaledRed.mat');
        %Load intensity measurment for the vesicles and not the pixels...
        if fileattrib(fullfile(strRootPath,strMeasurement))
            fprintf('Loading intensity measurment for %s\n',SubObjectName)
            handles = LoadMeasurements(handles, fullfile(strRootPath,strMeasurement));
            handles = LoadMeasurements(handles, fullfile(strRootPath,strMeasurement2));
            vesicleName = SubObjectName;
        else
            handles = LoadMeasurements(handles,fullfile(strRootPath,(strcat('Measurements_',SubObjectName,'_Children.mat'))));
            vesicleName = handles.Measurements.(SubObjectName).ChildrenFeatures{1};
            vesicleName = strrep(vesicleName,'Count','');
            fprintf('Loading intensity measurments for %s\n',vesicleName)
            handles = LoadMeasurements(handles,fullfile(strRootPath,(strcat('Measurements_',vesicleName,'_Intensity_RescaledGreen'))));
            handles = LoadMeasurements(handles,fullfile(strRootPath,(strcat('Measurements_',vesicleName,'_Intensity_RescaledRed'))));
           
        end
      
        
        if find(strcmpi(handles.Measurements.(SubObjectName).ParentFeatures,'Cells'))
            intParentColumnVes = find(strcmpi(handles.Measurements.(SubObjectName).ParentFeatures,'Cells'));
        else
            intParentColumnVes = find(strcmpi(handles.Measurements.(vesicleName).ParentFeatures,'Cells'));
        end
        
        intCellCountColumn = find(strcmpi(handles.Measurements.Image.ObjectCountFeatures,'Cells'));
        
         
        if isempty(find(strcmpi(handles.Measurements.Image.ObjectCountFeatures,SubObjectName)))
            intVesicleCountColumn = find(strcmpi(handles.Measurements.Image.ObjectCountFeatures,vesicleName));
        else
            intVesicleCountColumn = find(strcmpi(handles.Measurements.Image.ObjectCountFeatures,SubObjectName));
        end
        
        intImageCount = length(handles.Measurements.Image.FileNames);
       
        
        
        
    %Look for the measurment that    
    cellFieldNames = fieldnames(handles.Measurements.(vesicleName));
    cellFieldNames(~cellfun(@isempty,strfind(cellFieldNames,'Features'))) = [];
    cellFieldNames(~cellfun(@isempty,strfind(cellFieldNames,'Parent'))) = [];
    
    for iMeasurment = 1:length(cellFieldNames)
       
       MeanVals =cellfun(@(x) NaN(x(1,intCellCountColumn),1),handles.Measurements.Image.ObjectCount,'UniformOutput',false); 
        % initialize not just the cell but also individual measurments as
        % NaNs
        SumVals = cellfun(@(x) NaN(x(1,intCellCountColumn),1),handles.Measurements.Image.ObjectCount,'UniformOutput',false);
%         cell(1,intImageCount);

        Fieldname = cellFieldNames{iMeasurment};
        fprintf('Calculating Mean %s for %s per cell\n',Fieldname,vesicleName)
        
        for iImage= 1:intImageCount
            Parents = handles.Measurements.(SubObjectName).Parent{iImage}(:,intParentColumnVes);
            matTempMeasurements = handles.Measurements.(vesicleName).(Fieldname){iImage};  
            MeanVals{iImage}= NaN(handles.Measurements.Image.ObjectCount{iImage}(1,intCellCountColumn),11);    
            SumVals{iImage}= NaN(handles.Measurements.Image.ObjectCount{iImage}(1,intCellCountColumn),11);    

             if  max(Parents)>0
               for iCell= 1:max(Parents)
                   Cellindices = find(Parents == iCell);
                   if  ~ isempty(Cellindices)    
                      MeanVals{iImage}(iCell,:) = nanmean(matTempMeasurements(Cellindices,:),1);  
                       SumVals{iImage}(iCell,:) = sum(matTempMeasurements(Cellindices,:),1);  
                   end
               end
             end
        end
        Measurements = struct();
         Measurements.Cells.(strcat('Mean',Fieldname,vesicleName)) = MeanVals;
         save(fullfile(strRootPath,strcat('Measurements_Cells_Mean',Fieldname,vesicleName,'.mat')),'Measurements')  
         fprintf('Saving Mean %s for %s per cell\n',Fieldname,vesicleName)
          Measurements = struct();
        Measurements.Cells.(strcat('Sum',Fieldname,vesicleName)) = SumVals;
        save(fullfile(strRootPath,strcat('Measurements_Cells_Sum',Fieldname,vesicleName,'.mat')),'Measurements')  
        fprintf('Saving Sum %s for %s per cell\n',Fieldname,vesicleName)
    end
        
    end 
    
    
    
 