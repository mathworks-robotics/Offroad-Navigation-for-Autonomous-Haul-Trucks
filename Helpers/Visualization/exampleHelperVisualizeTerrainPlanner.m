function exampleHelperVisualizeTerrainPlanner(states,costMap,fixedParams,tuneableParams)
%exampleHelperVisualizeTerrainPlanner Animate global trajectory
%

% Copyright 2023-2024 The MathWorks, Inc.

    %% Visualize solution
    exampleHelperPlotLines(states,{'LineWidth',5});
    hold on;
    exampleHelperPlotLines(states(1,:),'rX',states(end,:),'gO');

    %% Visualize path atop gradient-scaled heatmap
    slopeMax = tand(tuneableParams.MaxAngle);
    [gx,gy] = deal(costMap.getMapData('dzdx'),costMap.getMapData('dzdy'));
    gradMagnitude = sqrt(gx.^2 + gy.^2);
    gradMagnitude(gradMagnitude>slopeMax) = slopeMax;
    gradMagnitude = rescale(gradMagnitude);
    hold on;
    hGradCost = imagesc(flipud(gradMagnitude));
    hGradCost.AlphaData = 0.3;
    colormap parula;
    c = colorbar;    
    c.Label.String = 'Terrain Slope Gradient';

    %% Visualize collisionChecker following path
    vehDims = exampleHelperVehicleGeometry(fixedParams.Length,fixedParams.Width,"collisionChecker");
    collisionChecker = inflationCollisionChecker(vehDims,fixedParams.NumCircles);
    [~,hVeh] = exampleHelperCreateVehicleGraphic(gca,"Start",collisionChecker);
    hT = hgtransform;
    arrayfun(@(x)set(x,"Parent",hT),hVeh);

    exampleHelperPaddedZoom(states,2,"PaddingFactor",5);

    for i = 1:size(states,1)
        hT.Matrix(1:3,:) = [eul2rotm([0 0 states(i,3)],'XYZ') [states(i,1:2)';0]];
         drawnow
    end
end