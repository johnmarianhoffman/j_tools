rawpath = '~/data/local_ge_raw/'
a = tic;
%[ct_geom,raw,tube_angles,table_positions] = wfbp_load_data(rawpath);
%raw      = flip(raw,2);
%rebin    = wfbp_rebin(raw,ct_geom);
filtered = wfbp_filter(rebin,ct_geom);
reconstructed_slice = wfbp_backproject(filtered,ct_geom,tube_angles,table_positions);
toc(a);