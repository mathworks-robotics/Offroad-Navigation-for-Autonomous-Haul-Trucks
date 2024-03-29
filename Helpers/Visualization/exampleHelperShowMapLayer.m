function [h,cBar] = exampleHelperShowMapLayer(map,nv)
    arguments
        map (1,1) mapLayer
        nv.Parent (1,1) {mustBeA(nv.Parent,{'matlab.ui.Figure','matlab.graphics.axis.Axes'})} = gca
        nv.Colorbar (:,1) matlab.lang.OnOffSwitchState {mustBeA(nv.Colorbar,{'matlab.lang.OnOffSwitchState'}),verifyNumProp(map,nv.Colorbar)} = "off"
        nv.Colormap {verifyColormap(map,nv.Colormap)} = jet
        nv.Title (:,1) string {verifyNumProp(map,nv.Title)} = []
        nv.FastUpdate (1,1) matlab.lang.OnOffSwitchState = 0;
    end
    % Create temp occupancy map for display purposes
    dat = map.getMapData;
    psz = pagedims(dat);
    ndim = numel(psz);
    occ = occupancyMap(zeros(map.GridSize),map.Resolution);
    occ.GridOriginInLocal = map.GridOriginInLocal;
    occ.LocalOriginInWorld = map.LocalOriginInWorld;

    if numel(size(dat)) == 2
        nPlot = 1;
    else
        nPlot = prod(map.DataSize(3:end));
    end
    cBar = [];
    for i = 1:nPlot
        % Plot occupancyMap, then replace data with rescaled data channel
        ax = nexttile(i);
        h = show(occ,Parent=ax,FastUpdate=nv.FastUpdate);
        h.CData = rescale(dat(:,:,i),0,1);

        % Create colormap
        colormap(ax,curvals(jet,nv.Colormap,i));

        % Create colorbar
        if curvals(0,nv.Colorbar,i)
            cBar = colorbar(ax);
            [vMin,vMax] = deal(min(dat(:,:,i),[],'all'),max(dat(:,:,i),[],'all'));
            cBar.Ticks = linspace(0,1,11)';
            cBar.TickLabels = linspace(vMin,vMax,11)';
        end

        % Add title
        if ndim == 1
            s = "";
        else
            ip = cell(1,prod(psz));
            [ip{1:ndim}] = ind2sub(psz,i);
            s = "," + string(ip(1:(numel(psz))));
        end
        def = strjoin(["data(:,:" s ")"],"");
        title(ax,curvals(def,nv.Title,i));
    end
end

function v = curvals(default,dat,i)
%curvals Retrieve values for current axes operation
    if isempty(dat)
        v = default;
    else
        switch class(dat)
            case 'cell'
                ii = min(i,numel(dat));
                if isempty(dat{ii})
                    v = default;
                else
                    v = dat{ii};
                end
            case 'string'
                ii = min(i,numel(dat));
                if isempty(dat(ii))
                    v = default;
                else
                    v = dat(ii);
                end
            otherwise
                if isscalar(default)
                    ii = min(i,numel(dat));
                    v = dat(ii);
                else
                    ndatadim = numel(size(default));
                    insz = size(dat);
                    pgsz = prod(insz(1:ndatadim));
                    ii = min(i,prod(pagedims(dat)));
                    v = reshape(dat((ii-1)*(pgsz) + 1:pgsz),insz(1:ndatadim));
                end
        end
    end
end

function validateCmap(cmap)
    if ~isempty(cmap)
        validateattributes(cmap,{'numeric'},{'2d','ncols',3,'nonnegative'});
    end
end

function N = pagedims(x)
%pagedims Number of pages beyond matrix
    N = size(x,3:max(numel(size(x)),3));
end

function verifyNumProp(map,p)
%verifyNumProp Ensure number of inputs is either empty, scalar, or match
%number of data channels
    dat = map.getMapData;
    assert(any(numel(p)==[0 1 prod(pagedims(dat))]));
end

function verifyColormap(map,cmaps)
%verifyColormap Ensure input is one or more valid colormaps
    if isnumeric(cmaps)
        for i = 1:pagedims(cmaps)
            validateCmap(cmaps(:,:,i));
        end
    else
        mustBeA(cmaps,'cell');
        verifyNumProp(map,cmaps);
        for i = 1:numel(cmaps)
            validateCmap(cmaps{i});
        end
    end
end