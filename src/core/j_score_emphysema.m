function j_score_emphysema(hr2_filepath,left_lung_filepath,right_lung_filepath,results_dirpath,qa_dirpath)

verbose=false;

% Configure paths ======================================================================
read_hr2_script_filepath  = '/home/john/Code/CTBB_Pipeline_Package/CTBB_Pipeline/src/read_hr2.py';
tmp=tempname;
tmp_img_filepath=[tmp '.img'];%'/tmp/denoise_tmp_img.img';
tmp_hr2_filepath=[tmp '.hr2'];

% Get all of our files loaded into MATLAB  =============================================
log(verbose,'Parsing hr2 file...\n');
ret_code=system(sprintf('python3 %s %s %s',read_hr2_script_filepath,hr2_filepath,tmp_img_filepath));

img=read_disp_recon_512(tmp_img_filepath);
log(verbose,'Loading left lung ROI...\n');
left=load_qia_roi(left_lung_filepath);

log(verbose,'Loading right lung ROI...\n');
right=load_qia_roi(right_lung_filepath);

% Read HR2 metadata
fid=fopen(tmp_hr2_filepath,'r');
s=fread(fid)';
fclose(fid);
s=char(s);

space_loc=strfind(s,'Spacing');
size_loc=space_loc+7;
spacing_bytes=double(s(size_loc));
null_byte=size_loc+1;
spacing_start=null_byte+1;

spacing=str2num(s(spacing_start:spacing_start+spacing_bytes-1));

% Pad our masks to be same dimensions as img
n_slices_img    = size(img,3);
n_slices_left   = size(left,3);
n_slices_right  = size(right,3);
                  
n_missing_left  = n_slices_img-n_slices_left;
n_missing_right = n_slices_img-n_slices_right;

left  = cat(3,left,zeros(size(img,1),size(img,2),n_missing_left));
right = cat(3,right,zeros(size(img,1),size(img,2),n_missing_right));

lungs=logical(left+right);

log(verbose,'Calculating lung volume...\n');
volume=sum(lungs(:));

% Run our Emphysema Calculations ======================================================
log(verbose,'Scoring RA values...\n');
% Run RA-*** scoring
ra_856  = get_ra(img,lungs,-856 )/volume;
ra_900  = get_ra(img,lungs,-900 )/volume;
ra_910  = get_ra(img,lungs,-910 )/volume;
ra_920  = get_ra(img,lungs,-920 )/volume;
ra_930  = get_ra(img,lungs,-930 )/volume;
ra_940  = get_ra(img,lungs,-940 )/volume;
ra_950  = get_ra(img,lungs,-950 )/volume;
ra_960  = get_ra(img,lungs,-960 )/volume;
ra_970  = get_ra(img,lungs,-970 )/volume;
ra_980  = get_ra(img,lungs,-980 )/volume;
ra_990  = get_ra(img,lungs,-990 )/volume;
ra_1000 = get_ra(img,lungs,-1000)/volume;
range_950_856 = ra_856-ra_950;

% Generate lung histogram
log(verbose,'Calculating percentile metrics...\n');
lung_vals     = img(lungs);
lung_vals     = lung_vals(lung_vals<=-200);
lung_min      = min(lung_vals(:));
lung_max      = -200;%max(lung_vals(:)); % We set to -200 HU to be in accordance with Pechin's implementation of histogramcalculation
[lung_hist,X] = hist(lung_vals,[lung_min:1:lung_max]);

% Calculate Percentile Locations
perc_10 = get_perc(lung_hist,X,0.10);
perc_15 = get_perc(lung_hist,X,0.15);
perc_20 = get_perc(lung_hist,X,0.20);

% Calculate Mean and Median
mean_lung=mean(lung_vals(:));
median_lung=median(lung_vals(:));

kurtosis = @(x) (sum((x(:)-mean(x(:))).^4)./numel(x))/(var(x(:)).^2)-3;
kurtosis_lung=kurtosis(lung_vals(:));

% Save quantitative results to disk
log(verbose,'Saving quantitative results to disk...\n');

% Save quantitative results
results_filepath=fullfile(results_dirpath,'results_emphysema.yml');
fid=fopen(results_filepath,'w');
fprintf(fid,'PERC10: %.1f\n',perc_10);
fprintf(fid,'PERC15: %.1f\n',perc_15);
fprintf(fid,'PERC20: %.1f\n',perc_20);
fprintf(fid,'RA-856: %.8f\n',ra_856);
fprintf(fid,'RA-900: %.8f\n',ra_900);
fprintf(fid,'RA-910: %.8f\n',ra_910);
fprintf(fid,'RA-920: %.8f\n',ra_920);
fprintf(fid,'RA-930: %.8f\n',ra_930);
fprintf(fid,'RA-940: %.8f\n',ra_940);
fprintf(fid,'RA-950: %.8f\n',ra_950);
fprintf(fid,'RA-960: %.8f\n',ra_960);
fprintf(fid,'RA-970: %.8f\n',ra_970);
fprintf(fid,'RA-980: %.8f\n',ra_980);
fprintf(fid,'Range-950-856: %.8f\n',range_950_856);
fprintf(fid,'kurtosis: %.8f\n',kurtosis_lung);
fprintf(fid,'mean: %.8f\n',mean_lung);
fprintf(fid,'median: %.8f\n',median_lung);
fprintf(fid,'volume: %.8f\n',volume*prod(spacing));
fclose(fid);

