function split_dicom_series(dicom_dir)

if nargin==0
    dicom_dir=uigetdir;
    if dicom_dir==0
        return;
    end
end

f=j_get_file_list(dicom_dir);

fprintf(1,'Getting dicom headers...\n')
for i=1:numel(f)
    disp(i)
    header_stack(i)=dicominfo(fullfile(dicom_dir,f{i}));
end

series={header_stack(:).SeriesTime};
series=unique(series);

fprintf(1,'Detected %d series\n',numel(series))
disp('Sorting...');

fprintf(1,'Making directories...\n')
for i=1:numel(series)
    disp(fullfile(dicom_dir,series{i}))
    mkdir(fullfile(dicom_dir,series{i}));
end

fprintf(1,'Moving files....\n')
for i=1:numel(header_stack)
    disp(i)
    curr_series=header_stack(i).SeriesTime;

    loc=ismember(series,curr_series)
    
    movefile(fullfile(dicom_dir,f{i}),fullfile(dicom_dir,series{loc}))
    
end