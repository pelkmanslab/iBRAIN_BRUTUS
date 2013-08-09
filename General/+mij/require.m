function require
% MIJ.REQUIRE will load and prepare the ImageJ environment. 
%   Function checks if MIJ class is already known, otherwise corresponding 
%   JARs would be added to the java classpath.
%

    if exist('MIJ', 'class')
        % Class exists, skip adding jars step.
        return
    end

    % Find path to +mij folder
    prefix = mij.getIJPath();
    % Add jars
    javaaddpath([prefix 'mij.jar']);
    javaaddpath([prefix 'ij.jar']);

end