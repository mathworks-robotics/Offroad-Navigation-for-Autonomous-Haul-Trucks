function [pathList,modifiedImage] = exampleHelperSkel2Edges(bwskel,nv)
%exampleHelperSkel2Edges Computes the nodes and edge list from a skeletonized image
%
% Copyright 2023-2024 The MathWorks, Inc.

    arguments
        bwskel (:,:) {mustBeNumericOrLogical}
        nv.Visualize (:,:) {mustBeMember(nv.Visualize,[0,1])} = 0;
    end
    % Clean image, remove "corner"-cases and generate branch/edge images
    [modifiedImage,branchPtImg] = moddedbranch(bwskel);
    openCells = modifiedImage;
    endPtImg = bwmorph(openCells,'endpoints');

    [ii,jj] = meshgrid([-1 0 1],[-1 0 1]);
    nbrOffset = [ii(:) jj(:)];
    nbrOffset(ceil(size(nbrOffset,1)/2),:) = [];
    sz = size(modifiedImage);

    if nv.Visualize
        figure;
        hIm = imshow(openCells);
        exampleHelperOverlayImage(branchPtImg,hIm.Parent,Radius=0,Color=[1 0 0]);
        exampleHelperOverlayImage(endPtImg,hIm.Parent,Radius=0,Color=[0 0 1]);
        title('Graph from Skeletonized Image');
    
        im = false(sz);
        exampleHelperOverlayImage(im,hIm.Parent,Radius=3,Color=[0 1 0]);
        hold on;
        hCur = plot(nan,nan,'gX','MarkerSize',20);
    else
        hIm = []; hCur = [];
    end

    % Find all end and branch points
    [bI,bJ] = find(branchPtImg);
    [eI,eJ] = find(endPtImg);

    % Edges may terminate when they contact either branch or end points
    branchPtImg = branchPtImg | endPtImg;

    % Build edge list
    [pathList,openCells] = constructEdges([eI(:) eJ(:)],branchPtImg,openCells,nbrOffset,hIm,hCur,nv.Visualize);
    pathList = [pathList; constructEdges([bI(:) bJ(:)],branchPtImg,openCells,nbrOffset,hIm,hCur,nv.Visualize)];
end

function [pathList,openCells,branchPtImg] = constructEdges(seedPts,branchPtImg,openCells,nbrOffset,hIm,hCur,visualize)
%constructEdges Compute edges originating from set of start locations

    % Initialize branches
    seeds = zeros(size(seedPts,1),3);
    pathList = repmat(struct('Path',[]),0,1);
    idx = 1;
    for i = 1:size(seedPts,1)
        % Find all open neighbors
        branchPt = seedPts(i,:);
        [nbr, iNbr] = findValidNeighbors(openCells,nbrOffset,branchPt);

        for iv = 1:size(nbr,1)
            % Add the beginning of each branch to the pathList
            pathList(end+1,1).Path = [branchPt;nbr(iv,:)]; %#ok<AGROW>
            if ~branchPtImg(nbr(iv,1),nbr(iv,2))
                % Add any branches that don't immediately end to the search
                % queue
                seeds(idx,:) = [nbr(iv,:) numel(pathList)];
                idx = idx+1;
            end
        end
    end

    % Trace each edge
    for i = 1:size(seeds,1)
        [pathList(i),openCells] = buildEdge(pathList(i),openCells,branchPtImg,nbrOffset,hCur,hIm,visualize);
    end

    % Remove dead branches
    deadBranch = arrayfun(@(x)size(x.Path,1)==2 && ~branchPtImg(x.Path(2,1),x.Path(2,2)), pathList);
    pathList(deadBranch) = [];
end

