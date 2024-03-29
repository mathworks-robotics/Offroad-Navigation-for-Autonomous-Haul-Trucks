% Generate ROS message descriptions
extractLocalMapSetup
globalPlanSetup
localPlanSetup
routePlanSetup

% Compile ROS messages
bdclose('all');
cd(fileparts(which('regenMsg')))
ros2genmsg