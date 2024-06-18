% Create map layers and generate TEB controller
load("OpenPitMinePart2Data.mat", "originalReferencePath", "smoothedReferencePath", "fixedTerrainAwareParams", "tuneableTerrainAwareParams");

% Create tunable parameters and generate a Simulink Bus
[tuneableTEBParams,fixedTEBParams] = exampleHelperTEBParams;
if ~exist("teb_bus_info","var")
    teb_bus_info = Simulink.Bus.createObject(tuneableTEBParams);
    teb_bus = evalin('base', teb_bus_info.busName);    
end

% Define simulation variables
tsReplan = 3;
tsIntegrator = 0.001;
tsVisualize = 0.1;

% Copyright 2023 The MathWorks, Inc.