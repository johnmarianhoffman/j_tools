function surface_grid = j_create_surface(grid_struct)

    try
        g = grid_struct.data;

    catch
        g = grid_struct;

    end
    
    surface_grid = zeros(size(g),'logical');
    nx = size(g,1);
    ny = size(g,2);    
    nz = size(g,3);

    for i=2:nx-1
        fprintf('Nx: %d/%d\n',i,nx)
        for j=2:ny-1
            for k=2:nz-1
                if (g(i,j,k)>0.5)&&get_neighborhood(i,j,k)
                    surface_grid(i,j,k)=true;

                    %exit_flag = false;
                    %for ii=x-1:x+1
                    %    for jj=y-1:y+1
                    %        for kk=z-1:z+1                
                    %
                    %            if g(ii,jj,kk)<0.5
                    %                surface_grid(i,j,k)=true;
                    %                exit_flag = true;
                    %                break;
                    %            end
                    %            if exit_flag
                    %                break;
                    %            end                            
                    %        end
                    %        if exit_flag
                    %            break;
                    %        end
                    %    end
                    %    if exit_flag
                    %        break;
                    %    end
                    %end

                end
            end
        end
    end

    function tf = get_neighborhood(x,y,z)

        tf = false;
        for ii=x-1:x+1
            for jj=y-1:y+1
                for kk=z-1:z+1                
                    if g(ii,jj,kk)<0.5
                        tf = true;
                        return;
                    end
                end
            end
        end

    end
end