function [S,openCells] = buildEdge(S,openCells,branchPtImg,nbrOffset,hCur,hIm,visualize)
%buildEdge Follow edge until end or branch point is found and record segment

    % Retrieve next branch start
    src = S.Path(1,:);
    pt = S.Path(end,:);
    sz = size(openCells);
    openCells(pt(1),pt(2)) = 0;

    % Find non-source neighbors
    [curNbr, iCurNbr] = findValidNeighbors(openCells,nbrOffset,pt);
    iSrc = sub2ind(sz,src(1),src(2));
    [~,iSrcNbr] = findValidNeighbors(openCells,nbrOffset,src);
    mNext = iCurNbr ~= iSrc & ~ismember(iCurNbr,iSrcNbr);

    if nnz(mNext) > 0
        pt(1:2) = curNbr(mNext,1:2);
        set(hCur,XData=pt(2),YData=pt(1));
        S.Path(end+1,:) = pt(1:2);

        while ~branchPtImg(pt(1),pt(2))
            % Close current cell
            openCells(pt(1),pt(2)) = 0;
            if visualize
                set(hCur,XData=pt(2),YData=pt(1));
                hIm.CData = openCells;
                drawnow limitrate;
            end

            % Find potential neighbors
            [nbr, iNbr] = findValidNeighbors(openCells,nbrOffset,pt);

            % Prioritize choosing branch-point, otherwise select the next
            % valid edge-point.
            branchNbr = nbr(branchPtImg(iNbr),:);
            if ~isempty(branchNbr)
                pt(1:2) = branchNbr(1,1:2);
            else
                pt(1:2) = nbr(1,:);
            end
            S.Path(end+1,:) = pt(1:2);
        end
    end
end

function [validNeighbors,validLinIdx] = findValidNeighbors(openCells,nbrOffset,pt)
%findValidNeighbors Find neighboring cells that have not been closed
    nbr = pt(1:2)+nbrOffset;
    linIdx = sub2ind(size(openCells),nbr(:,1),nbr(:,2));
    isValidPt = all(nbr > 0,2) & all(nbr <= size(openCells),2) & openCells(linIdx);
    validNeighbors = nbr(isValidPt,:);
    validLinIdx = linIdx(isValidPt);
end

function [openCells, branchPtImg] = moddedbranch(skelImg)
%moddedbranch Eliminate spurious corner-points leftover from
%skeletonization or end-branch removal
    openCells = bwmorph(skelImg,'spur');
    sz = size(openCells);

    % Compute branch points
    branchPtImg = bwmorph(openCells,'branchpoints');
    [bI,bJ] = find(branchPtImg);

    [ii,jj] = meshgrid([-1 0 1],[-1 0 1]);
    nbrOffset = [ii(:) jj(:)];
    nbrOffset(ceil(size(nbrOffset,1)/2),:) = [];

    hIm = imshow(openCells);
    exampleHelperOverlayImage(branchPtImg,hIm.Parent,Radius=0,Color=[1 0 0]);
    title('Graph from Skeletonized Image');

    % Remove mid-branch "corner"-case whereby 2 branchpoints are found
    % side-by-side
    for ib = 1:numel(bI)
        % Check each adjacent cell, and remove if it is a non-branchpt and
        % has no free non-branch neighbors
        nbr = [bI(ib) bJ(ib)] + nbrOffset;
        linIdx = sub2ind(sz,nbr(:,1),nbr(:,2));
        validIdx = find(all(nbr > 0,2) & all(nbr <= size(openCells),2) & openCells(linIdx) & ~branchPtImg(linIdx));
        for nIdx = 1:numel(validIdx)
            curNbr = nbr(validIdx(nIdx),:);
            nextNbr = curNbr + nbrOffset;
            nbrLinIdx = sub2ind(sz,nextNbr(:,1),nextNbr(:,2));
            freeNeighbors = all(nextNbr > 0,2) & all(nextNbr <= size(openCells),2) & openCells(nbrLinIdx);
            if nnz(freeNeighbors & ~branchPtImg(nbrLinIdx)) == 0
                % Spurious corner, remove from the openCell list and clear
                % any adjacent "branchPoints"
                openCells(curNbr(1),curNbr(2)) = false;
                branchPtImg(nbrLinIdx(freeNeighbors)) = false;
            end
        end
    end
end