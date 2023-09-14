function [stateFree,dist] = exampleHelperCheckCollisionSDF(sdf,capPts,radius,curpath)
%exampleHelperCheckCollisionSDF Use signed distance to check for collision along path
    
    if size(curpath,2) == 3
        nCapPt = size(capPts,1);
        R = eul2rotm(-curpath(:,3).*[1 0 0],'ZYX');
        dV = pagemtimes(capPts,R(1:2,1:2,:));
        pts = reshape([curpath(:,1)' + squeeze(dV(:,1,:)) curpath(:,2)' + squeeze(dV(:,2,:))],[],2);
    else
        nCapPt = 1;
        pts = curpath;
    end
    dist = min(reshape(sdf.distance(pts)-radius,nCapPt,[]),[],1)';
    stateFree = dist > 0 | isnan(dist);
end