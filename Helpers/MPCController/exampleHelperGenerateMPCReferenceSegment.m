function [stageParam,ii] = exampleHelperGenerateMPCReferenceSegment(curPose, refPath, predictionHorizon)
%exampleHelperFindPivots Find MPC reference parameters for given pose
%
% Copyright 2024 The MathWorks, Inc.
    
    arguments
        curPose (1,3) {mustBeNumeric, mustBeReal}
        refPath (:,3) {mustBeNumeric, mustBeReal}
        predictionHorizon (1,1) {mustBeNumeric, mustBePositive}
    end

    ind = zeros(1,10);

    % Extract current xy position
    pos = curPose(1:2);
    pos = pos(:)'; %force row vector
    % Extract xy position from the reference path
    path = refPath(:,1:2); 

    % Find the closes point on the reference path to the current position
    [~, ii] = min(vecnorm(path-pos,2,2));

    % Find the next 10 points on the path, make sure we don't run over the
    % end of the path    
    for jj=1:length(ind)
        ind(jj) = min(ii+(jj-1), size(refPath,1));
    end

    % Assemble trajectory. In the first stage, the trajectory is not part of the cost function, therefore we set the first row to zero.
    trajectory = [ zeros(1,3);
                   curPose(:)';
                   refPath(ind(2:end),:)
                 ];
    % MPC needs a smooth pose angle trajectory. If the pose angle is
    % wrapping around e.g. 2pi, we need to catch it and fix it to avoid the discontinuity.
    trajectory(2:end,3) = unwrap(trajectory(2:end,3));
    
    % Assemble stage parameter vector for MPC
    stageParam = reshape( [trajectory, predictionHorizon*ones(11,1)]', 44, 1);
