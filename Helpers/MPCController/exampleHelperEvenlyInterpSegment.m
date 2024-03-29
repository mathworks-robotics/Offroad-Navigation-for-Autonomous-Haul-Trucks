function [interpPath,kOut,interpCtrl] = exampleHelperEvenlyInterpSegment(poses,vNominal,timestep,ctrl)
%exampleHelperEvenlyInterpSegment Reinterpolate SE2 path using piecewise C1/C0-continous arcs
%   
%   Assumes each segment is tangent with origination pose and intersects 
%   the XY coordinate of the following pose.
%
% Copyright 2024 The MathWorks, Inc.

    arguments
        poses (:,3) double {mustBeReal}
        vNominal (1,1) double {mustBePositive, mustBeReal} = 1
        timestep (1,1) double {mustBePositive, mustBeReal} = 0.1
        ctrl (:,2) double {mustBeReal} = []
    end
    waypointSpacing = vNominal*timestep;
    vSeg = [diff(poses(:,1:2));diff(poses(end-1:end,1:2))];
    direction = sum(vSeg.*[cos(poses(:,3)) sin(poses(:,3))],2) > 0;
    [interpPath,kOut,id] = exampleHelperArcInterp(poses, "StepSize", waypointSpacing, "Direction", direction);

    % Overwrite final pose
    interpPath(end,:) = poses(end,:);
    if ~isempty(ctrl)
        interpCtrl = ctrl(id,:);
    end
end