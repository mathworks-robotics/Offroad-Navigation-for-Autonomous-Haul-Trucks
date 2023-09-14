function [tuneablePlannerParams,nonTuneablePlannerParams] = exampleHelperTerrainPlannerParams
%exampleHelperTerrainPlannerParams Generate default values for a parameterized plannerHybridAStar 
%
% Copyright 2023 The MathWorks, Inc.

    [length, width, turnRadius] = exampleHelperMiningTruckSpecs;

    % Create struct for tuneable params
    tuneablePlannerParams = struct();
    tuneablePlannerParams.MinTurningRadius = turnRadius;
    tuneablePlannerParams.MotionPrimitiveLength = turnRadius*75/180*pi; % Max 75 degree turns over primitive length
    tuneablePlannerParams.ForwardCost = 1;
    tuneablePlannerParams.ReverseCost = 1;
    tuneablePlannerParams.DirectionSwitchingCost = 1;
    tuneablePlannerParams.MaxAngle = 15;

    % Create struct for non-tuneable params
    nonTuneablePlannerParams = struct();
    nonTuneablePlannerParams.Length = length;
    nonTuneablePlannerParams.Width = width;
    nonTuneablePlannerParams.Width = width;
    nonTuneablePlannerParams.NumMotionPrimitives = 5;
    nonTuneablePlannerParams.AnalyticExpansionInterval = 3;
    nonTuneablePlannerParams.InterpolationDistance = 1;
    nonTuneablePlannerParams.NumCircles = 3;
    nonTuneablePlannerParams.Resolution = 1;
end