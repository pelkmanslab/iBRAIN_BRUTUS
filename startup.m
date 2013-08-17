disp(sprintf('%s: randomizing rand initial state',which('startup.m')))
rand('twister',sum(100*clock))
setenv('OMP_NUM_THREADS','1')
set(0,'DefaultTextInterpreter','none')
disp(sprintf('%s: %d CPUs detected, using %s threads',which('startup.m'),feature('numCores'),getenv('OMP_NUM_THREADS')))

% Set some standard warnings to off
warning off MATLAB:divideByZero
warning off MATLAB:log:LogOfZero
warning off all
fprintf('%s: disabling all warnings\n',mfilename)

ibrainroot = pwd;
if ~fileattrib([ibrainroot filesep 'etc' filesep 'config' ])
    disp(['Missing ibrainroot folder and/or etc/config: ' ibrainroot ])
else 
    [result, ibrain_matlab_path] = system(['IBRAINROOT=' ibrainroot ';. $IBRAINROOT/etc/config; if [ "$IBRAIN_MATLAB_PATH" == "" ];then exit 1;fi ; echo $IBRAIN_MATLAB_PATH']);
    ibrain_matlab_path = deblank(ibrain_matlab_path);
    if result ~= 0
        disp('Missing IBRAIN_MATLAB_PATH setting in your $IBRAINROOT/etc/config!')
    end
    if ~fileattrib([ibrainroot filesep 'pathdef.m']) && result == 0
        disp(['Missing ' ibrainroot filesep 'pathdef.m file; recreating it...'])

        % Add iBRAIN MATLAB code to path
        %ibrain_matlab_path = '~/code/dep';
        disp(['Resetting path and including subfolders of (as well as sibling repositories if found): ' ibrain_matlab_path])
        addpath(ibrain_matlab_path);
        resetpath();
        disp('done.')
         

        % Add some other matlab folders (note ~/matlab added anyway).
        
        % Save file.
        pathdef_file = fullfile(ibrainroot, 'pathdef.m');
        disp(['Saving path into: ' pathdef_file])
        savepath(pathdef_file);
    end
end

clear all;

% Prepend compiled tlbxs
cmt.load();

