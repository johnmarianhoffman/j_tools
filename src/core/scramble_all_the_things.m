function scramble_all_the_things()
% Recursive version of scramble_that_shit

    % Initialize some variable
    handles.curr_path=pwd;
    
    % Create the GUI
    handles.fig=figure('Name','Get those names outta there!','NumberTitle','off');

    set(handles.fig,'MenuBar','none')

    
    scrn=get(0,'ScreenSize');
    center_x=scrn(3)/2;
    center_y=scrn(4)/2;
    gui_width=500;
    gui_height=100;

    set(handles.fig,'position',[center_x-gui_width/2 center_y-gui_height/2 gui_width gui_height]);

    handles.edit_box=uicontrol('parent',handles.fig,'style','edit','position',[20 gui_height-40 350 25],'string','/path/to/directory/','background','white');
    handles.select_button=uicontrol('parent',handles.fig,'style','pushbutton','position',[20+375 gui_height-40 75 25],'string','Select');
    handles.scramble_button=uicontrol('parent',handles.fig,'style','pushbutton','position',[gui_width/2-50 gui_height-100 100 50],'string','SCRAMBLE!');

    % Assign our callbacks
    set(handles.select_button,'callback',@select_callback);
    set(handles.scramble_button,'callback',@scramble_callback);

    guidata(handles.fig,handles);
    
end

function select_callback(hObject,eventdata)
    handles=guidata(hObject);
    d=uigetdir;
    if d==0
        return;
    else
        set(handles.edit_box,'string',d);
        handles.curr_path=d;
    end
    guidata(hObject,handles);
end

function scramble_callback(hObject,eventdata)
    handles=guidata(hObject);
    j_scramble_recursive(handles.curr_path);
end

function j_scramble_recursive(p)
% Check for dicom files
    disp(p)
    dir_list=j_get_dir_list(p);
    file_list=j_get_file_list(p);

    for i=1:numel(file_list)
        % If we find a dicom file, scramble the directory and break the loop
        if j_isdicom(fullfile(p,file_list{i}))
            j_scramble_filenames(p);
            break;
        end 
    end 

    % Recurse into each subdirectory
    for i=1:numel(dir_list)
        j_scramble_recursive(fullfile(p,dir_list{i}));
    end 

end 

function j_scramble_filenames(p)

    fprintf(1,'Scrambling %s',p)
    
    % Get the current directory and set up destination p
    src_dir=p;
    dest_dir=fullfile(src_dir,'scrambled');

    % Create the output directory
    mkdir(dest_dir);

    % Get the list of all the files
    file_list=j_get_file_list(src_dir);

    h=waitbar(0,sprintf('Scrambling filenames in %s',src_dir));
    for i=1:numel(file_list)
        waitbar(i/numel(file_list),h);
        curr_file=fullfile(src_dir,file_list{i});
        
        % Check if the file is a dicom_file
        if j_isdicom(curr_file)
            output_filename=sprintf('%s%s','NAME_REMOVED',file_list{i}(min(find(file_list{i}=='.')):end));
            copyfile(curr_file,fullfile(dest_dir,output_filename));
        else
            continue
        end
    end

    close(h)

end

function d=j_get_file_list(d)
    d=dir(d);
    d=d(~[d(:).isdir]);
    d={d(:).name};
end

function d=j_get_dir_list(d)

    d=dir(d);
    d=d([d(:).isdir]);
    d={d(:).name};

    d(ismember(d,'.'))=[];
    d(ismember(d,'..'))=[];

end


function tf=j_isdicom(file_path)

    fid=fopen(file_path,'r');
    fseek(fid,128,'bof');
    raw=fread(fid,4,'schar');

    word=char(raw');
    tf=isequal('dicm',lower(word));

end

