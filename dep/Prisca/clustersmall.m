function T = cluster(Z, varargin)
%CLUSTER Construct clusters from a hierarchical cluster tree.
%   T = CLUSTER(Z,'Cutoff',C) constructs clusters from the hierarchical
%   cluster tree represented by Z.  Z is a (M-1)-by-3 matrix, generated by
%   LINKAGE.  C is a threshold for defining clusters.  Starting from the
%   root, CLUSTER steps down through the tree until it encounters a node
%   whose inconsistent value (see INCONSISTENT) is less than C, and whose
%   descendants' values are all less than C.  All leaves below that node
%   are grouped into a cluster (a singleton if the node itself is a leaf).
%   CLUSTER follows every branch in the tree until all leaf nodes are in
%   clusters. T is a vector of length M containing the cluster number for
%   each of the M observations in the original data.  If C is a vector,
%   T is a matrix of cluster assignments with one column per cutoff value.
%
%   T = CLUSTER(Z,'Cutoff',C,'Depth',D) evaluates inconsistent values by
%   looking to a depth D below each node.  The default depth is 2.
%
%   T = CLUSTER(Z,'Cutoff',C,'Criterion','distance') uses distance as the
%   criterion for forming clusters.  Each node's height in the tree
%   represents the distance between the two subnodes merged at that
%   node.  All leaves below any node whose height is less than C are
%   grouped into a cluster (a singleton if the node itself is a leaf).
%
%   T = CLUSTER(Z,'Cutoff',C,'Criterion','inconsistent') is equivalent to
%   CLUSTER(Z,'Cutoff',C).
%
%   T = CLUSTER(Z,'MaxClust',N) constructs a maximum of N clusters using
%   distance as a criterion.  Each node's height in the tree represents the
%   distance between the two subnodes merged at that node.  CLUSTER finds
%   the smallest height at which a "horizontal cut" through the tree will
%   leave N or fewer clusters.  If N is a vector, T is a matrix of cluster
%   assignments with one column per maximum value.
%
%   Example:  Compare clusters from Fisher iris data with species
%      load fisheriris
%      d = pdist(meas);
%      z = linkage(d);
%      c = cluster(z,'maxclust',5);
%      crosstab(c,species)
%
%   See also PDIST, LINKAGE, COPHENET, INCONSISTENT, CLUSTERDATA.
   
%   Obsolete syntax: T = CLUSTER(Z, CUTOFF, DEPTH, FLAG).  If FLAG is
%   'clusters', CUTOFF is interpreted as the maximum number of clusters
%   to create.  If FLAG is 'inconsistent', CLUSTER splits nodes whose
%   inconsistent values are greater than CUTOFF.  If FLAG is 'distance',
%   CLUSTER splits nodes whose distance values are greater than CUTOFF.
    
%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.13.4.6 $   $Date: 2009/11/05 17:02:20 $
 
if nargin < 2
   error('stats:cluster:TooFewInputs','Not enough input arguments.');
end

% Try to verify that the first input is a tree
if ~(isnumeric(Z) && size(Z,2)==3 && ndims(Z)==2 ...
                  && all(all(Z(:,1:2)==round(Z(:,1:2)))))
    error('stats:cluster:BadTree',...
          'Z must be a hierarchical tree as computed by the linkage function.');
end

depth = 2;
criterion = 'inconsistent';
maxclust = Inf;
cutoff = NaN; 
inconsistent_set=0;
usecutoff = true;   % use cutoff rather than maxclust

% For backward compatibility, handle older syntax
if ~ischar(varargin{1})
   cutoff = varargin{1};
   cutoff = cutoff(:);
   if nargin >= 3
      depth = varargin{2};
   end
   if nargin < 4
      if all((cutoff >= 2) & (cutoff == fix(cutoff)))
         maxclust = cutoff;
         cutoff = NaN;
         usecutoff = false;
      end
   else
      flag = varargin{3};
      j = strmatch(flag, {'clusters','inconsistent','distance'});
      if isempty(j),
         error('stats:cluster:BadFlag',...
               'FLAG value must be ''clusters'' or ''inconsistent'' or ''distance''');
      end
      if j==1
         maxclust = cutoff;
         cutoff = NaN;
         usecutoff = false;
      elseif j==3
         criterion='distance';
      end
   end

% Otherwise, must have param/value pairs
else
   if rem(nargin,2)==0
      error('stats:cluster:BadNumArgs',...
            'Incorrect number of arguments to CLUSTER.');
   end
   okargs = {'cutoff','maxclust','criterion','depth'};
   for j=1:2:nargin-1
      pname = varargin{j};
      pval = varargin{j+1};
      k = strmatch(lower(pname), okargs);
      if isempty(k)
         error('stats:cluster:BadParameter',...
               'Unknown parameter name:  %s.',pname);
      elseif length(k)>1
         error('stats:cluster:BadParameter',...
               'Ambiguous parameter name:  %s.',pname);
      else
         switch(k)
          case 1
            cutoff = pval;
          case 2
            maxclust = pval;
          case 3
            okcrit = {'inconsistent','distance'};
            kk = strmatch(lower(pval),okcrit);
            if length(kk)~=1
               error('stats:cluster:BadCriterion','Bad clustering criterion.');
            else
               criterion = okcrit{kk};
            end
            if isequal (criterion, 'inconsistent')
                inconsistent_set=1;
            end
            
          case 4
            depth = pval;
         end
      end
   end
end

