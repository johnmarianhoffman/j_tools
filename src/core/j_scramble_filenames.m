function j_scramble_filenames(path)

% Get the current directory and set up destination path
    src_dir=pwd;
    dest_dir=fullfile(src_dir,'scrambled');

    % Create the output directory
    mkdir(dest_dir);

    % Get the list of all the files
    file_list=j_get_file_list(src_dir);

    for i=1:numel(file_list)
        curr_file=fullfile(src_dir,file_list{i});
        
        % Check if the file is a dicom_file
        if j_isdicom(curr_file)
            output_filename=sprintf('%s%s','NAME_REMOVED',file_list{i}(min(find(file_list{i}=='.')):end));
            copyfile(curr_file,fullfile(dest_dir,output_filename));
            fprintf(1,'copying %d\n',i);
        else
            fprintf(1,'skipping %d\n',i);
            continue
        end


    end
end