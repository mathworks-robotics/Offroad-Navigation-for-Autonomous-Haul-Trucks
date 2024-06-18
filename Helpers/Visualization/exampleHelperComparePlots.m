function h = exampleHelperComparePlots(f,varargin)
%exampleHelperComparePlots Display multiple images on the same figure
%

% Copyright 2023-2024 The MathWorks, Inc.

    arguments
        f (1,1) {mustBeA(f,'matlab.ui.Figure')}
    end
    arguments (Repeating)
        varargin
    end
    n = numel(varargin);

    for i = 1:n
        h(i) = nexttile(i); %#ok<AGROW>
        imshow(flipud(varargin{i}));
    end
end