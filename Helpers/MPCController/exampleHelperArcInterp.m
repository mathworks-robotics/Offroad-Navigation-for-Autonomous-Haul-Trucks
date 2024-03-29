function [pArcInterp,kOut,id] = exampleHelperArcInterp(poses,nv)
%exampleHelperArcInterp Fit arcs between SE2 poses and evenly interpolate wrt arclength
%
% Copyright 2024 The MathWorks, Inc.

    arguments
        poses (:,3)
        nv.StepSize (1,1) {mustBePositive, mustBeReal} = 1;
        nv.Direction (:,1) {mustBeMember(nv.Direction,[0 1])} = 1;
    end
    
    % Assumes each segment is tangent with origination pose and intersects 
    % the XY coordinate of the following pose.

    % Dirs must be scalar or equal number of poses
    dirs = repmat(nv.Direction,size(poses,1)/numel(nv.Direction),1);
    
    poses(~dirs,3) = poses(~dirs,3)+pi;

    % Compute distances between poses when fitting a tangent arc
    [S,R,dTh,~,in] = exampleHelperArcDist(poses);
    
    % Compute segment arclengths
    S = cumsum([0;S]);
    
    % Identify segment for interpolated points
    s = 0:(nv.StepSize):S(end);
    if size(poses,1) > 1
        id = reshape(discretize(s,S),[],1);
    else
        id = ones(numel(s),1);
    end
    dS = s(:)-S(id);
    pArcInterp = zeros(0,3);
    kOut = 1./R(id);
    
    % Interpolate each segment
    for i = 1:numel(R)
        ds = dS(id==i);
        if ~isempty(ds)
            if in(i)
                % Handle degenerate line-segment case
                p0 = poses(i,1:2);
                v = normalize(poses(i+1,1:2)-p0,'norm');
                pts = p0 + v.*ds;
                dth = zeros(size(pts,1),1);
            else
                pts = nav.algs.internal.ControlPolicies.evaluateArc(poses(i,:),R(i),ds')';
                dth = dTh(i)*ds(:)/diff(S(i+[0 1]));
            end
            
            th = poses(i,3)+dth;
            if ~dirs(i)
                th = th - pi;
            end
            
            pArcInterp = [pArcInterp; [pts th]]; %#ok<AGROW>
        end
    end
end