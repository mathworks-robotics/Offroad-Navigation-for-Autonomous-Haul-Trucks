function [S,R,dTh,c,in] = exampleHelperArcDist(poses)
%exampleHelperArcDist Compute arc parameters between successive poses
%
% Copyright 2024 The MathWorks, Inc.

    % Assumes each segment is tangent with origination pose and intersects 
    % the XY coordinate of the following pose.

    % Prepare outputs
    nSeg = size(poses,1)-1;
    S = zeros(nSeg,1);
    R = zeros(nSeg,1);
    dTh = zeros(nSeg,1);
    c = zeros(nSeg,1);

    % Compute arc parameters for each segment. Assume segment is tangent with
    % origination pose and intersects the next pose.
    for i = 1:nSeg
        [R(i),c(i),dTh(i),S(i)] = nav.algs.internal.ControlPolicies.posePointArc(poses(i,:),poses(i+1,1:2));
    end

    % Handle degenerate line case
    in = isnan(S);
    in = in | any(abs(mod(dTh,pi)-[0 pi]) < sqrt(eps),2);
    idx = find(in);
    S(in) = vecnorm(poses(idx+1,1:2)-poses(idx,1:2),2,2);
end