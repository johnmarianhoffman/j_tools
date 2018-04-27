function [tiling,inset_image_stack,sample_stack]=j_pipeline_tile(library_dirpath,config_filepath,pipeline_id,varargin)
c=yaml.ReadYaml(config_filepath);

disp(c)
%c.doses=c.doses(end:-1:1);

%% Set up our ROI
% User can adjust these
if ~isempty(varargin)
    slice_index_on_thinnest_slice=varargin{1};
else
    slice_index_on_thinnest_slice=60;
end
roi_dim=64;
roi_center_row=371;
roi_center_col=381;

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

tiling=[];
inset_image_stack=[];

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

            % Handle hr2 libraries
            if ~exist(img_path,'file')
                [p,f,~]=fileparts(img_path);
                hr2_path=fullfile(p,[f '.hr2']);
                t=tempname;
                tmp_img=[t '.img'];
                tmp_hr2=[t '.hr2'];
                system(sprintf('python3 /home/john/Code/CTBB_Pipeline_Package/CTBB_Pipeline/src/read_hr2.py %s %s',hr2_path,tmp_img));
                img_path=tmp_img;
            end 
            fprintf(1,'%s: %d\n',img_file,exist(img_path,'file'));

            tmp_stack=read_disp_recon_512(img_path);

            if exist('tmp_img','var')
                tmp_stack=permute(tmp_stack,[2 1 3]);
                delete(tmp_img);
            end
                        
            if c.doses{i}==100&&c.slice_thicknesses{j}==0.6&&c.kernels{k}==1
                sample_stack=tmp_stack;
            end
            
            tmp_slice=tmp_stack(:,:,slice_indices(j));
            roi=reshape(tmp_slice(mask),[roi_dim roi_dim]);

            output_slice_idx=k+(j-1)*numel(c.kernels)+(i-1)*numel(c.slice_thicknesses)*numel(c.kernels);
            output_slice_idx=i+(k-1)*numel(c.doses)+(j-1)*numel(c.doses)*numel(c.kernels);
            
            inset_image_stack(:,:,output_slice_idx)=tmp_slice+250*mask;
            roi_stacks(:,:,output_slice_idx)=roi;
            
        end 
    end 
end

% Create the tiling that will be returned to the user
tiling=j_tile(roi_stacks,[3,12],1,true);
%tiling=j_tile(hu(roi_stacks),[4,12],1,true);

end

function load_config(p)

end