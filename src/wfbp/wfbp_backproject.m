function reconstructed_slice = wfbp_backproject(filtered_projection_data,ct_geom,tube_angles,table_positions)
    
%  Goal of backprojection is to determine p_hat and q_hat for each voxel/projection combination
    
% In this dummy example, we simply pick the middle slice of the scan
% and reconstruct it at native detector resolution
    
    recon_fov = 250;
    img_dim   = 512;
    
    dx = recon_fov/img_dim;
    dy = recon_fov/img_dim;
    
    slice_location = (table_positions(1) + table_positions(end))/2;
    z = slice_location;
    z = -153.25;
    fprintf("Reconstructing slice at %0.2f (%.2f -> %.2f)\n",z,table_positions(1),table_positions(end));
    
    reconstructed_slice = zeros(img_dim,img_dim,1,'single');
    
    num_projections = size(filtered_projection_data,3);
    theta_range = 1:num_projections; %indices of the projections we actually need to backprojection for this slice (todo)
    %for (i=1:num_projections)
    %    abs(table_positions(i) - slice_location) < ct_geom.z_rot;
    %    theta_range(end+1) = i;
    %end
    
    n_half_turns = floor(num_projections/(ct_geom.projections_per_rotation/2));
    
    for i=1:img_dim
        fprintf("Backprojecting row %d/%d\n",i,img_dim);
        curr_x = ((i-1)-(img_dim-1)/2)*dx;
        for j=1:img_dim
            curr_y = ((j-1)-(img_dim-1)/2)*dy;
            
            %fprintf("%.2f,%.2f\n",curr_x,curr_y);
            
            if (curr_x^2 + curr_y^2 > (recon_fov/2)^2)
                continue
            end
            
            for theta_tilde_idx=1:(ct_geom.projections_per_rotation/2)
                backprojected_value  = 0.0;
                normalization_factor = 0.0;
                
                %fprintf("Next angle\n");
                
                for k = 0:(n_half_turns-1)
                
                    curr_theta_idx = theta_tilde_idx + k*(ct_geom.projections_per_rotation/2);
                    curr_theta = tube_angles(curr_theta_idx);
                    curr_table_position = table_positions(curr_theta_idx);
                    
                    p_hat = curr_x*sin(curr_theta) - curr_y*cos(curr_theta);
                    
                    l_hat = sqrt(ct_geom.distance_source_to_isocenter^2 - p_hat^2) - (curr_x*cos(curr_theta) - curr_y*sin(curr_theta));
                    q_hat = (z - curr_table_position + (ct_geom.z_rot/(2*pi))*asin(p_hat/ct_geom.distance_source_to_isocenter))/(l_hat*tan(ct_geom.theta_cone/2));
                    
                    %fprintf("%.2f    %.5f  %.5f\n",1/WEIGHT);
                    
                    if (q_hat > 1 || q_hat < -1)
                        continue;
                    end
                    
                    %fprintf("collides\n");
                    
                    %fprintf("Project %d intersects reconstruction slice\n",i);
                    
                    % Compute interpolation coordinates (zero indexed)
                    tmp = ct_geom.distance_source_to_isocenter*ct_geom.detPixSizeCol/ct_geom.distance_source_to_detector;
                    
                    %p_idx = p_hat/ct_geom.detPixSizeCol + ct_geom.detCentralCol;
                    p_idx = p_hat/tmp + ct_geom.detCentralCol;
                    %fprintf('%.5f -> %.5f\n',p_hat,p_idx);
                    q_idx = ((q_hat+1)/2)*(ct_geom.n_detector_rows-1);
                    
                    q_floor = floor(q_idx);
                    q_ceil  = ceil(q_idx);
                    
                    p_floor = floor(p_idx);
                    p_ceil  = ceil( p_idx);
                    
                    if (p_floor < 0 || q_floor < 0)
                        continue;
                    end
                    
                    if (p_ceil >= ct_geom.n_detector_channels || q_ceil >= ct_geom.n_detector_rows)
                        continue;
                    end
                    
                    w_q = q_idx - q_floor;
                    w_p = p_idx - p_floor;
                    
                    % Do the interpolation
                    interpolated_value = (1-w_q)*(1-w_p)*filtered_projection_data(q_floor+1 , p_floor+1 , curr_theta_idx) + (1-w_q)*(w_p)*filtered_projection_data(q_floor+1 , p_ceil+1 , curr_theta_idx) + ...
                        (w_q)*(1-w_p)*filtered_projection_data(q_ceil +1 , p_floor+1 , curr_theta_idx)  +   (w_q)*(w_p)*filtered_projection_data(q_ceil+1 , p_ceil+1 , curr_theta_idx);
                    
                    WEIGHT = W(q_hat,0.6);
                    backprojected_value  = backprojected_value + WEIGHT*interpolated_value;
                    normalization_factor = normalization_factor + WEIGHT;
                    
                end
                
                reconstructed_slice(i,j,1) = reconstructed_slice(i,j,1) + (2*pi/ct_geom.projections_per_rotation) * (1/normalization_factor) * backprojected_value;
            end
        end
    end
end

function wq = W(q,Q)

    q = abs(q);
   
    if (q<Q)
        wq = 1;
    elseif (Q<=q && q < 1)    
        wq = cos((pi/2)*(q - Q)/(1-Q));
        wq = wq*wq;
    else
        wq = 0;
    end
    
end
