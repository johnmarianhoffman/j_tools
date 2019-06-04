%%%  #INRIMAGE-4#{ // format type
%%%  XDIM=150 // x dimension
%%%  YDIM=200 // y dimension
%%%  ZDIM=100 // z dimension
%%%  VDIM=1 // dimension of the data, here 1 for scalar or 3 for thing like RGB values
%%%  VX=5 // voxel size in x
%%%  VY=5 // voxel size in y
%%%  VZ=5 // voxel size in z
%%%  // a higher voxel size results in a more precise 3D mesh
%%%  TYPE=unsigned fixed // type of data written, can float, signed fixed or unsigned fixed, unclear if it makes a difference in my case
%%%  SCALE=2**0 // not used by most programs apparently
%%%  PIXSIZE=8 bits // size of a char, can be 8, 16, 32 or 64
%%%  CPU=pc // the type of cpu for little/big endianness, pc is little endian
%%%  
%%%  // Fill with carriage returns until the header is a multiple of 256 bytes, including the end of the header (4 bytes including the line break)
%%%  
%%%  ##} // the line break is included in the header count


function j_grid_convert(in_filepath,out_filepath)
    g = j_grid_reader(in_filepath);

    fid = fopen(out_filepath,'w');

    % INR Header
    header_bytes= 0;
    header_bytes = header_bytes + inr_string('#INRIMAGE-4#{');
    header_bytes = header_bytes + inr_string('XDIM',g.nx);
    header_bytes = header_bytes + inr_string('YDIM',g.ny);
    header_bytes = header_bytes + inr_string('ZDIM',g.nz);
    header_bytes = header_bytes + inr_string('VDIM',1);
    header_bytes = header_bytes + inr_string('VX',g.resolution);
    header_bytes = header_bytes + inr_string('VY',g.resolution);    
    header_bytes = header_bytes + inr_string('VZ',g.resolution);
    header_bytes = header_bytes + inr_string('TYPE','float');
    header_bytes = header_bytes + inr_string('SCALE','2**0');
    header_bytes = header_bytes + inr_string('PIXSIZE','32 bits');
    header_bytes = header_bytes + inr_string('CPU','pc');
    header_bytes = header_bytes + inr_string( repmat([char(10)],[1,255-(mod(header_bytes+4,256))]));    
    header_bytes = header_bytes + inr_string('##}');
    
    % INR Data
    fwrite(fid,g.data,'float32');

    function byte_count = inr_string(tag,val)

        if nargin==1
            s = [tag char(10)];
        else
            s = [tag '=' num2str(val) char(10)];
        end
        
        fwrite(fid,s);
        byte_count = strlength(s);        
    end    
end

