%% Load data
load("OpenPitMinePart1Data.mat");

%% Create planner params and Simulink busses
[tuneableTerrainAwareParams, fixedTerrainAwareParams] = exampleHelperTerrainPlannerParams;
fsp_tunable_info = Simulink.Bus.createObject(tuneableTerrainAwareParams);
fsp_fixed_info = Simulink.Bus.createObject(fixedTerrainAwareParams);
fsp_tunable_bus = evalin('base', fsp_tunable_info.busName);
fsp_fixed_bus = evalin('base', fsp_fixed_info.busName);

% Copyright 2023 The MathWorks, Inc.