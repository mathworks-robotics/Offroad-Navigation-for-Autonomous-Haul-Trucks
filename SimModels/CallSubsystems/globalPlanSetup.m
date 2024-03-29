% Initialize model inputs
exampleHelperCreateBehaviorModelInputs

% Define the initial start pose of the vehicle in the scene:
start = [267.5 441.5 -pi/2];
goal  = [350 300 0];

% Configure service messages
matType = coder.typeof(0,[1201 1201],[1 1]);
refPathType = coder.typeof(0,[maxRefPathLen 3],[1 0]);
inMsg = struct(...
    'TuneableTerrainAwareParams',tuneableTerrainAwareParams, ...
    'Start',start, ...
    'Goal',goal,...
    'DigitalElevationMap',matType, ...
    'Resolution',res, ...
    'GridLoc',gridLoc);
outMsg = struct('RefPath',refPathType);

% Generate service and all required message types
sType = [coder.typeof(inMsg) coder.typeof(outMsg)];
msgDir = fullfile(matlab.project.rootProject().RootFolder,'ROSHelper');
ros2msgfromstruct(sType,Folder=msgDir,PkgName="offroad_msg",...
    Name="PlanGlobal",Type="srv");