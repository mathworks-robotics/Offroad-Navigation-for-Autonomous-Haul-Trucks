function projectshutdown
%projectshutdown - Remove files from the project from user path
rmpath(genpath('Helpers'));
rmpath(genpath('images'));
rmpath(genpath('SimModels'));
%disp('project files removed from path.');
end