function [tuneableTEBParams,fixedTEBParams] = exampleHelperTEBParams
%exampleHelperTEBParams Generate default values for a parameterized controllerTEB
%

% Copyright 2023-2024 The MathWorks, Inc.

    [length, width, turnRadius, maxFV, maxRV, maxW, maxLA] = exampleHelperMiningTruckSpecs;
    robotInfo = exampleHelperVehicleGeometry(length,width,"teb");

    tuneableTEBParams = struct();
    tuneableTEBParams.LookaheadTime = 6; % sec
    tuneableTEBParams.ObstacleSafetyMargin = 1;% meter
    tuneableTEBParams.CostWeights.Time = 100; 
    tuneableTEBParams.CostWeights.Smoothness = 500;
    tuneableTEBParams.CostWeights.Obstacle = 10; 
    tuneableTEBParams.MinTurningRadius = turnRadius;  % meter
    tuneableTEBParams.MaxVelocity = [maxFV maxW]; % [meter/sec rad/sec]
    tuneableTEBParams.MaxAcceleration = [maxLA 0.1]; % [meter/sec/sec rad/sec/sec]
    tuneableTEBParams.MaxReverseVelocity = maxRV; % meter/second

    fixedTEBParams = struct();
    fixedTEBParams.Length = length; % meter
    fixedTEBParams.Width = width; % meter
    fixedTEBParams.NumIteration = 3;
    fixedTEBParams.ReferenceDeltaTime = 0.2; % sec
    fixedTEBParams.RobotInformation = robotInfo;
end