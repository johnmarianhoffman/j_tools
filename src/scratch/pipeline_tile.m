recon_root='/PechinTest2/trial_run_result_022216_clinical/case_1/';

doses={'3.33' '10' '30' '50' '100'};
kernels={'1' '2' '3'};
slice_thicknesses={'1' '2'};

% Load stacks of images
if ~exist('stack','var')
    for i=1:numel(doses)
        for j=1:numel(kernels)
            for k=1:numel(slice_thicknesses)
                try
                    filepath=fullfile(recon_root,doses{i},[kernels{j} '_' slice_thicknesses{k}],sprintf('simulate_k%s_st%s.img',kernels{j},slice_thicknesses{k}));
                    stack{j,k,i}=read_disp_recon_512(filepath);                
                catch
                    filepath=fullfile(recon_root,doses{i},[kernels{j} '_' slice_thicknesses{k}],sprintf('case_1_k%s_st%s.img',kernels{j},slice_thicknesses{k}));
                    disp(filepath);                
                    stack{j,k,i}=read_disp_recon_512(filepath);                
                end


                stack{j,k,i}=read_disp_recon_512(filepath);
            end
        end
    end
end
% Create a tiling

tiling=zeros(512*numel(slice_thicknesses),512*numel(kernels),numel(doses));

slice_number=174;


for i=1:numel(doses)
    for j=1:numel(kernels)
        for k=1:numel(slice_thicknesses)
            if isequal(slice_thicknesses{k},'1')
                tiling((k-1)*512+1:k*512,(j-1)*512+1:j*512,i)=stack{j,k,i}(:,:,slice_number);
            else
                tiling((k-1)*512+1:k*512,(j-1)*512+1:j*512,i)=stack{j,k,i}(:,:,round(slice_number/2));
            end
        end
    end
end

sv(hu(tiling));
