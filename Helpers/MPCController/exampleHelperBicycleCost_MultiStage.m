function cost =  exampleHelperBicycleCost_MultiStage(i,x,u,udot,params)
%exampleHelperBicycleCost_MultiStage Compute cost for bicycle kinematic model
%
%   i:                                        (current timestep)
%   x:      [x y theta]                       (i'th state)
%   u:      [v steeringAngle]                 (i'th control)
%   dmv:    [v steeringAngle]                 (rate of change of the manipulated variables)
%   params: [refState(1:3) predictionHorizon] (the target state and total number of timesteps)
%
% Copyright 2024 The MathWorks, Inc.
    
    %#codegen

    arguments
        i (1,1) double {mustBePositive}
        x (:,1) double {mustBeReal}
        u (:,1) double {mustBeReal} %#ok<INUSA>
        udot (:,1) double {mustBeReal}
        params (:,1) double {mustBeReal}
    end
    
    cost = 0;

    if i > 1
        W = diag([3 3 3].^2); %weight vector squared
        err = x-params(1:3);
        cost = cost + err'*W*err;
    end 
    
    if i <= params(4)
        Wdmv = diag([0.1 .1].^2); %weight vector squared
        % dmv is used to penalize high-frequency control movement
        cost = cost + udot'*Wdmv*udot;
    end
end