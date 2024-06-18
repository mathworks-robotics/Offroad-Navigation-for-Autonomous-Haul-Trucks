function [ax,gHandle] = exampleHelperVisualizeNetwork(pathBus_struct,maxElementPerEdge,gHandle,ax,nv)
%exampleHelperVisualizeNetwork Visualize network in cartesian coordinates
%

% Copyright 2023-2024 The MathWorks, Inc.
arguments
    pathBus_struct 
    maxElementPerEdge
    gHandle matlab.graphics.chart.primitive.GraphPlot = matlab.graphics.chart.primitive.GraphPlot.empty
    ax matlab.graphics.chart.primitive.Line = matlab.graphics.chart.primitive.Line.empty
    nv.networkVisible (1,1) matlab.lang.OnOffSwitchState = "on"
    nv.graphVisible (1,1) matlab.lang.OnOffSwitchState = "on"
end
% Densify the network according to maxEdgeLength
    pList = exampleHelperDecodeBus(pathBus_struct);
    pListDense = exampleHelperDiscretizePathList(pList,maxElementPerEdge);
    pathBus_dense = exampleHelperEncodeBus(pListDense);
    
    % Identify unique nodes from struct
    [eUnique,~,eSparseIdx] = unique(pathBus_dense.PathIndices(1:pathBus_dense.NumPath,:));
    
    % Create sparse graph tables
    sSparse = pathBus_dense.PointList(eUnique,:);
    eSparse = reshape(eSparseIdx,[],2);
    
    % Display sparse graph
    gHandle = exampleHelperVisualizeGraph([sSparse (1:size(sSparse,1))'],[eSparse; fliplr(eSparse)],gHandle,Visible=nv.graphVisible);
    %hold on;
    
    % Separately plot the network
    tmp = arrayfun(@(edge)[edge.Path; nan(1,2)],pListDense,UniformOutput=false);
    pts = vertcat(tmp{:});
    if isempty(ax)
        ax = plot(pts(:,1),pts(:,2),'g-');
    else
        ax.Visible = nv.networkVisible;
    end
end