%% Create the NLMPC Object

mpcverbosity('off');
tsMPC = 0.1;
mpcHorizon = 1;
nStage = mpcHorizon/tsMPC;
stateSize = 3;
controlSize = 2;
nlobjTracking = nlmpcMultistage(nStage,stateSize,controlSize);
nlobjTracking.Optimization.Solver = "fmincon";
nlobjTracking.Ts = tsMPC;

%% Vehicle Parameters
% Use vehicle-parameters defined for our TEB controller
[tunableTEBParams,fixedTEBParams] = exampleHelperTEBParams;
vWheelBase = fixedTEBParams.Length;

%% Specify the prediction model and its analytical Jacobian in the controller object.

% Since the model requires one parameters (|vWheelBase|), set |Model.ParameterLength| to 1.
nlobjTracking.Model.StateFcn        = "exampleHelperBicycleDerivative_MultiStage";
nlobjTracking.Model.StateJacFcn     = "exampleHelperBicycleJacobian_MultiStage";
nlobjTracking.Model.ParameterLength = 1;

%% Define constraints for the manipulated variables. 
% Here, MV(1) is the ego vehicle speed in m/s, and MV(2) is the steering angle in radians.

nlobjTracking.UseMVRate = true;
nlobjTracking.ManipulatedVariables(1).Min       = -tunableTEBParams.MaxReverseVelocity;
nlobjTracking.ManipulatedVariables(1).Max       =  tunableTEBParams.MaxVelocity(1);
nlobjTracking.ManipulatedVariables(1).RateMin   = -tunableTEBParams.MaxAcceleration(1);
nlobjTracking.ManipulatedVariables(1).RateMax   =  tunableTEBParams.MaxAcceleration(1);

vNom = nlobjTracking.ManipulatedVariables(1).Max;
ds = tsMPC*vNom;
nPt = 100;
refPath = linspace(0,ds*nPt,nPt+1)'.*[1 0 0];

% Set steer angle limits
nlobjTracking.ManipulatedVariables(2).Min       = -tunableTEBParams.MaxVelocity(2);
nlobjTracking.ManipulatedVariables(2).Max       =  tunableTEBParams.MaxVelocity(2);
nlobjTracking.ManipulatedVariables(2).RateMin   = -tunableTEBParams.MaxAcceleration(2);
nlobjTracking.ManipulatedVariables(2).RateMax   =  tunableTEBParams.MaxAcceleration(2);

%% Define cost function and gradient.

for ct=1:nStage+1
    nlobjTracking.Stages(ct).CostFcn         = "exampleHelperBicycleCost_MultiStage";
    nlobjTracking.Stages(ct).CostJacFcn      = "exampleHelperBicycleGradient_MultiStage";
    nlobjTracking.Stages(ct).ParameterLength = 4;
end

%% Validate the controller design.

simdata = getSimulationData(nlobjTracking,'TerminalState');
simdata.StateFcnParameter = vWheelBase;
simdata.StageParameter = reshape([refPath(1:(nStage+1),:)'; repmat(nStage,1,nStage+1)],[],1);
validateFcns(nlobjTracking,[-14.8 0 0],[0.1 0],simdata);

%% Define busses needed to represent MPC paths in Simulink
mpcPath_struct = struct('States',rand(10,3));
mpcPath_struct_combined = exampleHelperEncodeBus(mpcPath_struct,maxRefPathLen);

% Create busses
mpcPathList_fixed_bus_info = Simulink.Bus.createObject(mpcPath_struct_combined);
mpcPathList_fixed_bus = evalin('base',mpcPathList_fixed_bus_info.busName);
mpcPathList_fixed_bus.Description = 'MPCPath_Fixed';
mpcPathList_fixed_bus.Elements(1).Dimensions = [maxRefPathLen 3];
mpcPathList_fixed_bus.Elements(2).Dimensions = [maxNumEdge 2];

mpcPathList_variable_bus_info = Simulink.Bus.createObject(mpcPath_struct);
mpcPathList_variable_bus = evalin('base',mpcPathList_variable_bus_info.busName);
mpcPathList_variable_bus.Description = 'MPCPath_Variable';
mpcPathList_variable_bus.Elements(1).DimensionsMode = "Variable";
mpcPathList_variable_bus.Elements(1).Dimensions = [inf 3];