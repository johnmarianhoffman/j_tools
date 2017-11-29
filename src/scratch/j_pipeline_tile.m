function [tiling,inset_image_stack]=j_pipeline_tile(library_dirpath,config_filepath,pipeline_id)
c=yaml.ReadYaml(config_filepath);

disp(c)
c.doses=c.doses(end:-1:1);

%% Set up our ROI
% User can adjust these
slice_index_on_thinnest_slice=60;
roi_dim=64;
roi_center_row=301;
roi_center_col=360;

% DON'T touch this code
slice_indices = zeros(1,numel(c.slice_thicknesses));
slice_indices(1)=slice_index_on_thinnest_slice;
for i=1:numel(slice_indices)
    slice_location=slice_indices(1)*c.slice_thicknesses{1};
    slice_indices(i)=round(slice_location/c.slice_thicknesses{i});
end
pos=j_PositionVectorConvert([roi_center_col roi_center_row roi_dim roi_dim],'c->m');

f=figure('visible','off');
a=axes;
imshow(zeros(512),[])
r=imrect(a,pos);
mask=createMask(r);
delete(f);

%% Build our stacks
roi_stacks=zeros(roi_dim,roi_dim,numel(c.doses)*numel(c.slice_thicknesses)*numel(c.kernels));
inset_image_stack=zeros(512,512,numel(c.doses)*numel(c.slice_thicknesses)*numel(c.kernels));
for i=1:numel(c.doses)
    for j=1:numel(c.slice_thicknesses)
        for k=1:numel(c.kernels)

            %fe69c7541099f0d26d7cd08fa70d2d2b_k3_st0.6/
            %fe69c7541099f0d26d7cd08fa70d2d2b_d100_k3_st0.6.hr2            
            study_dir=sprintf('%s_k%d_st%.1f',pipeline_id,c.kernels{k},c.slice_thicknesses{j});
            img_file =sprintf('%s_d%d_k%d_st%.1f.img',pipeline_id,c.doses{i},c.kernels{k},c.slice_thicknesses{j});
            
            img_path=fullfile( library_dirpath,'recon',num2str(c.doses{i}),study_dir,'img',img_file);

            fprintf(1,'%s: %d\n',img_path,exist(img_path,'file'));

            tmp_stack=read_disp_recon_512(img_path);
            tmp_slice=tmp_stack(:,:,slice_indices(j));
            roi=reshape(tmp_slice(mask),[roi_dim roi_dim]);

            output_slice_idx=k+(j-1)*numel(c.kernels)+(i-1)*numel(c.slice_thicknesses)*numel(c.kernels);
            output_slice_idx=i+(k-1)*numel(c.doses)+(j-1)*numel(c.doses)*numel(c.kernels);

            
            inset_image_stack(:,:,output_slice_idx)=hu(tmp_slice)+250*mask;
            roi_stacks(:,:,output_slice_idx)=roi;
            
        end 
    end 
end

% Create the tiling that will be returned to the user
%tiling=j_tile(hu(roi_stacks),[3,12],1,true);
tiling=j_tile(hu(roi_stacks),[4,12],1,true);

end

function load_config(p)


end