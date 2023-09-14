function [hSDF,hContour] = exampleHelperDisplayContouredSDF(sdf,minDist)
%exampleHelperDisplayContouredSDF Displays the colormap with shaded offlimit regions
%
% Copyright 2023 The MathWorks, Inc.

    [~,hSDF] = sdf.show(BoundaryColor=[0 0 0],Colorbar="on");
    [~,hContour] = contourf(-flipud(sdf.distance),[-minDist inf],FaceColor='r',FaceAlpha=0.5);
    hContour.XData = linspace(sdf.XWorldLimits(1),sdf.XWorldLimits(2),numel(hContour.XData));
    hContour.YData = linspace(sdf.YWorldLimits(1),sdf.YWorldLimits(2),numel(hContour.YData));
end