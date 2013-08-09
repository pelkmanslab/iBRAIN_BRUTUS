function result = strformat(pattern, params)
%STRFORMAT PATTERN PARAMS
%  Usage example
%
%         plato.strformat([...
%             'This is a multiline message:\n', ...
%             '  message = {message}'], ...
%             struct('message', 'hi!') ...
%         )
%     
%         plato.strformat([...
%             'This is a multiline message:\n', ...
%             '  message = {0}'], ...
%             {'hi!'} ...
%         );

        
    result = replace_special_symbols(pattern);
    
    % Replace params.       
    if (nargin == 1) || (numel(params) == 0)
        return
    end

    if isstruct(params)
        keys = fieldnames(params);
        for index = 1:numel(keys)
            key = keys{index};
            value = params.(key);            
            result = strrep(result, ['{' key '}'], stringify(value));
        end
    elseif iscell(params)
        keys = 1:numel(params);
        for key = keys
            value = params{key};
            result = strrep(result, ['{' key '}'], stringify(value));
        end
    else
        error(mfilename, ['Params should be a cell array ', ...
              'or a struct.']);
    end

end

function outstr = replace_special_symbols(instr)
    % Also replace all \n
    persistent NEWLINE;
    if isempty(NEWLINE)
        NEWLINE = sprintf('\n');
    end   
    
    outstr = strrep(instr, '\n', NEWLINE);
end

function out = stringify(value)
    out = value;
    if isnumeric(value)
        out = num2str(value);
    end
end