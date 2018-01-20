function lookup=seg_edit_pipeline(lib,seg_edit_list)

verbose=true;
dry_run=true;
    
hr2_script_path='/home/john/Code/CTBB_Pipeline_Package/CTBB_Pipeline/src/read_hr2.py';

% Parse list of cases to be corrected ========================================
edit_list=yaml.ReadYaml(seg_edit_list);
patients=fieldnames(edit_list);

% Get case list (to lookup pipeline ID with study number)
fid=fopen(fullfile(lib,'case_list.txt'),'r');
raw=char(fread(fid)');
fclose(fid);

lines=strsplit(raw,'\n');
for i=1:numel(lines)
    lines{i}=strsplit(lines{i},',');
end

for i=1:numel(patients)
    % Build paths to hr2 file and segmentations ==============================

    pipeline_id=find_pipeline_id(patients{i},lines);

    log(verbose,'Starting patient %d/%d %s,%s\n',i,numel(patients),patients{i},pipeline_id);
    log(verbose,'========================================\n');
    
    slice_thicknesses=edit_list.(patients{i}).slice_thicknesses;
    reason=edit_list.(patients{i}).reason;

    for j=1:numel(slice_thicknesses)

        switch slice_thicknesses{j}
          case 0.6
            st='0.6';
          case 1.0
            st='1.0';
          case 2.0
            st='2.0';
        end
        
        study_dirpath=fullfile(lib,...
                              'recon',...
                              '100',...
                              sprintf('%s_k1_st%s',pipeline_id,st));

        hr2_filepath        = fullfile(study_dirpath,'img',sprintf('%s_d100_k1_st%s.hr2',pipeline_id,st));
        left_lung_filepath  = fullfile(study_dirpath,'seg','left_lung.roi');
        right_lung_filepath = fullfile(study_dirpath,'seg','right_lung.roi');

        copyfile(left_lung_filepath,[left_lung_filepath '_org']);
        copyfile(right_lung_filepath,[right_lung_filepath '_org']);        

        tmp_name=tempname;
        temp_img=[tmp_name '.img'];
        temp_hr2=[tmp_name '.hr2'];

        % Convert hr2 file into img and load
        log(verbose,'Loading image data: %s...\n',hr2_filepath);
        system(sprintf('python3 %s %s %s',hr2_script_path,hr2_filepath,temp_img));
        stack=read_disp_recon_512(temp_img);
        delete(temp_img);
        delete(temp_hr2);        
        
        % Load ROIs
        log(verbose,'Loading left lung: %s...\n',left_lung_filepath);
        left=load_qia_roi(left_lung_filepath);

        log(verbose,'Loading right lung: %s...\n',right_lung_filepath);
        right=load_qia_roi(right_lung_filepath);

        n_slices_stack=size(stack,3);
        n_slices_left=size(left,3);
        n_slices_right=size(right,3);

        left=cat(3,left,zeros(512,512,n_slices_stack-n_slices_left));
        right=cat(3,right,zeros(512,512,n_slices_stack-n_slices_right));

        assignin('base','stack',stack);
        assignin('base','left',left);
        assignin('base','right',right);

        % Edit the segmentations and save to tmp path
        h=viewer_seg_edit(stack,left);
        t=text(20,20,strjoin(reason,'\n'));
        set(t,'color','white');

        waitfor(h)
        movefile('/tmp/lung.roi','/tmp/right_lung.roi');
        
        h=viewer_seg_edit(stack,right);
        t=text(20,20,strjoin(reason,'\n'));
        set(t,'color','white');
        waitfor(h)
        movefile('/tmp/lung.roi','/tmp/right_lung.roi');

        % Push updated segmentations back to library
        if dry_run
            for ii=[100 50 25 10]
                for jj=[1 2 3]

                    outdose=num2str(ii);
                    
                    output_study_dirpath=fullfile(lib,...
                              'recon',...
                              outdose,...
                              sprintf('%s_k%s_st%s',pipeline_id,num2str(jj),st));

                    output_hr2_path=fullfile(output_study_dirpath,'img',...
                                             sprintf('%s_d%s_k%s_st%s.hr2',pipeline_id,outdose,num2str(jj),st));

                    output_left_lung=fullfile(output_study_dirpath,'seg','left_lung.roi');
                    output_right_lung=fullfile(output_study_dirpath,'seg','right_lung.roi');                    
                    
                    cmd_l=sprintf('cp %s %s','/tmp/left_lung.roi',output_left_lung);
                    cmd_r=sprintf('cp %s %s','/tmp/right_lung.roi',output_right_lung);

                    log(verbose,'%s\n',output_hr2_path);
                    log(verbose,'%s\n',cmd_l);
                    log(verbose,'%s\n',cmd_r);
                end
            end            
        end 
        
        % DELETE segmentations from temporary directory (to prevent accidental overwrite)





        
        log(verbose,'========================================\n');
    end 

end

end

function patient_id=find_pipeline_id(internal_id,lines)
% Super klugey, but works.  DONT EVER USE FOR ANYTHING ELSE.
internal_id_ptr=['/data/DefAS_Full/raw/17007_SCMP2DFA' strrep(internal_id,'x','') '.ptr'];
internal_id_ima=['/data/DefAS_Full/raw/17007_SCMP2DFA' strrep(internal_id,'x','') '.IMA'];

for i =1:numel(lines)-1

    l=lines{i};
    curr_internal_id=l{1};
    curr_patient_id=l{2};

    if isequal(curr_internal_id,internal_id_ptr) || isequal(curr_internal_id,internal_id_ima)
        patient_id=curr_patient_id;
        return;
    end
end

end

function log(verbose,message,varargin)
    if verbose
        fprintf(1,message,varargin{:})
    end
end