dicom_dir='~/Study_Data/prm_tests/insp'
%test_stack=j_get_dicom(dicom_dir);
org_stack=test_stack;

img_org=org_stack(:,:,150);

% rescale test stack to 0-1
img_min=min(img_org(:));
img_max=max(img_org(:));
img_rescale=mat2gray(img_org);

tic
img_denoised=bfilter2(img_rescale,5,[1 .05]);
toc

% Rescale back to HU values
img_denoised=(img_max-img_min)*img_denoised+img_min;
save_mat_img(img_denoised,[-1400,200],'2d_CT_tests.png')

viewer([img_org img_denoised img_org-img_denoised])
