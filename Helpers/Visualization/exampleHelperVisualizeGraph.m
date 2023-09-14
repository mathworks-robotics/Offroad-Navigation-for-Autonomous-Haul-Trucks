function exampleHelperVisualizeGraph(stateTable,linkTable)
%exampleHelperVisualizeGraph Visualize graph in cartesian coords
%
% Copyright 2023 The MathWorks, Inc.

    graph = navGraph(stateTable,linkTable);
    hold on;
    gHandle = show(graph);
    gHandle.XData = graph.States.StateVector(:,1);
    gHandle.YData = graph.States.StateVector(:,2);
    gHandle.EdgeColor = 'r';
end