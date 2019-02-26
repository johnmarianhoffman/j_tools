function image_viewer(image_path,overlay_path)    
% Graphics
    handles.f  = figure;
    handles.ax = axes('parent',handles.f);
    handles.img = imshow(zeros(512,512,3,'uint8'),'parent',handles.ax);
    hold on
    handles.img_overlay = imshow(zeros(512,512,3,'uint8'),'parent',handles.ax);
    hold off
    
    set(handles.f,'units','normalized');
    set(handles.ax,'position',[0 0 1 1]);
    set(handles.f,'units','pixels');

    handles.load_image   = uicontrol('parent',handles.f,'style','pushbutton','string','load_image','callback',@load_image_callback,'position',[0 0 150 30]);
    handles.load_overlay = uicontrol('parent',handles.f,'style','pushbutton','string','load_overlay','callback',@load_overlay_callback,'position',[150 0 150 30]);

    set(handles.f,'keypressfcn',@keypress_callback);

    handles.info = annotation('textbox',[0 0 1 1])
    set(handles.info,'string',{image_path,overlay_path},'color',[0 0 0],'interpreter','none','horizontalalignment','center');

    % Data
    handles.image             = [];
    handles.overlay           = [];
    handles.curr_image_path   = image_path;
    handles.curr_overlay_path = overlay_path;
    handles.color_cam_ids     = [5,6,7,8,13,14,15,16,21,22,23,24,29,30,31,32,37,38,39,40,45,46,47,48,53,54,55,56,61,62,63,64];
    handles.curr_image_idx    = 0;
    
    handles.overlay_opacity = 100;

    load_shit(handles.curr_image_path,handles.curr_overlay_path,handles);
    guidata(handles.f,handles);

end

function load_image_callback(h,e)
    handles = guidata(h);    

    if ~f
        return
    else
        load_image(fp,handles);        
    end

    handles.curr_image_path = fp;
    guidata(h,handles);
end

function load_overlay_callback(h,e)
    handles = guidata(h);

    [f,p] = uigetfile({'*.*'});
    fp = fullfile(p,f);
    
    if ~f
        return
    else
        load_overlay(fp,handles);
    end
end

function keypress_callback(h,e)
    handles = guidata(h);

    switch e.Key
      case 'rightarrow'
        next_image = mod(handles.curr_image_idx+1,numel(handles.color_cam_ids));
      case 'leftarrow'
        next_image = mod(handles.curr_image_idx-1,numel(handles.color_cam_ids));
      otherwise
        return
    end

    s = build_filepath_strings(next_image,handles);

    handles.curr_image_path   = s{1};
    handles.curr_overlay_path = s{2};

    disp(handles.curr_image_idx)
    disp(handles.curr_image_path)    
    disp(handles.curr_overlay_path)
    
    %load_image(handles.curr_image_path,handles);
    %load_overlay(handles.curr_overlay_path,handles);

    load_shit(handles.curr_image_path,handles.curr_overlay_path,handles);
    
    guidata(h,handles);
    
end

function load_image(fp,handles)
    cdata = imread(fp);
    disp(fp);
    
    set(handles.img,'cdata',cdata);
    
    if size(cdata,3)==1
        colormap(handles.ax, gray(256))
    end
    set(handles.ax,'xlim',[0.5,size(cdata,2)+0.5],'ylim',[0.5,size(cdata,1)+2]);
end

function load_shit(im,ov,handles)
    img = imread(im);
    overlay = imread(ov);
    
    %overlay = double(overlay)/max(overlay(:));
    
    for i=1:3
        curr_slice = img(:,:,i);        
        curr_slice(logical(overlay)) = curr_slice(logical(overlay)) + handles.overlay_opacity;
        img(:,:,i) = curr_slice;
    end

    set(handles.img,'cdata',img);    
    set(handles.ax,'xlim',[0.5,size(img,2)+0.5],'ylim',[0.5,size(img,1)+2]);
    set(handles.info,'string',{im,ov});    
    
end

function redraw_current(h)
    handles = guidata(h);

    for i=1:3
        curr_slice = img(:,:,i);        
        curr_slice(logical(overlay)) = curr_slice(logical(overlay)) + handles.overlay_opacity;
        img(:,:,i) = curr_slice;
    end

    set(handles.img,'cdata',img);    
    set(handles.ax,'xlim',[0.5,size(img,2)+0.5],'ylim',[0.5,size(img,1)+2]);
    set(handles.info,'string',{im,ov});
end



function load_overlay(fp,handles)
    overlay = imread(fp);

    % Set up the overlay
    delete(handles.img_overlay);
    im_size=size(overlay);
    green = cat(3, zeros(im_size), ones(im_size), zeros(im_size));
    hold on
    handles.img_overlay = imshow(green,'Parent',handles.ax);
    hold off    
    
    set(handles.img_overlay, 'AlphaData', double(overlay)/1024);

    guidata(handles.f,handles);
end

function s = build_filepath_strings(idx,handles)
    s=cell(1,2,3);

    [p,f,e] = fileparts(handles.curr_image_path);
    s{1} = strrep(f,num2str(handles.color_cam_ids(handles.curr_image_idx+1)),num2str(handles.color_cam_ids(idx+1)));
    s{1} = fullfile(p,[s{1},e]);
    
    [p,f,e] = fileparts(handles.curr_overlay_path);
    s{1} = strrep(f,num2str(handles.color_cam_ids(handles.curr_image_idx+1)),num2str(handles.color_cam_ids(idx+1)));    
    s{2} = fullfile(p,[s{2},e]);    

    s{3} = idx;
end