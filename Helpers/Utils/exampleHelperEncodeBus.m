function pathBus = exampleHelperEncodeBus(pathList,maxNumPoints,maxNumEdge)
%exampleHelperEncodeBus Flattens varsize struct-array with varsize elements
%
% Copyright 2023 The MathWorks, Inc.

    n = numel(pathList);
    pathSizes = arrayfun(@(x)size(x.Path,1),pathList);
    i0 = cumsum([1; pathSizes(:)]);
    if nargin == 1
        pts = zeros(sum(pathSizes),2);
        edgeIdx = [i0(1:end-1) i0(2:end)-1];
    else
        pts = zeros(maxNumPoints,2);
        edgeIdx = zeros(maxNumEdge,2);
        edgeIdx(1:n,:) = [i0(1:end-1) i0(2:end)-1];
    end
    for i = 1:n
        pts(i0(i):(i0(i+1)-1),:) = pathList(i).Path;
    end

    pathBus = struct('PointList',pts,'PathIndices',edgeIdx,'NumPath',numel(pathList));
end