function datasetElement = exampleHelperStruct2simInput(datasetElement,structInput)
%exampleHelperStruct2simInput Populates the datasetElement with the struct for use with Simulink inport
%
% Copyright 2023 The MathWorks, Inc.

    % Loop through each field and populate the dataset element
    pathListFields = fieldnames(structInput);
    for name = pathListFields(:)'
    
        if isstruct(structInput.(name{:})) % nested struct
            % Call the same function recursively
            datasetElement.(name{:}) = struct2simInput(datasetElement.(name{:}), structInput.(name{:}));
        else
            nTime = numel(datasetElement.(name{:}).Time);
            if iscell(datasetElement.(name{:}).Data)
                % Varsize fields take the form of cell-arrays
                % for i = 1:nTime
                %     datasetElement.(name{:}).Data(i) = structInput.(name{:});
                % end
                datasetElement.(name{:}).Data = cellfun(@(x)structInput.(name{:}),datasetElement.(name{:}).Data,'UniformOutput',false);
            else
                % Fixed-size elements may be organized as [datadims]-by-[#steps]
                datasetElement.(name{:}).Data = repmat(structInput.(name{:}),1,1,nTime);
            end
        end
    end
end