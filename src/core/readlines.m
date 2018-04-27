function lines=readlines(filepath)
% lines=readlines(filepath)
%
% Returns cell array of strings (lines) containing each line
% of file at filepath.

% Get case list (to lookup pipeline ID with study number)
fid=fopen(filepath,'r');
raw=char(fread(fid)');
fclose(fid);

lines=strsplit(raw,'\n');

end