function [ct_geom,projection_data,tube_angles,table_positions] = wfbp_load_siemens(dirpath)

% CT Geometry information
ct_geom.projections_per_rotation     = 1152;
ct_geom.detPixSizeCol                = 1.286;
ct_geom.detPixSizeRow                = 2.1894;
ct_geom.n_detector_channels          = 736;
ct_geom.n_detector_rows              = 16;
ct_geom.detCentralCol                = 366.25;
ct_geom.detCentralRow                = 7.5;
ct_geom.distance_source_to_detector  = 1085.6;
ct_geom.distance_source_to_isocenter = 595;
ct_geom.collimated_slicewidth        = 1.2;
ct_geom.theta_cone                   = 0.030249;
ct_geom.z_rot                        = 19.2;

% Load projection data
projection_data = single(j_bin_float(fullfile(dirpath,'raw.bin')));
projection_data = reshape(projection_data,ct_geom.n_detector_channels,ct_geom.n_detector_rows,[]);
projection_data = permute(projection_data,[2 1 3]);

% Generate tube angles 
num_projections = size(projection_data,3);
tube_angles = zeros(1,num_projections);
tube_start_angle = 236.25*pi/180;
for (i=1:num_projections)
    curr_idx = i-1;
    tube_angles(i) = tube_start_angle + 2*pi*curr_idx/ct_geom.projections_per_rotation;
end

% Generate table positions
for (i=1:num_projections)
    curr_idx = i-1;
    table_positions(i) = ct_geom.z_rot*curr_idx/ct_geom.projections_per_rotation;
end

end