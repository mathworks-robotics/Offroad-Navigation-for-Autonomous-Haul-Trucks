function hTform = exampleHelperVisualizeVehicle(curpose,length,width,hTform)
%exampleHelperVisualizeVehicle Plot or update vehicle
%
% Copyright 2023 The MathWorks, Inc.

    arguments
        curpose (1,3) double
        length (1,1) double
        width (1,1) double
        hTform (1,1) matlab.graphics.primitive.Transform = hgtransform
    end
    if nargin == 3
        vehDims = exampleHelperVehicleGeometry(length,width,"collisionChecker");
        checker = inflationCollisionChecker(vehDims,NumCircles=3);
        [~,hVeh] = exampleHelperCreateVehicleGraphic(gca,"Start",checker);
        hTform = hgtransform;
        arrayfun(@(x)set(x,Parent=hTform),hVeh);
    end
    hTform.Matrix(1:3,:) = [eul2rotm([0 0 curpose(3)],'XYZ') [curpose(1:2)';0]];
end