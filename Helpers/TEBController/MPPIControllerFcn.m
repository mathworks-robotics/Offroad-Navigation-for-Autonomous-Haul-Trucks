function [velcmds,optpath,sampleTime,needGlobalReplan,needLocalReplan,trajs,numTrajs,lookaheadPoses] = MPPIControllerFcn(...
    mat,res,gridLoc,refPathXY,isRefPathChanged,curpose,curvel,controllerParams,length,width)
% MPPIControllerFcn return the optimal velocity commands using MPPI
% controller

% Copyright 2024-2025 The MathWorks, Inc.
    
    persistent mppiObj
    persistent mapObj
    persistent vehicleObj;
    persistent constraintViolated;
    
    if isempty(constraintViolated)
        constraintViolated = 0;
    end
    
    if isempty(mapObj)
        mapObj = createMap(mat, res, gridLoc);
    else
        setMapData(mapObj, mat);
        mapObj.GridLocationInWorld = gridLoc;
    end                    
    if isempty(vehicleObj)
        vehicleObj = createVehicleModel(length,controllerParams);    
    end    

    if isempty(mppiObj)
        mppiObj = createMPPI(mapObj,vehicleObj,refPathXY,controllerParams,length,width);
    elseif isRefPathChanged
        mppiObj.ReferencePath = refPathXY;
    end
   
    [velcmds,optpath,info,numTrajs,needLocalReplan,needGlobalReplan] = stepImp(mppiObj, controllerParams, constraintViolated,curpose,curvel);
    sampleTime = mppiObj.SampleTime;
    trajs = info.Trajectories;   
    lookaheadPoses = info.LookaheadPoses;
end


function localMap = createMap(mat, res, gridLoc)
localMap = signedDistanceMap(mat,res,InterpolationMethod='linear');
localMap.GridOriginInLocal = -localMap.GridSize/(2*localMap.Resolution);
localMap.GridLocationInWorld = gridLoc(:)';
end

function vehicleObj = createVehicleModel(length,controllerParams)
vehicleObj = bicycleKinematics("VehicleInputs","VehicleSpeedHeadingRate");
vehicleObj.WheelBase = length;
maxForwardVel = controllerParams.MaxVelocity(1);
maxReverseVel = -controllerParams.MaxReverseVelocity;
vehicleObj.VehicleSpeedRange = [maxReverseVel maxForwardVel]; % [min, max velocity]
vehicleObj.MaxSteeringAngle = controllerParams.MaxSteeringAngle;
end

function mppi = createMPPI(mapObj,vehicleObj,refPathXY,mppiParameters,length, width)
% createMPPI create MPPI and set the parameters
mppi = offroadControllerMPPI(refPathXY,Map=mapObj,VehicleModel=vehicleObj);
% Configure cost weights parameters
mppi.Parameter.CostWeight.PathFollowing =mppiParameters.PathFollowingCost;
mppi.Parameter.CostWeight.PathAlignment = mppiParameters.PathAlignmentCost;
mppi.Parameter.ObstacleSafetyMargin = mppiParameters.ObstacleSafetyMargin;
mppi.LookaheadTime = mppiParameters.LookaheadTime; % In sec
mppi.NumTrajectory = mppiParameters.NumTrajectory;
mppi.Parameter.CostWeight.ObstacleRepulsion = mppiParameters.ObstacleRepulsion;
mppi.Parameter.VehicleCollisionInformation = struct("Dimension",[length, width],"Shape","Rectangle");
end

function [velcmds,optpath,info,numTrajs,needLocalReplan,needGlobalReplan] = stepImp(mppiObj, controllerParams, constraintViolated,curpose,curvel)
% stepImp return the control commands from the MPPI controller.

needLocalReplan = 0;
needGlobalReplan = 0;

if constraintViolated == 1
    % When constraints are violated in previous MPPI output, relax the
    % parameters in MPPI temporarily. The number of trajectories are doubled
    % increase the standard deviation, and keep the PathFollowing cost
    % to 0 and restore them back after velocity commands are generated.
    mppiObj.NumTrajectory = 2*controllerParams.NumTrajectory;
    stdDev = controllerParams.StandardDeviation;
    mppiObj.StandardDeviation = [stdDev(1) 2*stdDev(2)];
    mppiObj.Parameter.CostWeight.PathFollowing = 0.1;
    numTrajs = mppiObj.NumTrajectory;
    % Generate optimal local path
    [velcmds,optpath,info] = mppiObj(curpose(:)',curvel(:)');
    mppiObj.NumTrajectory = controllerParams.NumTrajectory;
    mppiObj.StandardDeviation = stdDev;
    mppiObj.Parameter.CostWeight.PathFollowing = controllerParams.PathFollowingCost;   
else
    [velcmds,optpath,info] = mppiObj(curpose(:)',curvel(:)');
    numTrajs = mppiObj.NumTrajectory;
end

% Trigger local replan if the mppi output trajectory has constraints violated. 
if info.ExitFlag == 1
    needLocalReplan = 1;
% Trigger global replan if the vehicle is far from reference path or it did
% not move using previous controls. 
elseif info.ExitFlag == 2
    needGlobalReplan = 1;
end

end