% Check arguments
maxclust = maxclust(:);
cutoff = cutoff(:);
if ~isnumeric(maxclust) || any(isfinite(maxclust) & maxclust<1)
   error('stats:cluster:BadMaxclust',...
         'The MAXCLUST value must be a number 1 or larger.');
end
if length(depth)~=1 || ~isnumeric(depth) || ~isfinite(depth) || depth<1
   error('stats:cluster:BadDepth','The DEPTH value must be at least 1.');
end
if any(isnan(cutoff))
   if any(~isfinite(maxclust))
      error('stats:cluster:MissingParameter',...
            'Must specify a MAXCLUST or CUTOFF value.');
   end
   usecutoff = false;
else
   if any(~isinf(maxclust))
      error('stats:cluster:ConflictingParameters',...
            'Must specify a MAXCLUST or CUTOFF value, but not both.');
   elseif any(cutoff<=0)
      error('stats:cluster:BadCutoff','CUTOFF must be positive.');
   end
end
if (~usecutoff && inconsistent_set==1)
    warning('stats:cluster:ConflictingParameters',...
            ['Cannot specify the MAXCLUST option with the INCONSISTENT criterion.\n'...
             'Using DISTANCE criterion instead.']);
end


% Start of algorithm
m = size(Z,1)+1;

if usecutoff % inconsistency or distance cutoff criterion for forming clusters
   T = zeros(m,numel(cutoff));
   if isequal(criterion,'inconsistent')
      Y = inconsistentsmall(Z,depth);
      crit = Y(:,4);
   else
      crit = Z(:,3);  % distance criterion
   end
   for j=1:numel(cutoff)
       conn = checkcut(Z, cutoff(j), crit);
       T(:,j) = labeltree(Z, conn);
   end
else % maximum number of clusters based on distance
    T = zeros(m,numel(maxclust));
    for j=1:numel(maxclust)
        if m <= maxclust(j)
            T(:,j) = (1:m)';
        elseif maxclust(j)==1
            T(:,j) = ones(m,1);
        else
            clsnum = 1;
            for k = (m-maxclust(j)+1):(m-1)
                i = Z(k,1); % left tree
                if i <= m % original node, no leafs
                    T(i,j) = clsnum;
                    clsnum = clsnum + 1;
                elseif i < (2*m-maxclust(j)+1) % created before cutoff, search down the tree
                    T(:,j) = clusternum(Z, T(:,j), i-m, clsnum);
                    clsnum = clsnum + 1;
                end
                i = Z(k,2); % right tree
                if i <= m  % original node, no leafs
                    T(i,j) = clsnum;
                    clsnum = clsnum + 1;
                elseif i < (2*m-maxclust(j)+1) % created before cutoff, search down the tree
                    T(:,j) = clusternum(Z, T(:,j), i-m, clsnum);
                    clsnum = clsnum + 1;
                end
            end
        end
    end
end

% -------- assign leaves under cluster c to c.
function T = clusternum(X, T, k, c)

m = size(X,1)+1;
while(~isempty(k))
   % Get the children of nodes at this level
   children = X(k,1:2);
   children = children(:);

   % Assign this node number to leaf children
   t = (children<=m);
   T(children(t)) = c;
   
   % Move to next level
   k = children(~t) - m;
end


% -------- assign cluster numbers
function T = labeltree(X,conn)
   
n = size(X,1);
nleaves = n+1;
T = ones(n+1,1);

% Each cut potentially yields an additional cluster
todo = true(n,1);

% Define cluster numbers for each side of each non-leaf node
clustlist = reshape(1:2*n,n,2);

% Propagate cluster numbers down the tree
while(any(todo))
   % Work on rows that are now split but not yet processed
   rows = find(todo & ~conn);
   if isempty(rows), break; end
   
   for j=1:2    % 1=left, 2=right
      children = X(rows,j);
   
      % Assign cluster number to child leaf node
      leaf = (children <= nleaves);
      if any(leaf)
         T(children(leaf)) = clustlist(rows(leaf),j);
      end
   
      % Also assign it to both children of any joined child non-leaf nodes
      joint = ~leaf;
      joint(joint) = conn(children(joint)-nleaves);
      if any(joint)
         clustnum = clustlist(rows(joint),j);
         childnum = children(joint) - nleaves;
         clustlist(childnum,1) = clustnum;
         clustlist(childnum,2) = clustnum;
         conn(childnum) = 0;
      end
   end

   % Mark these rows as done  
   todo(rows) = 0;
end

% Renumber starting from 1
[~,~,T] = unique(T);


% -------- cut the tree at a specified point
function conn = checkcut(X, cutoff, crit)

% See which nodes are below the cutoff, disconnect those that aren't
n = size(X,1)+1;
conn = (crit <= cutoff);  % these are still connected

% We may still disconnect a node unless all non-leaf children are
% below the cutoff, and grand-children, and so on
todo = conn & (X(:,1)>n | X(:,2)>n);
while(any(todo))
   rows = find(todo);
   
   % See if each child is done, or if it requires disconnecting its parent
   cdone = true(length(rows),2);
   for j=1:2     % 1=left child, 2=right child
      crows = X(rows,j);
      t = (crows>n);
      if any(t)
         child = crows(t)-n;
         cdone(t,j) = ~todo(child);
         conn(rows(t)) = conn(rows(t)) & conn(child);
      end
   end

   % Update todo list
   todo(rows(cdone(:,1) & cdone(:,2))) = 0;
end

