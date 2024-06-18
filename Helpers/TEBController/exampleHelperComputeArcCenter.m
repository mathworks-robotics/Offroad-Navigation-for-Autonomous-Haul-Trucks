function [xCtr] = exampleHelperComputeArcCenter(pose,rad)
%exampleHelperComputeArcCenter Computes center of arc based on pose and signed
%radius of curvature
%

% Copyright 2023-2024 The MathWorks, Inc.
    arguments
        pose (:,3) double
        rad  (:,1) double
    end
    th = pose(:,3);
    vPerp = [-sin(th) cos(th)].*rad;
    xCtr = pose(:,1:2)+vPerp;
end