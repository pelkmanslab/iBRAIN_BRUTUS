function test_bypass()
%TEST_BYPASS Summary of this function goes here
%   Detailed explanation goes here

    cmt.prepend_compiled_path();

    function_list = cmt.get_functions();

    for ix = 1:length(function_list) 
        funcname = function_list{ix};
        try
            %t = timer('TimerFcn',@close_everything, 'StartDelay', 1);
            %start(t);
            disp(funcname)
            eval(funcname); 
            %delete(t);
        catch exception
            %disp(exception)
        end
        if length(license('inuse')) > 1
            disp('The following function failed to be bypassed: ')
            disp(funcname)
            return
        end
    end

end

function close_everything(x, y)
    close all hidden;
end