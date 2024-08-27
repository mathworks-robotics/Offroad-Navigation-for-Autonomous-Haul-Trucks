function planner = exampleHelperCreateTerrainPlanner(costMap,tuneableParams,fixedParams,transitionFcn)
%exampleHelperCreateTerrainPlanner Creates plannerHybridAStar from incoming parameters and cost function
%
% Copyright 2023-2024 The MathWorks, Inc.

    if nargin == 3
        % Create plannerHybridAStar with terrain-aware cost function
        gWeight = 1; % Weight
        transitionFcn = @(motionSegment)exampleHelperZHeuristic(motionSegment, costMap, gWeight);
    end
    % Create a stateValidator object and update the statebounds
    map = getLayer(costMap,"terrainObstacles");
    ss = stateSpaceSE2([map.XLocalLimits; map.YWorldLimits; [-pi pi]]);
    vehDims = exampleHelperVehicleGeometry(coder.const(fixedParams.Length),coder.const(fixedParams.Width),"collisionChecker");
    collisionChecker = inflationCollisionChecker(vehDims,fixedParams.NumCircles);
    vehMap = vehicleCostmap(single(map.getOccupancy),'CollisionChecker',collisionChecker,'MapLocation',map.GridLocationInWorld);
    validator = validatorVehicleCostmap(ss,Map=vehMap,ThetaIndex=3);
    
    % Initialize planner
    planner = plannerHybridAStar(validator, TransitionCostFcn=transitionFcn);
    
    % Update fixed properties
    names = fieldnames(fixedParams);
    for i = 1:numel(names)
        name = names{i};
        if isprop(planner,name)
            planner.(name) = fixedParams.(name);
        end
    end
    
    % Update tuneable properties
    names = fieldnames(tuneableParams);
    for i = 1:numel(names)
        name = names{i};
        if isprop(planner,name)
            planner.(name) = tuneableParams.(name);
        end
    end
end