function exampleHelperVisualizeNetwork(pathBus_struct,maxElementPerEdge)
    arguments
        pathBus_struct (1,1)
        maxElementPerEdge (1,1) {mustBePositive} = inf
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
    exampleHelperVisualizeGraph([sSparse (1:size(sSparse,1))'],[eSparse; fliplr(eSparse)]);
    hold on;
    
    % Separately plot the network
    tmp = arrayfun(@(edge)[edge.Path; nan(1,2)],pListDense,UniformOutput=false);
    pts = vertcat(tmp{:});
    exampleHelperPlotLines(pts,'g-');
    
    % Verify sparse nodes are equivalent to nodes taken from dense list
    eTbl = pathBus_dense.PathIndices(1:pathBus_dense.NumPath,:);
    sTbl = pathBus_dense.PointList(eTbl(:),:);
    isequal(sSparse(eSparseIdx(:),:),sTbl);
end