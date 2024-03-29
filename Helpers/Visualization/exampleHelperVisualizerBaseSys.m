classdef exampleHelperVisualizerBaseSys < matlab.System
%exampleHelperVisualizerBaseSys Base class for visualizer

    % Public, tunable properties
    properties
        %Display Visual
        DisplayVisual (1,1) logical = 1;
    end

    properties (Constant, Abstract, Access = protected)
        SignalNames  (1,:) string;
        TunableProps (1,:) string;
    end

    properties (Constant, Access=protected)
        NumInport = numel(exampleHelperVisualizerBaseSys.SignalNames);
    end

    properties (Access = protected)
        VizHandles = {};
    end

    properties (Access = protected,AbortSet)
        VizProps
    end

    % Pre-computed constants or internal states
    properties (Access = private)
        IsFirstStep
        IsDirty = 1;
        PropListener (:,1) event.proplistener;
    end

    methods (Abstract,Access = protected)
        handles = showImpl(obj);
    end

    methods (Access = protected)
        function isVarsize = isInputSizeMutableImpl(obj,idx) %#ok<INUSD>
            isVarsize = false;
        end
        function names = getInputNamesImpl(obj)
            names = obj.SignalNames;
        end
        function num = getNumInputsImpl(obj)
            num = numel(obj.SignalNames);
        end
        function num = getNumOutputsImpl(~)
            % Define total number of inputs for system with optional inputs
            num = 0;
        end
        function setupImpl(obj)
            % Create handles for future use based on which checkboxes have
            % been set
            obj.IsFirstStep = true;
            obj.IsDirty = true;
            
            for i = 1:numel(obj.TunableProps)
                obj.PropListener(i) = addlistener(obj,obj.TunableProps(i),'PostSet',@obj.handleCallbacks);
            end
        end
        function stepImpl(obj,varargin)
            % Attempt to update visualization inputs, if any input changes,
            % the visualization function will execute, otherwise no-op.
            obj.VizProps = varargin;
            
            if ~isempty(obj.VizHandles)
                validHandles = arrayfun(@(x)isvalid(x),obj.VizHandles{:});
                if any(~validHandles)
                    % Start clean
                    obj.reinitHandles;
                    obj.IsDirty = true;
                end
            else
                obj.IsDirty = true;
            end
            obj.IsFirstStep = false;
            obj.show;
            obj.IsDirty = false;
            drawnow limitrate
        end

        function resetImpl(obj)
            % Initialize / reset internal properties
            obj.IsFirstStep = true;
            obj.IsDirty = true;
            if ~isempty(obj.VizHandles)
                delete(obj.VizHandles{:});
            end
        end

        function show(obj)
            if obj.DisplayVisual
                if obj.IsDirty
                    h = obj.showImpl;
                    if ~isempty(h)
                        obj.VizHandles = {h};
                    end
                end
            else
                if ~isempty(obj.VizHandles)
                    delete(obj.VizHandles{:});
                end
            end
        end
    end

    methods % AbortSet setter
        function set.VizProps(obj,vals)
            obj.VizProps = vals;
            isDirty = true;
            for i = 1:obj.NumInport
                if isempty(vals{i})
                    isDirty = true;
                end
            end
            obj.IsDirty = isDirty; %#ok<MCSUP>
        end
        function set.DisplayVisual(obj,val)
            obj.DisplayVisual = val;
            obj.IsDirty = true; %#ok<MCSUP>
        end
    end

    methods (Access = protected)
        function handleCallbacks(obj,varargin)
            obj.propertyChangedCallbacks(varargin{:});
            obj.IsDirty = true;
        end
        function propertyChangedCallbacks(~,varargin)
            % By default this is a no-op. Override this in derived class 
            % to influence desired behavior.
        end
        function reinitHandles(obj)
            % Reset handles
            if ~isempty(obj.VizHandles)
                delete(obj.VizHandles{:});
                obj.VizHandles = {};
            end
        end
    end
end