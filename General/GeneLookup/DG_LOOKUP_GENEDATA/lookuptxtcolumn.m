function [intColumnNumber, cellTxtColumn] = lookuptxtcolumn(txt,strColumnHeader)
% help for lookuptxtcolumn()
% searchs for cellstr datasets in the header for a strmatch and returns the
% corresponding column and columnnumber including header.
%
% usage:
%   [intColumnNumber, cellTxtColumn] = lookuptxtcolumn(txt,strColumnHeader)


    cellTxtColumn = {};
    intColumnNumber = 0;
    
    [foo, intColumnNumber] = find(~cellfun('isempty',strfind(cellstr(txt),strColumnHeader)));
    x = find(foo == 1);
    if not(isempty(x))
        intColumnNumber = intColumnNumber(x(1));
        cellTxtColumn = cellstr(txt(:,intColumnNumber));
    end
end