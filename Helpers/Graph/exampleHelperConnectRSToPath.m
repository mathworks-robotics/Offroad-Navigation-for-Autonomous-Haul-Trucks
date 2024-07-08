function [onrampPath,onrampIdx] = exampleHelperConnectRSToPath(path, localEdges, offNetworkState, map, vehDims, minTurnRadius)
%exampleHelperConnectRSToPath Attempt to find nearest collision-free RS connection from initial state to a graph-node/path
%
% Copyright 2023-2024 The MathWorks, Inc.

    arguments
        path (:,:) {mustBeNumeric}
        localEdges (:,1) struct
        offNetworkState (1,:) {mustBeNumeric}
        map (1,1) {mustBeA(map,{'occupancyMap','binaryOccupancyMap'})}
        vehDims {mustBeA(vehDims,{'vehicleDimensions'})}
        minTurnRadius (1,1) {mustBePositive, mustBeReal} = 17.2
        

    end
    % Aligning end of local edges with beginning of path 
    for i = 1:numel(localEdges)
        if ~isequal(localEdges(i).Path(1,1:2),path(1,1:2))
            assert(isequal(path(1,1:2),localEdges(i).Path(end,1:2)));
            localEdges(i).Path = flipud(localEdges(i).Path);
        end
    end

    % Compute closest point along the path
    dists = vecnorm(path(:,1:2)-offNetworkState(1:2),2,2);
    [minDist,idx] = sort(dists,'descend');

    onrampPath = zeros(0,2);
    onrampIdx = 1;

    % collision checker for vehicle
    collisionChecker = inflationCollisionChecker(vehDims,3);

    % convert map to sdf for collision checking
    sdf = exampleHelperConvert2SDFMap(map,interpolationMethod="linear");

    % Rearrange the local edges in ascending order according to proximity
    % to network path    
    proximityMetric = zeros(numel(localEdges),1);
    for i = 1:numel(localEdges)
        dist = vecnorm((path(1:2,1:2) - localEdges(i).Path(1:2,1:2)),2,2);
        proximityMetric(i) = max(dist);
    end
    [~,sortedProximityIdx] = sort(proximityMetric);
    sortedLocalEdges = localEdges(sortedProximityIdx);

    % Check to see if point lies along a local edge to initial node
    for i = 1:numel(sortedLocalEdges)
        if i==1
            iSorted = size(sortedLocalEdges(i).Path,1):-1:1;
        else
            iSorted = 1:size(sortedLocalEdges(i).Path,1);
        end

        % Search for route between start location and local edge
        [onrampIdx,onrampPath] = findNearestFreeConnection(offNetworkState,iSorted,sdf,sortedLocalEdges(i).Path,minTurnRadius,collisionChecker);

        if ~isempty(onrampPath)
            break;
        end
    end

    if isempty(onrampPath)
        % if point doesn't lie along a local edge, cast rays along the
        % path until the nearest obstacle-free route from initial
        % state->path is found
        [onrampIdx,onrampPath] = findNearestFreeConnection(offNetworkState,idx,sdf,path,minTurnRadius,collisionChecker);
    end
end

function [onrampIdx,onrampPath] = findNearestFreeConnection(offNetworkState,iSorted,sdf,path,minTurnRadius,collisionChecker)
%findNearestFreeConnection Try to connect to nearest point along 
%   edge until collision-free path is found, or points exhausted.

    % Choose the first point with a clear line-of-sight to the path
    onrampIdx = 1;
    onrampPath = zeros(0,2);
    halfCellSize = 1/(2*sdf.Resolution);
    states = exampleHelperSmoothReferencePath(path);
    validPathFound = false;
    for i = 1:numel(iSorted)
        onrampIdx = iSorted(i);
        rsConnection = reedsSheppConnection("MinTurningRadius",minTurnRadius);
        pathObj = exampleHelperUncell(rsConnection.connect(offNetworkState,states(onrampIdx,:)));
        nSample = ceil(pathObj.Length/halfCellSize);
        pts = pathObj.interpolate(linspace(0,pathObj.Length,nSample));
        stateFree = exampleHelperCheckVehicleCollision(sdf,pts,collisionChecker);
        if all(stateFree)
            onrampPath = pts;
            validPathFound = true;            
        end
        if validPathFound==true
        break;
        end
    end
end