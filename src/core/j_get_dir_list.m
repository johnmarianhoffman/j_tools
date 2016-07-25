function d=j_get_dir_list(d)

d=dir(d);
d=d([d(:).isdir]);
d={d(:).name};

d(ismember(d,'.'))=[];
d(ismember(d,'..'))=[];

end