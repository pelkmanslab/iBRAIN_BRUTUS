function SeparateMeasurementsFromHandles_new(handles,strOutputPath)

    % check if handles.Measurements exists
    if not(isfield(handles, 'Measurements'))
       error('SeparateMeasurementsFromHandles: Handles does not contain any Measurements') 
       return
    end

    if nargin < 2
        strOutputPath = handles.Current.DefaultOutputDirectory;
    end

    ListOfObjects = fieldnames(handles.Measurements); 

    for i = 1:length(ListOfObjects)

        ListOfMeasurements = fieldnames(handles.Measurements.(ListOfObjects{i}));

        for ii = 1:length(ListOfMeasurements)

            OutPutFile = fullfile(strOutputPath, sprintf('Measurements_%s_%s.mat',char(ListOfObjects(i)), char(ListOfMeasurements(ii))));

            % init the output variable Measurements
            Measurements = struct();            

            % save MeasurementFields 
            disp(sprintf('saving Measurements.%s.%s',char(ListOfObjects(i)), char(ListOfMeasurements(ii))))
            Measurements.(char(ListOfObjects(i))).(char(ListOfMeasurements(ii))) = handles.Measurements.(char(ListOfObjects(i))).(char(ListOfMeasurements(ii)));
            save(OutPutFile, 'Measurements');%,'-v7.3'               

            clear Measurements;

        end
    end


end % end function