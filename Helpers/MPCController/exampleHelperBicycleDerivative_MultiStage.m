function dxdt = exampleHelperBicycleDerivative_MultiStage(x, u, p)
%exampleHelperBicycleDerivative_MultiStage Compute derivative for bicycle kinematic model
%
%   x: [x y theta]          (state)
%   u: [v steeringAngle]    (control)
%   p: [vWheelBase]         (parameters)
%
% Copyright 2024 The MathWorks, Inc.

arguments
    x (:,1) double {mustBeReal}
    u (:,1) double {mustBeReal}
    p (1,1) double {mustBeReal}
end

    % Parameters
    vWheelBase = p(1);
    
    % Variables
    theta = x(3);
    v = u(1);
    steeringAngle = u(2);
    
    % State equations
    dxdt = zeros(3,1);
    dxdt(1) = v*cos(theta);
    dxdt(2) = v*sin(theta);
    dxdt(3) = v/vWheelBase*tan(steeringAngle);
end