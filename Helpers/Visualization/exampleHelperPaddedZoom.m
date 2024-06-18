function exampleHelperPaddedZoom(data,nDim,nv)
%exampleHelperPaddedZoom Compute bounds on data and zoom to padded region
%
% data can be a numeric matrix of the form N-by-[x y ...], or a
% cell/struct-array with elements containing numeric matrices of
% aforementioned form. If struct/cell-array, the DataGetter must be
% provided which returns the matrix in each element, and all values
% will be considered when computing bounds.
%

% Copyright 2023-2024 The MathWorks, Inc.

    arguments
        data
        nDim (1,1) {mustBeMember(nDim,[1,2,3])} = 1;
        nv.PaddingFactor (1,1) {mustBePositive, mustBeReal, mustBeGreaterThanOrEqual(nv.PaddingFactor,1)} = 1;
        nv.DataGetter (1,1) {mustBeA(nv.DataGetter,'function_handle')} = @(x)x;
    end

    % Compute bounds across input data
    minBounds = nan(1,nDim);
    maxBounds = nan(1,nDim);
    if iscell(data) || isstruct(data)
        % Test getter
        if ~isnumeric(nv.DataGetter(data(1)))
            error('VisualizationHelper:InvalidDataGetter','DataGetter must return an N-by-[x y ..] matrix');
        end
        for i = 1:numel(data)
            dat = nv.DataGetter(data(i));
            [minBounds,maxBounds] = bounds([dat(:,1:nDim);minBounds;maxBounds],1);
        end
    else
        [minBounds,maxBounds] = bounds([nv.DataGetter(data(:,1:nDim));minBounds;maxBounds],1);
    end

    % Add padding
    halfSize = (maxBounds-minBounds)/2;
    ctr = (maxBounds+minBounds)/2;
    plotbounds = ctr+[-1;1]*halfSize*nv.PaddingFactor;
    xlim(plotbounds(:,1)');
    if nDim > 1
        ylim(plotbounds(:,2)');
    end
    if nDim > 2
        zlim(plotbounds(:,3)');
    end
end