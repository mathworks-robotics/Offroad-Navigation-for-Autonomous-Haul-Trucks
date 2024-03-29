classdef gendatacallbacks

    methods(Static)

        % Following properties of 'maskInitContext' are available to use:
        %  - BlockHandle 
        %  - MaskObject 
        %  - MaskWorkspace: Use get/set APIs to work with mask workspace.
        function MaskInitialization(maskInitContext)
            ws = maskInitContext.MaskWorkspace;
            dataSize = ws.get('dataSize');
            varsizeDims = ws.get('varsizeDims');
            validateattributes(dataSize,{'numeric'},{'2d','positive','integer'},'MaskInitialization','dataSize');
            
            if isempty(varsizeDims)
                isVarsize = zeros(1,numel(dataSize));
            else
                validateattributes(varsizeDims,{'numeric'},{'numel',numel(dataSize)},'MaskInitialization','varsizeDims');
                mustBeMember(varsizeDims,[0 1]);
                isVarsize = varsizeDims;
            end
            ws.set('isVarsize',isVarsize);
            ws.set('variantFixedTF',all(isVarsize==0));
        end

        % Use the code browser on the left to add the callbacks.

    end
end