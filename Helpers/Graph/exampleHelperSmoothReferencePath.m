function resampledPath = exampleHelperSmoothReferencePath(path,step)
%exampleHelperSmoothReferencePath Attempts to smooth the path by fitting a cubic polynomial
% Fits a cubic polynomial through every third point along a path. 
% Path is then resampled and with orientation computed via 
% finite-differencing. This provides the TEB controller with a 
% slightly smoother reference path, increasing its ability to 
% produce smooth local trajectories.
%
% Copyright 2023 The MathWorks, Inc.

    arguments 
        path (:,:) {mustBeNumeric}
        step (1,1) {mustBeInteger,mustBePositive} = 3;
    end

    % Create unit-timesteps for the polynomial trajectory sampled 
    % at every Nth point
    dState = vecnorm(diff(path(1:step:end,1:2)),2,2);
    dState(dState==0) = 1;
    t = cumsum([0;dState]);

    % Resample the path at even intervals (interlaced with slight 
    % dt offset for finite differencing)
    tSample = linspace(0,t(end),size(path,1)) + [0; 1e-5];
    tSample(:,end) = tSample(:,end)-1e-5;
    Q = cubicpolytraj(path(1:step:end,1:2)',t(:)',tSample(:))';

    % Use finite-diff to approximate orientation
    v = reshape(diff(reshape(Q,2,[]),1),[],2);
    angles = atan2(v(:,2),v(:,1));
    
    % Construct the path
    resampledPath = zeros(size(path,1),3);
    resampledPath(:,1:2) = Q(1:2:end,:);
    resampledPath(:,3) = angles;

    if size(path,2) == 3
        % Reset initial and final orientations to the current 
        % orientation, and goal orientation, respectively.
        resampledPath([1,end],end) = path([1 end],end);
    end
end