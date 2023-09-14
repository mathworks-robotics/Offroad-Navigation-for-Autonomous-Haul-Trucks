function [h,xCtr] = exampleHelperPlotTangentArc(pose,R,dTh,spec)
%exampleHelperPlotTangentArc Plot arc tangent to a given pose with signed radius
%
% Copyright 2023 The MathWorks, Inc.

    if nargin ~= 4
        spec = {'--'};
    else
        if ~iscell(spec)
            spec = {spec};
        end
    end
    xCtr = exampleHelperComputeArcCenter(pose,R);
    t = linspace(0,dTh,100)'+pose(:,3)-pi/2;
    xy = xCtr+R*[cos(t) sin(t)];
    h = plot(xy(:,1),xy(:,2),spec{:});
    hold on;
    exampleHelperPlotLines([xy(1,:);xCtr;xy(end,:)],'k--');
end