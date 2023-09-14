function linkCosts = exampleHelperDefaultEdgeCost(pathList,edge2pathIdx)
%exampleHelperDefaultEdgeCost Accumulated "euclidean" XY distance along path
%
% Copyright 2023 The MathWorks, Inc.

    pathCosts = [arrayfun(@(x)sum(vecnorm(diff(x.Path,1),2,2)),pathList); 0];
    linkCosts = pathCosts(edge2pathIdx);
end