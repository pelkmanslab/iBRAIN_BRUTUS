function [ TiffFiles, TiffPath ] = getImages( projectPath )
%GETIMAGES get images for registration
%   Detailed explanation goes here


%%% get subproject folders
ProjFolder = CPdir(projectPath);
ProjFolder = {ProjFolder(logical([ProjFolder.isdir] & cell2mat(cellfun(@(x)length(x)>2,{ProjFolder.name},'UniformOutput',false)))).name};
SubprojPath = cellfun(@(x)fullfile(projectPath,x),ProjFolder,'UniformOutput',false);

%%% get image filenames for each subproject
TiffPath = cellfun(@(x)fullfile(x,'TIFF'),SubprojPath,'UniformOutput',false);
TiffFolder = cellfun(@CPdir,TiffPath,'UniformOutput', false);
TiffFiles = cellfun(@(x){x(~logical([x.isdir])).name},TiffFolder,'UniformOutput',false);
TiffFiles = cellfun(@(x)flatten(regexpi(x,'.*(C|w)\d{2}\.(png|tiff?)','match')),TiffFiles,'UniformOutput',false);
% check microscope type
[~,MicroscopeType] = check_image_position(TiffFiles{1}{1});
if strcmpi(MicroscopeType,'NIKON')
    FilenameNomenclature = 'NIKON.*_t\d{1,}(_z\d{1,}_|_)[A-Z]\d{2,3}_s\d{1,}_w\d{1,}[^\.]*\.(tiff?|png)';
elseif strcmpi(MicroscopeType,'CV7K')
    FilenameNomenclature = '.*_([^_]{3})_(T\d{4})(F\d{3})(L\d{2})(A\d{2})(Z\d{2})(C\d{2})*\.(tiff?|png)';
else
    error('No ''NIKON'' or ''CV7K'' files found')
end
% get only images that match microscope nomenclature
TiffFiles = cellfun(@(x)sort(flatten(regexpi(x,FilenameNomenclature,'match'))),TiffFiles,'UniformOutput',false);


end

