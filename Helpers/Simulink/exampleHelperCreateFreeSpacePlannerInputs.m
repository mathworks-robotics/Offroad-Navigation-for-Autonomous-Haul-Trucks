%% Load data
load("OpenPitMinePart1Data.mat");

%% Create planner params and Simulink busses
[tuneableTerrainAwareParams, fixedTerrainAwareParams] = exampleHelperTerrainPlannerParams;
if ~exist("fsp_tunable_info","var")
fsp_tunable_info = Simulink.Bus.createObject(tuneableTerrainAwareParams);
fsp_tunable_bus = evalin('base', fsp_tunable_info.busName);
end

if ~exist("fsp_fixed_info","var")
fsp_fixed_info = Simulink.Bus.createObject(fixedTerrainAwareParams);
fsp_fixed_bus = evalin('base', fsp_fixed_info.busName);
end

% Copyright 2023 The MathWorks, Inc.