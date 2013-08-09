function [bnIsAllowed evalStr] = inputVectorsForEvalCP3D(Str,varargin)
% [bnIsAllowed evalStr] = inputVectorsForEvalCP3D(Str,varargin)
% checks string, which should be eval'ed, for absence of characters of
% whitelist. optional second input argument can be TRUE/FALSE to indicate
% whether NaN should be allowed - default is FALSE. 
%
% BNISALLOWED is TRUE or FALSE and indicates whether string is allowed
% EVALSTRING is (reformatted> add [ and ]) STR to evaluate. In case of non
% allowed STR, EVALSTRING will be empty


switch nargin
    case 1
        bnAllowNaN = false;
    case 2
        bnAllowNaN = varargin{1};
    otherwise
        error('Number of input arguments not correct');
end

allowedChar = ismember(Str,'0123456789.,:[] ');
if bnAllowNaN == true;
    NaNStart = strfind(Str,'NaN');
    if any(NaNStart)
        allowedChar(NaNStart)= true;
        allowedChar(NaNStart+1)= true;
        allowedChar(NaNStart+2)= true;
    end
end

if any(~allowedChar) == true
    bnIsAllowed = false;
    evalStr = [];           % report empty string to eval so that bad code does not get accidentally eval'ed
else
    bnIsAllowed = true;
    evalStr = Str;    
    if evalStr(1) ~= '['         % reformat: add square brackets
        evalStr = ['[' evalStr];
    end
    if evalStr(end) ~= ']'
        evalStr = [evalStr ']'];
    end
end   
    
end