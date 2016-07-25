function j_visualize_pipeline(axis_1,axis_2,axis_3,case_name,doses,kernels,sts,varargin)
% Takes output of j_load_pipeline_data and allows user to visualize
%
%   j_visualize_pipeline(axis_1,axis_2,axis_3,case_name,doses,kernels,sts,varargin)
%
% axis_1/2 - 'dose' | 'slice_thickness' | 'kernel'  (for row/column tiling)
% axis_3   - 'dose' | 'slice_thickness' | 'kernel' | []  (scroll axis)
%          if [], user will be able to scroll though all of the slices in the stack
% case_name -
% doses     - array of dose values to tile, likely the same as that fed to j_load_pipeline_data
% kernels   - array of kernel values to tile, likely the same as that fed to j_load_pipeline_data
% slice...  - array of slice_thickness values to tile, likely the same as that fed to j_load_pipeline_data
% varargin  - if axis_3 is not [], provide a table position to use for the visualization (we'll account for slice thickness)

% Preallocate for speed
% Determine number of rows
    switch axis_1(1)
      case 'd'
        n_rows=numel(doses);
        %axis_1=doses;
      case 's'
        n_rows=numel(sts);
        %axis_1=sts;
      case 'k'
        n_rows=numel(kernels);
        %axis_1=kernels
    end

    % Determine the number of columns
    switch axis_2(1)
      case 'd'
        n_col=numel(doses);
        %axis_2=doses;
      case 's'
        n_col=numel(sts);
        %axis_2=sts;    
      case 'k'
        n_col=numel(kernels);
        %axis_2=kernels;    
    end

    % Determine number of slices
    switch axis_3(1)
      case 'd'
        n_slice=numel(doses);
        %axis_3=doses;
      case 's'
        n_slice=numel(sts);
        %axis_3=sts;    
      case 'k'
        n_slice=numel(kernels);
        %axis_3=kernels;    
      otherwise
        %    n_slice=size(
    end

    var_name=cell(n_rows,n_col,n_slice);

    % Create list of variables
    for i=1:n_slice % axis_3

        switch axis_3(1)
          case 'd'
            dose_val=doses(i);
          case 's'
            slice_val=sts(i);
          case 'k'
            kernel_val=kernels(i);
        end
        
        for j=1:n_rows % axis_2

            switch axis_1(1)
              case 'd'
                dose_val=doses(j);
              case 's'
                slice_val=sts(j);
              case 'k'
                kernel_val=kernels(j);
            end
            
            for k=1:n_col % axis_1

                switch axis_2(1)
                  case 'd'
                    dose_val=doses(k);
                  case 's'
                    slice_val=sts(k);
                  case 'k'
                    kernel_val=kernels(k);
                end

                var_name{j,k,i}=sprintf('%s_d%s_k%s_s%s',case_name,num2str(dose_val),num2str(kernel_val),num2str(slice_val));


                var_name{j,k,i}(ismember(var_name{j,k,i},'.'))='p';
                fprintf(1,'%s\n',var_name{j,k,i});
                
            end
        end    
    end


    % Form the actual tiling
    table_pos=varargin{1};
    slice_numbers=round(repmat(table_pos,size(sts))./sts);

    assignin('base','tiling',zeros(512*n_rows,512*n_col,n_slice)) ;

    for i=1:n_slice
        if axis_3(1)=='s'
            slice_idx=slice_numbers(i);
        end
            
        for j=1:n_rows
            if axis_1(1)=='s'
                slice_idx=slice_numbers(j);
            end

            for k=1:n_col

                if axis_2(1)=='s'
                    slice_idx=slice_numbers(k);
                end


                curr_stack=var_name{j,k,i};
                assignin('base','i',i);
                assignin('base','j',j);
                assignin('base','k',k);

                assign_command=sprintf('tiling(((j-1)*512+1):j*512,((k-1)*512+1):k*512,i)=%s(:,:,%d);',curr_stack,slice_idx);
                fprintf('%s\n',assign_command);
                evalin('base',assign_command);

            end
        end
    end

    
end