function [ path ] = getIJPath()
%GETIJPATH Return path of the mij package. 
%   Path contians ImageJ plugins and macros folder.

path = [regexprep(mfilename('fullpath'), ['\' filesep '[\w\.]*$'],'') filesep];

end
