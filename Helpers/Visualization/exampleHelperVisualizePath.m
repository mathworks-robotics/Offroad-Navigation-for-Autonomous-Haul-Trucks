function hPath = exampleHelperVisualizePath(pathXY,color,hPath)
%exampleHelperVisualizePath Plot or update XY path
%
% Copyright 2023 The MathWorks, Inc.

    if nargin == 2
        hPath = plot(pathXY(:,1),pathXY(:,2),color);
    else
        set(hPath,XData=pathXY(:,1),YData=pathXY(:,2));
    end
end