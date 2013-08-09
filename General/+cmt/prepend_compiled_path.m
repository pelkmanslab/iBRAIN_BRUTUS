function prepend_compiled_path()
%PREPEND_COMPILED_PATH Prepend compiled path to MATLAB path
%   Function fill discover the path of +cmt package

    compiled_path = [strrep(cmt.get_path(), ['+cmt' filesep],'') 'Compiled'];
    the_path = create_path(compiled_path, {}); % no ignore dirs
    addpath(the_path);
end

