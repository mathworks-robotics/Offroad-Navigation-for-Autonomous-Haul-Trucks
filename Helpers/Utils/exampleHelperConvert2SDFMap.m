function sdf = exampleHelperConvert2SDFMap(map,nv)
%exampleHelperConvert2SDFMap converts binary/occupancy map to sdf map
%

% Copyright 2023-2024 The MathWorks, Inc.

arguments
    map (1,1) {mustBeA(map,{'occupancyMap','binaryOccupancyMap'})}
    nv.interpolationMethod (1,1) {mustBeMember(nv.interpolationMethod,{'linear','none'})} = "linear"
end
sdf = signedDistanceMap(map.checkOccupancy==1,Resolution=map.Resolution,InterpolationMethod=nv.interpolationMethod);
sdf.GridOriginInLocal = map.GridOriginInLocal;
sdf.GridLocationInWorld = map.GridLocationInWorld;
end