function filtered_projection_data = wfbp_filter(rebinned_projection_data,ct_geom)

filtered_projection_data = zeros(size(rebinned_projection_data),'single');

% Generate the filter 
    k = [-ct_geom.n_detector_channels/2:ct_geom.n_detector_channels/2-1];
    filt = generate_ramp(k,ct_geom.detPixSizeCol,1,1);
    
    filt = ifft(fftshift(filt));
    filt = repmat(filt,[ct_geom.n_detector_rows,1]);
    
    num_projections = size(rebinned_projection_data,3);
    
    for i=1:num_projections
        fprintf("Filtering projection %d\n",i);
        curr_proj = rebinned_projection_data(:,:,i);
        f_proj = fft(curr_proj,[],2);
        f_proj = f_proj.*filt;
        filtered_projection_data(:,:,i) = real(ifft(f_proj,[],2));
    end
    
end

function f=generate_ramp(k,ds,c,a)
% Simple function for creating filters
%
% Inputs:
%    k - list of indices (like [-200 -199 -198 ... 198 199])
%    ds - detector spacing (r_f*sin(fan_angle_increment/2))
%    c - [0,1]
%    a - [1, 0.5 0.54]
    
    f=(c^2/(2*ds))*(a*r(c*pi*k)+((1-a)/2)*r(pi*c*k+pi)+((1-a)/2)*r(pi*c*k-pi));
end

function vec=r(t)
vec=(sin(t)./t)+(cos(t)-1)./(t.^2);
vec(t==0)=0.5;
end