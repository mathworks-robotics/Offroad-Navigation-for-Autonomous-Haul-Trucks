function encodedBus = exampleHelperEncodeBus(S,maxFieldLength,maxArraySize,nv)
%exampleHelperEncodeBus Flattens varsize struct-array with varsize elements
%
%   Example:
%
%       % Create struct-array with multiple fields, potentially containing 
%       % varsize elements
%       xList   = arrayfun(@(x)struct('X',rand),1:5)';
%       yList   = arrayfun(@(x)struct('Y',rand(randi(10),3)),1:5)';
%       xyList  = exampleHelperMergeStruct(xList,yList);
%       
%       % Run-length encode the struct-arrays
%       xyBusVarSz   = exampleHelperEncodeBus(xyList);
%
%       % Convert to RLE bus with fixed buffer sizes
%       maxFieldRows = 1e3;
%       maxArrayElem = 10;
%       xyBusFixed  = exampleHelperEncodeBus(xyList,maxFieldRows,maxArrayElem);
%
%       % Convert subset of input struct
%       xBusOnly    = exampleHelperEncodeBus(xyList,maxFieldRows,maxArrayElem,FieldNames="X");
%
%       % Decode back to original format
%       xyDecodeVarSz   = exampleHelperDecodeBus(xyBusVarSz);
%       xyDecodeFixed   = exampleHelperDecodeBus(xyBusFixed);
%       xDecodeOnly     = exampleHelperDecodeBus(xBusOnly);
%       
%       % Rename decoded fields
%       abDecode        = exampleHelperDecodeBus(xyBusVarSz,FieldNames=["a","b"]);
%       
%       % Verify results
%       fAssert = @(a,b)assert(isequal(a,b));
%       fAssert(xyDecodeVarSz,xyList);
%       fAssert(xyDecodeFixed,xyList);
%       fAssert(xDecodeOnly,  xList);
%       fAssert(xDecodeOnly,  xList);
%       fAssert([abDecode.a],[xList.X]);
%       fAssert(vertcat(abDecode.b),vertcat(yList.Y));

% Copyright 2023 The MathWorks, Inc.

%#codegen
%#internal

    arguments
        S        (:,1) {mustBeA(S,'struct')}
        maxFieldLength {mustBeScalarOrEmpty,mustBePositive,mustBeInteger} = [];
        maxArraySize   {mustBeScalarOrEmpty,mustBePositive,mustBeInteger} = [];
        nv.Widths = [];
        nv.FieldNames {mustBeText} = {};
    end

    % Identify fields to be run-length-encoded
    if isempty(nv.FieldNames)
        fields = fieldnames(S);
    else
        fields = cellstr(nv.FieldNames);
    end

    % Prep struct inputs
    nField = numel(fields);
    sInputs = cell(2,nField*3);

    if ~isempty(nv.Widths)
        coder.const(nv.Widths);
        if coder.internal.isConstTrue(isscalar(nv.Widths))
            widths = repelem(nv.Widths,nField,1);
        else
            assert(numel(nv.Widths)==numel(fields));
            widths = nv.Widths;
        end
    else
        widths = cellfun(@(x)size(S(1).(x),2),fields);
    end

    % Encode each field
    for i = 1:nField
        idx = 3*(i-1)+1;
        sInputs{1,idx}    = fields{i};
        sInputs{1,idx+1}  = fields{i} + "Indices";
        sInputs{1,idx+2}  = fields{i} + "_N";
        [sInputs{2,idx},sInputs{2,idx+1},sInputs{2,idx+2}] = ...
            encodeElement(S,fields{i},maxFieldLength,maxArraySize,widths);
    end
    encodedBus = struct(sInputs{:});
end

function [eCombined,eIdx,n] = encodeElement(S,field,maxFieldLength,maxNumEdge,fWidth)
    n = numel(S);
    % fWidth = size(S(1).(field),2);
    sz = arrayfun(@(x)size(x.(field),1),S);
    i0 = cumsum([1; sz(:)]);
    if isempty(maxFieldLength)
        eCombined = zeros(sum(sz),fWidth,'like',S(1).(field)(1));
    else
        eCombined = zeros(maxFieldLength,fWidth,'like',S(1).(field)(1));
    end
    if isempty(maxNumEdge)
        eIdx = [i0(1:end-1) i0(2:end)-1];
    else
        eIdx = zeros(maxNumEdge,2);
        eIdx(1:n,:) = [i0(1:end-1) i0(2:end)-1];
    end
    for i = 1:n
        eCombined(i0(i):(i0(i+1)-1),:) = S(i).(field);
    end
end