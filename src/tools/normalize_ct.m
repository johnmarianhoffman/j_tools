function norm_stack = normalize_ct(stack)
% Kernel-based normalization from Gallardo-Estrella 2016

% Generate the gaussian filters
    window = 32;
    sigma   = [0,1,2,4,8,16];
    filters = zeros(window+1,window+1,numel(sigma));
    for i =2:numel(sigma)
        curr_filt=gauss(sigma(i),window);
        filters(:,:,i) = curr_filt/sum(curr_filt(:));
        tmp = curr_filt/sum(curr_filt(:));
        disp(sum(tmp(:)));        
    end
    
    weights = [70.34,67.54,60.9,51.45,36.14];
    
    % Process images
    norm_stack = zeros(size(stack));
    filtered_slice = zeros(size(stack,1),size(stack,2),numel(sigma));
    lambdas = zeros(1,numel(sigma));
    for i=1:size(stack,3)
        curr_slice = stack(:,:,i);
        
        % Generate the filtered slices
        for j =1:numel(sigma)
            if j==1
                filtered_slice(:,:,j) = curr_slice;
            else
                filtered_slice(:,:,j) = conv2(curr_slice,filters(:,:,j),'same');
            end            
        end

        difference_images = diff(filtered_slice,1,3);        

        % Compute the weights (lambda)
        for j = 1:numel(sigma)-1
            r_i = weights(j);
            e_i = get_energy(filtered_slice(:,:,j));
            lambdas(j) = 1.0;r_i/e_i;
        end
        disp(lambdas)

        % Assemble the normalized images
        I_final = filtered_slice(:,:,end);
        for j = 1:numel(sigma)-1            
            I_final = I_final + lambdas(j)*(filtered_slice(:,:,j)-filtered_slice(:,:,j+1));
        end
        norm_stack(:,:,i) = I_final;

        fprintf('%d/%d\n',i,size(stack,3));
    end
end

function val=gauss(sigma,window)
    x = -window/2:window/2;
    y = -window/2:window/2;
    [x,y]=meshgrid(x,y);

    exponent = ((x).^2 + (y).^2)./(2*sigma^2);
    amplitude = 1 / ( 2*pi*sigma^2);  
    % The above is very much different than Alan's "1./2*pi*sigma^2"
    % which is the same as pi*Sigma^2 / 2.
    val = amplitude  * exp(-exponent);
end

function e_i = get_energy(filtered_slice)
    lung_vox = filtered_slice(filtered_slice<-750);    
    e_i = std(lung_vox);
end