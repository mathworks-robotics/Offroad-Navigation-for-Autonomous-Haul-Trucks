function map = exampleHelperInflateRoadNetwork(map,pathListGrid,inflationRadius)
% exampleHelperInflateRoadNetwork Clear obstacle in close proximity to the
% map

% Copyright 2023-2025 The MathWorks, Inc.

if isa(map, 'binaryOccupancyMap')
    tmpMap = binaryOccupancyMap(zeros(map.GridSize),Resolution=map.Resolution);
else
    tmpMap = occupancyMap(zeros(map.GridSize),Resolution=map.Resolution);
end


% Inflate the roadnetwork
setOccupancy(tmpMap,vertcat(pathListGrid.Path),1,'grid');
inflate(tmpMap,inflationRadius);

% Remove inflated skeleton from the original map
if isa(map, 'binaryOccupancyMap')
    setOccupancy(map,map.occupancyMatrix & ~tmpMap.occupancyMatrix);
else
    occpMat = map.checkOccupancy([1,1], map.GridSize, 'grid');    
    setOccupancy(map, occpMat);
end
end