function j_picture_plot(x_fig,y_fig,fig,varargin)

if numel(varargin)==3
    warning('Looks like you''re just showing a figure.  You''d probably be better off with IMSHOW.')
elseif numel(varargin)>3 && mod(numel(varargin),2)==1
    error('Must provide match x and y vectors for plots.')    
end

% Create the figure
handles.fig=figure;
handles.axes=axes('parent',handles.fig);

% Show the image
fig=flipdim(fig,1);
handles.image=imagesc(x_fig,y_fig,fig);
colormap('gray');

% Plot the... plots
hold(handles.axes,'on')
for i=1:2:numel(varargin)
    idx=floor(i/2)+1;
    
    x=varargin{i};
    y=varargin{i+1};

    handles.plots{idx} = plot(x,y,'color',rand(1,3));
    handles.legend_string{idx} = ['Series ' num2str(idx)];
end

set(handles.axes,'ydir','normal');

handles.legend=legend(handles.legend_string);

guidata(handles.fig,handles);

% Create properties dialog box
properties_dlg(handles.fig)

end

function properties_dlg(fig_handle)
    handles=guidata(fig_handle)
    
    f=figure;
    p=get(f,'position');

    set(f,'position',[p(1) p(2) 250 250]);

    vbox=uiextras.VBox('Parent',f,'Spacing',5);

    quickpanel=uiextras.Panel('Parent',vbox);
    uicontrol('Parent',quickpanel,'style','text','String','Picture Plot Properties','Fontsize',12);

    % Title tool:
    hbox_title=uiextras.HBox('Parent',vbox);
    uicontrol('Parent',hbox_title,'style','text','String','Title: ');
    uicontrol('Parent',hbox_title,'style','edit','String','','callback',@(h,e) title(handles.axes,get(h,'string')),'background',[1 1 1])

    % X Label
    hbox_xlabel=uiextras.HBox('Parent',vbox);
    uicontrol('Parent',hbox_xlabel,'style','text','String','X Label: ');
    uicontrol('Parent',hbox_xlabel,'style','edit','String','','callback',@(h,e) xlabel(handles.axes,get(h,'string')),'background',[1 1 1])
    
    % Y Labelx
    hbox_ylabel=uiextras.HBox('Parent',vbox);
    uicontrol('Parent',hbox_ylabel,'style','text','String','X Label: ');
    uicontrol('Parent',hbox_ylabel,'style','edit','String','','callback',@(h,e) ylabel(handles.axes,get(h,'string')),'background',[1 1 1])

    
    for i=1:numel(handles.plots)
        create_line_item(vbox,handles.plots{i},i)
    end

    wl_pushbutton=uicontrol('parent',vbox,'style','pushbutton','string','Figure W/L');
    set(wl_pushbutton,'callback',@(h,e) imcontrast(handles.image));

    function line_item=create_line_item(parent,attached_plot,attached_plot_idx)
        
        line_item.hbox=uiextras.HBox('Parent',parent,'Padding',2);
        plot_color=permute(get(attached_plot,'color'),[1 3 2]);
        line_item.color_pushbutton=uicontrol('parent',line_item.hbox,'style','pushbutton','string','','cdata',repmat(plot_color,20,20));
        line_item.label_edit=uicontrol('Parent',line_item.hbox,'style','edit','string',handles.legend_string{attached_plot_idx},'Background',[1 1 1]);
        
        set(line_item.color_pushbutton,'callback',@color_pushbutton_callback);
        set(line_item.label_edit,'callback',@label_edit_callback);

        set(line_item.hbox,'Sizes',[25 -1]);

        function color_pushbutton_callback(hObject,eventdata)
            current_c=get(attached_plot,'Color');
            new_c=uisetcolor;

            if ~new_c
                return;
            else
                set(attached_plot,'Color',new_c);
                set(line_item.color_pushbutton,'cdata',repmat(permute(new_c,[1 3 2]),20,20));
            end
            
        end

        function label_edit_callback(hObject,eventdata)
            s=get(hObject,'string');
            l=get(handles.legend,'string');
            l{attached_plot_idx}=s;
            set(handles.legend,'String',l);
        end
        
    end

end
