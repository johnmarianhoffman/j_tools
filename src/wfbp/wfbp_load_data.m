function [ct_geom,projection_data,tube_angles,table_positions] = wfbp_load_data(dirpath)

    projection_filepaths = get_file_list(dirpath);
    
    ct_geom = get_geometry(fullfile(dirpath,projection_filepaths{1}));
    
    % Preallocate arrays
    n_projections   = numel(projection_filepaths);
    tube_angles     = zeros(1,n_projections);
    table_positions = zeros(1,n_projections);
    projection_data = zeros(ct_geom.n_detector_rows,ct_geom.n_detector_channels,n_projections,'single');
    
    for (i = 1:numel(projection_filepaths))
        
        projection_filepath = fullfile(dirpath,projection_filepaths{i});
        fprintf("Reading projection: %s\n",projection_filepath);
        
        h = dicominfo(projection_filepath,'dictionary','raw_data_dict.txt');
        tube_angles(i) = double(h.DetectorFocalCenterAngularPosition);
        table_positions(i) = double(h.DetectorFocalCenterAxialPosition);
        
        tmp = dicomread(projection_filepath);
        projection_data(:,:,i) = permute(single(tmp)*single(ct_geom.rescale_slope) + single(ct_geom.rescale_intercept),[2 1]);
        
        %detFocalCenterPhi = double(header.DetectorFocalCenterAngularPosition); % tube_angle
        %detFocalCenterZ = double(header.DetectorFocalCenterAxialPosition); % table_position
        %
        %projection = projectionUncorr * double(header.RescaleSlope) + double(header.RescaleIntercept);% projection representing line integral of linear attenuation coefficients, double-precision
    end
    
    ct_geom.z_rot = table_positions(ct_geom.projections_per_rotation + 1) - table_positions(1);
    
end

function ct_geom = get_geometry(filepath)
    
    h = dicominfo(filepath,'dictionary','raw_data_dict.txt');
    
    ct_geom.projections_per_rotation     = double(h.NumberofSourceAngularSteps); 
    ct_geom.detPixSizeCol                = double(h.DetectorElementTransverseSpacing); % dcol, detector column width measured at detector surface, mm
    ct_geom.detPixSizeRow                = double(h.DetectorElementAxialSpacing); % drow, detector row width measured at detector surface, mm
    ct_geom.n_detector_channels          = double(h.NumberofDetectorColumns); % Ncol, number of detector columns
    ct_geom.n_detector_rows              = double(h.NumberofDetectorRows); %Nrow, number of detector rows 
    ct_geom.detCentralCol                = double(h.DetectorCentralElement(1)); % ColX, the detector column that aligns with isocenter and detector focal center
    ct_geom.detCentralRow                = double(h.DetectorCentralElement(2)); % RowY, the detector row that aligns with isocenter and detector focal center
    ct_geom.distance_source_to_detector  = double(h.ConstantRadialDistance); % d0, in-plane detector focal center-to-detector distance(radius of detector arc), mm
    ct_geom.distance_source_to_isocenter = double(h.DetectorFocalCenterRadialDistance); % rho0, detector focal center radial location, mm
    
    ct_geom.rescale_intercept = h.RescaleIntercept;
    ct_geom.rescale_slope     = h.RescaleSlope;
    
    ct_geom.collimated_slicewidth = ct_geom.distance_source_to_isocenter*(ct_geom.detPixSizeRow/ct_geom.distance_source_to_detector);
    detector_cone_offset = (ct_geom.n_detector_rows - 1)/2.0;
    ct_geom.theta_cone = 2.0*atan(detector_cone_offset * ct_geom.collimated_slicewidth/ct_geom.distance_source_to_isocenter);
    
end

function d = get_file_list(d)
    d=dir(d);
    d=d(~[d(:).isdir]);
    d={d(:).name};
end