function exampleHelperVisualizeExcludedPoints(remainingPath,badPts,curpose,radius)
%exampleHelperVisualizeExcludedPoints Visualize points found inside vehicle's radius of curvature
%

% Copyright 2023-2024 The MathWorks, Inc.

    h1 = exampleHelperPlotLines(remainingPath(badPts(:),:),'-x');
    h2 = exampleHelperPlotLines(remainingPath(~badPts(:),:),'-x');
    h3 = exampleHelperPlotTangentArc(curpose,radius,2*pi,'-');
    h4 = exampleHelperPlotTangentArc(curpose,-radius,2*pi,'-');
    L = legend({'Original ReferencePath','','','Interpolated ReferencePath', ...
        'Constraint-Violating LookaheadPoints','Valid LookaheadPoints', ...
        'Unreachable Min-Turn Region (left)','','Unreachable Min-Turn Region (right)',''});
    pause(1);
    delete(L);
    delete(h1);
    delete(h2);
    delete(h3);
    delete(h4);
end