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

% Copyright 2023 The MathWorks, Inc.