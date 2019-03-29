function fused_image = j_fuse_depth_confidence(depth,confidence)
    tmp = depth(depth~=0);
    mini = min(tmp(:));
    maxi = max(tmp(:));

    img_1 = repmat(j_imrescale(depth,[mini-1,maxi+1]),[1 1 3]);
    img_2 = confidence_to_rgb(confidence);
    img_1_alpha = repmat(confidence,[1 1 3]);
    img_2_alpha = (1-img_1_alpha);

    fused_image = img_1_alpha.*img_1 + img_2_alpha.*img_2;
end

function rgb = confidence_to_rgb(confidence_map)
    map = stoplight(1024);
    rgb = zeros([size(confidence_map) 3]);

    colorID = min(max(1,ceil(confidence_map*1024)),1024);
    rgb = ind2rgb(colorID,map).*(confidence_map~=0);
end

function map = stoplight(length)
    if nargin < 1
        length = size(get(gcf,'colormap'),1);
    end

    h = (0:length-1)' / (length-1) / 3;

    if isempty(h)
	map = [];
    else
	map = hsv2rgb([h ones(length, 1) repmat(.9, length, 1)]);
    end
end