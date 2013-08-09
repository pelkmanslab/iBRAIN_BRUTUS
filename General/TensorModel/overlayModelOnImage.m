% function overlayModelOnImage()

strOutlinePath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\50K_final\MHV_KY\061102_MHV_KY_GFP_50K_GFP_P1_1\NUCLEI\';
strModelPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\';
strDataPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\061102_MHV_KY_GFP_50K_GFP_P1_1\';

%%% CREATE FILE LIST OF ALL OUTLINE IMAGES
cellstrOutlineFiles = dirc(strOutlinePath,'f');

%%% LOAD MODEL PARAMETERS
load(fullfile(strModelPath,'ProbModel_Tensor.mat'));

%%% GATHER ORIGINAL DATA
handles = struct();
handles = LoadMeasurements(handles,fullfile(strDataPath,'Measurements_Image_FileNames.mat'));
handles = LoadMeasurements(handles,fullfile(strDataPath,'Measurements_Image_ObjectCount.mat'));

structDataColumnsToUse = initStructDataColumnsToUse();
for i = fieldnames(structDataColumnsToUse)'
    disp(sprintf('  loading %s',structDataColumnsToUse.(char(i)).MeasurementsFileName))
    handles = LoadMeasurements(handles,fullfile(strDataPath,structDataColumnsToUse.(char(i)).MeasurementsFileName));
end


% intRowTodo = 8;
% intColTodo = 3;


matRows = cellstr(regexp(char(65:80),'\w','match'));
matCols = regexp(sprintf('%.2d',1:24),'\d\d','match');


%convert ImageNames to something we can index
matMatchingOutlineFileIndices = [~cellfun('isempty',(strfind([cellstrOutlineFiles(:,2)],strToMatch))), strcmpi([cellstrOutlineFiles(:,3)],'tif')]

cellOutlineFileNames = {};
for l = 1:size(cellstrOutlineFiles,1)
    cellstrOutlineFiles{l,3}
    if strcmpi(cellstrOutlineFiles{l,3},'tif')
        cellOutlineFileNames{l} = char(handles.Measurements.Image.FileNames{l}(1));
    end
end

%convert ImageNames to something we can index
cellOrigFileNames = cell(length(handles.Measurements.Image.FileNames),1);
for l = 1:size(handles.Measurements.Image.FileNames,2)
    cellOrigFileNames{l} = char(handles.Measurements.Image.FileNames{l}(1));
end


for iRow = 8
    for iCol = 3
        strToMatch = ['_',matRows{iRow},matCols{iCol}]
        matImageIndices = find(~cellfun('isempty',(strfind(cellOrigFileNames,strToMatch))));
        
        for k = matImageIndices'
            strOutlineFileName = strrep(cellOrigFileNames{k},'.tif','_SegmentedNuclei.tif');
            strcmp(cellOutlineFileNames,strOutlineFileName)
        end        
    end
end




% end