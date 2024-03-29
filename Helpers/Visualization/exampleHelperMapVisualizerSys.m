classdef exampleHelperMapVisualizerSys < exampleHelperVisualizerBaseSys
%exampleHelperMapVisualizerSys System object for visualizing maps in Simulink

    % Public, tunable properties
    properties
        %Map Type
        MapType  (1,1) string {mustBeMember(MapType,["SDF","Occ","Bin","Generic"])} = "SDF";

        %Is Ego
        IsEgo (1,1) logical {mustBeMember(IsEgo,[0 1])} = 0;
    end

    properties (Constant, Access = protected)
        VisFunctionStr = "exampleHelperVisualizeMap";
        SignalNames = ["mat" "gridSize" "res" "gridLoc"];
        TunableProps = [];
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
            [mat,sz,res,loc] = deal(obj.VizProps{:});
            [~,h] = exampleHelperVisualizeMap(mat,res,loc,Ego=obj.IsEgo,GridSize=sz,Type=obj.MapType);
        end
    end
end