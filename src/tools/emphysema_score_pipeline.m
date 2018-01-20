function emphysema_score_pipeline(library,ref_library,varargin)
% This file should only be used for John's dissertation
%
% "library" is the directory we're going to score emphysema for
% "ref_library" is the directory we're going to pull our segmentations from (if we don't already have them)
%
%  Both library paths need to be absolute. I guarantee nothing if they are not.

skip_existing=true;
verbose=true;
case_list_file=fullfile(library,'hr2_list.txt');

if skip_existing
    warning(sprintf(['Cases with existing results will not be ' ...
                     'reevaluated.  Change "skip_existing" parameter ' ...
                     'in emphysema_score_pipeline.m if you do not ' ...
                     'want this behavior.']));
end 

if ~isempty(varargin)
    paths=varargin;
else
    % Get file list
    log(verbose,'Generating case list  (this may take a while)...\n');
    n_hr2=5200;
    paths=cell(n_hr2,1);
    fid=fopen(case_list_file,'r');

    i=1;
    tline=fgetl(fid);
    while ischar(tline)
        paths{i}=tline;
        tline=fgetl(fid);
        i=i+1;
    end
    fclose(fid);

    paths=paths(1:(i-1));
end

t_ref=tic;

parfor i=1:size(paths,1)
    ERROR_CODE=0;
    codes='';
    t_ind=tic;

    % CONFIGURE FUNCTION CALL ============================================================
    % Need to configure four variable
    %   hr2_filepath
    %   left_lung_filepath
    %   right_lung_filepath
    %   results_dirpath
    %   qa_dirpath

    % hr2_filepath
    hr2_filepath=paths{i};
    
    % Lung ROIs
    [img_dir,f,e]=fileparts(hr2_filepath);
    [study_dir,f,e]=fileparts(img_dir);
    seg_dir=fullfile(study_dir,'seg');

    % left_lung_filepath    
    tmp_path=fullfile(seg_dir,'left_lung.roi');

    if exist(tmp_path,'file')
        left_lung_filepath=tmp_path;
    elseif exist(strrep(tmp_path,library,ref_library),'file')
        left_lung_filepath=strrep(tmp_path,library,ref_library);
    else
        ERROR_CODE=1;
        codes=[codes ' ' num2str(ERROR_CODE)];
    end

    % right_lung_filepath    
    tmp_path=fullfile(seg_dir,'right_lung.roi');

    if exist(tmp_path,'file')
        right_lung_filepath=tmp_path;
    elseif exist(strrep(tmp_path,library,ref_library),'file')
        right_lung_filepath=strrep(tmp_path,library,ref_library);
    else
        ERROR_CODE=2;
        codes=[codes ' ' num2str(ERROR_CODE)];
    end

    % results_dirpath
    results_dirpath=fullfile(study_dir,'qi_raw');
    if ~exist(results_dirpath,'dir')
        ret_code=mkdir(study_dir,'qi_raw');
        if ~ret_code % (1 if success, 0 if fail)
            ERROR_CODE=3;
            codes=[codes ' ' num2str(ERROR_CODE)];
        end 
    end
    
    % qa_dirpath
    qa_dirpath=fullfile(study_dir,'qa');
    if ~exist(qa_dirpath,'dir')        
        ret_code=mkdir(study_dir,'qa');
        if ~ret_code % (1 if success, 0 if fail)
            ERROR_CODE=4;
            codes=[codes ' ' num2str(ERROR_CODE)];
        end
    end

    % Check if we already have results data
    results_filepath=fullfile(results_dirpath,'results_emphysema.yml')
    if exist(results_filepath,'file') && skip_existing
        ERROR_CODE=5;
    end
    
    % CALL SCORING FUNCTION ============================================================
    if ~ERROR_CODE
        try
            j_score_emphysema(hr2_filepath,left_lung_filepath,right_lung_filepath,results_dirpath,qa_dirpath);
        catch ME
            ERROR_CODE=-1;
            codes=[codes ' ' num2str(ERROR_CODE)];
        end 
    end
    
    % PREPARE FINAL ERROR MESSAGE ======================================================
    if ~ERROR_CODE
        message='SUCCESS';
    elseif ERROR_CODE==5
        message='SKIPPING';
    else
        message=sprintf('ERRORS:[%s]',codes);
    end

    t_ind=toc(t_ind);
    
    fprintf(1,'%s: %s %d %.2f s\n',study_dir,message,i,t_ind);
end

t_total=toc(t_ref);
fprintf(1,'Total elapsed time: %.2f s\n',t_total);

end

function log(verbose_flag,string,varargin)
    if verbose_flag    
        fprintf(string,varargin{:});
    end
end