function [length, width, turnRadius, maxFV, maxRV, maxW, maxLA] = exampleHelperMiningTruckSpecs
%exampleHelperMiningTruckSpecs Generate default parameters for an
%industrial haul truck
%

% Copyright 2023-2024 The MathWorks, Inc.

    % turnRadius = 17.2;
    % width = 5.76; (rear-track width)
    % length/ wheelbase: 6.5 m
    % Max speed: 36 mph (16 m/s)

    % Max linear accel [1]
    % 30 mph = 13.4 m/s
    % 500 ft = 152 meters
    % max linear accel = (13.4 - 0)/(152/(13.4/2)) % [v2 - v1]/(d/avg(v)) ~ 0.6 m/s/s
    % [1] Yang, Guangchuan, Hao Xu, Zhongren Wang, and Zong Tian. “Truck Acceleration Behavior Study and Acceleration Lane Length Recommendations for Metered On-Ramps.” International Journal of Transportation Science and Technology 5, no. 2 (October 2016): 93–102. https://doi.org/10.1016/j.ijtst.2016.09.006.
    maxLA = round((13.4 - 0)/(152/(13.4/2)),1);

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