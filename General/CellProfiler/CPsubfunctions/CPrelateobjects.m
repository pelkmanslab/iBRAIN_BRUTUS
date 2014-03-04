function [handles,ChildList,FinalParentList] = CPrelateobjects(handles,ChildName,ParentName,ChildLabelMatrix,ParentLabelMatrix,ModuleName)

% CellProfiler is distributed under the GNU General Public License.
% See the accompanying file LICENSE for details.
%
% Developed by the Whitehead Institute for Biomedical Research.
% Copyright 2003,2004,2005.
%
% Authors:
%   Anne E. Carpenter
%   Thouis Ray Jones
%   In Han Kang
%   Ola Friman
%   Steve Lowe
%   Joo Han Chang
%   Colin Clarke
%   Mike Lamprecht
%   Peter Swire
%   Rodrigo Ipince
%   Vicky Lay
%   Jun Liu
%   Chris Gang
%
% Website: http://www.cellprofiler.org
%
% $Revision: 2802 $

%%% This line creates two rows containing all values for both label matrix
%%% images. It then takes the unique rows (no repeats), and sorts them
%%% according to the first column which is the sub object values.
try ChildParentList = sortrows(unique([ChildLabelMatrix(:) ParentLabelMatrix(:)],'rows'),1);
catch
    %%% For the cases where the ChildLabelMatrix was produced from a
    %%% cropped version of the ParentLabelMatrix, the sizes of the matrices
    %%% will not be equal, so the line above will fail. So, we crop the
    %%% ParentLabelMatrix and try again to see if the matrices are then the
    %%% proper size.
    %%% Removes Rows and Columns that are completely blank.
    ColumnTotals = sum(ParentLabelMatrix,1);
    RowTotals = sum(ParentLabelMatrix,2)';
    warning off all
    ColumnsToDelete = ~logical(ColumnTotals);
    RowsToDelete = ~logical(RowTotals);
    warning on all
    drawnow
    CroppedParentLabelMatrix = ParentLabelMatrix;
    CroppedParentLabelMatrix(:,ColumnsToDelete,:) = [];
    CroppedParentLabelMatrix(RowsToDelete,:,:) = [];
        %%% In case the entire image has been cropped away, we store a single
    %%% zero pixel for the variable.
    if isempty(CroppedParentLabelMatrix)
        CroppedParentLabelMatrix = 0;
    end
    %%% And we try the original line again.
    try ChildParentList = sortrows(unique([ChildLabelMatrix(:) CroppedParentLabelMatrix(:)],'rows'),1);
        clear ParentLabelMatrix
        ParentLabelMatrix = CroppedParentLabelMatrix;
    catch error(['Image processing was canceled in the ',ModuleName, ' module because the parent and children objects you are trying to relate come from images that are not the same size.'])
    end
end

    %%% We want to get rid of the children values and keep the parent values.
ParentList = ChildParentList(:,2);
%%% This gets rid of all parent values which have no corresponding children
%%% values (where children = 0 but parent = 1).
for i = 1:max(ChildParentList(:,1))
    ParentValue = max(ParentList(ChildParentList(:,1) == i));
    if isempty(ParentValue)
        ParentValue = NaN;%hack: 2014/02/07 [MH] changed from 0 to NaN
    end
    FinalParentList(i,1) = ParentValue;
end

if exist('FinalParentList','var')
    if max(ChildLabelMatrix(:)) ~= size(FinalParentList,1)
        error(['Image processing was canceled in CPrelateobjects, a subfunction used by the ',ModuleName,' module, because objects cannot have two parents, something is wrong.']);
    end
    handles = CPaddmeasurements(handles,ChildName,'Parent',ParentName,FinalParentList);
else
    handles = CPaddmeasurements(handles,ChildName,'Parent',ParentName,0);
end

for i = 1:max(ParentList)
    if exist('FinalParentList','var')
        ChildList(i,1) = length(FinalParentList(FinalParentList == i));
    else
        ChildList(i,1) = 0;
    end
end

if exist('ChildList','var')
    handles = CPaddmeasurements(handles,ParentName,'Children',ChildName,ChildList);%hack: 2014/01/03 [MH] 'Count' removed (resulted in problems finding children objects later)
else
    handles = CPaddmeasurements(handles,ParentName,'Children',ChildName,0);
    ChildList = 0;
end

if ~exist('FinalParentList','var')
    FinalParentList = 0;
end