function handles = UnLoadCP3DStack(handles)

% Help for the UnLoadCP3D module:
% Category: File Processing
%
% SHORT DESCRIPTION:
% Will set image to an empty matrix
% 
% *************************************************************************
%
% Website: http://www.cellprofiler.org
%
% $Revision: 1879 $

%%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%%


drawnow

[CurrentModule, CurrentModuleNum, ModuleName] = CPwhichmodule(handles);


%textVAR01 = Which images do you want to load into memory?
%infotypeVAR01 = imagegroup
StackName = char(handles.Settings.VariableValues{CurrentModuleNum,1});
%inputtypeVAR01 = popupmenu

%textVAR02 = 

%%%VariableRevisionNumber = 1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRELIMINARY ERROR CHECKING & FILE HANDLING %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % set to empty
handles.Pipeline.(StackName) = [];



end