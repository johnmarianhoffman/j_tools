function stack = j_load_confidence_maps(study_dir,frame_number)

    confidence_map_root = strtrim(ls('-pd',study_dir));

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

    stack = zeros(4096,3000,numel(depth_cam_dirs));
    for i=1:numel(depth_cam_dirs)
        filepath = fullfile(confidence_map_root,'confidence_maps',depth_cam_dirs{i},sprintf('%06d.tiff',frame_number));
        fprintf('Loading "%s"...\n',filepath);        
        stack(:,:,i) = rot90(cv_float_loader(filepath),-1);
    end

end
