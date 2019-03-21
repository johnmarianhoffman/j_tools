fprintf('We''re disabling name shadowing warnings since we abuse these.\n');
warning('off','MATLAB:dispatcher:nameConflict');

addpath(fullfile(pwd,'src/core/'));
addpath(fullfile(pwd,'src/core/gui/'));
addpath(fullfile(pwd,'src/core/magicleap/'));
addpath(fullfile(pwd,'src/dev/'));
addpath(fullfile(pwd,'src/dev/aliases/'));
addpath(fullfile(pwd,'src/lib/'));
addpath(fullfile(pwd,'src/lib/GUILayout/layout/'));
addpath(fullfile(pwd,'src/tools/'));
addpath(fullfile(pwd,'src/scratch/'));
addpath(fullfile(pwd,'src/games/'));

addpath(genpath(fullfile(pwd,'src/lib/')));

if ~usejava('desktop');
    addpath(fullfile(pwd,'src/dev/ml_emacs/toolbox'),'-begin');
    rehash;
    emacsinit;
end

