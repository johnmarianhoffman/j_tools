function mask=j_load_qia_roi(filepath)
global raw;
global pointer;
pointer=0;
disp('Assuming we have 512x512 images')

raw=dlmread(filepath,' ');

num_z=pop_item();

while pointer < numel(raw)
    curr_z_slice=pop_item();
    if ~exist('mask','var')
        mask=false(512,512,num_z+curr_z_slice-1);
    end    
    disp(curr_z_slice);
    num_y=pop_item();

    for i=1:num_y
        curr_y_coor=pop_item();
        n_x_intervals=pop_item();
        for i=1:n_x_intervals
            x_start=pop_item();
            x_end=pop_item();

            mask(x_start:x_end,curr_y_coor,curr_z_slice)=true;
        end 
    end
end

end

function [val]=pop_item()
global raw
global pointer
pointer=pointer+1;
val=raw(pointer);
end

% 501859