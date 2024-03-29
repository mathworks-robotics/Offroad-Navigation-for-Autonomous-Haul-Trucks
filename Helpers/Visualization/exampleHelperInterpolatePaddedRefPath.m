function paddedRefPath = exampleHelperInterpolatePaddedRefPath(localReferencePath, nominalSpeed, MPCSampleTime, direction, maxPathlength)

    waypointSpacing = nominalSpeed*MPCSampleTime;    
    localReferencePathInterpolated = exampleHelperArcInterp(localReferencePath, "StepSize", waypointSpacing, "Direction", direction);

    sz = size(localReferencePathInterpolated,1);

    paddedRefPath = repmat(localReferencePath(end,:),maxPathlength,1);
    if(sz > maxPathlength)
        error("Interpolated path exceeds maximum path length");        
    end        
    paddedRefPath(1:sz,:) = localReferencePathInterpolated;
end 