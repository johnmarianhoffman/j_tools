function img_matrix = j_imclamp(img_matrix,clamp_val)
img_matrix(img_matrix>clamp_val) = clamp_val;
end