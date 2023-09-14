function [velcmds, tstamps, curpath,adjustedPath,needLocalReplan,needFreeSpaceReplan] = ...
        exampleHelperProcessTEBErrorCodes(teb,curpose,curvel,velcmds,tstamps,curpath,info,adjustedPath,length,width)
%exampleHelperProcessTEBErrorCodes Checks for TEB error codes and attempts 
%to rectify the path if needed
%
% Copyright 2023 The MathWorks, Inc.

    feasibleDriveDuration = tstamps(info.LastFeasibleIdx);
    needFreeSpaceReplan = 0;
    needLocalReplan = 0;
    minDuration = teb.LookAheadTime/5;
    vehDims = exampleHelperVehicleGeometry(length,width,"collisionChecker");
    collisionChecker = inflationCollisionChecker(vehDims,3);

    if height(tstamps) == 1
        if adjustedPath == 0
            exampleHelperUpdateTEBRefPath(teb,curpose(:)',1);
            adjustedPath = 1;
            needLocalReplan = 1;
        else
            needFreeSpaceReplan = 1;
        end
    else
        if (info.LastFeasibleIdx ~= height(tstamps) && ...
                feasibleDriveDuration < minDuration) || abs(curvel(1)-velcmds(1)) > 5 || size(velcmds,1) == 1
            if adjustedPath == 1
                needFreeSpaceReplan = 1;
                needLocalReplan = 0;
            else
                needLocalReplan = 0;
                needFreeSpaceReplan = 0;
                if info.ExitFlag == 3
                    % Attempt to threshold the velocity commands
                    minRadius = teb.MaxVelocity(1)/teb.MaxVelocity(2);
                    minVel = -teb.MaxReverseVelocity;
                    maxVel = teb.MaxVelocity(1);

                    % Identify speed violations
                    speedViolation = velcmds(:,1) < minVel | velcmds(:,1) > maxVel;

                    % Reduce speed
                    velcmds(speedViolation,1) = max(min(velcmds(speedViolation,1),maxVel),minVel);

                    % Compute radius of curvature
                    roc = abs(velcmds(:,1)./velcmds(:,2));

                    % Identify turn violations
                    turnViolation = roc < minRadius;

                    % Limit turn violations
                    velcmds(turnViolation,2) = velcmds(turnViolation,1)/minRadius.*sign(velcmds(turnViolation,2));
                else
                    if info.ExitFlag == 2
                        % Precompute trajectory and check for collision
                        ss = stateSpaceDubins([-inf inf; -inf inf; -pi pi]);
                        ss.MinTurningRadius=1;
                        
                        % Create signedDistanceMap, then manually confirm
                        % whether states are free or in collision
                        map = teb.Map;
                        sdf = signedDistanceMap(map.checkOccupancy==1,Resolution=map.Resolution,InterpolationMethod="linear");
                        sdf.GridOriginInLocal = map.GridOriginInLocal;
                        sdf.GridLocationInWorld = map.GridLocationInWorld;
                        vx = collisionChecker.CenterPlacements(:)*collisionChecker.VehicleDimensions.Wheelbase;
                        vy = zeros(3,1);
                        radius = collisionChecker.InflationRadius;
                        capPts = [vx vy];
                        stateFree = exampleHelperCheckCollisionSDF(sdf,capPts,radius,curpath);
                        
                        if ~all(stateFree)
                            pathIdx = find(~stateFree,1);
                            if tstamps(pathIdx) < minDuration
                                % Update reference path by excluding points inside the min
                                % turn radius
                                if adjustedPath == 0
                                    exampleHelperUpdateTEBRefPath(teb,curpose(:)');
                                    adjustedPath = 1;
                                    needLocalReplan = 1;
                                else
                                    needFreeSpaceReplan = 1;
                                end
                            else
                                velcmds = velcmds(1:info.LastFeasibleIdx,:);
                                tstamps = tstamps(1:info.LastFeasibleIdx,:);
                                curpath = curpath(1:info.LastFeasibleIdx,:);
                            end
                        end
                    end
                end
            end
        end
    end

    if any(diff(tstamps) < 0)
        % Restrict planner to feasible portion of the path
        velcmds = velcmds(1:info.LastFeasibleIdx,:);
        tstamps = tstamps(1:info.LastFeasibleIdx,:);
        curpath = curpath(1:info.LastFeasibleIdx,:);
    end
end