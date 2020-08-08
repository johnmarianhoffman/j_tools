function rebinned_projection_data = wfbp_rebin(projection_data,ct_geom)
% Row-wise rebin
% Note, we ignore the "true" tube angle since the offsets will just cancel out
    
    num_projections = size(projection_data,3);
    delta_theta = 2*pi/ct_geom.projections_per_rotation;
    
    rebinned_projection_data = zeros(size(projection_data),'single');

    for i=1:size(projection_data,3) % Projections
        fprintf("Rebinning projection %d/%d\n",i,num_projections);
        for j=1:size(projection_data,2) % Channels    
            
            curr_channel_idx    = j - 1;
            curr_projection_idx = i - 1;
            
            p = (curr_channel_idx - ct_geom.detCentralCol)*ct_geom.detPixSizeCol;
            beta = asin(p/ct_geom.distance_source_to_detector);
            %beta = asin(p/ct_geom.distance_source_to_isocenter);
            
            theta = curr_projection_idx * delta_theta;
            
            %alpha = theta + beta;% GE Maybe
            alpha = theta - beta;
                       
            beta_idx = (beta*ct_geom.distance_source_to_detector/ct_geom.detPixSizeCol)+ct_geom.detCentralCol;
            %beta_idx = (beta*ct_geom.distance_source_to_isocenter/ct_geom.detPixSizeCol)+ct_geom.detCentralCol;
            alpha_idx = (alpha)/delta_theta;
            
            for k = 1:size(projection_data,1)
                
                beta_floor = floor(beta_idx) + 1;
                beta_ceil = ceil(beta_idx) + 1;
                
                alpha_floor = floor(alpha_idx) + 1;
                alpha_ceil = ceil(alpha_idx) + 1;
                
                if (alpha_floor < 1 || beta_floor < 1)
                    continue;
                end
                
                if (beta_ceil > ct_geom.n_detector_channels || alpha_ceil > num_projections)
                    continue;
                end
                
                %disp(alpha_floor);
                %disp(alpha_ceil);
                %disp(beta_floor);
                %disp(beta_ceil);
                
                w_b = beta_idx+1 - beta_floor;
                w_a = alpha_idx+1 - alpha_floor;
                
                rebinned_projection_data(k,j,i) = ...
                    (1-w_b) * (1-w_a) * projection_data(k,beta_floor,alpha_floor) +  (w_b) * (1-w_a) * projection_data(k,beta_ceil,alpha_floor) + ...
                    (1-w_b) * (w_a)   * projection_data(k,beta_floor,alpha_ceil)  +  (w_b) *  (w_a)  * projection_data(k,beta_ceil,alpha_ceil);
                
            end
        end    
    end
end

