function f = j_window_level(img,ax_handle)

img_min = min(img(:));
img_max = max(img(:));

handles.curr_clims = get(ax_handle,'clim');

handles.f = figure('position',[500 500 400 200],'menubar','none');
handles.ax = ax_handle;
handles.vbox = uiextras.VBox();
handles.min_slider = uicontrol('parent',handles.vbox,'style','slider','min',img_min,'max',img_max,'value',handles.curr_clims(1));
handles.max_slider = uicontrol('parent',handles.vbox,'style','slider','min',img_min,'max',img_max,'value',handles.curr_clims(2));
handles.level_slider = uicontrol('parent',handles.vbox,'style','slider','min',img_min,'max',img_max,'value',mean(handles.curr_clims(:)));

handles.img_max = img_max;
handles.img_min = img_min;

addlistener(handles.min_slider   ,'ContinuousValueChange' ,@min_slider_callback);
addlistener(handles.max_slider   ,'ContinuousValueChange' ,@max_slider_callback);
addlistener(handles.level_slider ,'ContinuousValueChange' ,@level_slider_callback);

f = handles.f;

guidata(f,handles);

end

function set_sliders(handles)
    clims = handles.curr_clims;
    set(handles.min_slider,'value',clims(1));
    set(handles.max_slider,'value',clims(2));
    set(handles.level_slider,'value',mean(clims(:)));
    set(handles.ax,'clim',handles.curr_clims);    
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

