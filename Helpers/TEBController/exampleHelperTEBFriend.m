classdef exampleHelperTEBFriend < nav.algs.internal.InternalAccess
%exampleHelperTEBFriend Provide access to internal property of TEB

    methods (Static)
        function teb = initTEB(mat, res, length, width, refPathXY, lastIdx, curpose, numIteration, referenceDeltaTime, gridLoc, tuneableTEBParams)
        %initTEB Initialize planner
            localMap = occupancyMap(mat,res);
            localMap.GridOriginInLocal = -localMap.GridSize/2/localMap.Resolution;
            localMap.GridLocationInWorld = gridLoc(:)';
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
            teb.ObstacleSafetyMargin = tuneableTEBParams.ObstacleSafetyMargin;
            
            % Update controller params
            teb.LookAheadTime           = tuneableTEBParams.LookaheadTime; % In sec
            teb.CostWeights.Time        = tuneableTEBParams.CostWeights_T.Time;
            teb.CostWeights.Smoothness  = tuneableTEBParams.CostWeights_T.Smoothness;
            teb.CostWeights.Obstacle    = tuneableTEBParams.CostWeights_T.Obstacle;
            teb.MinTurningRadius        = tuneableTEBParams.MinTurningRadius;
            teb.MaxVelocity             = tuneableTEBParams.MaxVelocity;
            teb.MaxAcceleration         = tuneableTEBParams.MaxAcceleration;
            teb.MaxReverseVelocity      = tuneableTEBParams.MaxReverseVelocity;
            teb.IdxCloseToRobot         = lastIdx;
        end
        function idx = getNearestIdx(teb)
        %getNearestIdx Retrieve index of nearest pose during latest "step"
            idx = teb.IdxCloseToRobot;
        end
        function idx = setNearestIdx(teb)
        %getNearestIdx Update nearest index index of nearest pose during latest "step"
            idx = teb.IdxCloseToRobot;
        end
    end
end