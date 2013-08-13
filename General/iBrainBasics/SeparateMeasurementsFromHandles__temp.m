% function SeparateMeasurementsFromHandles(handles,cluster)

% strAlternativeOutputPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_TDS\070212_SV40_TDS_50K_rt_P3_2';
strAlternativeOutputPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Lilli\070813_A431_FAK_Trfn\RISC\';

% strAlternativeOutputPath = '/Volumes/share-2-$/Data/Users/Berend/BATCH_RESULTS/Data/Users/50K_final/RV_KY/061222_RV_50K_KY_P1_1_3'

warning off all

% check if handles.Measurements exists
if not(isfield(handles, 'Measurements'))
   error('SeparateMeasurementsFromHandles: Handles does not contain any Measurements') 
   return
end

% we want to work with either a cluster file, when called from CPCluster,
% or without one, in which case we assume BathFilePrefix to be 'Batch_'.
if nargin == 2 && isfield(cluster, 'BatchFilePrefix')
    BatchFilePrefix = cluster.BatchFilePrefix;
    StartImage = cluster.StartImage;
    EndImage = cluster.EndImage;
else
    BatchFilePrefix = 'Batch_';
    StartImage = 1%handles.Current.BatchInfo.Start;
    EndImage = length(handles.Measurements.Image.FileNames)%handles.Current.BatchInfo.End;
end

strDataSorterOutputFolderPath = handles.Current.DefaultOutputDirectory;

cellstrFieldsWithNoDescription = {'VirusScreenGaussians','VirusScreenThresholds','GridNucleiCount','GridNucleiEdges'};

%%%%%%%%%%%%%%%%%%%%%%%
%%%  STORING  DATA  %%%
%%%%%%%%%%%%%%%%%%%%%%%

ListOfObjects = fieldnames(handles.Measurements);
for i = 1:length(ListOfObjects)
    ListOfMeasurements = fieldnames(handles.Measurements.(char(ListOfObjects(i))));
    for ii = 1:length(ListOfMeasurements)

        if length(ListOfMeasurements{ii}) > 6 && ... 
                (not(strcmp(ListOfMeasurements{ii}(1,end-7:end),'Features')) || not(strcmp(ListOfMeasurements{ii}(1,end-3:end),'Text')))
            % we are not dealing with a ...Features or ...Text list

            OutPutFile = fullfile(strDataSorterOutputFolderPath, sprintf('%s%d_to_%d_Measurements_%s_%s',BatchFilePrefix,StartImage,EndImage,char(ListOfObjects(i)), char(ListOfMeasurements(ii))));
            matPossibleFeaturesIndex = strcmp(ListOfMeasurements, strcat(char(ListOfMeasurements(ii)),'Features'));
            matPossibleTextIndex = strcmp(ListOfMeasurements, strcat(char(ListOfMeasurements(ii)),'Text'));
            intFieldDescriptionIndex = [find(matPossibleFeaturesIndex), find(matPossibleTextIndex)];

            % init the output variable Measurements
            Measurements = struct();            

            % save MeasurementFields that do not have a DescriptionField as
            % listed in cellstrFieldsWithNoDescription
            if not(isempty(find(strcmp(cellstrFieldsWithNoDescription, char(ListOfMeasurements(ii))))))
                disp(sprintf('saving %s%d_to_%d_Measurements.%s.%s',BatchFilePrefix,StartImage,EndImage,char(ListOfObjects(i)), char(ListOfMeasurements(ii))))
                Measurements.(char(ListOfObjects(i))).(char(ListOfMeasurements(ii))) = handles.Measurements.(char(ListOfObjects(i))).(char(ListOfMeasurements(ii)));


                try
                    save(OutPutFile, 'Measurements');
                catch
                    OutPutFile = fullfile(strAlternativeOutputPath, sprintf('%s%d_to_%d_Measurements_%s_%s',BatchFilePrefix,StartImage,EndImage,char(ListOfObjects(i)), char(ListOfMeasurements(ii))));
                    save(OutPutFile, 'Measurements');            
                end        

            % also save all fieldnames
            elseif not(isempty(intFieldDescriptionIndex))
                disp(sprintf('saving %s%d_to_%d_Measurements.%s.%s and %s',BatchFilePrefix,StartImage,EndImage,char(ListOfObjects(i)), char(ListOfMeasurements(intFieldDescriptionIndex)), char(ListOfMeasurements(ii))))
                Measurements.(char(ListOfObjects(i))).(char(ListOfMeasurements(intFieldDescriptionIndex))) = handles.Measurements.(char(ListOfObjects(i))).(char(ListOfMeasurements(intFieldDescriptionIndex)));
                Measurements.(char(ListOfObjects(i))).(char(ListOfMeasurements(ii))) = handles.Measurements.(char(ListOfObjects(i))).(char(ListOfMeasurements(ii)));

                try
                    save(OutPutFile, 'Measurements');
                catch
%                     OutPutFile = fullfile(strAlternativeOutputPath, sprintf('%s%d_to_%d_Measurements_%s_%s',BatchFilePrefix,StartImage,EndImage,char(ListOfObjects(i)), char(ListOfMeasurements(ii))));
                    OutPutFile = fullfile(strAlternativeOutputPath, sprintf('Measurements_%s_%s',char(ListOfObjects(i)), char(ListOfMeasurements(ii))));                    
                    save(OutPutFile, 'Measurements');            
                end              
            end
            clear Measurements;
        end
    end
end

clear all