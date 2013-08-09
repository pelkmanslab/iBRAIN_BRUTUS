function cellstrFileName = findfilewithregexpi(strRootPath,strRegExp,boolFullPath)
%
% usage:
%
% cellstrFileName = findfilewithregexpi(strRootPath,strRegExp,boolFullPath)

if nargin==0
    strRootPath = '\\nas-biol-imsb-1.d.ethz.ch\share-2-$\Data\Users\Cameron\CHOL-LBPA_HELAMZ_QIAGEN_Druggable\CHOL-LBPA_HELAMZ_Batch_17-18_BSF002784x_CP517-1aa\BATCH';
    strRegExp = 'CHOL-LBPA_HELAMZ_.*.mat';
    boolFullPath = false;
end

if nargin<3
    boolFullPath = false;
end

% get directory content listing
cellTargetFolderList = CPdir(strRootPath)';
cellTargetFolderList([cellTargetFolderList.isdir]) = [];
cellTargetFolderList = {cellTargetFolderList.name}';

% get rid of non-"Well" directories
matMatch = ~cellfun(@isempty,regexpi(cellTargetFolderList,strRegExp));

% if one hit is found, return string, otherwise cell-array
if size(find(matMatch))==1
    cellstrFileName = cellTargetFolderList{matMatch};
else
    cellstrFileName = cellTargetFolderList(matMatch);
end

% convert to full path if requested
if boolFullPath && ~isempty(cellstrFileName)
    if iscell(cellstrFileName)
        cellstrFileName = cellfun(@(x) fullfile(strRootPath,x),cellstrFileName,'UniformOutput',false);
    else
        cellstrFileName = fullfile(strRootPath,cellstrFileName);
    end
end

end
