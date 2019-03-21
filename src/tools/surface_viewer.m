function surface_viewer(surface_grid)

% Preprocess the surface_grid
    non_zeros = round(1024*surface_grid(surface_grid~=0)/10);    
    cmap = j_stoplight(1024);

    if nargin<1    
        s = generate_sphere(40);
        [x,y,z] = ind2sub(size(s),find(s~=0));
        c = squeeze(ind2rgb(non_zeros(:),cmap));
    else
        [x,y,z] = ind2sub(size(surface_grid),find(surface_grid~=0));
        c = squeeze(ind2rgb(non_zeros(:),cmap));
    end

    handles.f       = figure;
    handles.pc_data = [z,y,max(x(:))-x];
    handles.ax      = pcshow(handles.pc_data,c);
    handles.pc      = get(handles.ax,'children');
    set(handles.ax,'Toolbar',[]);
    xlabel('x');
    ylabel('y');    
    zlabel('z');

    zoom('off');
    pan('off');
    rotate3d('off');

    campos('manual');
    camtarget('manual');
    camproj('perspective');
    axis(gca,'vis3d');

    handles.velocity = 100;
    handles.cam_dir = camtarget()-campos();
    handles.cam_dir = (1/norm(handles.cam_dir))*handles.cam_dir;
    handles.cam_x   = cross(handles.cam_dir,camup());

    handles.prev_target = camtarget();

    handles.org_cam_pos = campos();
    handles.org_cam_tar = camtarget();    

    handles.button_down = false;

    set(handles.f ,'keypressfcn'           ,@keypress_callback);
    set(handles.f ,'windowbuttonmotionfcn' ,@mousemotion_callback);
    set(handles.f ,'windowbuttondownfcn'   ,@buttondown_callback);
    set(handles.f ,'windowbuttonupfcn'     ,@buttonup_callback);

    guidata(handles.f,handles);
end

function keypress_callback(h,e)
    handles = guidata(h);
    switch e.Key
      case 'w'
        campos(campos()+handles.velocity*handles.cam_dir);
      case 's'
        campos(campos()-handles.velocity*handles.cam_dir);    
      case 'd'
        campos(campos()+handles.velocity*handles.cam_x);
        camtarget(camtarget()+handles.velocity*handles.cam_x);    
      case 'a'
        campos(campos()-handles.velocity*handles.cam_x);
        camtarget(camtarget()-handles.velocity*handles.cam_x);    
      case 'e'
        campos(campos()+handles.velocity*camup());
        camtarget(camtarget()+handles.velocity*camup());
      case 'c'
        campos(campos()-handles.velocity*camup());
        camtarget(camtarget()-handles.velocity*camup());

      case 'r'
        A = [cos(pi/4) sin(pi/4) 0 0; ...
             -sin(pi/4) cos(pi/4) 0 0; ...
             0 0 1 0; ...
             0 0 0 1];
        tform = affine3d(A);
        

      case 'leftbracket'
        disp('sizedown')
        curr_size = get(handles.pc,'sizedata');
        disp(curr_size)
        set(handles.pc,'sizedata',curr_size-4);
        
      case 'rightbracket'
        disp('sizeup')        
        curr_size = get(handles.pc,'sizedata');
        disp(curr_size)        
        set(handles.pc,'sizedata',curr_size+4);

      case 'space'
        campos(handles.org_cam_pos);
        camtarget(handles.org_cam_tar);        
        
    end

    handles.prev_target = camtarget();
    guidata(handles.f,handles);
end

function mousemotion_callback(h,e)
    handles = guidata(h);

    if handles.button_down
        offset = get(handles.f,'currentpoint') - handles.start_point;
        camtarget(handles.prev_target+.25*offset(2)*camup()+.25*offset(1)*handles.cam_x);
    end

end

function buttondown_callback(h,e)
    handles = guidata(h);
    handles.button_down = true;
    handles.start_point = get(handles.f,'currentpoint');
    
    set(handles.f ,'windowbuttonmotionfcn' ,@mousemotion_callback);
    guidata(e.Source,handles);
end

function buttonup_callback(h,e)
    handles = guidata(h);
    handles.button_down = false;
    set(handles.f ,'windowbuttonmotionfcn' ,@mousemotion_callback);

    % Recompute our key vectors
    handles.prev_target = camtarget();
    handles.cam_dir = camtarget()-campos();
    handles.cam_dir = (1/norm(handles.cam_dir))*handles.cam_dir;
    handles.cam_x = cross(handles.cam_dir,camup());

    guidata(e.Source,handles);
end


function surface = generate_sphere(R)

    x = -100:100;
    y = -100:100;
    z = -100:100;

    [X,Y,Z] = meshgrid(x,y,z);

    mask = (X.^2 + Y.^2 + Z.^2 < R^2);

    surface = j_create_surface(mask);

end