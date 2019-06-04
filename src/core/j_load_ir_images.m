function stack = j_load_ir_images(study_dir,frame_number)

images_root = strtrim(ls('-pd',study_dir));
images_root = fullfile(images_root,'images');

ir_cam_dirs = {'2' ,  
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

stack = zeros(4096,3000,numel(ir_cam_dirs));


    for i=1:numel(ir_cam_dirs)
        filepath = fullfile(images_root,ir_cam_dirs{i},sprintf('%06d.tiff',frame_number));
        fprintf('Loading "%s"...\n',filepath);        
        stack(:,:,i) = rot90(imread(filepath),-1);
    end

end

