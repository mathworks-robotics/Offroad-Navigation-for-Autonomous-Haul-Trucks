function [A, B] = exampleHelperBicycleJacobian_MultiStage(x, u, p)
%exampleHelperBicycleJacobian_MultiStage Compute jacobian for bicycle kinematic model
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
    alpha = u(2);
    
    % Linearize the state equations at the current condition
    A = zeros(3,3);
    B = zeros(3,2);
    
    A(1,3) = -v*sin(theta);
    A(2,3) =  v*cos(theta);
    
    B(1,1) = cos(theta);
    B(2,1) = sin(theta);
    
    B(3,1) = tan(alpha)/vWheelBase;
    B(3,2) = v/vWheelBase*(sec(alpha)^2);
end
