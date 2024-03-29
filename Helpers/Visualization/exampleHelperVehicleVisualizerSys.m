classdef exampleHelperVehicleVisualizerSys < exampleHelperVisualizerBaseSys
%exampleHelperVehicleVisualizerSys System object for visualizing a vehicleCollisionChecker in Simulink

    % Public, tunable properties
    properties
        %Num Collision Circles?
        NumCircles (1,1) double {mustBeInteger} = 3

        %Length
        Length (1,1) double {mustBeFinite} = 4

        %Width
        Width (1,1) double {mustBeFinite} = 2
    end

    properties (Constant, Access = protected)
        VisFunctionStr = "exampleHelperVisualizeMap";
        SignalNames = ["curPose"];
        TunableProps = [];
    end

    % Pre-computed constants or internal states
    properties (Access = private,AbortSet)
        IsFirstStep
    end

    methods (Access = protected)
        function varsize = isInputSizeMutableImpl(obj,idx)
            if obj.DisplayVisual && idx == 1
                varsize = true;
            else
                varsize = false;
            end
        end
        function h = showImpl(obj)
            curPose = obj.VizProps{1};
            h = exampleHelperVisualizeVehicle(curPose,obj.Length,obj.Width,obj.VizHandles{:});
        end
    end
end