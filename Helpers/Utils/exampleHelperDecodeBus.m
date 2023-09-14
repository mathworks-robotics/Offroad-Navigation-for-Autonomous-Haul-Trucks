function pathList = exampleHelperDecodeBus(pathBus)
%exampleHelperDecodeBus Expands encoded fixed-size struct with varsize elements
%
% Copyright 2023 The MathWorks, Inc.

    pts = zeros(0,2);
    coder.varsize('pts',[inf 2]);
    pathList = repmat(struct('Path',pts),pathBus.NumPath,1);

    for i = 1:pathBus.NumPath
        [i0,i1] = deal(pathBus.PathIndices(i,1),pathBus.PathIndices(i,2));
        pathList(i).Path = pathBus.PointList(i0:i1,:);
    end
end