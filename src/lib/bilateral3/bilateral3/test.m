dicom_dir='~/Study_Data/prm_tests/insp'
test_stack=j_get_dicom(dicom_dir);
org_stack=test_stack;

save_mat_img(test_stack(:,:,128),[-1400,200],sprintf('test_reference.png'))

for i=5:5
    
    % rescale test stack to 0-255
    img_min=min(test_stack(:));
    img_max=max(test_stack(:));
    test_stack=255*mat2gray(test_stack);

    % Set filter parameters
    sigmaS=3; % 3
    sigmaR=3; % 3
    samS=5;
    samR=5;

    % run bilateral filtering
    tic
    test_stack=bilateral3(test_stack, sigmaS,sigmaS,sigmaR,samS,samR);
    toc

    % Scale back to HU values
    test_stack=mat2gray(test_stack);
    test_stack=(img_max-img_min)*test_stack+img_min;
    save_mat_img(test_stack(:,:,128),[-1400,200],sprintf('test_all%d.png',samR))
    %test_stack=org_stack;
    
end

save_mat_img(org_stack(:,:,128)-test_stack(:,:,128),[-10,10],sprintf('test_difference.png'))