function exit(confirm)

if (nargin<1)
    fprintf('Just saved your ass.  Run with "FURREAL" if you really want to quit.\n')
elseif (strcmp(confirm,'FURREAL'))
    fprintf('Ok now we''re actually exiting...\n');
    run('/usr/local/MATLAB/R2018b/toolbox/matlab/general/exit.m');
else    
    fprintf('This input argument ''%s'' is nonsense. Get your shit together.\n',confirm);
end

end