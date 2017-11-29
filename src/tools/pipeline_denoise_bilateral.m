function pipeline_denoise_bilateral(hr2_filepath,w,sigma_d,sigma_r)

    read_hr2_script_filepath  = '/home/john/Code/CTBB_Pipeline_Package/CTBB_Pipeline/src/read_hr2.py';
    write_hr2_script_filepath = '/home/john/Code/CTBB_Pipeline_Package/CTBB_Pipeline/src/write_hr2.py';
    tmp_img_filepath='/tmp/denoise_tmp_img.img';

    % Convert the HR2 file into IMG file
    %disp('Converting HR2 data to readable IMG');
    system(sprintf('python3 %s %s %s',read_hr2_script_filepath,hr2_filepath,tmp_img_filepath));

    % Read img file into matlab (Note: these are already in HU)
    %disp('Loading IMG into MATLAB');
    image_stack=read_disp_recon_512(tmp_img_filepath);

    % Rescale images to between 0 and 1
    img_min=min(image_stack(:));
    img_max=max(image_stack(:));
    stack_rescale=mat2gray(image_stack);
    stack_denoise=zeros(size(stack_rescale));

    % Run denoising
    % Note: GTX780 GPU only has enough memory to denoise ~125 slices at a time.
    %       For most stacks we'll have to denoise in multiple calls, and
    %       then stitch the denoised stacks together.  We pad with extra slices
    %       to make this ok.
    %disp('Denoising data')
    n_slices=size(stack_rescale,3);
    %fprintf('Number of slices: %d\n',n_slices)
    n_calls=ceil(n_slices/125);

    for i=1:n_calls
        %fprintf('Call %d/%d\n',i,n_calls);
        
        % Start/end without extra slice padding
        slice_range_start_actual = (i-1)*125+1;
        slice_range_end_actual   = min(i*125,n_slices);

        %fprintf('Desired sliced: %d through %d\n',slice_range_start_actual,slice_range_end_actual);
        
        % Pad out our extra slices
        slice_range_start=max(slice_range_start_actual-5,1);
        slice_range_end=min(slice_range_end_actual+5,n_slices);

        %fprintf('Padded Slices: %d through %d\n',slice_range_start,slice_range_end);

        % Run denoising
        tmp_stack=stack_rescale(:,:,slice_range_start:slice_range_end);
        res=j_bilateral3_gpu(tmp_stack,w,sigma_d,sigma_r);

        % Store back to denoised array
        if slice_range_start_actual==1
            stack_denoise(:,:,slice_range_start_actual:slice_range_end_actual)=res(:,:,1:125);
        elseif slice_range_end_actual==n_slices
            stack_denoise(:,:,slice_range_start_actual:slice_range_end_actual)=res(:,:,6:end);
        else
            stack_denoise(:,:,slice_range_start_actual:slice_range_end_actual)=res(:,:,6:130);
        end
    end

    % Scale denoised data back to HU
    stack_rescale=stack_denoise*(img_max-img_min)+img_min;

    % Save denoised data to tmp img file and convert back to hr2
    %disp('Saving data back to temporary img file')
    j_bin_float(tmp_img_filepath,'w',stack_rescale);

    %disp('Converting back to HR2...')
    system(sprintf('python3 %s %s %s',write_hr2_script_filepath,tmp_img_filepath,hr2_filepath));

    %fprintf('Denoised HR2 file: %s\n',hr2_filepath);
    %disp('Done')    
end