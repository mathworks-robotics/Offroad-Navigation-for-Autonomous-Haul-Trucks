function pathList = exampleHelperDiscretizePathList(pathListIn,edgeSize)
%exampleHelperDiscretizePathList Subdivide incoming edges given max edge size
%
% Copyright 2023 The MathWorks, Inc.

    if ~isinf(edgeSize)
        mustBeInteger(edgeSize);
        mustBeGreaterThanOrEqual(edgeSize,2);
        maxPtPerEdge = edgeSize-1;
        segPerEdge = arrayfun(@(x)1+floor((size(x.Path,1)-1)/edgeSize),pathListIn);
        if any(segPerEdge~=1)
            pathEl = zeros(0,2);
            coder.varsize('pathEl',[inf,2]);
            pathList = repmat(struct('Path',pathEl),sum(segPerEdge),1);
            si = 1;
            for i = 1:numel(pathListIn)
                pathEl = pathListIn(i).Path;
                i0 = 1;
                for j = 1:(segPerEdge(i)-1)
                    pathList(si).Path = pathEl(i0:(i0+maxPtPerEdge),:);
                    i0 = i0+maxPtPerEdge;
                    si = si+1;
                end
                pathList(si).Path = pathEl(max(i0,1):end,:);
                si = si+1;
            end
        else
            pathList = pathListIn;
        end
    else
        pathList = pathListIn;
    end
end