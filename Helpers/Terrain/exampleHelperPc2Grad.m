function [dzdx,dzdy,dem,xlim,ylim,xx,yy] = exampleHelperPc2Grad(ptCloud,res)
%exampleHelperPc2Grad Computes DEM and gradient info from pointcloud
%

% Copyright 2023-2024 The MathWorks, Inc.

    % Convert pointcloud to dem
    [demInit,xlim,ylim] = pc2dem(ptCloud,1/res);

    % Fill holes
    x = linspace(xlim(1),xlim(2),size(demInit,2));
    y = linspace(ylim(1),ylim(2),size(demInit,1));
    [xx,yy] = ndgrid(x,y);
    nanPts = isnan(demInit(:));
    scatInterp = scatteredInterpolant(xx(~nanPts),yy(~nanPts),demInit(~nanPts));
    idx = find(isnan(demInit(:)));
    demInit(idx(:)) = scatInterp([xx(idx(:)) yy(idx(:))]);

    % Compute gradient
    linInterp = griddedInterpolant(xx,yy,demInit,'linear','linear');
    del = 1e-8;
    dzdx = single(reshape((linInterp([xx(:) yy(:)])-linInterp([xx(:)-del yy(:)]))/del,size(xx)));
    dzdy = single(reshape((linInterp([xx(:) yy(:)])-linInterp([xx(:) yy(:)-del]))/del,size(xx)));
    dem = single(demInit);
end