function gHandle = exampleHelperVisualizeGraph(stateTable,linkTable,gHandle,nv)
%exampleHelperVisualizeGraph Visualize graph in cartesian coords
%
% Copyright 2023 The MathWorks, Inc.
arguments
    stateTable (:,:)
    linkTable (:,:)
    gHandle matlab.graphics.chart.primitive.GraphPlot = matlab.graphics.chart.primitive.GraphPlot.empty
    nv.EdgeColor (1,1) string = 'r'
    nv.NodeColor (1,1) string = 'r'
    nv.LineStyle (1,1) string = '-'
    nv.EdgeAlpha (1,1) double = 1
    nv.Visible (1,1) matlab.lang.OnOffSwitchState = "on"
end
 
if isempty(gHandle)
    graph = navGraph(stateTable,linkTable);
    hold on;
    gHandle = show(graph);
    gHandle.XData = graph.States.StateVector(:,1);
    gHandle.YData = graph.States.StateVector(:,2);
end
    gHandle.NodeColor = nv.NodeColor;
    gHandle.EdgeColor = nv.EdgeColor;
    gHandle.LineStyle = nv.LineStyle;
    gHandle.EdgeAlpha = nv.EdgeAlpha;
    gHandle.Visible = nv.Visible;
end