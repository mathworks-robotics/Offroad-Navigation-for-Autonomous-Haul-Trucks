function varargout = exampleHelperUncell(in)
%exampleHelperUncell Short alias for exploding cell-array
%
%   Used when something returns a cell-array but you want to immediately
%   get the stored data.
%
%   Examples:
%       s = struct('a',1,'b',2,'c','abc');
%           % [a,b,c] = deal(struct2cell(s){:});    % Does not work
%       [a,b,c] = uncell(struct2cell(s))            % Works
%
%       someFcn = @(n){rand(n,3)};
%           % val = someFcn(10){:};                 % Does not work
%       val = uncell(someFcn(10))                   % Works
%

% Copyright 2023-2024 The MathWorks, Inc.

    arguments
        in (:,:) {mustBeA(in,{'cell'})}
    end
    n = nargout;
    [varargout{1:n}] = deal(in{:});
end