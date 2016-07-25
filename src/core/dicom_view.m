function varargout=dicom_view(dicom_dir)

file_list=dir(dicom_dir);
file_list=file_list(~[file_list.isdir]);
file_list={file_list.name};

dicom_stack=zeros(512,512,numel(file_list));

h=waitbar(0,'Loading DICOM stack');

for i=1:numel(file_list)
    waitbar(i/numel(file_list),h,sprintf('%i/%i',i,numel(file_list)));
    if isdicom(fullfile(dicom_dir,file_list{i}))
        dicom_stack(:,:,i)=dicomread(fullfile(dicom_dir,file_list{i}));
        header_stack(i)=dicominfo(fullfile(dicom_dir,file_list{i}));
    end
end

rescale_slope=header_stack(1).RescaleSlope;
rescale_intercept=header_stack(1).RescaleIntercept;

dicom_stack=rescale_slope*dicom_stack+rescale_intercept;

varargout{1}=dicom_stack;

% Sort on table_positions/or slice number?
close(h);
%sv(dicom_stack);




end


