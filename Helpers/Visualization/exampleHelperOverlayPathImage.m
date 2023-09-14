function exampleHelperOverlayPathImage(imgHandle,pathList,corder,nv)
%exampleHelperOverlayPathImage Overlay struct-array of pixel-based paths atop a black-and-white image
%
% Copyright 2023 The MathWorks, Inc.

    arguments
        imgHandle (:,:) {mustBeA(imgHandle,{'matlab.graphics.primitive.Image'})}
        pathList (:,1) struct
        corder (:,3) double = colororder
        nv.Radius (1,1) double {mustBeInteger,mustBeNonnegative} = 0;
        % nv.Parent (1,1) {mustBeA(nv.Parent,{'matlab.graphics.axis.Axes'})} = gca;
        nv.Frame (1,1) string {mustBeMember(nv.Frame,["ij","xy"])} = "xy";
    end
    ax = imgHandle.Parent;

    sz = size(imgHandle.CData,[1,2]);

    n = prod(sz);
    cols = nextColor(1:numel(pathList),corder);
    mask = zeros([sz 3]);
    isXYPath = isequal(nv.Frame,"xy");
    if isXYPath
        tmpMap = binaryOccupancyMap(mask(:,:,1));
    end

    for i = 1:numel(pathList)
        if isXYPath
            pathList(i).Path = tmpMap.world2grid(pathList(i).Path);
        end
        lIdx = sub2ind(sz,pathList(i).Path(:,1),pathList(i).Path(:,2));
        mask(lIdx) = cols(i,1);
        mask(lIdx+n) = cols(i,2);
        mask(lIdx+n*2) = cols(i,3);
    end
    if ~isnan(nv.Radius)
        mask = imdilate(mask,strel('disk',nv.Radius));
    end
    hs = ishold; hold(ax,"on");
    if isXYPath
        mask = rot90(flipud(mask));
    end
    hNew = imagesc(mask,Parent=ax);
    hNew.AlphaData = 0.9*any(mask,3);
    
    if ~hs
        hold(ax,"off");
    end
end

function color = nextColor(idx,cOrd)
%nextColor Find ith color for the given color order
    arguments
        idx (:,1) {mustBePositive, mustBeInteger};
        cOrd (:,3) double = colororder;
    end

    color = cOrd(mod(idx-1,size(cOrd,1))+1,:);
end