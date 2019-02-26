function edge_count = detect_if_mask_hits_edges(m)
    initerosionkernelsize = 11;

    % For VolCap. Images are rotatated right (camup is [0 1])
    m = logical(m); % Just in case
    edge_count = logical([0 0 0 0]);
    threshold = 10; % require this many consective pixels to be along the border
    edge_buffer = ceil(initerosionkernelsize/2);

    % Top row of image matrix (left side of the scene)
    for i = 1:initerosionkernelsize
        pixels = m(i,:);
        pixels = reshape(pixels,1,numel(pixels));
        if (strfind(pixels,ones(1,threshold)))
            edge_count(1) = true;
            break;
        end
    end

    % Bottom row of image matrix (right side of the scene)
    for i = 1:initerosionkernelsize
        pixels = m(end-(i-1),:);
        pixels = reshape(pixels,1,numel(pixels));
        if (strfind(pixels,ones(1,threshold)))
            edge_count(2) = true;
            break;
        end
    end

    % Left side of image matrix (bottom/floor of the scene) NOTE WE MAY NOT WANT TO USE THIS ONE
    for i = 1:initerosionkernelsize
        pixels = m(:,i);
        pixels = reshape(pixels,1,numel(pixels));
        if (strfind(pixels,ones(1,threshold)))
            edge_count(3) = true;
            break;
        end
    end
    % Left side of image matrix (bottom/floor of the scene) NOTE WE MAY NOT WANT TO USE THIS ONE
    for i = 1:initerosionkernelsize
        pixels = m(:,end-(i-1));
        pixels = reshape(pixels,1,numel(pixels));
        if (strfind(pixels,ones(1,threshold)))
            edge_count(4) = true;
            break;
        end
    end
    
end