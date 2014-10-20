function matrix = tokens2num(cellArray_regexpTokensOutput)

% TOKENS2NUM converts output of regexp.m with 'tokens' 
% to numerical array.

if size(cellArray_regexpTokensOutput, 1)
    cellArray = cell2cell(cellArray_regexpTokensOutput);
else
    cellArray = cell2cell(cell2cell(cellArray_regexpTokensOutput)');
end

if iscell(cellArray)
    matrix = cellfun(@(x) str2num(x), cellArray);
else
    matrix = str2double(cellArray);
end

end