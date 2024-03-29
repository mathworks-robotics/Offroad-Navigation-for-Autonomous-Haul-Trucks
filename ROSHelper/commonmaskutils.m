classdef commonmaskutils
    methods (Static)
        function idx = param2idx(paramName)
            names = get_param(gcb,'MaskNames');
            idx = find(cellfun(@(x)isequal(x,paramName),names));
        end
        function param = getMaskParam(maskObj,paramName)
            params = maskObj.Parameters;
            param = params(arrayfun(@(x)isequal(x.Name,paramName),params));
        end
        function value = getWSValue(paramName)
            wsVars = get_param(gcb,"MaskWSVariables");
            value = wsVars(arrayfun(@(x)isequal(string(x.Name),string(paramName)),wsVars)).Value;
        end
        function dims(callbackContext)
            validateattributes(eval(callbackContext.ParameterObject.Value),...
                    {'numeric'},{'2d','positive','integer'});
        end
        function [msgType,N] = genMsgType(dims,isVarsize,userDataType)
            % Generate message type
            N = prod(dims);
            if ~isVarsize && numel(dims) <= 2 && any(dims==1)
                switch N
                    case {1,2,3}
                        if N == 1
                            msgType = commonmaskutils.generateMatrixMessage(userDataType,N);
                        else
                            msgType = "geometry_msgs/Vector3";
                        end
                    otherwise
                        msgType = commonmaskutils.generateMatrixMessage(userDataType);
                end
            else
                msgType = commonmaskutils.generateMatrixMessage(userDataType);
            end
        end
        function msgType = generateMatrixMessage(userDataType,N)
            if nargin == 1
                N = inf;
            end
            msgBase = "std_msgs/";
            switch userDataType
                case "byte"
                    msgClass = "Byte";
                case "single"
                    msgClass = "Float32";
                case "double"
                    msgClass = "Float64";
                case "int8"
                    msgClass = "Int8";
                case "int16"
                    msgClass = "Int16";
                case "int32"
                    msgClass = "Int32";
                case "int64"
                    msgClass = "Int64";
                otherwise
                    error('Must be one of the predefined types');
            end
            if N == 1
                dimClass = "";
            else
                dimClass = "MultiArray";
            end
            msgType = msgBase + msgClass + dimClass;
        end
    end
end