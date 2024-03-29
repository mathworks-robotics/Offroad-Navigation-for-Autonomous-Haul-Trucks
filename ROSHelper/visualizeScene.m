classdef visualizeScene < matlab.System
    % untitled3 Add summary here
    %
    % This template includes the minimum set of functions required
    % to define a System object.

    % Public, tunable properties
    properties
        %Show Map?
        ShowMap  (1,1) logical = true
        %Show Path?
        ShowPath (1,1) logical = true
        %Map Type
        MapType  (1,1) string {mustBeMember(MapType,["SDF","Occ","Bin","Generic"])} = "SDF";
        %Show Vehicle?
        ShowVehicle (1,1) logical = false;
        %Show Local Path?
        ShowLocalPath (1,1) logical = false;
        %Path Spec
        PathSpec (1,:) cell = {'g'};
        %Local Path Spec
        LocalPathSpec (1,:) cell = {'b'};
    end

    % Pre-computed constants or internal states
    properties (Access = private,AbortSet)
        IsFirstStep
        PathHandle = {};
        VehicleHandle = {};
        LocalPathHandle = {};
        MapProps
        PathProps
        VehicleProps
        LocalPathProps
    end

    properties (Access = protected)
        MapDirty = 1;
        PathDirty = 1;
        VehicleDirty = 1;
        LocalPathDirty = 1;
    end

    methods (Access = protected)
        function varsize = isInputSizeMutableImpl(obj,idx)
            if obj.ShowMap && idx == 1
                varsize = true;
            else
                varsize = false;
            end
        end
        function names = getInputNamesImpl(obj)
            names = [];
            if obj.ShowMap
                names = [names "mat" "res" "gridSize" "gridLoc"];
            end
            if obj.ShowPath
                names = [names "path" "nPathRows"];
            end
            if obj.ShowVehicle
                names = [names "curPose"];
            end
            if obj.ShowLocalPath
                names = [names "localPath" "nLocalPathRows"];
            end
        end
        function num = getNumInputsImpl(obj)
            % Define total number of inputs for system with optional inputs
            num = 0;
            if obj.ShowMap
                num = num+4;
            end
            if obj.ShowPath
                num = num+2;
            end
            if obj.ShowVehicle
                num = num+1;
            end
            if obj.ShowLocalPath
                num = num+2;
            end
        end
        function num = getNumOutputsImpl(~)
            % Define total number of inputs for system with optional inputs
            num = 0;
        end
        function setupImpl(obj)
            % Create handles for future use based on which checkboxes have
            % been set
            obj.IsFirstStep = true;
            obj.MapDirty = true;
            obj.PathDirty = true;
            obj.VehicleDirty = true;
            obj.LocalPathDirty = true;
        end

        function stepImpl(obj,varargin)
            % Implement algorithm. Calculate y as a function of input u and
            % internal states.
            coder.extrinsic('exampleHelperVisualizePath');
            coder.extrinsic('exampleHelperVisualizeMap');
            n = 0;
            if obj.ShowMap
                obj.MapProps = varargin(n+(1:4));
                n = n+4;
            end
            if obj.ShowPath
                obj.PathProps = varargin(n+(1:2));
                n = n+2;
            end
            if obj.ShowVehicle
                obj.VehicleProps = varargin(n+1);
                n = n+1;
            end
            if obj.ShowLocalPath
                obj.LocalPathProps = varargin(n+(1:2));
                n = n+2;
            end
            obj.IsFirstStep = false;
            obj.showImpl;
            drawnow limitrate
        end

        function resetImpl(obj)
            % Initialize / reset internal properties
            obj.IsFirstStep = true;
            obj.MapDirty = true;
            obj.PathDirty = true;
        end

        function showImpl(obj)
            if obj.ShowMap && obj.MapDirty
                [mat,res,sz,loc] = deal(obj.MapProps{:});
                exampleHelperVisualizeMap(mat,res,loc,Ego=false,GridSize=sz,Type=obj.MapType);
                obj.MapDirty = false;
            end
            if obj.ShowPath && obj.PathDirty
                path = obj.PathProps{1};
                n = obj.PathProps{2};
                obj.PathHandle = {exampleHelperVisualizePath(path(1:n,:),obj.PathSpec,obj.PathHandle{:})};
                obj.PathDirty = false;
            end
            if obj.ShowVehicle && obj.VehicleDirty
                length = 6.5; %<TODO> Make mask parameters
                width = 5.76; %<TODO> Make mask parameters
                obj.VehicleHandle = {exampleHelperVisualizeVehicle(obj.VehicleProps{:},length,width,obj.VehicleHandle{:})};
                obj.VehicleDirty = false;
            end
            if obj.ShowLocalPath && obj.LocalPathDirty
                localPath = obj.LocalPathProps{1};
                n = obj.LocalPathProps{2};
                obj.LocalPathHandle = {exampleHelperVisualizePath(localPath(1:n,:),obj.LocalPathSpec,obj.LocalPathHandle{:})};
                obj.LocalPathDirty = false;
            end
        end
    end

    methods % AbortSet setters
        function set.MapProps(obj,vals)
            obj.MapProps = vals;
            if ~isempty(vals{1}) && all(vals{3}>0)
                obj.MapDirty = true; %#ok<MCSUP>
            else
                obj.MapDirty = false; %#ok<MCSUP>
            end
        end
        function set.PathProps(obj,vals)
            obj.PathProps = vals;
            if ~isempty(vals{1}) && vals{2} > 0
                obj.PathDirty = true; %#ok<MCSUP>
            else
                obj.PathDirty = false; %#ok<MCSUP>
            end
        end
        function set.VehicleProps(obj,vals)
            obj.VehicleProps = vals;
            obj.VehicleDirty = true; %#ok<MCSUP>
        end
        function set.LocalPathProps(obj,vals)
            obj.LocalPathProps = vals;
            if ~isempty(vals{1}) && vals{2} > 0
                obj.LocalPathDirty = true; %#ok<MCSUP>
            else
                obj.LocalPathDirty = false; %#ok<MCSUP>
            end
        end
    end

    methods (Static)
        function mapTypeStr = enum2type(mapTypeEnum)
            switch mapTypeEnum
                case 0
                    mapTypeStr = "Occ";
                case 1
                    mapTypeStr = "Bin";
                case 2
                    mapTypeStr = "SDF";
                otherwise
                    mapTypeStr = "Generic";
            end
        end
    end
end