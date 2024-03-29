function projectstartup
%projectstartup - Configure project
    prj = matlab.project.rootProject();
    addFcn = @addpath;
    if isempty(prj)
        prjDir = fileparts(which("projectstartup"));
    else
        prjDir = prj.RootFolder;
        prj = matlab.project.rootProject();
        prj.addFolderIncludingChildFiles('Helpers');
        prj.addFolderIncludingChildFiles('SimModels');
        prj.addFolderIncludingChildFiles('ROSHelper');
    end
    addFcn(prjDir);
    addFcn(genpath(fullfile(prjDir,'Helpers')));
    addFcn(fullfile(prjDir,'Helpers','MPCController'));
    addFcn(genpath(fullfile(prjDir,'images')));
    addFcn(genpath(fullfile(prjDir,'SimModels')));
    addFcn(genpath(fullfile(prjDir,'ROSHelper')));
    addFcn(genpath(fullfile(prjDir,'TestScripts')));
    disp('project files added to path.');
    
    cfg = Simulink.fileGenControl('getConfig');
    
    buildDir = char(fullfile(prjDir,"Build",matlabRelease.Release));
    cfg.CacheFolder = buildDir;
    cfg.CodeGenFolder = buildDir;
    Simulink.fileGenControl('setConfig', 'config', cfg, 'createDir', true);
    disp('set build directory.');
end