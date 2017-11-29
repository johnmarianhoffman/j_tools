function out_idx=j_adjust_slice_index(idx,ref_thickness_1,output_slice_thickness)
% Map an index from one slice thickness to another
    slice_location=(idx-1)*ref_thickness_1;
    out_idx=round(slice_location/output_slice_thickness + 1);
end