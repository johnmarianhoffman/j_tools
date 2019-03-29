function f = j_window_level(img,ax_handle)

img_min = min(img(:));
img_max = max(img(:));

handles.curr_clims = get(ax_handle,'clim');

handles.f = figure('position',[500 500 400 200],'menubar','none');
handles.ax = ax_handle;
handles.vbox = uiextras.VBox();

handles.hbox_min   = uiextras.HBox('Parent',handles.vbox);
handles.hbox_max   = uiextras.HBox('Parent',handles.vbox);
handles.hbox_level = uiextras.HBox('Parent',handles.vbox);
handles.hbox_buttons = uiextras.HBox('Parent',handles.vbox);



handles.min_slider   = uicontrol('parent' ,handles.hbox_min   ,'style' ,'slider' ,'min' ,img_min ,'max' ,img_max ,'value' ,handles.curr_clims(1));
handles.max_slider   = uicontrol('parent' ,handles.hbox_max   ,'style' ,'slider' ,'min' ,img_min ,'max' ,img_max ,'value' ,handles.curr_clims(2));
handles.level_slider = uicontrol('parent' ,handles.hbox_level ,'style' ,'slider' ,'min' ,img_min ,'max' ,img_max ,'value' ,mean(handles.curr_clims(:)));

handles.min_edit   = uicontrol('parent' ,handles.hbox_min   ,'style' ,'edit' ,'string' ,num2str(handles.curr_clims(1)));
handles.max_edit   = uicontrol('parent' ,handles.hbox_max   ,'style' ,'edit' ,'string' ,num2str(handles.curr_clims(2)));
handles.level_edit = uicontrol('parent' ,handles.hbox_level ,'style' ,'edit' ,'string' ,mean(handles.curr_clims(:)));

set([handles.hbox_min handles.hbox_max handles.hbox_level],'Widths',[-1 100]);

handles.compress_button = uicontrol('parent',handles.hbox_buttons,'style','pushbutton','string','Compress Sliders');

handles.img_max = img_max;
handles.img_min = img_min;

% Set Callbacks
addlistener(handles.min_slider   ,'ContinuousValueChange' ,@min_slider_callback);
addlistener(handles.max_slider   ,'ContinuousValueChange' ,@max_slider_callback);
addlistener(handles.level_slider ,'ContinuousValueChange' ,@level_slider_callback);

set(handles.min_edit,'callback',@min_edit_callback);
set(handles.max_edit,'callback',@max_edit_callback);
set(handles.level_edit,'callback',@level_edit_callback);

set(handles.compress_button,'callback',@compress_button_callback);

f = handles.f;

guidata(f,handles);

end

function set_sliders(handles)
    clims = handles.curr_clims;

    curr_min = get(handles.min_slider,'min');
    curr_max = get(handles.max_slider,'max');
    
    set([handles.min_slider handles.max_slider handles.level_slider],'min',min(curr_min,clims(1)));
    set([handles.min_slider handles.max_slider handles.level_slider],'max',max(curr_max,clims(2)));

    set(handles.min_slider,'value',clims(1));
    set(handles.max_slider,'value',clims(2));
    set(handles.level_slider,'value',mean(clims(:)));
    
    set(handles.min_edit,'string',num2str(clims(1)));
    set(handles.max_edit,'string',num2str(clims(2)));
    set(handles.level_edit,'string',num2str(mean(clims(:))));
    
    set(handles.ax,'clim',clims);    
end

function min_slider_callback(h,e)
    handles = guidata(h);
    v = get(handles.min_slider,'value');

    if (v>handles.curr_clims(2))
        handles.curr_clims(2) = v;
    end

    handles.curr_clims = [ v handles.curr_clims(2)];
    set_sliders(handles);
    
    guidata(h,handles);
end

function max_slider_callback(h,e)
    handles = guidata(h);
    v = get(handles.max_slider,'value');

    if (v<handles.curr_clims(1))
        handles.curr_clims(1) = v;
    end

    handles.curr_clims = [ handles.curr_clims(1) v];
    set_sliders(handles);
    
    guidata(h,handles);
end

function level_slider_callback(h,e)
    handles = guidata(h);
    v = get(handles.level_slider,'value');
    delta = v - mean(handles.curr_clims(:));
    handles.curr_clims = handles.curr_clims + delta;

    set_sliders(handles);

    guidata(h,handles);
end

function min_edit_callback(h,e)

    handles = guidata(h);
    v = str2double(get(handles.min_edit,'string'));

    if (v>handles.curr_clims(2))
        handles.curr_clims(2) = v;
    end

    handles.curr_clims = [ v handles.curr_clims(2)];
    set_sliders(handles);
    
    guidata(h,handles);    
end

function max_edit_callback(h,e)

    handles = guidata(h);
    v = str2double(get(handles.max_edit,'string'));

    if (v<handles.curr_clims(1))
        handles.curr_clims(1) = v;
    end

    handles.curr_clims = [handles.curr_clims(1) v];
    set_sliders(handles);
    
    guidata(h,handles);    
end

function level_edit_callback(h,e)

    handles = guidata(h);
    v = str2double(get(handles.level_edit,'string'));
    delta = v - mean(handles.curr_clims(:));
    handles.curr_clims = handles.curr_clims + delta;

    set_sliders(handles);

    guidata(h,handles);
end

function compress_button_callback(h,e)
    handles = guidata(h);
    set([handles.min_slider handles.max_slider handles.level_slider],'min',handles.curr_clims(1));
    set([handles.min_slider handles.max_slider handles.level_slider],'max',handles.curr_clims(2));        
end