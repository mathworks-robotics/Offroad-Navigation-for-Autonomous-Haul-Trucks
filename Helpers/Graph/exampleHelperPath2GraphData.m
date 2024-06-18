function [uniqueStates,links,edge2pathIdx,cachedPaths] = exampleHelperPath2GraphData(pathListIn,edgeSize,visualize)
%exampleHelperPath2GraphData Converts struct-array of xy edges to a set of unique nodes and link
%
% Copyright 2023-2024 The MathWorks, Inc.

    arguments
        pathListIn
        edgeSize (1,1) {mustBePositive} = inf
        visualize (1,1) double {mustBeMember(visualize,[0 1])} = 0;
    end

    % Discretize path list if requested
    pathList = exampleHelperDiscretizePathList(pathListIn,edgeSize);

    % Store original path list
    dupeLinkPath = struct('Path',zeros(0,2));

    % Retrieve all edges, sort them so we can identify duplicates
    n = numel(pathList);
    edgePairs = zeros(n*2,2);
    for i = 1:n
        edgePairs((i-1)*2+(1:2),:) = pathList(i).Path([1 end],:);
    end
    initEdges = reshape(edgePairs',4,[])';
    [sortedEdges,iSort] = sortrows(initEdges);
    assert(isequal(initEdges(iSort,:),sortedEdges));

    % Create idx vector for unsorting later
    unSort = zeros(numel(iSort),1);
    unSort(iSort,1) = 1:size(iSort,1);
    assert(isequal(sortedEdges(unSort,:),initEdges));

    % Count the duplicate links
    [uniqueEdges,ia,ic] = unique(sortedEdges,'rows');

    assert(isequal(uniqueEdges(ic,:),sortedEdges));
    assert(isequal(uniqueEdges(ic(unSort),:),initEdges));

    h = accumarray(ic, 1);
    H = h(ic);
    duplicatedLinks = [sortedEdges(:,1:2) ones(numel(H),1) sortedEdges(:,3:4) H];
    dupeStartIdx = find(diff(H)==1);

    % Allocate edge->path indices, accounting for all original
    % edges and the imaginary edges inserted between duplicate
    % links. By default we will also flip the edges so that 2 way
    % traversal is enabled, doubling the final number of edges.
    numNewDuplicates = sum(h(h~=1)-1);

    if numNewDuplicates == 0
        cachedPaths = repmat(pathList(:),2,1);
    else
        cachedPaths = [repmat(pathList(:),2,1); dupeLinkPath];
    end

    for i = (numel(pathList)+1):(2*numel(pathList))
        cachedPaths(i).Path = flipud(cachedPaths(i).Path);
    end

    newDupeLinks = zeros(numNewDuplicates,6);
    iDupe = 0;
    for i = 1:numel(dupeStartIdx)
        idx = dupeStartIdx(i);
        numDupe = H(idx+1);

        % Insert imaginary nodes between parent and destination node
        duplicatedLinks(idx+(1:numDupe),end) = 1:numDupe;

        % Connect parent to new imaginary links
        newDupeLinks(iDupe+(1:(numDupe-1)),:) = [duplicatedLinks(idx+(2:numDupe),4:end) duplicatedLinks(idx+1,4:end)];
        iDupe = iDupe+numDupe-1;
    end

    assert(isequal(duplicatedLinks(unSort,[1 2 4 5]),initEdges))

    % Unsort the duplicated links and combine with duplicates
    combinedLinks = [duplicatedLinks; newDupeLinks];

    % Flatten all real/psuedo edges and find all unique nodes
    forwardNodes = reshape(combinedLinks',3,[])';
    reverseNodes = reshape(combinedLinks(:,[4:end 1:3])',3,[])';
    allNodes = [forwardNodes; reverseNodes];
    [uniqueStates, IA, IC] = unique(allNodes,'rows');

    % Rebuild edges using idx-pairs mapped to unique states
    links = reshape(IC,2,[])';

    edge2pathIdx = [iSort;                                 % Forward links
        repelem(numel(pathList)*2+1,numNewDuplicates,1);   % Forward Duplicates
        iSort+numel(pathList);                            % Reverse links
        repelem(numel(pathList)*2+1,numNewDuplicates,1)];  % Reverse Duplicates

    if visualize
        for i = 1:size(links,1)
            % Ensure uniquely mapped edges rebuild original edge-list
            pair1 = uniqueStates(links(i,:)',:);
            pair2 = allNodes((i-1)*2+1 + [0;1],:);
            assert(isequal(pair1,pair2));
        end

        for i = 1:size(links,1)
            % Ensure uniquely mapped edges rebuild original edge-list
            pair1 = uniqueStates(links(i,:)',:);
            pair2 = allNodes((i-1)*2+1 + [0;1],:);
            assert(isequal(pair1,pair2));

            % Ensure the edge2pathIdx mapping is correct
            curPath = cachedPaths(edge2pathIdx(i)).Path;
            if ~isempty(curPath)
                pair3 = curPath([1;end],:);
                assert(isequal(pair1(:,1:2),pair3));
            end
        end
    end
end