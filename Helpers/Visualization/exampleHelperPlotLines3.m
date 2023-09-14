function lineHandle = exampleHelperPlotLines3(varargin)%(s1,s2,s3,s4,s5)
%exampleHelperPlotLines3 Display individual or pair-wise connected N-by-[x y z] lines
% Assume the following patterns:
%   (<data1>)                       % Default line plotted
%   (<data1, spec1>)                % Line plotted with spec
%   (<___>, <data2>)                % Interlines plotted with default spec
%   (<___>, <data2 spec12>)         % Interlines plotted with spec
%   (<___>, <data2 spec2 spec12>)   % Interlines and 2nd line plotted with specs
%   (<___>, <___>, -repeat)         % Second set can repeat/daisy-chain
%
% Copyright 2023 The MathWorks, Inc.

    n = nargin;

    % Find indices containing line data values
    lineDataIdx = find(cellfun(@(x)isnumeric(x),varargin));
    diffIdx = diff([lineDataIdx numel(varargin)+1]);

    numPtGroup = numel(lineDataIdx);
    lineSpecs = repmat({{}},1,numPtGroup*2);

    specNum = 1;

    % Handle first line
    if numPtGroup == 1
        if n == 2
            lineSpecs{specNum} = spec2cell(varargin{2});
        else
            lineSpecs{specNum} = {'k'};
        end
    else
        if diffIdx(1) == 2
            lineSpecs{specNum} = spec2cell(varargin{2});
        else
            lineSpecs{specNum} = {};
        end
    end

    specNum = 3;

    % Handle repeat sections
    for i = 2:numPtGroup
        grpIdx = lineDataIdx(i);
        switch diffIdx(i)
            case 3
                lineSpecs{specNum}   = spec2cell(varargin{grpIdx+1});
                lineSpecs{specNum+1} = spec2cell(varargin{grpIdx+2});
            case 2
                lineSpecs{specNum+1} = spec2cell(varargin{grpIdx+1});
            case 1
                lineSpecs{specNum+1} = {'k'};
        end
        specNum = specNum+2;
    end

    lineHandle = zeros(0,1);
    ax = gca;
    holdWasOn = ishold(ax);
    f = onCleanup(@()revertHold(ax,holdWasOn));

    % Plot lines
    grpIdx = 1;
    for i = 1:2:numel(lineSpecs)
        p2 = varargin{lineDataIdx(grpIdx)};
        if isempty(p2)
            continue;
        end
        if ~isempty(lineSpecs{i})
            [x,y,z] = getPtSingle(p2);
            lineHandle(end+1) = plot3(x(:),y(:),z(:),lineSpecs{i}{:});
            hold on;
        end
        if ~isempty(lineSpecs{i+1})
            p1 = varargin{lineDataIdx(grpIdx-1)};
            if isempty(p1)
                continue
            else
                [x,y,z] = mergePt(p1,p2);
                lineHandle(end+1) = plot3(x(:),y(:),z(:),lineSpecs{i+1}{:});
            end
        end
        grpIdx = grpIdx+1;
    end
end

function [x,y,z] = mergePt(p1,p2)
%mergeXY Create line-segments between two 3D lines
    sz1 = size(p1,1);
    sz2 = size(p2,1);
    if size(p1,2) == 1
        assert(isequal(size(p1),size(p2)));
        n = (1:numel(p1))';
        x = [n n nan(numel(p1),1)]';
        y = [p1(:) p2(:) nan(numel(p1),1)]';
        z = zeros(1,numel(p1));
    else
        if sz1(1) == 1
            p1 = repmat(p1,size(p2,1),1);
        end
        if sz2(1) == 1
            p2 = repmat(p2,size(p1,1),1);
        end
        x = [p1(:,1) p2(:,1) nan(size(p1,1),1)]';
        y = [p1(:,2) p2(:,2) nan(size(p1,1),1)]';
        z = [p1(:,3) p2(:,3) nan(size(p1,1),1)]';
    end
end

function [x, y, z] = getPtSingle(s1)
%getPtSingle Plot 3D line that has been provided as column vector
    if size(s1,2) == 1
        x = 1:size(s1,1);
        y = s1(:,1);
        z = zeros(size(s1,2),1);
    else
        x = s1(:,1);
        y = s1(:,2);
        z = s1(:,3);
    end
end

function revertHold(ax,holdState)
%revertHold Return axis to given hold-state
    if holdState
        hold(ax,'on');
    else
        hold(ax,'off');
    end
end