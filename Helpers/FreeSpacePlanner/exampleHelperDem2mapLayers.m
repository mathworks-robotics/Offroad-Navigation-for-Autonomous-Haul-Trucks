function [costMap,maxSlope] = exampleHelperDem2mapLayers(dem,maxInclineAngle,res)
%exampleHelperDem2mapLayers Converts DEM data to a multiLayerMap storing cost,
%gradients, and obstacles based on the slope limit
%
% Copyright 2023 The MathWorks, Inc.

    arguments
        dem (:,:) double {mustBeNumeric}
        maxInclineAngle (1,1) double {mustBeFinite, mustBeReal} = 15;
        res (1,1) double {mustBePositive} = 1;
    end
    % Discretize and Store Environment Information in Map Layers

    % Query and store the Z-height
    zLayer = mapLayer(dem,LayerName="Z",Resolution=res);
    [gx,gy] = gradient(dem);
    
    dzdxLayer = mapLayer(gx*res,LayerName="dzdx",Resolution=res);
    dzdyLayer = mapLayer(gy*res,LayerName="dzdy",Resolution=res);
    maxSlope = tand(maxInclineAngle); % Max preferred slope for vehicle
    
    slope2cost = @(x)exampleHelperGradient2Cost(maxSlope,x);
    GX = dzdxLayer.getMapData();
    GY = dzdyLayer.getMapData();
    xCost = mapLayer(slope2cost(GX),LayerName="xCost",Resolution=res);
    yCost = mapLayer(slope2cost(GY),LayerName="yCost",Resolution=res);
    diagCost = mapLayer(slope2cost(sqrt(GX.^2+GY.^2)),LayerName="diagCost",Resolution=res);
    
    % Terrain Obstacles
    mInvalidSlope = getMapData(xCost) > 1 | getMapData(yCost) > 1 | getMapData(diagCost) > 1;
    terrainObstacles = binaryOccupancyMap(mInvalidSlope,LayerName="terrainObstacles",Resolution=res);
    
    % Combine Individual Map Layers
    costMap = multiLayerMap({zLayer xCost yCost dzdxLayer dzdyLayer diagCost terrainObstacles});
end