% Save lung histogram
histogram_filepath=fullfile(results_dirpath,'histogram_lung.yml');
fid=fopen(histogram_filepath,'w');
for i=1:numel(X)
    fprintf(fid,'%.1f: %d\n',X(i),lung_hist(i));
end
fclose(fid);

% Generate visualizations ============================================================
log(verbose,'Generating visualizations...\n');
% Locate the slice with the largest crossection of lung voxels (used
% for vis)
% NOTE: Permuting our data in place so that we don't abuse
% RAM too much (for concurrent execution)
img    = permute(img,[3 1 2]);
lungs  = permute(lungs,[3 1 2]);

count=0;
idx=0;
for i=1:size(lungs,3)
    curr_slice=lungs(:,:,i);
    curr_count=sum(curr_slice(:));

    if curr_count>count
        count=curr_count;
        idx=i;
    end    
end

slice_img   = squeeze(img(:,:,idx));
slice_lungs = squeeze(lungs(:,:,idx));

slice_img   = j_pseudo_iso(slice_img,[spacing(3) spacing(2)]);
slice_lungs = j_pseudo_iso(slice_lungs,[spacing(3) spacing(2)]);

% Bare image visualization (no overlay)
image_png=j_overlay(slice_img,false(size(slice_lungs)),[0 0 0],0.0,[-1400 200]);
image_png=uint8(255*image_png);

% Lung Segmentation
overlay_png=j_overlay(slice_img,slice_lungs,[0 1 0],0.4,[-1400 200]);
overlay_png=uint8(255*overlay_png);

% RA-950 scoring
ra_950_mask=(logical(slice_lungs)&(slice_img<=-950));
ra_950_png=j_overlay(slice_img,ra_950_mask,[255,0, 0]/255,0.6,[-1400 200]);
% outline boundaries
seg_borders=bwboundaries(slice_lungs);
for k=1:length(seg_borders)
    boundary=seg_borders{k};
    for j=1:size(boundary,1)
        ra_950_png(boundary(j,1),boundary(j,2),:)=[0,1,0];
    end
end
ra_950_png=uint8(255*ra_950_png);

log(verbose,'Saving visualizations to disk...\n');

% Save everything to disk
imwrite(image_png,fullfile(qa_dirpath,'image.png'));
imwrite(overlay_png,fullfile(qa_dirpath,'overlay.png'));
imwrite(ra_950_png,fullfile(qa_dirpath,'RA-950.png'));

% Clean up temporary files ============================================================
log(verbose,'Cleaning up temporary files...\n');
delete(tmp_img_filepath);
delete(tmp_hr2_filepath);

% Dump results to screen if requested =================================================
log(verbose,'====================\n');
log(verbose,'RA results:\n')
log(verbose,'====================\n')
log(verbose,'RA-856  = %.4f\n',ra_856);
log(verbose,'RA-900  = %.4f\n',ra_900);
log(verbose,'RA-910  = %.4f\n',ra_910);
log(verbose,'RA-920  = %.4f\n',ra_920);
log(verbose,'RA-930  = %.4f\n',ra_930);
log(verbose,'RA-940  = %.4f\n',ra_940);
log(verbose,'RA-950  = %.4f\n',ra_950);
log(verbose,'RA-960  = %.4f\n',ra_960);
log(verbose,'RA-970  = %.4f\n',ra_970);
log(verbose,'RA-980  = %.4f\n',ra_980);
log(verbose,'RA-990  = %.4f\n',ra_990);
log(verbose,'RA-1000 = %.4f\n',ra_1000);
log(verbose,'Range-950-856 = %.4f\n',range_950_856);
log(verbose,'====================\n');

log(verbose,'PERC results: \n');
log(verbose,'====================\n');
log(verbose,'PERC10   = %d HU\n',perc_10);
log(verbose,'PERC15   = %d HU\n',perc_15);
log(verbose,'PERC20   = %d HU\n',perc_20);
log(verbose,'====================\n');

log(verbose,'Other results:\n')
log(verbose,'====================\n')
log(verbose,'Mean     = %.2f HU\n',mean_lung);
log(verbose,'Median   = %.2f HU\n',median_lung);
log(verbose,'Kurtosis = %.2f \n',kurtosis_lung);
log(verbose,'Volume   = %.2f mm^3\n',volume*prod(spacing));
log(verbose,'====================\n');

log(verbose,'DONE\n');
end

function PERC_loc=get_perc(hist,X,PERC)
% PERC is the decimal value of the percentage point we're looking for
% i.e. for PERC15 we would use 0.15
i=0;
count=0;
total=sum(hist);
while count <= PERC * total
    i=i+1;
    count=count+hist(i);
end
PERC_loc=X(i);
end

function ra_val=get_ra(img,mask,RA)
% Returns the number of masked voxels below the RA value
lungs=img(logical(mask));
RA=(lungs<RA);
ra_val=sum(RA(:));
end

function log(verbose_flag,string,varargin)
if verbose_flag    
    fprintf(string,varargin{:});
end
end