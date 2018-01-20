function save_qia_roi(output_filepath,mask)
global output;
global pointer;
pointer=0;

% Write order:

% # of z
% Z_coor
% # of y
% y_coor
% # of x intervals
% start_x,end_x
% ... repeat for # intervals ...
% Next y coor
% ... repeat ...

% Preallocate our output array (won't need all of this memory though)
output=zeros(1,numel(mask));

% Find the total number of non-zero mask slices (not this is not the
% total number of slices in the mask matrix)
n_z=0;
for i=1:size(mask,3)
    curr_slice=mask(:,:,i);
    if sum(curr_slice(:))~=0
        n_z=n_z+1;
    end
end
save_to_output(n_z);

% Travel over each slice
for i=1:size(mask,3)
    curr_slice=mask(:,:,i);

    if sum(curr_slice(:))==0
        continue
    else
        curr_z_idx=i;
        save_to_output(curr_z_idx);

        tmp=mean(curr_slice,1);
        n_y=numel(find(tmp~=0));
        save_to_output(n_y);
        
        for j=1:size(curr_slice,1)
            curr_row=curr_slice(:,j);
            [n_intervals,intervals]=find_intervals(curr_row);
            
            if n_intervals~=0
                curr_y=j;
                save_to_output(curr_y);
                n_intervals;
                save_to_output(n_intervals);
                for k=1:numel(intervals)
                    save_to_output(intervals(k));
                end
            end    
                
        end        
    end
    
end

% Get rid of all zero entries at end of vector
output(output==0)=[];

dlmwrite(output_filepath,output,'delimiter',' ');

end

% 501859

function save_to_output(val)
    global output
    global pointer
    pointer=pointer+1;
    output(pointer)=val;
end

