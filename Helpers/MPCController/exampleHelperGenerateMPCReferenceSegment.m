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

    remainingPath = refPath(ii:end,:);
    numStates = size(remainingPath,1);
    refEndPose = refPath(end,:);
    dist = vecnorm(curPose(1:2)-refEndPose(1:2),2,2);
    if numStates < predictionHorizon 
        if numStates >= 2 && dist > 2
            % Interpolate evenly between curPose and end pose at reference
            % path to have predictionHorizon number of states for MPC.
            xBounds = [min(remainingPath(:,1))-10, max(remainingPath(:,1))+10];
            yBounds = [min(remainingPath(:,2))-10, max(remainingPath(:,2))+10];
            ss = stateSpaceSE2([xBounds;yBounds;[-pi pi]]);
            pathObj = navPath(ss, remainingPath);
            interpolate(pathObj, 10);
            refPathToMPC = pathObj.States;      
        else
            refPathToMPC = repmat(refEndPose,predictionHorizon,1);
        end
    else
        refPathToMPC = remainingPath(1:predictionHorizon,:);
    end
    
    % Assemble trajectory. In the first stage, the trajectory is not part of the cost function, therefore we set the first row to zero.
    trajectory = [ zeros(1,3);
                   curPose(:)';
                   refPathToMPC(2:end,:)
                 ];
    % MPC needs a smooth pose angle trajectory. If the pose angle is
    % wrapping around e.g. 2pi, we need to catch it and fix it to avoid the discontinuity.
    trajectory(2:end,3) = unwrap(trajectory(2:end,3));
    
    % Assemble stage parameter vector for MPC
    stageParam = reshape( [trajectory, predictionHorizon*ones(11,1)]', 44, 1);
