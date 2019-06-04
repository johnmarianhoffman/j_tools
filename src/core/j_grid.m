classdef j_grid < handle

    properties
        resolution;
        nx        ;
        ny        ;
        nz        ;
        nxy       ;
        nvox      ;
        offset_x  ;
        offset_y  ;
        offset_z  ;
        half_res  ;
        min_x      ;
        min_y      ;
        min_z      ;
        max_x      ;
        max_y      ;
        max_z      ;
        half_res_2 ;
        data;
    end

    methods (Access=public)
        function obj = j_grid(filepath,type)
            if nargin ==0
                return;
            elseif nargin<2
                type = 'float32';
                fprintf('Grid type defaulting to ''%s''\n',type);
            else
            end
            
            if (~exist(filepath,'file'))
                fprintf('File does not exist! (%s)\n',filepath);
                fprintf('Exiting.\n');
                return
            end

            fid = fopen(filepath,'rb');

            obj.resolution = fread(fid,1,'int');
            obj.nx         = fread(fid,1,'int');
            obj.ny         = fread(fid,1,'int');
            obj.nz         = fread(fid,1,'int');
            obj.nxy        = fread(fid,1,'uint64');
            obj.nvox       = fread(fid,1,'uint64');
            obj.offset_x   = fread(fid,1,'float32');
            obj.offset_y   = fread(fid,1,'float32');    
            obj.offset_z   = fread(fid,1,'float32');
            obj.half_res   = fread(fid,1,'float32');

            obj.min_x      = fread(fid,1,'float32');
            obj.min_y      = fread(fid,1,'float32');
            obj.min_z      = fread(fid,1,'float32');
            obj.max_x      = fread(fid,1,'float32');
            obj.max_y      = fread(fid,1,'float32');
            obj.max_z      = fread(fid,1,'float32');    

            obj.half_res_2 = fread(fid,1,'float32');

            obj.data = reshape(fread(fid,obj.nvox,type),obj.nx,obj.ny,obj.nz);

            fclose(fid);            
        end

        function saveToINR(obj,out_filepath)

            fid = fopen(out_filepath,'w');

            if (~fid)
                error('Could not open output filepath: %s',out_filepath);
                return;
            end

            % INR Header
            header_bytes= 0;
            header_bytes = header_bytes + inr_string('#INRIMAGE-4#{');
            header_bytes = header_bytes + inr_string('XDIM',obj.nx);
            header_bytes = header_bytes + inr_string('YDIM',obj.ny);
            header_bytes = header_bytes + inr_string('ZDIM',obj.nz);
            header_bytes = header_bytes + inr_string('VDIM',1);
            header_bytes = header_bytes + inr_string('VX',obj.resolution);
            header_bytes = header_bytes + inr_string('VY',obj.resolution);    
            header_bytes = header_bytes + inr_string('VZ',obj.resolution);
            header_bytes = header_bytes + inr_string('X0',obj.offset_x);
            header_bytes = header_bytes + inr_string('Y0',obj.offset_y);
            header_bytes = header_bytes + inr_string('Z0',obj.offset_z);
            header_bytes = header_bytes + inr_string('TYPE','float');
            header_bytes = header_bytes + inr_string('SCALE','2**0');
            header_bytes = header_bytes + inr_string('PIXSIZE','32 bits');
            header_bytes = header_bytes + inr_string('CPU','pc');
            header_bytes = header_bytes + inr_string( repmat([char(10)],[1,255-(mod(header_bytes+4,256))]));    
            header_bytes = header_bytes + inr_string('##}');
            
            % INR Data
            fwrite(fid,obj.data,'float32');

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

        function createDebugGrid(obj)
        % Creates a simple grid for testing things
            algebraic =  @(x,y,z,t) t.^4 + 6*sqrt(2)*x.*y.*z.*t + 2*(y.^3.*z + z.^2.*x + x.^3.*y);

            ellipse = @(x,y,z,r,a,b,c) a*x.^2 + b*y.^2 + c*z.^2 - r.^2;

            bound = 5;
            griddim = 256;
            x = linspace(-bound,bound,griddim);
            y = linspace(-bound,bound,griddim);
            z = linspace(-bound,bound,griddim);
            
            [X,Y,Z] = meshgrid(x,y,z);

            obj.data = ellipse(X,Y,Z,1,1,1,3);

            obj.nx         = size(obj.data,1);
            obj.ny         = size(obj.data,2);
            obj.nz         = size(obj.data,3);
            obj.nxy        = obj.nx*obj.ny;
            obj.nvox       = obj.nx*obj.ny*obj.nz;
            obj.offset_x   = -bound;
            obj.offset_y   = -bound;
            obj.offset_z   = -bound;
            obj.resolution = 2*bound/obj.nx;            
            obj.half_res   = 2*bound/obj.nx;
            obj.half_res_2  = obj.half_res^2;                        
            obj.min_x      = -bound;
            obj.min_y      = -bound;
            obj.min_z      = -bound;
            obj.max_x      = bound;
            obj.max_y      = bound;
            obj.max_z      = bound;

        end
    end
end