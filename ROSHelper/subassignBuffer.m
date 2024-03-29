function bufferData = subassignBuffer(bufferData, dims, data)
    indVecs = cell(1,numel(dims));
    for i = 1:numel(dims)
        indVecs{i} = 1:dims(i);
    end
    ind = cell(1,numel(dims));
    [ind{:}] = ndgrid(indVecs{:});
    linIdx = sub2ind(size(bufferData),ind{:});
    bufferData(linIdx) = data(1:prod(dims));
end