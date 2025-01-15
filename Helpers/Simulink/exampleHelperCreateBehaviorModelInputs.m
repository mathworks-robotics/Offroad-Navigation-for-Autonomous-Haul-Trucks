% Initialize route, teb, and free-space parameters
exampleHelperCreateRoutePlannerInputs
exampleHelperCreateControllerInputs
exampleHelperCreateFreeSpacePlannerInputs

% Free up space around the road network
vehDims = exampleHelperVehicleGeometry(fixedControllerParams.Length,fixedControllerParams.Width,"collisionChecker");
collisionChecker = inflationCollisionChecker(vehDims,3);
binMap = binaryOccupancyMap(~imSlope,Resolution=fixedTerrainAwareParams.Resolution);
exampleHelperInflateRoadNetwork(binMap,pathList,collisionChecker.InflationRadius*1.5);

% Configure obstacle image
worldGridLoc = binMap.GridLocationInWorld;
worldRes = binMap.Resolution;
worldMat = binMap.occupancyMatrix;

% Compute max distance traversible in an iteration of the local planner
[tuneableControllerParams,fixedControllerParams] = exampleHelperControllerParams;
 maxDistance = (tuneableControllerParams.MaxVelocity(1)*tuneableControllerParams.LookaheadTime/binMap.Resolution);

% Create the ego-centric local map
localMap = binaryOccupancyMap(2*maxDistance,2*maxDistance,binMap.Resolution);
localMap.GridOriginInLocal = -localMap.GridSize/(2*localMap.Resolution);
localMat = localMap.occupancyMatrix;

% Define default initial translation and rotation for the mining truck
globalMapSize = size(dem);
mapHeight = mapLayer(dem);
zOffset = getMapData(mapHeight,[0.5,1200.5]) - 155;
mapSize = mapHeight.GridSize([2 1])/mapHeight.Resolution;

% Define default parameters controlled with drop-downs in the live script
vssPhysModel = "Simple";
vssCommProtocol = "SLSignals";

% Clear "start" to not conflict with simulation command
clear start;

% Copyright 2023-2025 The MathWorks, Inc.