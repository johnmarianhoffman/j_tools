function load_all_figures(indir)

list=dir(indir);

file_list=list(~[list.isdir]);

file_list={file_list.name};

for i=1:numel(file_list)

    [~,~,ext]=fileparts(file_list{i});
    if isequal(ext,'.fig')
        open(fullfile(indir,file_list{i}));
    end

end

end