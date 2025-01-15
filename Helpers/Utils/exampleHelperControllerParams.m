function [tuneableControllerParams,fixedControllerParams] = exampleHelperControllerParams
% exampleHelperControllerParams Generate default values for local planners.

% Copyright 2023-2025 The MathWorks, Inc.

    [length, width, turnRadius, maxFV, maxRV, maxW, maxLA] = exampleHelperMiningTruckSpecs;
    robotInfo = exampleHelperVehicleGeometry(length,width,"teb");

    tuneableControllerParams = struct();
    tuneableControllerParams.LookaheadTime = 4; % sec
    tuneableControllerParams.ObstacleSafetyMargin = 1;% meter
    tuneableControllerParams.CostWeights.Time = 100; 
    tuneableControllerParams.CostWeights.Smoothness = 500;
    tuneableControllerParams.CostWeights.Obstacle = 10; 
    tuneableControllerParams.MinTurningRadius = turnRadius;  % meter
    tuneableControllerParams.MaxVelocity = [maxFV maxW]; % [meter/sec rad/sec]
    tuneableControllerParams.MaxAcceleration = [maxLA 0.1]; % [meter/sec/sec rad/sec/sec]
    tuneableControllerParams.MaxReverseVelocity = maxRV; % meter/second
    tuneableControllerParams.MaxSteeringAngle = pi/4;
    tuneableControllerParams.PathFollowingCost = 1;
    tuneableControllerParams.PathAlignmentCost = 1.3;
    tuneableControllerParams.NumTrajectory = 300;
    tuneableControllerParams.ObstacleRepulsion = 200;
    tuneableControllerParams.StandardDeviation = [2 0.5];

    fixedControllerParams = struct();
    fixedControllerParams.Length = length; % meter
    fixedControllerParams.Width = width; % meter
    fixedControllerParams.NumIteration = 3;
    fixedControllerParams.ReferenceDeltaTime = 0.2; % sec
    fixedControllerParams.RobotInformation = robotInfo;
end