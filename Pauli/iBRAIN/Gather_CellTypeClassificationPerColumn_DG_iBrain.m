function Gather_CellTypeClassificationPerColumn_DG_iBrain(strRootPath)
% THIS FUNCTION IS OBSOLETE.. DO NOT USE
% CURRENTLY SAVED IN iBRAIN AS Gather_CellTypeData_iBRAIN2!!!! 

% Performs the SVM classification for objects, creating
% Measurements_Nuclei_CellTypeClassificationPerColumn
% and Measurements_Nuclei_CellType_Overview

% default input options (works nice for testing)
if nargin==0
    strRootPath = 'Z:\Data\Users\VSV_DG\070401_VSV_DG_batch3_CP068-1c\BATCH';

    strRootPath = npc(strRootPath);
end

% checks on input parameters
boolInputPathExists = fileattrib(strRootPath);
if not(boolInputPathExists)
    error('%s: could not read input strRootPath %s',mfilename,strRootPath)
else
    disp(sprintf('%s: starting on %s',mfilename,strRootPath))
end


%--------------------------------------------------------------------------------------------------------------------------------------------
% Interphase, mitotic, apoptotic overviews for infection screens

% finding and load/parse the latest classifications for the following svm
% classes
classes{1}='interphase'; %Interphase
classes{2}='mitotic'; %Mitotic
classes{3}='apoptotic'; %Apoptotic
classes{4}='blob'; %Blob
classes{5}='infection'; %SVM infected

% loop over all latest infection screen classes, and load data
disp(sprintf('%s: parsing latest svm files ',mfilename))
handles = struct();
class_list = cell(1,length(classes));
numPositiveClassNumbers = nan(1,length(classes));
for i = 1:length(classes)
    [handles, class_list{i}, numPositiveClassNumbers(i)] = load_latest_svm_file(handles, strRootPath, classes{i},'newest');
end

% loading the image filenames to determine the total image number

handles0 = LoadMeasurements(handles,fullfile(strRootPath,'Measurements_Image_FileNames.mat'));
handles  = handles0; % handles0 is needed later in CellType Gathering
handles2 = struct();
%handles3 = struct();
for iImage = 1:length(handles.Measurements.Image.FileNames)
    if not(isempty(class_list{1})) && not(isempty(class_list{2})) && not(isempty(class_list{3})) && not(isempty(class_list{4}))
        
        % set celltype classification matrices such that 1 matches the
        % phenotype, and 0 does not match the phenotype.
        matInterphaseIndices = handles.Measurements.SVM.(class_list{1}){iImage} == numPositiveClassNumbers(1);
        matMitoticIndices = handles.Measurements.SVM.(class_list{2}){iImage} == numPositiveClassNumbers(2);
        matApoptoticIndices = handles.Measurements.SVM.(class_list{3}){iImage} == numPositiveClassNumbers(3);
        matBlobIndices = handles.Measurements.SVM.(class_list{4}){iImage} == numPositiveClassNumbers(4);
        matInfectedSVMIndices = handles.Measurements.SVM.(class_list{5}){iImage} == numPositiveClassNumbers(5);

        data=[matBlobIndices,matInterphaseIndices,matMitoticIndices,matApoptoticIndices];
        ind{1}=ismember(data,[0 0 0 0],'rows');% -> other
        ind{2}=ismember(data,[0 0 0 1],'rows');% -> Apoptotic
        ind{3}=ismember(data,[0 0 1 0],'rows');% -> Mitotic
        ind{4}=ismember(data,[0 0 1 1],'rows');% -> Mitotic
        ind{5}=ismember(data,[0 1 0 0],'rows');% -> Interphase
        ind{6}=ismember(data,[0 1 0 1],'rows');% -> Interphase
        ind{7}=ismember(data,[0 1 1 0],'rows');% -> Interphase
        ind{8}=ismember(data,[0 1 1 1],'rows');% -> Interphase

        ind{9}=ismember(data,[1 0 0 0],'rows');% -> blob/other
        ind{10}=ismember(data,[1 0 0 1],'rows');% -> blob/other
        ind{11}=ismember(data,[1 0 1 0],'rows');% -> blob/other
        ind{12}=ismember(data,[1 0 1 1],'rows');% -> blob/other
        ind{13}=ismember(data,[1 1 0 0],'rows');% -> blob/other
        ind{14}=ismember(data,[1 1 0 1],'rows');% -> blob/other
        ind{15}=ismember(data,[1 1 1 0],'rows');% -> blob/other
        ind{16}=ismember(data,[1 1 1 1],'rows');% -> blob/other

        matInterphaseIndices=ind{5}|ind{6}|ind{7}|ind{8};
        matMitoticIndices=ind{3}|ind{4};
        matApoptoticIndices=ind{2};
        matOthers=ind{1}|ind{9}|ind{10}|ind{11}|ind{12}|ind{13}|ind{14}|ind{15}|ind{16};
        matInfectedSVM=(ind{2}|ind{3}|ind{4}|ind{5}|ind{6}|ind{7}|ind{8}) & ismember(matInfectedSVMIndices,1,'rows');

        handles2.Measurements.Nuclei.Apoptotic{iImage} = matApoptoticIndices;
        handles2.Measurements.Nuclei.Interphase{iImage} = matInterphaseIndices;
        handles2.Measurements.Nuclei.Mitotic{iImage} = matMitoticIndices;
        handles2.Measurements.Nuclei.Others{iImage} = matOthers;
        handles2.Measurements.Nuclei.InfectedSVM{iImage} = matInfectedSVM;

        if (sum(matApoptoticIndices) + sum(matInterphaseIndices) + sum(matMitoticIndices) + sum(matOthers)) ~= length(matOthers)
            error('OOHHH NOO, DOESN''T ADD UP!!!')
        end

        SVM_Set_Available=1;
    else
        error('NOT ALL SVMs ARE AVAILABLE!')
        SVM_Set_Available=0;
    end

end

% store handles2 as handles in Measurements_Nuclei_CellTypeClassificationPerColumn.mat
clear handles
handles = handles2;

if SVM_Set_Available
    disp('SVM set (interphase, mitotic, apoptotic, blob) is available');
    disp(sprintf('SAVING %s',fullfile(strRootPath,'Measurements_Nuclei_CellTypeClassificationPerColumn.mat')))
    save(fullfile(strRootPath,'Measurements_Nuclei_CellTypeClassificationPerColumn.mat'),'handles')
else
    disp('SVM set (interphase, mitotic, apoptotic, blob) is NOT available');
end

