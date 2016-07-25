function j_export_fig(fig_handle,outpath)

load(fullfile(j_path,'src/resources/fig_style.mat'));

hgexport(fig_handle,outpath,s);

end