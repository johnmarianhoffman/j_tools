function ctbb_pipeline_denoise(library,varargin)
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

for i=1:size(paths,1)
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
    
    % Parse string to figure out the dose and slice thickness utilized for tuning
    [p,f,e]         = fileparts(hr2_filepath);
    elems           = strsplit(f,'_');
    patient         = elems{1};
    dose            = elems{2};
    kernel          = elems{3};
    slice_thickness = elems{4};
    
    dose            = str2double(dose(2:end));
    kernel          = str2double(kernel(2:end));
    slice_thickness = str2double(slice_thickness(3:end));

    % Baseline parameters
    w=2;
    sigma_d=1;
    sigma_r=0.05;

    relative_dose=100/dose;
    relative_st=1.0/slice_thickness;
    tuning_param=sqrt(2)^((relative_dose*relative_st)-1);
    
    % CHECK IF IT LOOKS LIKE WE'VE DENOISED BEFORE =======================================
    if exist([hr2_filepath '_org']) && skip_existing
        ERROR_CODE=5;
    end

    % RUN DENOISING ============================================================
    if ~ERROR_CODE
        
        % Copy file over
        ret_code=system(sprintf('cp %s %s',hr2_filepath,[hr2_filepath '_org']));
        if ret_code
            ERROR_CODE=1;
            codes=[codes ' ' num2str(ERROR_CODE)];
        end
    
        % Run Denoising
        if ~ERROR_CODE
            try
                pipeline_denoise_bilateral(hr2_filepath,w,sigma_d,tuning_param*sigma_r);
            catch ME
                ERROR_CODE=-1;
                codes=[codes ' ' num2str(ERROR_CODE)];
                % If we didn't successfully denoise, remove "history" of the attempt                
                delete([hr2_filepath '_org']);
            end
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
    
    fprintf(1,'%s: %s %d %.2f s\n',hr2_filepath,message,i,t_ind);
end

t_total=toc(t_ref);
fprintf(1,'Total elapsed time: %.2f s\n',t_total);

end

function log(verbose_flag,string,varargin)
    if verbose_flag    
        fprintf(string,varargin{:});
    end
end