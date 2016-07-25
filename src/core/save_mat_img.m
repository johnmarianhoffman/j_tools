function save_mat_img(image,scale,filepath)

    if isequal(scale,[])
        scale(1)=min(image(:));
        scale(2)=max(image(:));
    end
    
    imwrite(mat2gray(image,scale),filepath);

end