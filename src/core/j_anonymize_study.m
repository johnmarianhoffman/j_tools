function j_anonymize_study(dir,mode,varargin)

files=j_get_file_list(dir);

if ~ismember(mode,{'overwrite','save'})
    error('"mode" argument must be either ''overwrite'' or ''save''')
end

if isequal(mode,'save')&&~exist(fullfile(dir,'anon'),'dir')
    mkdir(dir,'anon');
end 

if ~isempty(varargin)
    start_val=varargin{1};
else
    start_val=1;
end

for i=start_val:numel(files)
    curr_file=fullfile(dir,files{i});

    if j_isdicom(curr_file)
        % Set up the output filepath
        if isequal(mode,'overwrite')
            output_filepath=fullfile(dir,sprintf('anon_%05d.dcm',i));
        else
            output_filepath=fullfile(dir,'anon',sprintf('anon_%05d.dcm',i));
        end

        % Do the anonymization
        fprintf(1,'Anonymizing: %s -> %s\n',curr_file,output_filepath)
        %dicomanon(curr_file,output_filepath,'WritePrivate',false);
        dicomanon(curr_file,output_filepath);        

        % If "overwriting" delete the original file
        if isequal(mode,'overwrite')
            delete(curr_file);
        end
    end
end


end