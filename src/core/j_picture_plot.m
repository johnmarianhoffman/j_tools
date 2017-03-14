function handles=j_picture_plot(x_fig,y_fig,fig,varargin)


    
%p=inputParser;
%p.addRequired('x_fig',@isnumeric);
%p.addRequired('y_fig',@isnumeric);
%p.addRequired('fig',@isnumeric);
%p.addOptional('info_struct',default_info_struct,@(x) isequal(0,0));
%
%p.parse(x_fig,y_fig,fig,info_struct,varargin{:})
%x_fig=p.Results.x_fig;
%y_fig=p.Results.y_fig;
%fig=p.Results.fig;
%p.info_struct=p.Results.info_struct;
default_color_bank = {[0.2314 0.4431 0.3373],...
                    [0 0.4471 0.7412],...
                    [1 0 0],...
                    [1 0.8431 0]}

default_info_struct.title         = '';
default_info_struct.xlabel        = '';
default_info_struct.ylabel        = '';
default_info_struct.series_labels = cell(1,floor(numel(varargin)/2));
default_info_struct.series_colors = default_color_bank(1:floor(numel(varargin)/2));

if nargin<5
    error('Need more input arguments');
end

if mod(numel(varargin),2)==1
    info=varargin{end};
    series_plots=varargin(1:(end-1));

    if ~isfield(info,'series_colors')
        info.series_colors = default_color_bank(1:floor(numel(varargin)/2));
    end
    
else
    info=default_info_struct;
    series_plots=varargin;
end

% Create the figure
handles.fig=figure;
handles.axes=axes('parent',handles.fig);

handles.info=info;

% Show the image
fig=flipdim(fig,1);
handles.image=imagesc(x_fig,y_fig,fig);
colormap('gray');

% Plot the... plots
hold(handles.axes,'on')
for i=1:2:numel(series_plots)
    idx=floor(i/2)+1;
    
    x=series_plots{i};
    y=series_plots{i+1};

    handles.plots{idx} = plot(x,y,'color',handles.info.series_colors{idx});
    handles.legend_string{idx} = handles.info.series_labels{idx};

    if isequal(handles.info.series_colors{idx},[1 0 0])
        set(handles.plots{idx},'LineWidth',1.0);
    end
    
end

set(handles.axes,'ydir','normal');

title(handles.info.title);
xlabel(handles.info.xlabel);
ylabel(handles.info.ylabel);
handles.legend=legend(handles.legend_string);

guidata(handles.fig,handles);

% Create properties dialog box
properties_dlg(handles.fig)

set(handles.axes,'PlotBoxAspectRatio',[1 1 1]);
ax_handle=handles.axes;

end

function properties_dlg(fig_handle)
    handles=guidata(fig_handle)
    
    f=figure('Menubar','none');
    p=get(f,'position');

    set(f,'position',[p(1) p(2) 250 250]);

    vbox=uiextras.VBox('Parent',f,'Spacing',5);

    quickpanel=uiextras.Panel('Parent',vbox);
    uicontrol('Parent',quickpanel,'style','text','String','Picture Plot Properties','Fontsize',12);

    % Title tool:
    hbox_title=uiextras.HBox('Parent',vbox);
    uicontrol('Parent',hbox_title,'style','text','String','Title: ');
    uicontrol('Parent',hbox_title,'style','edit','String',handles.info.title,'callback',@(h,e) title(handles.axes,get(h,'string')),'background',[1 1 1])

    % X Label
    hbox_xlabel=uiextras.HBox('Parent',vbox);
    uicontrol('Parent',hbox_xlabel,'style','text','String','X Label: ');
    uicontrol('Parent',hbox_xlabel,'style','edit','String',handles.info.xlabel,'callback',@(h,e) xlabel(handles.axes,get(h,'string')),'background',[1 1 1])
    
    % Y Label
    hbox_ylabel=uiextras.HBox('Parent',vbox);
    uicontrol('Parent',hbox_ylabel,'style','text','String','Y Label: ');
    uicontrol('Parent',hbox_ylabel,'style','edit','String',handles.info.ylabel,'callback',@(h,e) ylabel(handles.axes,get(h,'string')),'background',[1 1 1])
    
    for i=1:numel(handles.plots)
        create_line_item(vbox,handles.plots{i},i);
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
