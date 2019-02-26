function [final_iterations,final_segs] =check_seg_criteria(study_dir)

color_cam_ids = [5,6,7,8,13,14,15,16,21,22,23,24,29,30,31,32,37,38,39,40,45,46,47,48,53,54,55,56,61,62,63,64];
final_iterations = zeros(1,numel(color_cam_ids));
final_segs       = zeros(3000,4096,3,numel(color_cam_ids));

for i=1:numel(color_cam_ids)
    camId = color_cam_ids(i);
    fprintf('========================================\n');
    fprintf('Computing for cam %d ... \n',camId);
    fprintf('========================================\n');    
    [final_iterations(i),final_segs(:,:,:,i)] = load_masks_check_changes(camId);
end
end