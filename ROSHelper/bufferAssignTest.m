maxSize = 10;
for nDim = 2:4
    for i = 1:10
        % Generate linear array of random data
        dims = randi([1 maxSize],1,nDim);
        data = rand(prod(dims),1);
        if nDim == 1
            bufferData = zeros(maxSize,1);
        else
            bufferData = zeros(repelem(maxSize,1,nDim));
        end

        % Sub-assign data to the buffer
        bufferData = subassignBuffer(bufferData,dims,data);

        % Verify the subregion is equivalent to original data
        S = struct('type','()','subs',{arrayfun(@(x)1:x,[dims 1],'UniformOutput',false)});
        dataActual = subsref(bufferData,S);
        dataExpected = reshape(data,[dims 1]);
        assert(isequal(dataActual,dataExpected));
    end
end