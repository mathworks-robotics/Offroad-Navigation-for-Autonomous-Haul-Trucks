% Define data
a = 1;
b = single(rand(100,2));
c = rand(10,2);
d = [0 0];

% Create structs (i.e. Simulink Bus)
s = struct('a',a,'b',b,'c',coder.typeof(0,[20 2],[1 0]),'d',d);
sType = coder.typeof(s);
reqType = sType;
respType = coder.typeof(struct('data',coder.typeof(single(0),[inf 2])));

% Prep test area
mkdir mytest
msgDir = fullfile(matlab.project.rootProject().RootFolder,'ROSHelper');

% Generate custom message
ros2msgfromstruct(sType,Folder=msgDir,PkgName="msgDir",Name="mytest");

% Generate custom service
ros2msgfromstruct([reqType; respType],Folder=msgDir,PkgName="msgDir", ...
    Name="mytest",Type="srv");