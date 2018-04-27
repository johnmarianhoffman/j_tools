function img_pseudo_iso=j_pseudo_iso(img,spacing)
%spacing is defined relative to the dimensions of img 

if numel(spacing)==2
    % Determine scaling factor
    base=min(spacing(:));
    scale_factors=round(spacing/base);

    img_pseudo_iso=zeros(scale_factors(1)*size(img,1),...
                         scale_factors(2)*size(img,2));

    for i=1:size(img_pseudo_iso,1)
        for j=1:size(img_pseudo_iso,2)
            try
                img_pseudo_iso(i,j)=img(floor(i/scale_factors(1))+1,...
                                        floor(j/scale_factors(2))+1);
            catch
            end
        end
    end
end

if numel(spacing)==3
    % Determine scaling factor
    base=min(spacing(:));
    scale_factors=round(spacing/base);

    img_pseudo_iso=zeros(scale_factors(1)*size(img,1),...
                         scale_factors(2)*size(img,2),...
                         scale_factors(3)*size(img,3));

    for i=1:size(img_pseudo_iso,1)
        for j=1:size(img_pseudo_iso,2)
            for k=1:size(img_pseudo_iso,3)
                img_pseudo_iso(i,j,k)=img(floor(i/scale_factors(1))+1,...
                                          floor(j/scale_factors(2))+1,...
                                          floor(k/scale_factors(3))+1);
            end
        end
    end
end

end