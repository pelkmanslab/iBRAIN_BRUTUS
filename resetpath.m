function resetpath(varargin)
%RESETPATH Call me after every svn update.

% Take care of optional arguments.
dontSave = false;
if nargin == 1
    dontSave = varargin{1};
end

if ~exist('labrep.resetPath')
    % PATH environment is broken. Trying to reconstruct it.
    labrepPath = which(mfilename);
    restoredefaultpath();
    labrepPath = fullfile(labrepPath(1:end-11), 'General');
    path([
        labrepPath pathsep ...
        fullfile(labrepPath, 'Upsilon')], path);
end
labrep.resetPath(dontSave);
end
