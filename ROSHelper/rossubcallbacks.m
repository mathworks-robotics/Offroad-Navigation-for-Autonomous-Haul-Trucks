classdef rossubcallbacks < commonmaskutils

    methods(Static)

        % Following properties of 'maskInitContext' are available to use:
        %  - BlockHandle 
        %  - MaskObject 
        %  - MaskWorkspace: Use get/set APIs to work with mask workspace.
        function MaskInitialization(maskInitContext)
            % Extract parameter values
            ws = maskInitContext.MaskWorkspace;
            obj = maskInitContext.MaskObject;
            isVarsize = ws.get('isVarsize');
            userDataType = commonmaskutils.getMaskParam(obj,'userDataType').Value;
            dims = ws.get('dims');
            varsizeDims = ws.get('varsizeDims');
            returnFixedTF = ws.get('returnFixedTF');
            topicName = ws.get('topicName');
            
            % Validate varsize dims
            if isVarsize
                if isempty(varsizeDims)
                    % Nothing to do
                else
                    validateattributes(varsizeDims,...
                        {'numeric'},{'2d','numel',numel(commonmaskutils.getWSValue('dims')),...
                        'nonnegative','integer'});
                    mustBeMember(varsizeDims,[0 1]);
                end
            end

            % Generate message type
            [msgType,N] = commonmaskutils.genMsgType(dims,isVarsize,userDataType);
            ws.set('N',N);
            
            % Check whether multi-dim array is needed, and if output is
            % fixed or varsize
            if N > 3 || isVarsize
                useMultiDimTF = true;
                if ~isVarsize || returnFixedTF || isempty(varsizeDims) || all(varsizeDims == 0) 
                    outputIsFixedTF = true;
                else
                    outputIsFixedTF = false;
                end
            else
                outputIsFixedTF = false;
                useMultiDimTF = false;
            end
            ws.set('useMultiDimTF',useMultiDimTF);
            ws.set('outputIsFixedTF',outputIsFixedTF);
            variantPath = getVariantPath();

            % Generate missing messages
            if ~isequal(get_param(bdroot(gcb),'DataDictionary'),'ros2lib.sldd') 
                Simulink.data.dictionary.open(ros.slros.internal.bus.Util.ROS2DataDict);
                set_param(bdroot(gcb),'DataDictionary','ros2lib.sldd');
            end
            ros.slros2.internal.bus.Util.createBusIfNeeded(char(msgType), bdroot(gcb));
            [emptyRosMsg, msgInfo] = ros.slros2.internal.bus.Util.newMessageFromSimulinkMsgType(msgType);
            emptyRosMsg = ros.slros.internal.bus.getBusStructForROSMsg(emptyRosMsg, msgInfo,'ros2');
            ros.slros2.internal.bus.createBusDefnInGlobalScope(emptyRosMsg, bdroot(gcb));
            ros.ros2.createSimulinkBus(bdroot(gcb),msgType);

            % Update subsystem properties
            ws.set('topicString',"/" + ws.get('topicName'));
            set_param(variantPath + "/Subscribe",'messageType',msgType);
            set_param(variantPath + "/Subscribe",'topic',"/" + topicName);
        end

        function isVarsize(callbackContext)
            % Display/hide varsize options
            onoff = matlab.lang.OnOffSwitchState(callbackContext.ParameterObject.Value);
            visStrings = get_param(gcb,'MaskVisibilities');
            dimIdx = commonmaskutils.param2idx('varsizeDims');
            fixedIdx = commonmaskutils.param2idx('returnFixedTF');
            visStrings{dimIdx} = char(onoff);
            visStrings{fixedIdx} = char(onoff);
            set_param(gcb,'MaskVisibilities',visStrings);

            if ~onoff
                % Set "returnFixedTF" to false
                vals = get_param(gcb,'MaskValues');
                vals{fixedIdx} = char(onoff);
                set_param(gcb,'MaskValues',vals);
            end
        end
    end
end
function subsysPath = getVariantPath()
    % Identify variant subsystem
    subsysPath = string(gcb) + "/SubscriberVariant";
    useMultiDim = matlab.lang.OnOffSwitchState(commonmaskutils.getWSValue('useMultiDimTF'));
    switch useMultiDim
        case 1
            subsysPath = subsysPath + "/MultiDim";
        case 0
            subsysPath = subsysPath + "/Vector";
    end
end