addpath(fullfile(pwd,'src/core/'));
addpath(fullfile(pwd,'src/core/gui/'));
addpath(fullfile(pwd,'src/dev/'));
addpath(fullfile(pwd,'src/dev/aliases/'));
addpath(fullfile(pwd,'src/lib/'));
addpath(fullfile(pwd,'src/tools/'));
addpath(fullfile(pwd,'src/scratch/'));


if ~usejava('desktop');
    addpath(fullfile(pwd,'src/dev/ml_emacs/toolbox'),'-begin');
    rehash;
    emacsinit;
end