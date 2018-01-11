function img=j_overlay(img,mask,overlay_color,overlay_alpha,window,spacing)
% stack is a grayscale image (most likely dicom)
% mask is a logical mask of the ROI to be show
% overlay_color is RGB ([R G B]) in uint8 to be shown
% overlay_alpha is alpha parameter for the overlay (transparency)
% window is the viewing window for the grayscale image (e.g. lung window for dicom is [-1400,200])

% Spacing is *not* required, but will adjust the image to simulate isotropic voxel sizes

if nargin==6
    img=j_pseudo_iso(img,spacing);
    mask=j_pseudo_iso(mask,spacing);
end

% Rescale image, using window and level, between 0 and 1
img=apply_window(img,window);
img=repmat(img,1,1,3);

disp('')
for i=1:3
    img(:,:,i)=overlay_color(i)*mask*overlay_alpha + mask.*img(:,:,i)*(1.0-overlay_alpha)+(~mask).*img(:,:,i);
end

end

function J=apply_window(I,w)
range_mask=(I>=w(1))&(I<=w(2));
I(range_mask)=(1/(w(2)-w(1)))*(I(range_mask)-w(1));
I(I<w(1))=0;
I(I>w(2))=1;
J=I;
end