function hNew = exampleHelperOverlayImage(mask,ax,nv)
%exampleHelperOverlayImage Display input image atop current axis and only 
% highlight the masked pixels
%
% Copyright 2023 The MathWorks, Inc.

    arguments
        mask (:,:) logical
        ax (1,1) {mustBeA(ax,'matlab.graphics.axis.Axes')} = gca
        nv.Radius (1,1) double {mustBeInteger} = nan
        nv.Color (1,3) = nan
    end

    if isnan(nv.Color)
        cOrder = colororder;
        col = cOrder(randi(size(cOrder,1)),:);
    else
        col = nv.Color;
    end

    if ~isnan(nv.Radius)
        mask = imdilate(mask,strel('disk',nv.Radius));
    end
    hs = ishold; hold(ax,"on");
    hNew = imshow(mask.*reshape(col,1,1,3));
    hNew.AlphaData = mask;
    if ~hs
        hold(ax,"off");
    end
end