function d=j_get_file_list(d)

d=dir(d);
d=d(~[d(:).isdir]);
d={d(:).name};

end