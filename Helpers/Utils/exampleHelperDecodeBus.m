function sOut = exampleHelperDecodeBus(S,nv)
%exampleHelperDecodeBus Expands encoded fixed-size struct with varsize elements
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

%#internal
%#codegen

    arguments
        S %(1,1) %{mustBeA(S,'struct')}
        nv.FieldNames {mustBeText} = {};
        nv.Widths = [];
    end
    
    coder.internal.prefer_const;

    % Identify fields to be run-length-encoded
    inFields = fieldnames(S);
    if isempty(nv.FieldNames)
        outFields = {inFields{1:3:end}};
    else
        outFields = cellstr(nv.FieldNames);
        assert(numel(outFields) == numel(fieldnames(S))/3);
    end
    nField = numel(outFields);

    if ~isempty(nv.Widths)
        coder.const(nv.Widths);
        if coder.internal.isConstTrue(isscalar(nv.Widths))
            widths = repelem(nv.Widths,nField,1);
        else
            assert(numel(nv.Widths)==numel(outFields));
            widths = nv.Widths;
        end
    else
        widths = cellfun(@(x)size(S.(x),2),outFields);
    end

    coder.const(widths);

    structSet = cell(1,nField);
    coder.unroll
    for i = 1:nField
        idx = (i-1)*3+1;
        structSet{i} = decodeElement(S.(inFields{idx}),S.(inFields{idx+1}),S.(inFields{idx+2}),widths(i),outFields{i});
    end

    sOut = exampleHelperMergeStruct(structSet{:});
end

function sElem = decodeElement(fVals,fIdx,nF,fWidth,fieldOut)
%#internal
    coder.internal.prefer_const
    vals = zeros(0,fWidth,'like',fVals);
    coder.varsize('vals',[inf fWidth]);
    sElem = repmat(struct(fieldOut,vals),nF,1);

    for i = 1:nF
        [i0,i1] = deal(fIdx(i,1),fIdx(i,2));
        sElem(i) = struct(fieldOut,fVals(i0:i1,:));
    end
end