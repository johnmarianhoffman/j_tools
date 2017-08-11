function stack2gif(stack,scale,output_filepath)
    
    if isequal(scale,[])
        scale(1)=min(stack(:));
        scale(2)=max(stack(:));
    end

    for i=1:size(stack,3)

        slice=gray2ind(mat2gray(stack(:,:,i),scale),256);
        
        % Write to the GIF File 
        if i == 1 
            imwrite(slice,output_filepath,'gif', 'Loopcount',inf);
        else 
            imwrite(slice,output_filepath,'gif','WriteMode','append'); 
        end 
    end
end