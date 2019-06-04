function handles = j_rectangle(v1,v2,v3,v4,ax_handle)

    keyboard
    
    handles = [];
    x = [v1(1) v2(1)];
    y = [v1(2) v2(2)];
    handles(end+1) = line(ax_handle,x,y);

    x = [v2(1) v3(1)];
    y = [v2(2) v3(2)];
    handles(end+1) = line(ax_handle,x,y);

    x = [v3(1) v4(1)];
    y = [v3(2) v4(2)];
    handles(end+1) = line(ax_handle,x,y);
    
    x = [v4(1) v1(1)];
    y = [v4(2) v1(2)];
    handles(end+1) = line(ax_handle,x,y);
end