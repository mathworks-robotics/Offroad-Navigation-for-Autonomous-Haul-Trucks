function [velcmds,timestamps,optpath,nearestIdx,info,needLocalReplan,needFreeSpaceReplan] = TEBControllerFcn(...
    mat,res,gridLoc,refPathXY,lastIdx,curpose,curvel,tuneableTEBParams,length, width, numIteration, referenceDeltaTime)
%TEBControllerFcn Wrapper of persistent controllerTEB planner
%
% Copyright 2023 The MathWorks, Inc.
    persistent adjustedPath

    if isempty(adjustedPath)
        adjustedPath = 0;
    end

    % Initialize TEB planner
    teb = exampleHelperTEBFriend.initTEB(mat,res,length,width, ...
        refPathXY,lastIdx,curpose,numIteration,referenceDeltaTime, ...
        gridLoc,tuneableTEBParams);

    % Generate optimal local path
    [velcmds_,timestamps_,optpath_,info] = teb(curpose(:)',curvel(:)');

    % Post-process the TEB results, handling error codes and constraint
    % violations.
    [velcmds,timestamps,optpath,adjustedPath,needLocalReplan,needFreeSpaceReplan] = ...
        exampleHelperProcessTEBErrorCodes(teb,curpose,curvel,velcmds_,timestamps_,optpath_,info,adjustedPath,length,width);

    if ~needLocalReplan && ~needFreeSpaceReplan
        % Reset replan flag if TEB or post-processing was successful
        adjustedPath = 0;
    end

    % Extract closest index
    nearestIdx = exampleHelperTEBFriend.getNearestIdx(teb);
end