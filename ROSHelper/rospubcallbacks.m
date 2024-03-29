classdef rospubcallbacks < commonmaskutils

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
            topicName = ws.get('topicName');

            % Generate message type
            [msgType,N] = commonmaskutils.genMsgType(dims,isVarsize,userDataType);
            ws.set('N',N);
            
            % Validate varsize dims
            if isVarsize || N > 3
                ws.set('useVarsizeTF',1);
                if isempty(varsizeDims)
                    % Nothing to do
                else
                    validateattributes(varsizeDims,...
                        {'numeric'},{'2d','numel',numel(commonmaskutils.getWSValue('dims')),...
                        'nonnegative','integer'});
                    mustBeMember(varsizeDims,[0 1]);
                end
            else
                ws.set('useVarsizeTF',0);
            end

            % Generate missing messages
            if ~isequal(get_param(bdroot(gcb),'DataDictionary'),'ros2lib.sldd') 
                Simulink.data.dictionary.open(ros.slros.internal.bus.Util.ROS2DataDict);
                set_param(bdroot(gcb),'DataDictionary','ros2lib.sldd');
            end
            ws.set('topicString',"/" + ws.get('topicName'));
            ros.slros2.internal.bus.Util.createBusIfNeeded(char(msgType), bdroot(gcb));
            [emptyRosMsg, msgInfo] = ros.slros2.internal.bus.Util.newMessageFromSimulinkMsgType(msgType);
            emptyRosMsg = ros.slros.internal.bus.getBusStructForROSMsg(emptyRosMsg, msgInfo,'ros2');
            ros.slros2.internal.bus.createBusDefnInGlobalScope(emptyRosMsg, bdroot(gcb));
            [rosMsgTypeStr, slBusName] = ros.slros2.internal.bus.Util.rosMsgTypeToDataTypeStr(char(msgType));
            ros.ros2.createSimulinkBus(bdroot(gcb),msgType);

            % Update subsystem properties
            set_param(gcb + "/Publish",'topic',"/" + topicName);
            set_param(gcb + "/Publish",'messageType',msgType);
            set_param(gcb + "/BlankMessage",'messageType',msgType);
            set_param(gcb + "/BlankMessage",'entityType',msgType);
            ros.slros2.internal.block.MessageBlockMask.dispatch('messageClassChange', char(gcb + "/BlankMessage"));
        end

        function isVarsize(callbackContext)
            % Display/hide varsize options
            onoff = matlab.lang.OnOffSwitchState(callbackContext.ParameterObject.Value);
            visStrings = get_param(gcb,'MaskVisibilities');
            dimIdx = commonmaskutils.param2idx('varsizeDims');
            visStrings{dimIdx} = char(onoff);
            set_param(gcb,'MaskVisibilities',visStrings);
        end
    end
end
function subsysPath = getVariantPath()
    % Identify variant subsystem
    subsysPath = string(gcb) + "/PublisherVariant";
    isVarsize = matlab.lang.OnOffSwitchState(commonmaskutils.getWSValue('isVarsize'));
    switch isVarsize
        case 1
            subsysPath = subsysPath + "/Varsize";
        case 0
            subsysPath = subsysPath + "/Fixed";
    end
end