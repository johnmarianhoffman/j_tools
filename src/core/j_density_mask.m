function mask=j_density_mask(stack,threshold,segmentation)

if nargin<3
    segmentation=true(size(stack));
end

mask=(stack<threshold)&segmentation;

end