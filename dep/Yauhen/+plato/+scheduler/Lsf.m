classdef Lsf
    %LSF Scheduler implementation for Platform LSF cluster.
    %   SUBMIT(CODE, ARGUMENTS, OPTIONS)
    %
    %   OPTIONS is a struct of submission options for LSF cluster 
    %
    %   ARGUMENTS is a cell or struct of arguments substituted into the
    %   code string.
    %
    %   CODE is string with a MATLAB code
    %
    %   See plato.strformat
    
    
    properties        
    end
    
    methods
        function [status,result] = submit(self, code, arguments, options)
            if nargin <= 3
                options = struct(...
                    'queue', '1:00', ...
                    'memory', '2048', ... % MB
                    'useLustre', 0, ...
                    'verbose', 1, ...
                    'matlabCommand', 'bmatlab' ...
                );
            else
                error(mfilename, 'Not enough arguments');
            end
            
            import plato.strformat;
            
            formattedCode = strformat(code, arguments);
            
            header = strformat([...
                    'bsub -W {queue} -R "rusage[mem={memory}]" <<EOS;\n' ...
                    '{matlabCommand} <<M_PROG;\n'], ...
                    options);
            submissionCommand = [header formattedCode strformat('M_PROG\nEOS')];
            
            if options.verbose
                [status,result] = system(submissionCommand, '-echo');
            else
                [status,result] = system(submissionCommand);
            end
            
        end
    end
    
end

