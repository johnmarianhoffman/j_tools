function j_grid_writer(filepath,grid)

    if nargin<2
        type = 'float32';
        fprintf('Grid type defaulting to ''%s''\n',type);
    end
    
    if (~exist(filepath,'file'))
        fprintf('File does not exist! (%s)\n',filepath);
        fprintf('Exiting.\n');
        return
    end

    fid = fopen(filepath,'rb');

    grid.resolution = fread(fid,1,'int');
    grid.nx         = fread(fid,1,'int');
    grid.ny         = fread(fid,1,'int');
    grid.nz         = fread(fid,1,'int');
    grid.nxy        = fread(fid,1,'uint64');
    grid.nvox       = fread(fid,1,'uint64');
    grid.offset_x   = fread(fid,1,'float32');
    grid.offset_y   = fread(fid,1,'float32');    
    grid.offset_z   = fread(fid,1,'float32');
    grid.half_res   = fread(fid,1,'float32');

    grid.min_x      = fread(fid,1,'float32');
    grid.min_y      = fread(fid,1,'float32');
    grid.min_z      = fread(fid,1,'float32');
    grid.max_x      = fread(fid,1,'float32');
    grid.max_y      = fread(fid,1,'float32');
    grid.max_z      = fread(fid,1,'float32');    

    grid.half_res_2 = fread(fid,1,'float32');

    grid.data = reshape(fread(fid,grid.nvox,type),grid.nx,grid.ny,grid.nz);

    fclose(fid);
end
