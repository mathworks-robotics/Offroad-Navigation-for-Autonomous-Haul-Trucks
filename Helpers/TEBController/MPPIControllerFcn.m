function [velcmds,optpath,sampleTime,needGlobalReplan,needLocalReplan,trajs,numTrajs,lookaheadPoses] = MPPIControllerFcn(...
    mat,res,gridLoc,refPathXY,isRefPathChanged,curpose,curvel,controllerParams,length,width)
% MPPIControllerFcn return the optimal velocity commands using MPPI
% controller

% Copyright 2024-2025 The MathWorks, Inc.
    
    persistent mppiObj
    persistent mapObj
    persistent vehicleObj;
    persistent numberOfViolations;
    
    if isempty(numberOfViolations)
        numberOfViolations = 0;
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
   
    [velcmds,optpath,info,numTrajs,needLocalReplan,needGlobalReplan,resetNumViolations] = stepImpl(mppiObj, controllerParams, numberOfViolations,curpose,curvel);
    sampleTime = mppiObj.SampleTime;
    trajs = info.Trajectories;   
    lookaheadPoses = info.LookaheadPoses;
    if resetNumViolations
        numberOfViolations = 0;
    else       
        numberOfViolations = numberOfViolations + 1;
    end
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

function [velcmds,optpath,info,numTrajs,needLocalReplan,needGlobalReplan,resetNumViolations] = stepImpl(mppiObj, controllerParams, numberOfViolations,curpose,curvel)
% stepImp return the control commands from the MPPI controller.

needLocalReplan = false;
needGlobalReplan = false;
resetNumViolations = true;
if numberOfViolations > 0
    % When constraints are violated in previous MPPI output, relax the
    % parameters in MPPI temporarily. The number of trajectories are doubled
    % increase the standard deviation, and keep the PathFollowing cost
    % to 0 and restore them back after velocity commands are generated.
    mppiObj.NumTrajectory = 2*controllerParams.NumTrajectory;
    stdDev = controllerParams.StandardDeviation;
    mppiObj.StandardDeviation = [stdDev(1) 2*stdDev(2)];
    mppiObj.Parameter.CostWeight.PathAlignment = 0;
    numTrajs = mppiObj.NumTrajectory;
    % Generate optimal local path
    [velcmds,optpath,info] = mppiObj(curpose(:)',curvel(:)');
    mppiObj.NumTrajectory = controllerParams.NumTrajectory;
    mppiObj.StandardDeviation = stdDev;
    mppiObj.Parameter.CostWeight.PathAlignment = controllerParams.PathAlignmentCost;    
else
    [velcmds,optpath,info] = mppiObj(curpose(:)',curvel(:)');
    numTrajs = mppiObj.NumTrajectory;
end

if info.ExitFlag == 1
    if numberOfViolations == 0
        % Trigger local replan if the mppi output trajectory has constraints 
        % violated and previous mppi call did not result in violation.      
        needLocalReplan = true;
        resetNumViolations = false; 
    elseif numberOfViolations >= 1
        % Trigger global replan if constraint violation occured on consecutive MPPI calls 
        needGlobalReplan = true;
    end
elseif info.ExitFlag == 2
    % Trigger global replan if the vehicle is far from reference path.
    needGlobalReplan = true;
end

end
