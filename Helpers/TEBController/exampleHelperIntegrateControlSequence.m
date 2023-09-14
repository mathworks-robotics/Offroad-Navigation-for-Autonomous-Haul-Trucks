function optPath = exampleHelperIntegrateControlSequence(initPose,velcmds,timestamps,dt)
%exampleHelperIntegrateControlSequence Generates the optimal path from time-stamped
%velocity commands at the specified integration step-size
%
% Copyright 2023 The MathWorks, Inc.

    curpose = initPose;
    t = 0;
    tIdxPrev = 0;
    statedot = zeros(1,3);
    optPath = zeros(numel(timestamps),3);
    while t < timestamps(end)
        curpose = curpose + statedot * dt;
        velcmd = velocityCommand(velcmds, timestamps, t);
        tIdx = discretize(t,timestamps);
        assert(isequal(velcmds(tIdx,:),velcmd));
        if tIdx ~= tIdxPrev
            optPath(tIdx,:) = curpose - statedot*(t-timestamps(tIdx));
            tIdxPrev = tIdx;
        end
        % Very basic robot model, should be replaced by simulator.
        statedot = [velcmd(1)*cos(curpose(3)) ...
                    velcmd(1)*sin(curpose(3)) ...
                    velcmd(2)];
        t = t+dt;
    end

    optPath(end,:) = curpose + statedot * (timestamps(end)-(t-dt));
end