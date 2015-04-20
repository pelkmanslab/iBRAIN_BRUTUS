function TrainingData = mergeTrainingDataEdges(strRootPath,TrainingData)

    Current = load(fullfile(strRootPath,'ProbModel_TrainingDataEdges.mat'));

    TrainingDataFieldnames = fieldnames(Current.TrainingData);
    
    % remove settings from being merged...
    TrainingDataFieldnames(strcmp(TrainingDataFieldnames, 'settings')) = [];
    
    for i = 1:length(TrainingDataFieldnames)
        strCurrentFieldName = char(TrainingDataFieldnames{i});

%         disp(sprintf('current %s min = %f',strCurrentFieldName,Current.TrainingData.(strCurrentFieldName).Min))
%         disp(sprintf('current %s max = %f',strCurrentFieldName,Current.TrainingData.(strCurrentFieldName).Max))        
        
        if ~isfield(TrainingData,strCurrentFieldName)
            TrainingData.(strCurrentFieldName).Min = Inf;                                            
            TrainingData.(strCurrentFieldName).Max = -Inf;
        end
        
        TrainingData.(strCurrentFieldName).Min = min(Current.TrainingData.(strCurrentFieldName).Min, TrainingData.(strCurrentFieldName).Min);
        TrainingData.(strCurrentFieldName).Max = max(Current.TrainingData.(strCurrentFieldName).Max, TrainingData.(strCurrentFieldName).Max);
        
        TrainingData.(strCurrentFieldName).BoolIntegerData = Current.TrainingData.(strCurrentFieldName).BoolIntegerData;
        
    end
end