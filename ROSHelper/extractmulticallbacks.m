classdef extractmulticallbacks < commonmaskutils

    methods(Static)

        % Following properties of 'maskInitContext' are available to use:
        %  - BlockHandle 
        %  - MaskObject 
        %  - MaskWorkspace: Use get/set APIs to work with mask workspace.
        function MaskInitialization(maskInitContext)
            % Extract parameter values
            ws = maskInitContext.MaskWorkspace;
            isVarsize = ws.get('isVarsize');
            varsizeDims = ws.get('varsizeDims');
            returnFixedTF = ws.get('returnFixedTF');
            maxDims = ws.get('varsizeDims');
            N = prod(maxDims);
            % Check whether multi-dim array is needed, and if output is
            % fixed or varsize
            if N > 3 || isVarsize
                if ~isVarsize || returnFixedTF || isempty(varsizeDims) || all(varsizeDims == 0) 
                    outputIsFixedTF = true;
                else
                    outputIsFixedTF = false;
                end
            else
                outputIsFixedTF = true;
            end
            ws.set('outputIsFixedTF',outputIsFixedTF);
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