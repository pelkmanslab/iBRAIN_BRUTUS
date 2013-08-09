function handles = LoadMeasurements(handles, strFileName)

    if not(isstruct(handles))
        error('LoadMeasurements: Handles should be a valid structure variable.')
        return
    end
    
    try
        tempHandles = load(strFileName);
    catch
        error(['LoadMeasurements: Unable to load ', strFileName]);        
    end
    
    if isfield(tempHandles, 'handles') && isfield(tempHandles.handles, 'Measurements') 
        tempHandles.Measurements = tempHandles.handles.Measurements;
        tempHandles = rmfield(tempHandles,'handles');
%         disp('removed handles from loaded file...')
    elseif not(isfield(tempHandles, 'Measurements'))
        error('LoadMeasurements: Input file does not contain a Measurements field');
        return
    end
    
    newHandles = handles;
%     disp(['LoadMeasurements: loaded ', strFileName]);        
        
    if not(isfield(newHandles, 'Measurements'))
        % if the struct didnt have any Measurements field, dump everything in as
        % is, we will not overwrite anything.
        newHandles.Measurements = tempHandles.Measurements;
%         disp('copying handles.Measurements')
    else
        ListOfObjects = fieldnames(tempHandles.Measurements);
        for i = 1:length(ListOfObjects)
            if not(isfield(newHandles.Measurements, ListOfObjects(i)))
                % if the first field wasn't already present we can add it as is
                newHandles.Measurements.(char(ListOfObjects(i))) = tempHandles.Measurements.(char(ListOfObjects(i)));
%                 disp(sprintf('copying handles.Measurements.%s',(char(ListOfObjects(i)))))
            else
                % else we need to look for fields inside the
                % Measurements.ObjectField which weren't already present
                ListOfMeasurements = fieldnames(tempHandles.Measurements.(char(ListOfObjects(i))));
                for ii = 1:length(ListOfMeasurements)
                    % check if measurement was already present, if so, only
                    % fill in the measurements that are present in this
                    % particular measurement file (COMPATIBILITY WITH PARTIAL CLUSTER RESULT FILES)
  
                    if not(isfield(newHandles.Measurements.(char(ListOfObjects(i))), ListOfMeasurements(ii) ))
%                         disp(sprintf('copying handles.Measurements.%s.%s',(char(ListOfObjects(i))),char(ListOfMeasurements(ii))))
                        newHandles.Measurements.(char(ListOfObjects(i))).(char(ListOfMeasurements(ii))) = tempHandles.Measurements.(char(ListOfObjects(i))).(char(ListOfMeasurements(ii)));
                    else

                        % find measurements indices that are present, and
                        % only fill in those..
                        if iscell(tempHandles.Measurements.(char(ListOfObjects(i))).(char(ListOfMeasurements(ii))))
                            % for cells
                            matMeasurementIndexes = find(~cellfun('isempty',tempHandles.Measurements.(char(ListOfObjects(i))).(char(ListOfMeasurements(ii)))));
                            for iii = 1:length(matMeasurementIndexes)
                                newHandles.Measurements.(char(ListOfObjects(i))).(char(ListOfMeasurements(ii))){matMeasurementIndexes(iii)} = tempHandles.Measurements.(char(ListOfObjects(i))).(char(ListOfMeasurements(ii))){matMeasurementIndexes(iii)};
                            end
    %                         disp(sprintf('filled %s with %d new measurements',char(ListOfMeasurements(ii)),length(matMeasurementIndexes)))                                                 
                        else
                            % for matrices (OutOfFocus exception... perhaps not smart?)
                            matMeasurementIndexes = find(tempHandles.Measurements.(char(ListOfObjects(i))).(char(ListOfMeasurements(ii))));
                            newHandles.Measurements.(char(ListOfObjects(i))).(char(ListOfMeasurements(ii)))(matMeasurementIndexes) = tempHandles.Measurements.(char(ListOfObjects(i))).(char(ListOfMeasurements(ii)))(matMeasurementIndexes);
                        end
                    end

                end
            end
        end
    end
    handles = newHandles;
end