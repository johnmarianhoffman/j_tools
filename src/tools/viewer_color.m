function viewer_color(cdata_mat)
imgs = cdata_mat;
handles.f          = figure;
handles.ax         = axes('parent',handles.f,'position',[0 0 1 1]);
handles.img        = imshow(squeeze(imgs(:,:,:,1)),'parent',handles.ax);
handles.curr_image = 1;
handles.n_images   = size(imgs,4);
handles.images     = imgs;
handles.text       = text(0,0,'Current image: 1','fontsize',22,'parent',handles.ax);
set(handles.f,'keypressfcn',@key_callback);
guidata(handles.f,handles);
end

function key_callback(h,e)

    handles = guidata(h);

    switch e.Key
      case 'rightarrow'
        handles.curr_image = handles.curr_image+1;
      case 'leftarrow'
        handles.curr_image = handles.curr_image-1;
      otherwise
        return;
    end

    if handles.curr_image > handles.n_images
        handles.curr_image = handles.n_images;
    elseif handles.curr_image < 1
        handles.curr_image = 1;
    end

    set(handles.img,'cdata',squeeze(handles.images(:,:,:,handles.curr_image)));
    set(handles.text,'string',sprintf('Current image: %d',handles.curr_image-1));
    
    guidata(h,handles);
    
end