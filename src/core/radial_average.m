function [radial_profile,x_axis]=radial_average(image,varargin)

    if ~isempty(varargin)
        bin_size=varargin{1};
    else
        bin_size=1;
    end
    
    
    dims=size(image);
    lim=min(dims(:));

    x_axis=bin_size:bin_size:lim/2;
    radial_profile=zeros(numel(x_axis),1);

    % Set up variables for while loop
    band_mask=1;

    radius_inner=0;
    radius_outer=bin_size;

    counter=1;
    
    while radius_outer<=lim/2
    %while sum(band_mask(:)>0)
        % Generate a "band" mask
        mask_out=draw_circle(dims(1)/2,dims(2)/2,radius_outer, ...
                             dims);
        mask_in =draw_circle(dims(1)/2,dims(2)/2,radius_inner, ...
                             dims);

        band_mask=mask_out-mask_in;

        % Extract the points in the image and average them
        radial_profile(counter)=mean(image(logical(band_mask)));

        % increment all the things
        counter=counter+1;
        radius_inner=radius_inner+bin_size;
        radius_outer=radius_outer+bin_size;

    end        
end
