function stack = j_load_confidence_maps(study_dir,frame_number)

    confidence_map_root = strtrim(ls('-pd',study_dir));

    ir_cams = true;
    vh_cams = true-ir_cams;
    
    if (ir_cams)
        depth_cam_dirs = {'2' ,  
                          '3' ,          
                          '10',  
                          '11',  
                          '18',  
                          '19',  
                          '26',  
                          '27',  
                          '34',  
                          '35',  
                          '42',  
                          '43',  
                          '50',  
                          '51',  
                          '58',  
                          '59'};
    end

    if (vh_cams)
        depth_cam_dirs = {'5',
                          '8',
                          '13',
                          '16',
                          '21',
                          '24',
                          '29',
                          '32',
                          '37',
                          '40',
                          '45',
                          '48',
                          '53',
                          '56',
                          '61',
                          '64'};
    end
    

    stack = zeros(4096,3000,numel(depth_cam_dirs));
    for i=1:numel(depth_cam_dirs)
        filepath = fullfile(confidence_map_root,'confidence_maps',depth_cam_dirs{i},sprintf('%06d.tiff',frame_number));
        fprintf('Loading "%s"...\n',filepath);        
        stack(:,:,i) = rot90(cv_float_loader(filepath),-1);
    end

end
