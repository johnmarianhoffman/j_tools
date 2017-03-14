function varargout=j_get_dicom(dicom_dir)

if nargin<1
    dicom_dir=uigetdir('/home/john/Study_Data/emphysema_fred/');
end

file_list=dir(dicom_dir);
file_list=file_list(~[file_list.isdir]);
file_list={file_list.name};

dicom_stack=zeros(512,512,numel(file_list));
tmp_stack=cell(1,numel(file_list));

h=waitbar(0,'Loading DICOM stack');

for i=1:numel(file_list)
    waitbar(i/numel(file_list),h,sprintf('%i/%i',i,numel(file_list)));
    if isdicom(fullfile(dicom_dir,file_list{i}))
        dicom_stack(:,:,i)=dicomread(fullfile(dicom_dir,file_list{i}));
        try 
            header_stack(i)=dicominfo(fullfile(dicom_dir,file_list{i}));
        catch
        end
        tmp_stack{i}=dicom_stack(:,:,i);
    end
end

rescale_slope=header_stack(1).RescaleSlope;
rescale_intercept=header_stack(1).RescaleIntercept;

% Sort on table_positions/or slice number?
close(h);

slice_locations=[header_stack(:).SliceLocation];
[~,i]=sort(slice_locations);
disp(mat2str(i))
tmp_stack=tmp_stack(i);
for i=1:numel(tmp_stack)
    dicom_stack(:,:,i)=tmp_stack{i};
end

dicom_stack=rescale_slope*dicom_stack+rescale_intercept;
varargout{1}=dicom_stack;
varargout{2}=header_stack;

end


