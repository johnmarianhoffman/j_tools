function  varargout = j_depth_confidence_viewer(d,c)

    img_stack = zeros([size(d,1) size(d,2) 3 size(d,3)]);

    n_maps = size(d,3);

    for i=1:n_maps
        fprintf('Fusing map %d of %d\n',i,n_maps);
        img_stack(:,:,:,i) = j_fuse_depth_confidence(d(:,:,i),c(:,:,i));
    end

    if nargout>0
        varargout{1} = img_stack;
    end

    viewer_color(img_stack);

end
