function [tuneableTEBParams,fixedTEBParams] = exampleHelperTEBParams
%exampleHelperTEBParams Generate default values for a parameterized controllerTEB
%
% Copyright 2023 The MathWorks, Inc.

    [length, width, turnRadius, maxFV, maxRV, maxW] = exampleHelperMiningTruckSpecs;
    robotInfo = exampleHelperVehicleGeometry(length,width,"teb");

    tuneableTEBParams = struct();
    tuneableTEBParams.LookaheadTime = 6; % 6
    tuneableTEBParams.ObstacleSafetyMargin = 1;
    tuneableTEBParams.CostWeights.Time = 100; %100
    tuneableTEBParams.CostWeights.Smoothness = 500; %500
    tuneableTEBParams.CostWeights.Obstacle = 10; %50
    tuneableTEBParams.MinTurningRadius = turnRadius;  % turnRadius
    tuneableTEBParams.MaxVelocity = [maxFV maxW];
    tuneableTEBParams.MaxAcceleration = [0.6 0.1]; % see calculations above
    tuneableTEBParams.MaxReverseVelocity = maxRV;

    fixedTEBParams = struct();
    fixedTEBParams.Length = length;
    fixedTEBParams.Width = width;
    fixedTEBParams.NumIteration = 1;
    fixedTEBParams.ReferenceDeltaTime = 0.2;
    fixedTEBParams.RobotInformation = robotInfo;
end