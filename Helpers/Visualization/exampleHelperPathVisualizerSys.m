classdef exampleHelperPathVisualizerSys < exampleHelperVisualizerBaseSys
%exampleHelperPathVisualizerSys System object for visualizing maps in Simulink

    % Public, tunable properties
    properties
        %Visualization Parameters
        VisualizationParameters (1,:) cell = {'k-'};
        
        %PlotType
        PlotType (1,1) string {mustBeMember(PlotType,["Line","Quiver"])} = "Line";
    end

    properties (Constant, Access = protected)
        SignalNames = ["Path","nRows"];
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
            path = obj.VizProps{1};
            n = obj.VizProps{2};
            h = exampleHelperVisualizePath(path(1:n,:),obj.VisualizationParameters,obj.VizHandles,Type=obj.PlotType);
        end
    end
end