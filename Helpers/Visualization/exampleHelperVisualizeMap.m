function [ax,h] = exampleHelperVisualizeMap(mat,res,gridLoc,nv)
    arguments
        mat (:,:,:) {mustBeReal}
        res (1,1) double {mustBePositive}
        gridLoc (1,2) double {mustBeReal}
        nv.Ego (1,1) logical {mustBeMember(nv.Ego,[0 1])} = 1;
        nv.Type (1,1) string {mustBeMember(nv.Type,["Occ","Bin","SDF","Generic"])} = "SDF";
        nv.GridSize {mustBeReal, mustBePositive} = []
        nv.Parent = gca;
    end

    if isempty(nv.GridSize)
        localMat = mat;
        sz = size(mat);
    else
        mustBeVector(nv.GridSize);
        mustBePositive(nv.GridSize);
        sz = nv.GridSize;
        localMat = mat(1:sz(1),1:sz(2),:);
    end
    ax = nv.Parent;

    fVis = @(map,varargin)show(map,"Parent",ax,varargin{:});
    switch nv.Type
        case "Occ"
            mustBeMember(numel(nv.GridSize),2);
            if ~islogical(mat)
                mustBeInRange(mat,[0 1]);
            end
            map = occupancyMap(localMat,Resolution=res);
            visInputs = {};
        case "Bin"
            mustBeMember(numel(nv.GridSize),2);
            mustBeMember(mat,[0,1]);
            map = binaryOccupancyMap(localMat,Resolution=res);
            visInputs = {};
        case "SDF"
            mustBeMember(numel(nv.GridSize),2);
            mustBeMember(mat,[0,1]);
            map = signedDistanceMap(localMat,Resolution=res);
            delete(findobj(gcf,'-regexp','Tag','SDFW*'));
            visInputs = {"BoundaryColor",[0 0 0],"Colorbar","on"};
        otherwise
            map = mapLayer(localMat,Resolution=res);
            visInputs = {"Colorbar",1,"Colormap",parula,"Title","Map"};
            fVis = @(map,varargin)exampleHelperShowMapLayer(map,"Parent",ax,varargin{:});
    end
    map.GridLocationInWorld = gridLoc;
    if nv.Ego
        map.GridOriginInLocal = -sz/map.Resolution/2;
    end
    
    hold on;
    switch nv.Type
        case {"Occ","Bin"}
            h = fVis(map,visInputs{:});
        otherwise
            [hIm,cBar] = fVis(map,visInputs{:});
            h = [hIm;cBar];
    end
    uistack(h(1),"bottom");
    hold off;
end