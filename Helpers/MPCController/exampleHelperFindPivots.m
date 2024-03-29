function [segments,pivotIdx,nSeg] = exampleHelperFindPivots(refPath,angThreshold)
%exampleHelperFindPivots Identify segments where path changes direction
%
% Copyright 2024 The MathWorks, Inc.

    arguments
        refPath (:,:)
        angThreshold (1,1) {mustBeFinite} = pi/8;
    end
    nCol = size(refPath,2);
    coder.const(nCol);
    switch nCol
        case {2,3}
            th = headingFromXY(refPath(:,1:2));
        otherwise
            error('refPath must be an Nx2 or Nx3 sequence of XY or SE2 states');
    end
    pivotIdx = [1;1+find(abs(robotics.internal.angdiff(th)) > pi-abs(angThreshold)); size(refPath,1)];
    nSeg = numel(pivotIdx)-1;
    seg = zeros(0,3);
    coder.varsize('seg',[inf nCol]);
    % coder.varsize('seg',[inf inf]);
    segments = repmat(struct('States',seg),nSeg,1);
    for i = 1:nSeg
        segments(i).States = refPath(pivotIdx(i):pivotIdx(i+1),:);
    end
end