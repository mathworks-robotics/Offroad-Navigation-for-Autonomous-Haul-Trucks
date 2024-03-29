function [Gx,Gmv,Gdmv] = exampleHelperBicycleGradient_MultiStage(i,x,u,dmv,params)
%exampleHelperBicycleGradient_MultiStage Gradient of cost for bicycle kinematic model
%
%   i:                                        (current timestep)
%   x:      [x y theta]                       (i'th state)
%   u:      [v steeringAngle]                 (i'th control)
%   dmv:    [v steeringAngle]                 (rate of change for i'th control)
%   params: [refState(1:3) predictionHorizon] (the target state and total number of timesteps)
%
% Copyright 2024 The MathWorks, Inc.
    
    %#codegen

    arguments
        i (1,1) double {mustBeReal}
        x (:,1) double {mustBeReal}
        u (:,1) double {mustBeReal} %#ok<INUSA>
        dmv (:,1) double {mustBeReal}
        params (:,1) double {mustBeReal}
    end
    
    if i > 1
        W = diag([3 3 3].^2);
        err = x-params(1:3);
        Gx = (W'+W)*err;
    else
        Gx = zeros(3,1);
    end
    
    Gmv = zeros(2,1);

    if i <= params(4)
        Wdmv = diag([0.1 .1].^2);
        Gdmv = (Wdmv' + Wdmv)*dmv;
    else 
        Gdmv = zeros(2,1);
    end
end