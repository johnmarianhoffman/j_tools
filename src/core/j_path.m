function p=j_path()
% Returns path to where j_tools is installed

s=which('j_path');
idx=strfind(s,'j_tools');

% Add in a little protection if someone does something stupid with the install
if numel(idx)>1
    idx=idx(end);
end

p=s(1:(idx+7));

end