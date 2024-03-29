classdef exampleHelperGraphVisualizerSys < exampleHelperVisualizerBaseSys
%exampleHelperGraphVisualizerSys System object for visualizing navGraph in Simulink

    % Public, tunable properties
    properties
        %Node Color
        NodeColor (1,1) string = 'r';

        %Node Color
        EdgeColor (1,1) string = 'r';

        %Line Style
        LineStyle (1,1) string = '-';

        %Custom Graph LineSpec
        GraphSpec (1,:) = {};

        %Network Color
        NetworkColor (1,1) string = 'b';

        %Network Style
        NetworkStyle (1,1) string = ':';

        %Custom Network LineSpec
        NetworkSpec (1,:) = {};
    end

    properties (AbortSet,SetObservable)
        %Max Element Per Edge
        MaxEdgeElem (1,1) double {mustBePositive} = inf;

        %Network Alpha
        NetworkAlpha (1,1) double {mustBeInRange(NetworkAlpha,0,1)} = 1;

        %Edge Alpha
        EdgeAlpha (1,1) double {mustBeInRange(EdgeAlpha,0,1)} = 1;
    end

    properties (Constant, Access = protected)
        VisFunctionStr = "exampleHelperVisualizeMap";
        SignalNames = ["pathList"];
        TunableProps = ["MaxEdgeElem","NetworkAlpha","EdgeAlpha"];
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
            if isempty(obj.VizHandles)
                hGraph = {};
                hNetwork = {};
            else
                hGraph = {obj.VizHandles{1}(1)};
                hNetwork = {obj.VizHandles{1}(2)};
            end
            
            % Decode bus
            pathList = exampleHelperDecodeBus(obj.VizProps{:});
            [nodes,edges] = exampleHelperPath2GraphData(pathList,obj.MaxEdgeElem);

            % Display Graph
            hGraph = {exampleHelperVisualizeGraph(nodes,edges,hGraph{:},...
                    EdgeColor=obj.EdgeColor,EdgeAlpha=obj.EdgeAlpha,LineStyle=obj.LineStyle,NodeColor=obj.NodeColor)};
            set(hGraph{:},obj.GraphSpec{:});

            % Display Road Network
            netLine = arrayfun(@(x)[x.Path; nan(1,size(x.Path,2))],pathList,UniformOutput=false);
            hNetwork = {exampleHelperVisualizePath(vertcat(netLine{:}),{"Color",obj.NetworkColor, ...
                "LineStyle",obj.LineStyle,obj.NetworkSpec{:}},hNetwork,Type="Line")}; %#ok<CCAT>
            set(hNetwork{:},Color=[hNetwork{1}.Color obj.NetworkAlpha]);
            h = [hGraph{:};hNetwork{:}];
        end
    end

    methods (Access = protected)
        function propertyChangedCallbacks(obj,src,~)
            switch src.Name
                case "MaxEdgeElem"
                    obj.reinitHandles;
                otherwise
                    % No change needed
            end
        end
    end
end