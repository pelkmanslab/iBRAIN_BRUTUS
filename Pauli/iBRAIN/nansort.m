%  NANSORT   Sort in ascending or descending order and removes NaN's and inf's.
%     For vectors, SORT(X) sorts the elements of X in ascending order.
%     For matrices, SORT(X) sorts each column of X in ascending order.
%     For N-D arrays, SORT(X) sorts the along the first non-singleton
%     dimension of X. When X is a cell array of strings, SORT(X) sorts
%     the strings in ASCII dictionary order.
%  
%     Y = SORT(X,DIM,MODE)
%     has two optional parameters.  
%     DIM selects a dimension along which to sort.
%     MODE selects the direction of the sort
%        'ascend' results in ascending order
%        'descend' results in descending order
%     The result is in Y which has the same shape and type as X.
%  
%     [Y,I] = SORT(X,DIM,MODE) also returns an index matrix I.
%     If X is a vector, then Y = X(I).  
%     If X is an m-by-n matrix and DIM=1, then
%         for j = 1:n, Y(:,j) = X(I(:,j),j); end
%  
%     When X is complex, the elements are sorted by ABS(X).  Complex
%     matches are further sorted by ANGLE(X).
%  
%     When more than one element has the same value, the order of the
%     elements are preserved in the sorted result and the indexes of
%     equal elements will be ascending in any index matrix.
%  
%     Example: If X = [3 7 5
%                      0 4 2]
%  
%     then nansort(X,1) is [0 4 2  and nansort(X,2) is [3 5 7
%                           3 7 5]                      0 2 4];
%  
%     See also issorted, sortrows, min, max, mean, median, unique.
% 
%     Overloaded methods:
%        cell/sort
%        ordinal/sort
%        sym/sort
% 
%     Reference page in Help browser
%        doc sort


function [out1,out2]=nansort(in1,in2,in3)

bad=find(isnan(in1)|isinf(in1));

if nargin==1
    [out1,out2]=sort(in1);
elseif nargin==2
    [out1,out2]=sort(in1,in2);
elseif nargin==3
    [out1,out2]=sort(in1,in2,in3);
end

remove=ismember(out2,bad);
out1(remove)=[];
out2(remove)=[];
