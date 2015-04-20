function OutputImage = CPdilatebinaryobjects(InputImage, NumericalObjectDilationRadius)

% This filter acts as if we had dilated each object by a certain number of
% pixels prior to making the projection. It is faster to do this
% convolution when the entire projection is completed rather than dilating
% each object as each image is processed.
%
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
% $Revision: 4076 $

if  NumericalObjectDilationRadius ~= 0
    StructuringElement = fspecial('gaussian',3*NumericalObjectDilationRadius,NumericalObjectDilationRadius);
    OutputImage = filter2(StructuringElement,InputImage,'same');
end