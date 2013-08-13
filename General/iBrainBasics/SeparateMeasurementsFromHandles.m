function SeparateMeasurementsFromHandles(handles,cluster)

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
    StartImage = handles.Current.BatchInfo.Start;
    EndImage = handles.Current.BatchInfo.End;
end

strDataSorterOutputFolderPath = handles.Current.DefaultOutputDirectory;
strAlternativeOutputPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\BATCHANALYSIS\070314_VSV_DG_batch1CP013-1aa\DataSorter';

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
        % also save all fieldnames
        elseif not(isempty(intFieldDescriptionIndex))
            disp(sprintf('saving %s%d_to_%d_Measurements.%s.%s and %s',BatchFilePrefix,StartImage,EndImage,char(ListOfObjects(i)), char(ListOfMeasurements(intFieldDescriptionIndex)), char(ListOfMeasurements(ii))))
            Measurements.(char(ListOfObjects(i))).(char(ListOfMeasurements(intFieldDescriptionIndex))) = handles.Measurements.(char(ListOfObjects(i))).(char(ListOfMeasurements(intFieldDescriptionIndex)));
            Measurements.(char(ListOfObjects(i))).(char(ListOfMeasurements(ii))) = handles.Measurements.(char(ListOfObjects(i))).(char(ListOfMeasurements(ii)));
        end

        try
            save(OutPutFile, 'Measurements');
        catch
            OutPutFile = fullfile(strAlternativeOutputPath, sprintf('%s%d_to_%d_Measurements_%s_%s',BatchFilePrefix,StartImage,EndImage,char(ListOfObjects(i)), char(ListOfMeasurements(ii))));
            save(OutPutFile, 'Measurements');            
        end
        
        clear Measurements;
    end
end


end % end function