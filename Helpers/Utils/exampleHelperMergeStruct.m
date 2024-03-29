function sOut = exampleHelperMergeStruct(varargin)
%exampleHelperMergeStruct Merge fields of matching-length struct-arrays
%
%   NOTE: Fields are assumed to be unique
%
%   Example:
%       xList   = arrayfun(@(x)struct('X',rand),1:5);
%       yList   = arrayfun(@(x)struct('Y',rand(randi(10),3)),1:5);
%       zList   = arrayfun(@(x)struct('Z',string(randi(10))),1:5);
%
%       % Merge x and y
%       xyList  = exampleHelperMergeStruct(xList,yList);
%
%       % Merge all three
%       xyzList_A = exampleHelperMergeStruct(xList,yList,zList);
%
%       % Merge 2-field xy struct with z
%       xyzList_B = exampleHelperMergeStruct(xyList,zList);
%
%       assert(isequal(xyzList_A,xyzList_B));

% Copyright 2023 The MathWorks, Inc.

%#codegen
    arguments (Repeating)
        varargin
    end
    cellfun(@(x)mustBeA(x,'struct'),varargin);
    nFirst = numel(varargin{1});
    nAll   = cellfun(@(x)numel(x),varargin);
    assert(all(nFirst == nAll));
    nField = cellfun(@(x)numel(fieldnames(x)),varargin);
    nTotField = sum(nField);
    sInputs = cell(2,nTotField);
    i0 = 1;

    if coder.target('MATLAB')
        for i = 1:nargin
            idx = i0:i0+(nField(i)-1);
            names = fieldnames(varargin{i});
            [sInputs{1,idx}] = exampleHelperUncell(names);
            for f = 1:numel(names)
                [sInputs{2,idx(1)+f-1}] = {varargin{i}.(names{f})};
            end
            i0 = i0(1)+nField(i);
        end
        sOut = reshape(struct(sInputs{:}),[],1);
    else
        cType = cell(2,nTotField);
        for i = 1:nargin
            idx = i0:i0+(nField(i)-1);
            names = fieldnames(varargin{i});
            [cType{1,idx}] = exampleHelperUncell(names);
            [cType{2,idx}] = exampleHelperUncell(getElType(varargin{i}(i)));
            i0 = i0(1)+nField(i);
        end
    
        sOut = repmat(struct(cType{:}),nFirst,1);
        argI = discretize(1:nTotField,[-inf cumsum(nField)+1]);
        fields = fieldnames(sOut);
    
        for iEl = 1:nFirst
            for iF = 1:nTotField
                sOut(iEl).(fields{iF}) = varargin{argI(iF)}(iEl).(fields{iF});
            end
        end
    end
end

function cType = getElType(el)
    % t = coder.typeof(el);
    % names = fieldnames(t.Fields);
    names = fieldnames(el);
    n = numel(names);
    cType = cell(1,n);
    for i = 1:n
        % cType{i} = t.Fields.(names{i});
        cType{i} = el.(names{i});
    end
end