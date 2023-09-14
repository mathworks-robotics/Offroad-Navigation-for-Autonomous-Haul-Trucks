function dataset = exampleHelperUpdateDataset(dataset,elemIdx,data)
%exampleHelperUpdateDataset Helper for converting saved data to simInputs
%
% Copyright 2023 The MathWorks, Inc.

    name = dataset{elemIdx}.Name;
    dataElem = dataset{elemIdx};
    if isa(data,'struct')
        dataElem = struct2simInput(dataElem,data);
    else
        switch class(dataElem)
            case "timetable"
                n = numel(dataElem);
                for i = 1:n
                    dataElem.Data{i} = data;
                end
            case "timeseries"
                n = numel(dataElem.Time);
                dataElem.Data = repmat(data,1,1,n);
            otherwise
                error('huh');
        end
    end
    dataset{elemIdx} = dataElem;
    dataset{elemIdx}.Name = name;
end