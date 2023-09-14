function [length, width, turnRadius, maxFV, maxRV, maxW] = exampleHelperMiningTruckSpecs
%exampleHelperMiningTruckSpecs Generate default parameters for an industrial mining vehicle
%
% Copyright 2023 The MathWorks, Inc.

    % turnRadius = 17.2;
    % width = 5.76; (rear-track width)
    % length/ wheelbase: 6.5 m
    % Max speed: 36 mph (16 m/s)

    % Max accel
    % https://www.sciencedirect.com/science/article/pii/S204604301630034X#:~:text=Statistics%20results%20indicate%20that%20on,mph%20in%20500%20feet%2C%20respectively.
    % 30 mph = 13.4 m/s
    % 500 ft = 152 meters
    % max accel = (13.4 - 0)/(152/(13.4/2)) % [v2 - v1]/(d/avg(v)) ~ 0.6 m/s/s

    % Length of mining truck (in meters)
    length = 6.5;

    % Width of mining truck (in meters)
    width = 5.76;

    % Minimum turning radius for the mining truck (meters)
    turnRadius = 17.2;

    % Maximum forward velocity (m/s)
    maxFV = 16;
    % Maximum reverse velocity (50% of the forward velocity) (m/s)
    maxRV = 0.5* maxFV;
    % Maximum angular velocity (rad/ sec)
    maxW = maxFV/turnRadius;

end