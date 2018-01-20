function ctbb_pipeline_denoise_HACKY(library,ext)
% EXT='hr2' || 'img'.
%
% This really should not be generally utilized
% outside of John's dissertation work.

    disp(sprintf('find %s -name *.hr2',library))

    [~,b]=system(sprintf('find %s -name *.hr2',library));

    b=strsplit(b,'\n');

    % Baseline parameters
    w=2;
    sigma_d=1;
    sigma_r=0.05;

    % Make a queue
    queue=b;
    err={};
    complete={};

    skip_flag=true;

    item_count=0;

    try
        while ~isempty(queue)
            [curr_case,queue]=pop(queue);
            item_count=item_count+1;

            % Because we had a failure, we need to skip the first N cases up to the one below
            try
                if curr_case

                    % Parse string to figure out the dose and slice thickness utilized for tuning
                    [p,f,e]=fileparts(curr_case);
                    elems           = strsplit(f,'_');
                    patient         = elems{1};
                    dose            = elems{2};
                    kernel          = elems{3};
                    slice_thickness = elems{4};
                    
                    dose            = str2double(dose(2:end));
                    kernel          = str2double(kernel(2:end));
                    slice_thickness = str2double(slice_thickness(3:end));

                    relative_dose=100/dose;
                    relative_st=1.0/slice_thickness;
                    tuning_param=sqrt(2)^((relative_dose*relative_st)-1);

                    fprintf('%s: %.1f %.1f %.2f: ',curr_case,dose,slice_thickness,tuning_param);

                    pipeline_denoise_bilateral(curr_case,w,sigma_d,tuning_param*sigma_r);

                    %if mod(item_count,100)==0
                    %    error('TK THIS IS A TEST')
                    %end

                    complete=add(complete,curr_case);
                    
                    fprintf(1,'SUCCESS\n');

                end
            catch ME
                err=add(err,curr_case);
                fprintf(1,'ERROR\n');
            end
        end

        % Save data to disk
        flush_to_disk(queue,'~/Study_Data/bilateral_tuning/queue.txt');
        flush_to_disk(err,'~/Study_Data/bilateral_tuning/error.txt');
        flush_to_disk(complete,'~/Study_Data/bilateral_tuning/complete.txt');

    catch ME
        % If there's a failure we don't see coming, and the above try/catch doesn't catch it,
        % we want to write the queue and error list to disk
        err=add(err,curr_case);
        flush_to_disk(queue,'~/Study_Data/bilateral_tuning/queue.txt');
        flush_to_disk(err,'~/Study_Data/bilateral_tuning/error.txt');
        flush_to_disk(complete,'~/Study_Data/bilateral_tuning/complete.txt');
        throw(ME);
    end
end

function [item,queue]=pop(queue)
    item=queue{1};
    queue(1)=[];
end

function push(queue) % Not needed for this work
end

function queue=add(queue,item)
    queue{end+1}=item;
end

function flush_to_disk(queue,filepath)

    fprintf(1,'Flushing to disk: %s\n',filepath);
    
    format='%s \n';

    fid=fopen(filepath,'w');
    for i=1:numel(queue)
        fprintf(fid,format,queue{i});
    end
    fclose(fid);
    
end 