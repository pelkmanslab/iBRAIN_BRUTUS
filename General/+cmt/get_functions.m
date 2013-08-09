function [ function_list ] = get_functions()
%GET_FUNCTIONS Get a list of bypassed functions


    load([cmt.get_path() filesep 'saved_funclist.mat']);
    function_list = saved_funclist;
    return
    
%     function_list = {
%         'imfill'
%         'regionprops'
%         'bwlabel'
%         'labelmatrix'        
%     };
%     return

    function_list = read_list([cmt.get_path() filesep 'funclist' filesep 'images']);

    ignore_list = {        
        % display
        'colorbar'
        'image'
        'imagesc'
        'immovie'
        'implay'
        'imshow'
        'imtool'
        'montage'
        'movie'
        'subimage'
        'warp'
        % other
        'cpselect'
        'imagemodel'
    };

    filtered = {};
    for ix = 1:length(function_list)
       funcname = function_list{ix};
       if find(ismember(ignore_list, funcname)==1)
           continue
       end
       filtered{end + 1} = funcname;
    end
    function_list = filtered;
end

function funclist = read_list(filename)
    [status, funclist] = system(['cat ' filename ' | head -n -2| awk ''/%   [a-z]/ {print $2}''']);
    funclist = strsplit(funclist);
end