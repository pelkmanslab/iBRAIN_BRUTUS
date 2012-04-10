disp(sprintf('%s: berend: randomizing rand initial state',which('startup.m')))
rand('twister',sum(100*clock))
setenv('OMP_NUM_THREADS','1')
set(0,'DefaultTextInterpreter','none')
%if ~isempty(strfind(version,'R2008a'));
% fprintf('%s: matlab version %s detected. Setting maxNumCompThreads(1).\n',which(mfilename),version)
% try
%  maxNumCompThreads(1);
% catch foo
%  disp foo
% end
%elseif ~isempty(strfind(version,'R2009a'))
%fprintf('%s: matlab version %s detected.\n',which(mfilename),version)
%end
%disp(sprintf('%s: berend: %d CPUs detected, using %s threads (max %d set by startup.m)',which('startup.m'),feature('numCores'),getenv('OMP_NUM_THREADS'),maxNumCompThreads))
disp(sprintf('%s: berend: %d CPUs detected, using %s threads',which('startup.m'),feature('numCores'),getenv('OMP_NUM_THREADS')))


% Set some standard warnings to off
warning off MATLAB:divideByZero
warning off MATLAB:log:LogOfZero
warning off all
fprintf('%s: disabling all warnings\n',mfilename)
