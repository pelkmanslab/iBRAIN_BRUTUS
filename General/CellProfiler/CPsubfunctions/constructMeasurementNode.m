function measurementNode = constructMeasurementNode(measurementNode,measurementData, measurementName)
     if isfield(measurementNode,'measurementField')<1
        measurementNode.('measurementField') = cell(0);
    end
    
    if isfield(measurementNode,measurementName)<1
        measurementNode.(measurementName) = struct;
        measurementNode.(measurementName).('fieldNames') = cell(0);
        measurementNode.measurementField{end+1} = measurementName;
    else
     if isfield( measurementNode.(measurementName), 'fieldNames' )<1
        measurementNode.(measurementName).('fieldNames') = cell(0); 
      end
    end



%      measurementNode.(measurementName).fieldNames = cell(0);
    
    if length(measurementData)>0
        measurementNode.(measurementName).('meanValue') = mean(measurementData);
        measurementNode.(measurementName).fieldNames{end+1} ='mean';
    
        measurementNode.(measurementName).('medianValue') = median(measurementData);
        measurementNode.(measurementName).fieldNames{end+1} =  'median';
    
        measurementNode.(measurementName).('stdValue') = std(measurementData);
        measurementNode.(measurementName).fieldNames{end+1} = 'std';
    
        measurementNode.(measurementName).('varianceValue') = var(measurementData);
        measurementNode.(measurementName).fieldNames{end+1} =  'variance';
    
        measurementNode.(measurementName).('skewnessValue') = skewness(measurementData);
        measurementNode.(measurementName).fieldNames{end+1} =  'skewness';
    
        measurementNode.(measurementName).('kurtosisValue') = kurtosis(measurementData);
        measurementNode.(measurementName).fieldNames{end+1} =  'kurtosis';
    
        measurementNode.(measurementName).('CVValue') = std(measurementData) /mean(measurementData) ;
        measurementNode.(measurementName).fieldNames{end+1} =  'CV';
    
        measurementNode.(measurementName).('indxDispersionValue') = std(measurementData)^2 /mean(measurementData) ;
        measurementNode.(measurementName).fieldNames{end+1} =  'indxDispersion';
    
    
    else
        
        measurementNode.(measurementName).('meanValue') = NaN;
        measurementNode.(measurementName).fieldNames{end+1} ='mean';
    
        measurementNode.(measurementName).('medianValue') = NaN;
        measurementNode.(measurementName).fieldNames{end+1} =  'median';
    
        measurementNode.(measurementName).('stdValue') = NaN;
        measurementNode.(measurementName).fieldNames{end+1} = 'std';
    
        measurementNode.(measurementName).('varianceValue') = NaN;
        measurementNode.(measurementName).fieldNames{end+1} =  'variance';
    
        measurementNode.(measurementName).('skewnessValue') = NaN;
        measurementNode.(measurementName).fieldNames{end+1} =  'skewness';
    
        measurementNode.(measurementName).('kurtosisValue') = NaN;
        measurementNode.(measurementName).fieldNames{end+1} =  'kurtosis';
    
        measurementNode.(measurementName).('CVValue') = NaN ;
        measurementNode.(measurementName).fieldNames{end+1} =  'CV';
    
        measurementNode.(measurementName).('indxDispersionValue') = NaN ;
        measurementNode.(measurementName).fieldNames{end+1} =  'indxDispersion';
    

        
    end
    
    %measurementNode.measurementField{end+1} = measurementName;
