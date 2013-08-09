function resetpath()
%RESETPATH Call me after every svn update.

if ~exist('labrep.resetPath')
    % PATH environment is broken. Trying to reconstruct it.
    labrepPath = which(mfilename);
    restoredefaultpath();       
    labrepPath = fullfile(labrepPath(1:end-11), 'General');
    path([
        labrepPath pathsep ...
        fullfile(labrepPath, 'Upsilon')], path);
end
labrep.resetPath();
end