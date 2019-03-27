function  j_depth_confidence_viewer(d,c)

    if nargin==1
        cam_id = d;

        root = '~/Desktop/';

        cams=[10,11,18,19,26,27,2,34,35,3,42,43,50,51,58,59];
        cams = sort(cams);
        
        depth = j_bin_float(fullfile(root,sprintf('depth_map_%d.bin',cam_id)));
        confidence = j_bin_float(fullfile(root,sprintf('confidence_map_%d.bin',cam_id)));
        depth = reshape(depth,[4096 3000]);
        confidence = reshape(confidence,[4096 3000]);
        
    elseif nargin==2
        depth = d;
        confidence = c;
    end

    tmp = depth(depth~=0);
    mini = min(tmp(:));
    maxi = max(tmp(:));

    img_1 = repmat(j_imrescale(depth,[mini-200,maxi+200]),[1 1 3]);
    img_2 = confidence_to_rgb(confidence);
    img_1_alpha = repmat(confidence,[1 1 3]);
    img_2_alpha = (1-img_1_alpha);

    fused_image = img_1_alpha.*img_1 + img_2_alpha.*img_2;
    
    f = figure;
    ax = axes;
    set(ax,'position',[0 0 1 1]);
    %img_depth = imshow(,'parent',ax);
    %hold(ax,'on');
    %img_conf = imshow(,'parent',ax);
    %hold(ax,'off');
    %
    %alpha = (1-confidence); % Good guess are invisible, bad guesses are visible
    %set(img_conf,'AlphaData',alpha.*(confidence>0));
    
    img_obj = imshow(fused_image);
    
end

function rgb = confidence_to_rgb(confidence_map)
    map = stoplight(1024);
    rgb = zeros([size(confidence_map) 3]);

    colorID = max(1,ceil(confidence_map*1024));
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