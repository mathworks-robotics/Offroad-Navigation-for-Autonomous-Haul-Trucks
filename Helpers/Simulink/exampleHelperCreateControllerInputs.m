% Create map layers and generate controller parameters
load("OpenPitMinePart2Data.mat", "originalReferencePath", "smoothedReferencePath", "fixedTerrainAwareParams", "tuneableTerrainAwareParams");

% Create tunable parameters and generate a Simulink Bus
[tuneableControllerParams,fixedControllerParams] = exampleHelperControllerParams;
if  ~exist("controller_bus_info","var")
    controller_bus_info = Simulink.Bus.createObject(tuneableControllerParams);
    controller_bus = evalin('base', controller_bus_info.busName);
    controller_bus.Elements(3).Name = 'CostWeights_T'; % Accommodates Simulink C++ bus requirement
end

% Accommodates Simulink C++ bus requirement
origNames = fieldnames(tuneableControllerParams);
tuneableControllerParamsCpp = Simulink.Bus.createMATLABStruct('controller_bus');
newNames = fieldnames(tuneableControllerParamsCpp);
for i = 1:numel(origNames)
    tuneableControllerParamsCpp.(newNames{i}) = tuneableControllerParams.(origNames{i});
end

% Define simulation variables
tsReplan = 3;
tsIntegrator = 0.02;
tsVisualize = 0.1;

% Copyright 2023-2025 The MathWorks, Inc.