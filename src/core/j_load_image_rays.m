function rays = j_load_image_rays(study_dir,frame_number)

study_dir = strtrim(ls('-pd',study_dir));
image_ray_dir = fullfile(study_dir,'image_rays');

depth_cams = {'2' ,  
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



rays = cell(1,numel(depth_cams));
for i=1:numel(depth_cams)
    filelist = glob(fullfile(image_ray_dir,sprintf('f%06d_camRef%s_*.imgrays',frame_number,depth_cams{i})));
    curr_file = filelist{1};
    fprintf('Loading images rays: %s\n',curr_file);
    rays{i}.data = cv_image_ray_loader(curr_file);
end

end