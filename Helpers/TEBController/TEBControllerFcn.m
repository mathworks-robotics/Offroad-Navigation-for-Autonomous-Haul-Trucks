function [velcmds,timestamps,optpath,info,needLocalReplan,needFreeSpaceReplan] = TEBControllerFcn(...
    mat,res,gridLoc,refPathXY,curpose,curvel,tuneableTEBParams,length, width, numIteration, referenceDeltaTime, lookaheadTime)
%TEBControllerFcn Wrapper of persistent controllerTEB planner
%
% Copyright 2023 The MathWorks, Inc.
    persistent teb localMap adjustedPath

    if isempty(teb)
        % Initialize planner
        localMap = occupancyMap(mat,res);
        localMap.GridOriginInLocal = -localMap.GridSize/2/localMap.Resolution;
        vehDims = exampleHelperVehicleGeometry(length,width,'collisionChecker');
        collisionChecker = inflationCollisionChecker(vehDims,3);
        robotInfo = exampleHelperVehicleGeometry(length,width,'teb');
        
        % Align first state of initial path with robot
        refPathXY(1,3) = curpose(3);
        teb = controllerTEB(refPathXY, localMap);

        % Set fixed parameters
        teb.NumIteration = numIteration;
        teb.ReferenceDeltaTime = referenceDeltaTime;
        teb.RobotInformation = robotInfo;
        teb.ObstacleSafetyMargin = collisionChecker.InflationRadius*2;
        adjustedPath = 0;
    end

    % Update map and referencePath
    localMap.setOccupancy(mat);
    localMap.GridLocationInWorld = gridLoc(:)';
    teb.ReferencePath = refPathXY;

    % Update controller params
    teb.LookAheadTime           = lookaheadTime; % In sec
    teb.CostWeights.Time        = tuneableTEBParams.CostWeights.Time;
    teb.CostWeights.Smoothness  = tuneableTEBParams.CostWeights.Smoothness;
    teb.CostWeights.Obstacle    = tuneableTEBParams.CostWeights.Obstacle;
    teb.MinTurningRadius        = tuneableTEBParams.MinTurningRadius;
    teb.MaxVelocity             = tuneableTEBParams.MaxVelocity;
    teb.MaxAcceleration         = tuneableTEBParams.MaxAcceleration;
    teb.MaxReverseVelocity      = tuneableTEBParams.MaxReverseVelocity;

    % Generate optimal local path
    [velcmds_,timestamps_,optpath_,info] = teb(curpose(:)',curvel(:)');

    % Post-process the TEB results, handling error codes and constraint
    % violations.
    [velcmds,timestamps,optpath,adjustedPath,needLocalReplan,needFreeSpaceReplan] = ...
        exampleHelperProcessTEBErrorCodes(teb,curpose,curvel,velcmds_,timestamps_,optpath_,info,adjustedPath,length,width);

    if ~needLocalReplan && ~needFreeSpaceReplan
        % Reset replan flag if TEB or post-processing was successful
        adjustedPath = 0;
    end
end