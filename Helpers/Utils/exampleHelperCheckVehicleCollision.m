function isValidState = exampleHelperCheckVehicleCollision(sdf,curpath,collisionChecker)
%exampleHelperCheckVehicleCollision checks vehcle collision for given path,
% sdf and collision checker
%

% Copyright 2023-2024 The MathWorks, Inc.

arguments
    sdf (1,1) {mustBeA(sdf,{'signedDistanceMap'})}
    curpath (:,:) {mustBeNumeric}
    collisionChecker {mustBeA(collisionChecker,{'driving.costmap.InflationCollisionChecker'})}
    
end
vx = collisionChecker.CenterPlacements(:)*collisionChecker.VehicleDimensions.Wheelbase;
vy = zeros(size(vx,1),1);
radius = collisionChecker.InflationRadius;
capPts = [vx vy];
isValidState = exampleHelperCheckCollisionSDF(sdf,capPts,radius,curpath);
end