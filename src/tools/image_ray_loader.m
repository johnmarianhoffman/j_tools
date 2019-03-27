function f = image_ray_loader(filepath)

    f.filepath = filepath;
    f.data = cell(3000,4096);
    f.rows = 0;
    f.cols = 0;

    size_t = 'uint64'; % convenience
    bool   = 'uchar';

    load_file();

    function load_file()
        fid = fopen(filepath,'r');
        if (fid==-1)
            fprintf('Not a valid filename!\n');
        end
        
        f.rows = fread(fid,1,size_t);
        for (i=1:f.rows)
            %fprintf('%d/%d...\n',i,f.rows)
            load_row()
        end

        fclose(fid);
        
        function load_row()
            curr_col_end = fread(fid,1,size_t);
            prev_data_invalid = fread(fid,1,bool);
            n_segments = fread(fid,1,size_t);
            %disp(n_segments)
            for (j=1:n_segments)
                load_segment()
            end
            
            function load_segment()
                col_start = fread(fid,1,size_t);
                seg_size  = fread(fid,1,size_t);

                %disp(col_start);
                %disp(seg_size);
                
                for (k = 1:seg_size)

                    imr.start_depth = fread(fid,1,'float32');
                    imr.step_size = fread(fid,1,'float32');
                    imr.ray_length = fread(fid,1,size_t);
                    imr.data = fread(fid,imr.ray_length,'float32');
                    
                    f.data{i,col_start+k-1} = imr;
                    
                end

            end
        end

    end
end

