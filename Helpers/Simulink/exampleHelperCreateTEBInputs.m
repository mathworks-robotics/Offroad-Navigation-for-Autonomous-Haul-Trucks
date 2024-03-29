% Create map layers and generate TEB controller
load("OpenPitMinePart2Data.mat", "originalReferencePath", "smoothedReferencePath", "fixedTerrainAwareParams", "tuneableTerrainAwareParams");

% Create tunable parameters and generate a Simulink Bus
[tuneableTEBParams,fixedTEBParams] = exampleHelperTEBParams;
if  ~exist("teb_bus_info","var")
    teb_bus_info = Simulink.Bus.createObject(tuneableTEBParams);
    teb_bus = evalin('base', teb_bus_info.busName);
    teb_bus.Elements(3).Name = 'CostWeights_T'; %<TODO> Remove after Simulink C++ bus issue is fixed
end

%<TODO> Remove after Simulink C++ bus issue is fixed
origNames = fieldnames(tuneableTEBParams);
tuneableTEBParamsCpp = Simulink.Bus.createMATLABStruct('teb_bus');
newNames = fieldnames(tuneableTEBParamsCpp);
for i = 1:numel(origNames)
    tuneableTEBParamsCpp.(newNames{i}) = tuneableTEBParams.(origNames{i});
end

% Define simulation variables
tsReplan = 3;
tsIntegrator = 0.001;
tsVisualize = 0.1;

% Copyright 2023 The MathWorks, Inc.