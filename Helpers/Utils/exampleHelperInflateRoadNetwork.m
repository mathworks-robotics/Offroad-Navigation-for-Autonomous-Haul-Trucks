function binMap = exampleHelperInflateRoadNetwork(binMap,pathListGrid,inflationRadius)
%exampleHelperInflateRoadNetwork Clear obstacle in close proximity to the pathList
%

% Copyright 2023-2024 The MathWorks, Inc.

    % Create an empty map of equal size to current obstacle map
    tmpMap = binaryOccupancyMap(zeros(binMap.GridSize),Resolution=binMap.Resolution);
    
    % Inflate the roadnetwork
    setOccupancy(tmpMap,vertcat(pathListGrid.Path),1,'grid');
    inflate(tmpMap,inflationRadius);
    
    % Remove inflated skeleton from the original map
    setOccupancy(binMap,binMap.occupancyMatrix & ~tmpMap.occupancyMatrix);
end