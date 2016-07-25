function save_all_figures(outdir)

mkdir(fullfile(outdir,'fig_dump'));

fig_list=get(0,'children');

for i=1:numel(fig_list);

    full_outpath=fullfile(outdir,'fig_dump',sprintf('figure_%i.fig',i));
    disp(full_outpath);
    
    saveas(fig_list(i),full_outpath);

end