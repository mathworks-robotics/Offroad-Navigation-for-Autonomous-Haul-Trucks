function hPath = exampleHelperVisualizePath(pathXY,color,hPath,nv)
%exampleHelperVisualizePath Plot or update XY path
%

% Copyright 2023-2024 The MathWorks, Inc.

arguments
    pathXY (:,:) double
    color (1,1) string
    hPath matlab.graphics.chart.primitive.Line = matlab.graphics.chart.primitive.Line.empty
    nv.Visible (1,1) matlab.lang.OnOffSwitchState = "on"
    nv.Linewidth (1,1) = 3;
end

    if nargin == 2
        hPath = plot(pathXY(:,1),pathXY(:,2),Color=color);
        hPath.Visible = nv.Visible;
        hPath.LineWidth = nv.Linewidth;

    else
        set(hPath,XData=pathXY(:,1),YData=pathXY(:,2));
        hPath.Visible = nv.Visible;
        hPath.LineWidth = nv.Linewidth;
    end
end