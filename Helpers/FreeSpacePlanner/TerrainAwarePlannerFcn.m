function se2Path = TerrainAwarePlannerFcn(start,goal,dem,gridLoc,tuneableParams,fixedParams)
%TerrainAwarePlannerFcn Wrapper of terrain informed plannerHybridAStar
%
% Copyright 2023 The MathWorks, Inc.

    arguments
        start (:,3) double
        goal (:,3) double
        dem (:,:) single
        gridLoc (1,2) double
        tuneableParams
        fixedParams
    end
    persistent costMap prevDEM prevGridLoc prevMaxAngle

    if isempty(costMap)
        % Create costMaps from dem
        costMap = exampleHelperDem2mapLayers(dem,tuneableParams.MaxAngle,fixedParams.Resolution);

        % Store previous inputs
        prevDEM = dem;
        prevMaxAngle = tuneableParams.MaxAngle;
        prevGridLoc = gridLoc;
    else
        updateMaps = ~isequal(prevDEM,dem) || ~isequal(prevGridLoc,gridLoc) || ~isequal(prevMaxAngle,tuneableParams.MaxAngle);

        % Store previous inputs
        prevDEM = dem;
        prevMaxAngle = tuneableParams.MaxAngle;
        prevGridLoc = gridLoc;

        % Check whether costmap must be updated
        if updateMaps
            updatePlannerMaps(costMap,dem,prevMaxAngle,fixedParams.Resolution);
        end
    end
    
    % Initialize planner
    planner = exampleHelperCreateTerrainPlanner(costMap,tuneableParams,fixedParams);
    
    % Update tuneable properties
    names = fieldnames(tuneableParams);
    for i = 1:numel(names)
        name = names{i};
        if isprop(planner,name)
            planner.(name) = tuneableParams.(name);
        end
    end

    % Plan a path
    pathObj = planner.plan(start,goal);
    pathObj.interpolate(max(1000,pathObj.NumStates));
    se2Path = pathObj.States;
end

function updatePlannerMaps(origCostMap,dem,maxAngle,res)
    % Create new costMap and validator map
    tmpCostMap = exampleHelperDem2mapLayers(dem,maxAngle,res);

    % Update planner's cost function
    origCostMap.syncWith(tmpCostMap);
end