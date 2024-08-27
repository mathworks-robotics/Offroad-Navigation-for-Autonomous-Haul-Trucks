function [hTag, ccHandles] = exampleHelperCreateVehicleGraphic(ax,poseMode,checker)
%exampleHelperCreateVehicleGraphic Creates hgtransform-wrapped inflationCollisionChecker
%

% Copyright 2023-2024 The MathWorks, Inc.

    arguments
        ax
        poseMode (1,1) string {mustBeMember(poseMode,["Start","Goal"])} = "Start";
        checker (1,1) = inflationCollisionChecker(NumCircles=3);
    end

    hTag = "CollisionChecker";

    if nargout > 1
        % Display collision checker
        hold on;
        ax.Visible = "off";
        x = ax.XLim;
        y = ax.YLim;
        checker.plot('Parent',ax,'Ruler','off');

        % Steal handles and reparent to hgTransform
        ccHandles = ax.Children(1:9);

        if isequal(poseMode,'Start')
            ccHandles(end).FaceColor = [1 0 0];
        else
            ccHandles(end).FaceColor = [0 1 0];
        end

        ax.XLim = x;
        ax.YLim = y;
        ax.Visible = "on";
    end
end