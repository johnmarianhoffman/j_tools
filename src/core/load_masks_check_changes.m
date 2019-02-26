function [final_iteration,tinted_image] = load_masks_check_changes(camId)
    
    % Load images
    frame_num = 3800;
    study_dir = sprintf('/volcap/data/recon/technical_tests/john_segmentation_testing/rsc_3800-4200_iterative_w_stopping_criteria/segmentation_output/%06d',frame_num);
    filename = sprintf('mask_cam_%d.tiff',camId);
    tinted_images = sprintf('tintedImage_cam_%d.tiff',camId);
    iterations = [0,1];

    m = zeros(3000,4096,numel(iterations));
    imgs = zeros(3000,4096,3,numel(iterations),'uint8');
    for i=iterations
        filepath = fullfile(study_dir,sprintf('iteration_%d',i),filename);
        m(:,:,i+1)= imread(filepath);
    end

    m = m/255;

    % Compute percent change
    p_change = 0;
    p_change_prev = 0;
    for i = 2:numel(iterations) % start computing for iteration 2, since we alway want to compute 1 3D iteration
        curr_mask = m(:,:,i);
        prev_mask = m(:,:,i-1);
        
        total = sum(prev_mask,'all');
        change = sum(curr_mask - prev_mask,'all');

        p_change = abs(change/total);

        fprintf('Change from iteration %d to %d: %.5f \n',iterations(i-1),iterations(i),p_change);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Implement our stopping criteria
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % (1) If we change too much or too little, we want to throw away the current iteration and use previous
        % (2) If we're not changing enough from iteration to iteration, we've probably "converged"
        %if (p_change<.002) || (p_change>.009) || (p_change - p_change_prev < .001)
        if (p_change<.002) || (p_change>.005) || (p_change - p_change_prev < .001)            
            final_iteration = i-1;            
            %fprintf('We would stop here: %d!\n',final_iteration);            
            filepath = fullfile(study_dir,sprintf('iteration_%d',final_iteration),tinted_images);
            fprintf('Keeping iteration %d (%s)\n',final_iteration,filepath);
            tinted_image = imread(filepath);
            break;
        end

        p_change_prev = p_change;
    end

end

