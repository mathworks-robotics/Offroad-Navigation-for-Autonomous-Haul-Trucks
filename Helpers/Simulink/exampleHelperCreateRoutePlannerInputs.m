%% Load Data
load("OpenPitMinePart1Data.mat", "imSlope", "pathList", "dem");

%% Format data for Simulink

% Initialize map
binMap = binaryOccupancyMap(imSlope);
mat = binMap.getOccupancy();
gridLoc = binMap.GridLocationInWorld;
res = binMap.Resolution;
maxRefPathLen = 1e4;
maxLocalPathLen = 1e3;

% Convert grid coordinate pathList to local coordinates
localPathList = pathList;
for i = 1:numel(pathList)
    localPathList(i).Path = binMap.grid2local(pathList(i).Path);
end

% Flatten pathList struct-array
maxNumPoints = 1e5;
maxNumEdge = 1e3;
pathBus_struct = exampleHelperEncodeBus(localPathList,maxNumPoints,maxNumEdge);

% Define bus with varsize elements
pathList_fixed_bus_info = Simulink.Bus.createObject(pathBus_struct);
pathList_fixed_bus = evalin('base',pathList_fixed_bus_info.busName);
pathList_fixed_bus.Description = 'PathList';
pathList_fixed_bus.Elements(1).Dimensions = [maxNumPoints 2];
pathList_fixed_bus.Elements(2).Dimensions = [maxNumEdge 2];

pathList_variable_bus_info = Simulink.Bus.createObject(pathBus_struct);
pathList_variable_bus = evalin('base',pathList_variable_bus_info.busName);
pathList_variable_bus.Description = 'PathList';
pathList_variable_bus.Elements(1).DimensionsMode = "Variable";
pathList_variable_bus.Elements(1).Dimensions = [inf 2];
pathList_variable_bus.Elements(2).DimensionsMode = "Variable";
pathList_variable_bus.Elements(2).Dimensions = [inf 2];

% Copyright 2023 The MathWorks, Inc.