function onrampPath = exampleHelperConnectRSToPath(path, localEdges, offNetworkState, map, minTurnRadius)
%exampleHelperConnectRSToPath Attempt to find nearest collision-free RS connection from initial state to a graph-node/path
%
% Copyright 2023 The MathWorks, Inc.

    arguments
        path (:,:) {mustBeNumeric}
        localEdges (:,1) struct
        offNetworkState (1,:) {mustBeNumeric}
        map (1,1) {mustBeA(map,{'occupancyMap','binaryOccupancyMap'})}
        minTurnRadius (1,1) {mustBePositive, mustBeReal} = 17.2
    end

    % Compute closest point along the path
    dists = vecnorm(path(:,1:2)-offNetworkState(1:2),2,2);
    [minDist,idx] = sort(dists);

    onrampPath = zeros(0,2);

    if minDist(1) < 5
        % Initial state is close enough to the path, cast rays along the
        % path until the nearest obstacle-free route from initial
        % state->path is found
        [onrampIdx,onrampPath] = findNearestFreeConnection(offNetworkState,idx,map,path,minTurnRadius);
    else
        % Check to see if point lies along a local edge to initial node
        for i = 1:numel(localEdges)
            [edgeDists,iSorted] = sort(vecnorm(localEdges(i).Path-offNetworkState(1:2),2,2));

            % Search for route between start location and local edge
            [onrampIdx,onrampPath] = findNearestFreeConnection(offNetworkState,iSorted,map,localEdges(i).Path,minTurnRadius);

            if ~isnan(onrampIdx)
                break;
            end
        end
    end
end

function [onrampIdx,onrampPath] = findNearestFreeConnection(offNetworkState,iSorted,binMap,path,minTurnRadius)
%findNearestFreeConnection Try to connect to nearest point along 
%   edge until collision-free path is found, or points exhausted.

    % Choose the first point with a clear line-of-sight to the path
    onrampIdx = nan;
    onrampPath = zeros(0,2);
    halfCellSize = 1/(2*binMap.Resolution);
    states = exampleHelperSmoothPath(path);
    for i = 1:numel(iSorted)
        idx = iSorted(i);
        rsConnection = reedsSheppConnection("MinTurningRadius",minTurnRadius);
        pathObj = exampleHelperUncell(rsConnection.connect(offNetworkState,states(idx,:)));
        nSample = ceil(pathObj.Length/halfCellSize);
        pts = pathObj.interpolate(linspace(0,pathObj.Length,nSample));
        isValid = ~binMap.checkOccupancy(pts(:,1:2));
        if all(isValid)
            onrampPath = pts;
            break;
        end
    end
end