% Initialize route, teb, and free-space parameters
exampleHelperCreateRoutePlannerInputs
exampleHelperCreateTEBInputs
exampleHelperCreateFreeSpacePlannerInputs

% Free up space around the road network
vehDims = exampleHelperVehicleGeometry(fixedTEBParams.Length,fixedTEBParams.Width,"collisionChecker");
collisionChecker = inflationCollisionChecker(vehDims,3);
binMap = binaryOccupancyMap(~imSlope,Resolution=fixedTerrainAwareParams.Resolution);
exampleHelperInflateRoadNetwork(binMap,pathList,collisionChecker.InflationRadius*1.5);

% Configure obstacle image
worldGridLoc = binMap.GridLocationInWorld;
worldRes = binMap.Resolution;
worldMat = binMap.occupancyMatrix;

% Compute max distance traversible in an iteration of the local planner
[tuneableTEBParams,fixedTEBParams] = exampleHelperTEBParams;
 maxDistance = (tuneableTEBParams.MaxVelocity(1)*tuneableTEBParams.LookaheadTime/binMap.Resolution);

% Create the ego-centric local map
localMap = binaryOccupancyMap(2*maxDistance,2*maxDistance,binMap.Resolution);
localMap.GridOriginInLocal = -localMap.GridSize/(2*localMap.Resolution);
localMat = localMap.occupancyMatrix;

% Copyright 2023 The MathWorks, Inc.