function fig=oiqWindowLevel(ax,image)

handles.figure1=figure('Name','Window Level',...
    'Numbertitle','off',...
    'Menubar','none',...
    'Units','pixels');

fig=handles.figure1;

% Add axes handles and image matrix to handles
handles.axes=ax;
handles.image=image;

% Get the max and min values that we'll use for sliders
clim=get(ax,'clim');
handles.current_clims=clim;
handles.current_window=clim(2)-clim(1);
handles.current_level=mean(clim);
window_lims=[0.001,4000];
level_lims=[-1500 1500];

% Adjust size and position of GUI
scrsz=get(groot,'ScreenSize');
wid=scrsz(3)/4;
hgh=scrsz(4)/4;
c_x=scrsz(3)/2;
c_y=scrsz(4)/2;
set(handles.figure1,'position',[c_x-wid/2 c_y-hgh/2 wid hgh]);

handles.hbox=uiextras.HBox('Parent',handles.figure1,'Padding',4);
handles.preset_box=uiextras.VBox('Parent',handles.hbox,'Spacing',2);
handles.manual_box=uiextras.VBox('Parent',handles.hbox,'Spacing',3);

% Preset box
preset_string=...
    {'Abdomen: 400/40';...
    'Lung: 1500/-500';
    'Bone: 2000/250';
    'Preset 4: 40/0';
    'Preset 5:'};
    
preset_wl=[400 40;
    1500 -50;
    2000 250;
    40 0;
    100 100];

for i=1:5
    handles.preset(i)=uicontrol('parent',handles.preset_box,'style','pushbutton','string',preset_string{i},'Callback',@preset_callback);
    handles.preset_clims{i}=[preset_wl(i,2)-preset_wl(i,1)/2 , preset_wl(i,2)+preset_wl(i,1)/2];
end

% Manual control box
handles.plot=axes('parent',handles.manual_box,'FontSize',6,'xticklabel',[],'yticklabel',[]);

handles.window_text_hbox=uiextras.HBox('Parent',handles.manual_box,'Spacing',5);
handles.window_text=uicontrol('parent',handles.window_text_hbox,'style','text','String','Window:');
handles.window_edit_text=uicontrol('parent',handles.window_text_hbox,'style','edit','string',num2str(handles.current_window),'backgroundcolor','white');
handles.window_slider=uicontrol('parent',handles.manual_box,'style','slider','min',window_lims(1),'max',window_lims(2),'value',handles.current_window);

handles.level_text_hbox=uiextras.HBox('Parent',handles.manual_box,'Spacing',5);
handles.level_text=uicontrol('parent',handles.level_text_hbox,'style','text','string','Level:');
handles.level_edit_text=uicontrol('parent',handles.level_text_hbox,'style','edit','string',num2str(handles.current_level),'backgroundcolor','white');
handles.level_slider=uicontrol('parent',handles.manual_box,'style','slider','min',level_lims(1),'max',level_lims(2),'value',handles.current_level);
set(handles.manual_box,'Sizes',[-3 -.5 -.4 -.5 -.4]);

histo=imhist(handles.image,round(max(image(:))-min(image(:))));
x=linspace(min(image(:)),max(image(:)),numel(histo));
bar(handles.plot,x,histo/max(histo));
handles.line=line([clim(1) clim(2)],[0 1]);

set(handles.plot,'xticklabel',[],'yticklabel',[]);

% Set callbacks
set([handles.window_slider handles.level_slider],'callback',@slider_callback);
set([handles.window_edit_text handles.level_edit_text],'callback',@edit_callback);

patch_in_all_gui_objects(handles.figure1,handles);

update_gui(handles);
end


function preset_callback(hObject,eventdata)
handles=guidata(hObject);
clims=handles.preset_clims{handles.preset==hObject};
handles.current_window=clims(2)-clims(1);
handles.current_level=mean(clims);
handles.current_clims=clims;
update_gui(handles);
guidata(hObject,handles);
end

function slider_callback(hObject,eventdata)
handles=guidata(hObject);
w=get(handles.window_slider,'value');
handles.current_window=w;
l=get(handles.level_slider,'value');
handles.current_level=l;
handles.current_clims=[l-w/2 , l+w/2];
update_gui(handles);
guidata(hObject,handles);
end

function edit_callback(hObject,eventdata)
handles=guidata(hObject);
w=str2double(get(handles.window_edit_text,'string'));
if w<=0
    w=0.01;
end
l=str2double(get(handles.level_edit_text,'string'));
handles.current_window=w;
handles.current_level=l;
handles.current_clims=[l-w/2 , l+w/2];
update_gui(handles);
guidata(hObject,handles);
end

function patch_in_all_gui_objects(fig,handles)
    guidata(fig,handles);
end

function handles=update_gui(handles)
% Make sure sliders are set to current w/l
    set(handles.window_slider,'value',handles.current_window);
    set(handles.level_slider,'value',handles.current_level);

    % Set text boxes to correct values
    set(handles.window_edit_text,'string',num2str(handles.current_window));
    set(handles.level_edit_text,'string',num2str(handles.current_level));

    % Update the wl histogram plot
    set(handles.line,'xdata',handles.current_clims,'ydata',[0 1]);

    % Update the image we're windowing and leveling 
    set(handles.axes,'clim',handles.current_clims);
end