function quiverHandle = exampleHelperPose2Quiver(poses,spec,nvPair)
%exampleHelperPose2Quiver Display Nx3 SE2 array as quiver
%

% Copyright 2023-2024 The MathWorks, Inc.

    arguments
        poses (:,:) double {validatePoses(poses)}
        spec = {};
        nvPair.Handle (1,1) {mustBeA(nvPair.Handle,'matlab.graphics.chart.primitive.Quiver')} = quiver(nan,nan,nan,nan,"AutoScale","off");
        nvPair.ZeroPoseVector = nan
        nvPair.ArrowSize (1,1) {mustBePositive, mustBeReal} = 1;
    end
    [N,D] = size(poses,1,2);
    quiverHandle = nvPair.Handle;
    
    switch D
        case 3
            L = nvPair.ArrowSize;
            if isnan(nvPair.ZeroPoseVector)
                th0 = 0;
            else
                v = nvPair.ZeroPoseVector(1:2);
                th0 = atan2(v(2),v(1));
            end
            th = th0+poses(:,3);
            set(quiverHandle,'XData',poses(:,1),'YData',poses(:,2),'UData',cos(th)*L,'VData',sin(th)*L,spec{:},'MaxHeadSize',L);
        otherwise
            if isnan(nvPair.ZeroPoseVector)
                v = [1 0 0];
            else
                v = normalize(nvPair.ZeroPoseVector(1:3),"norm");
            end
            v = v*nv.ArrowSize;
            
            q = quaternion(poses(:,4:end));
            V = q.rotatepoint(v);
            set(quiverHandle,'XData',poses(:,1),'YData',poses(:,2),'ZData',poses(:,3), ...
                'UData',V(:,1),'VData',V(:,2),'WData',V(:,3),spec{:},'MaxHeadSize',nvPair.ArrowSize);
    end
end

function validatePoses(poses)
    assert(any(size(poses,2)==[3 7]));
end