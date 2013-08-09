function TrainingData = mergeTrainingData(TrainingData, strFileName)

% % %     if nargin==0
% % %         load('\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\070111_SV40_MZ_MZ_P3_1_2\ProbModel_TrainingDataValues.mat');
% % %         strFileName = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\070111_SV40_MZ_MZ_P3_1_3\ProbModel_TrainingDataValues.mat';
% % %     end
    
    if not(isstruct(TrainingData))
        error('mergeTrainingData: TrainingData should be a valid structure variable.')
        return
    end
    
    try
        tempTrainingData = load(strFileName);
    catch
        error(['mergeTrainingData: Unable to load ', strFileName]);        
    end
    
    if isfield(tempTrainingData, 'TrainingData')
        tempTrainingData = tempTrainingData.TrainingData;
    elseif not(isfield(tempTrainingData, 'TrainingData'))
        error('mergeTrainingData: Input file does not contain TrainingData');
        return
    end
    
    % make input TrainingData as basis for the newTrainingData
    newTrainingData = TrainingData;
    
        
    if not(isa(newTrainingData, 'struct'))
        error('mergeTrainingData: Input TrainingData should be a struct');
    else
        ListOfObjects = fieldnames(tempTrainingData);
        for i = 1:length(ListOfObjects)
            if not(isfield(newTrainingData.(char(ListOfObjects(i))),'Data'))
%                 newTrainingData.(char(ListOfObjects(i)))
%                 tempTrainingData.(char(ListOfObjects(i)))
                
                % if the first field wasn't already present we can add it as is
                newTrainingData.(char(ListOfObjects(i))).Data = tempTrainingData.(char(ListOfObjects(i))).Data;
                newTrainingData.(char(ListOfObjects(i))).Min = tempTrainingData.(char(ListOfObjects(i))).Min;
                newTrainingData.(char(ListOfObjects(i))).Max = tempTrainingData.(char(ListOfObjects(i))).Max;
                newTrainingData.(char(ListOfObjects(i))).BinEdges = tempTrainingData.(char(ListOfObjects(i))).BinEdges;
                newTrainingData.(char(ListOfObjects(i))).Bins = tempTrainingData.(char(ListOfObjects(i))).Bins;
                newTrainingData.(char(ListOfObjects(i))).Histogram = tempTrainingData.(char(ListOfObjects(i))).Histogram;
%                 disp('making new Data field')
            else

                if newTrainingData.(char(ListOfObjects(i))).Min == tempTrainingData.(char(ListOfObjects(i))).Min & ...
                        newTrainingData.(char(ListOfObjects(i))).Max == tempTrainingData.(char(ListOfObjects(i))).Max & ...
                        newTrainingData.(char(ListOfObjects(i))).BinEdges == tempTrainingData.(char(ListOfObjects(i))).BinEdges & ...
                        newTrainingData.(char(ListOfObjects(i))).Bins == tempTrainingData.(char(ListOfObjects(i))).Bins
                
                    % merge Data fields
                    newTrainingData.(char(ListOfObjects(i))).Data = [newTrainingData.(char(ListOfObjects(i))).Data;tempTrainingData.(char(ListOfObjects(i))).Data];

                    % add Histogram fields
                    newTrainingData.(char(ListOfObjects(i))).Histogram = newTrainingData.(char(ListOfObjects(i))).Histogram + tempTrainingData.(char(ListOfObjects(i))).Histogram;
                else
                    error('mergeTrainingData: Input TrainingData do not have similar minima/maxima/binedges');
                end

            end
        end
    end
    % return the newTrainingData
    TrainingData = newTrainingData;
end