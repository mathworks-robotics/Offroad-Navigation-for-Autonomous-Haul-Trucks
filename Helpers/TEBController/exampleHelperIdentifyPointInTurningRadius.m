function isInside = exampleHelperIdentifyPointInTurningRadius(refPath,curpose,minTurnRadius)
%exampleHelperIdentifyPointInTurningRadius Find points in path within vehicle's radius of curvature
    ctrs = exampleHelperComputeArcCenter(curpose,minTurnRadius*[-1;1]);
    dist = min(vecnorm(ctrs(1,:)-refPath(:,1:2),2,2),vecnorm(ctrs(2,:)-refPath(:,1:2),2,2));
    isInside = dist < abs(minTurnRadius);
end