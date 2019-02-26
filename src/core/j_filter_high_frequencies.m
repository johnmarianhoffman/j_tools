function array = j_filter_high_frequencies(array,percent_to_filter)
dims = size(array);

filter_size = ceil(dims * percent_to_filter);

fprintf('Generating filter...\n');
m = rectangle(array,filter_size);

fprintf('Forward FFT of array...\n');
f_array = fftn(array);

fprintf('Applying filter...\n');
f_array(m) = 0;

fprintf('Inverse FFT of array...\n');
array = real(ifftn(f_array));

fprintf('Cleaning up filtered array...\n');
array(array<.01) = 0;

end

function mask = rectangle(array,filter_sizes)
    dims = size(array);
    center = dims/2+0.5;
    
    for i =1:numel(size(array))
        mesh_vects{i} = 1:dims(i);
    end 

    if numel(dims)==2
        % to do later
    elseif numel(dims ==3)
        [X,Y,Z] = meshgrid(mesh_vects{2},mesh_vects{1},mesh_vects{3});
        mask = (X >= (center(2) - filter_sizes(2)/2))&(X <= (center(2) + filter_sizes(2)/2))& ...
               (Y >= (center(1) - filter_sizes(1)/2))&(Y <= (center(1) + filter_sizes(1)/2))& ...
               (Z >= (center(3) - filter_sizes(3)/2))&(Z <= (center(3) + filter_sizes(3)/2));
    end


    
end