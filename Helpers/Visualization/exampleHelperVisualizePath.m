function h = exampleHelperVisualizePath(path,spec,hPath,nv)
%exampleHelperVisualizePath Plot or update XY path
%
% Copyright 2023 The MathWorks, Inc.

    arguments
        path (:,:)
        spec = {};
        hPath = {};
        nv.Type (1,1) string {mustBeMember(nv.Type,["Line","Quiver"])} = "Line";
    end
    if ~iscell(spec)
        spec = {spec};
    end
    if isempty(hPath)
        hold on;
        switch nv.Type
            case "Line"
                h = plot(hPath{:},path(:,1),path(:,2),spec{:});
            otherwise
                assert(size(path,2) >= 3);
                h = quiver(hPath{:},path(:,1),path(:,2),cos(path(:,3)),sin(path(:,3)),spec{:});
        end
        hold off;
    else
        h = hPath{:};
        switch nv.Type
            case "Line"
                set(h,XData=path(:,1),YData=path(:,2));
            otherwise
                assert(size(path,2) >= 3);
                set(h,XData=path(:,1),YData=path(:,2),UData=cos(path(:,3)),VData=sin(path(:,3)));
        end
    end
end