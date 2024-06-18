function exampleHelperUpdateTEBRefPath(teb,curpose,visualizeExcludedPts)
%exampleHelperUpdateTEBRefPath Attempts to fix the reference path by eliminating
%points that are kinematically unreachable
%

% Copyright 2023-2024 The MathWorks, Inc.

    if nargin == 2
        visualizeExcludedPts = false;
    end
    coder.extrinsic('exampleHelperVisualizeExcludedPoints');

    % Find the current nearest point, and first index considered "far"
    % enough from the near index to have future "bad" points still be
    % considered (e.g. those found later in a back-tracing path)
    r = teb.MinTurningRadius;
    ptDist = vecnorm(teb.ReferencePath(:,1:2)-curpose(1:2),2,2);
    [~,nearIdx] = min(ptDist);
    farIdx = find(ptDist(nearIdx:end,:) > 2*r,1);

    % If any points are within the turn radius, start the refPath at the
    % first point after the excluded region
    remainingPath = teb.ReferencePath(nearIdx:end,:);

    % Find all points within turn radius
    badPts = exampleHelperIdentifyPointInTurningRadius(remainingPath,curpose,r);

    % Exclude goal point, this should always be considered
    if isempty(farIdx)
        badPts(end) = 0;
    else
        badPts(farIdx(1):end) = 0;
    end

    if visualizeExcludedPts
        exampleHelperVisualizeExcludedPoints(remainingPath,badPts,curpose,r);
    end

    % Update the referencePath
    if nnz(~badPts) >= 3
        teb.ReferencePath = remainingPath(~badPts,:);
    end
end