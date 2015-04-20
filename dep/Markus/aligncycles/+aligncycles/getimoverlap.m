function [ yOverlap1, yOverlap2, xOverlap1, xOverlap2 ] = getimoverlap( yShift, xShift )

%CALCULATECYCLEOVERLAP calculates the overlap of images from different
%multiplexing cycles based on pre-calculated shift vectors.

%%% in y direction 
yShiftDirect = sign(yShift);
if any(yShiftDirect>0) %down
    yOverlap1 = max(yShift(yShiftDirect==1));
else
    yOverlap1 = 0;
end
if any(yShiftDirect<0) %up
    yOverlap2 = abs(min(yShift(yShiftDirect==-1)));
else
    yOverlap2 = 0;
end

%%% in x direction
xShiftDirect = sign(xShift);
if any(xShiftDirect>0) %right
    xOverlap1 = max(xShift(xShiftDirect==1));
else
    xOverlap1 = 0;
end
if any(xShiftDirect<0) %left
    xOverlap2 = abs(min(xShift(xShiftDirect==-1)));
else
    xOverlap2 = 0;
end

end

