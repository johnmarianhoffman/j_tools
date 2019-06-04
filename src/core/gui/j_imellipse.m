classdef j_imellipse < imellipse
    %OIQIMELLIPSE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        title
        hidden
        info
        info_box
        info_hidden=true;
    end
    
    events
        roi_update;
        roi_moved;
        roi_deletion;
    end
    
    methods
        function oime=j_imellipse(name,varargin)
            % Call format is oiqimellipse(name,[optional paramter value pairs],args_for_imellipse)
            
            opts.show_infobox=false;
            opts.enable_rename=true;
            opts.enable_delete=true;
            
            count=1;
            while count<=numel(varargin)
                switch varargin{count}
                    case 'show_infobox'
                        opts.show_infobox=varargin{count+1};
                        count=count+2;
                    case 'enable_rename'
                        opts.enable_rename=varargin{count+1};
                        count=count+2;
                    case 'enable_delete'
                        opts.enable_delete=varargin{count+1};
                        count=count+2;
                    otherwise
                        varargin=varargin(count:end);
                        break;
                end
            end
            
            oime@imellipse(varargin{:});
            
            % Protection if user escapes
            if isempty(oime)
                return;
            end
            
            oime.name=name;
            
            pos=round(getPosition(oime));
            pos_c=j_PositionVectorConvert(pos,'m->c');
            
            ax=get(oime,'parent');
            oime.info.ax=ax;
            im=findobj(ax,'type','image');
            oime.info.image=get(im,'CData');
            update_info(oime);
            oime.info_box=text(pos(1)+pos(3),pos(2)+pos(4),...
                sprintf('Position: %i,%i\nMean: %.2f\nSD: %.2f',pos_c(1),pos_c(2),oime.info.mean,oime.info.sd),'Parent',ax,'visible','off');
            oime.title=text(pos_c(1),pos_c(2),...
                oime.name,'Parent',ax,...
                'HorizontalAlignment','Center','Color','b');            
            
            set(oime.info_box,'color','white',...
                'backgroundcolor','black');
            
            addNewPositionCallback(oime,@(p) pos_callback(p,oime));
       
            % Adjust context menu items
            cm_obj=findobj(oime,'Type','line','-or','Type','patch');
            cm=get(cm_obj,'uicontextmenu');
            cm=cm{1};
            % remove the built-in matlab delete (since "Deletable" property
            % seems to be broken in 2015b)
            cm_array=get(cm,'Children');
            delete(cm_array(1));
            cm_array=cm_array(2:end);
            set(cm,'Children',cm_array);
            
            cm_delete=uimenu(cm,'Label','Delete ROI','Callback',@(varargin) cm_roi_delete(oime));
            cm_rename=uimenu(cm,'Label','Rename ROI','Callback',@(varargin) cm_roi_rename(oime));
            uimenu(cm,'Label','Toggle info','Callback',@(varargin) cm_toggle_info(oime));
            set(cm_obj,'uicontextmenu',cm);
            set(oime,'UIContextMenu',cm);
            
            % Based on input options, enable/disable various things
            switch opts.enable_delete
                case true
                    set(cm_delete,'enable','on');
                case false
                    set(cm_delete,'enable','off');
            end
            
            switch opts.enable_rename
                case true
                    set(cm_rename,'enable','on');
                case false
                    set(cm_rename,'enable','off');
            end
            
            switch opts.show_infobox
                case true
                    oime.info_hidden=false;
                    set(oime.info_box,'visible','on');
                case false
                    % Do nothing, hidden by default
            end
           
        end
        
        function hide(oime)
            set(oime.title,'visible','off');
            set(oime.info_box,'visible','off');
            set(oime,'visible','off');
        end
        
        function show(oime)
            set(oime.title,'visible','on');
            set(oime,'visible','on');
            if ~oime.info_hidden
                set(oime.info_box,'visible','on');
            end
        end
        
        function add_context_item(oime,label,callback)
            % Can handle a single item or one layer of nested items
            % if label is a string, we get on item
            % if label is a cell array of form { parent_label
            % {nested_label_1 nested_label_2 ... nested_label_n}} then we
            % will get a multilevel item (however only one callback)
            
            cm_obj=findobj(oime,'Type','line','-or','Type','patch');
            cm=get(cm_obj,'uicontextmenu');
            cm=cm{1};
            
            switch class(label)
                case 'char'
                    cm_item=uimenu(cm,'Label',label,'Callback',callback);
                case 'cell'
                    cm_parent=uimenu(cm,'Label',label{1});
                    
                    for i=1:numel(label{2})
                        uimenu('Parent',cm_parent,'Label',label{2}{i},'Callback',callback);    
                    end
            end
            set(cm_obj,'uicontextmenu',cm);
            set(oime,'UIContextMenu',cm);
        end
        
        function update_info(oime)           
            pos=j_PositionVectorConvert(round(getPosition(oime)),'m->c');
            
            mask=createMask(oime);
            mean_val=mean(double(oime.info.image(mask)));
            sd_val=std(double(oime.info.image(mask)));
            
            oime.info.pos_row=pos(2);
            oime.info.pos_col=pos(1);
            oime.info.mean=mean_val;
            oime.info.sd=sd_val;
        end

        function delete(oime)
            delete(oime.title);
            delete(oime.info_box);
            notify(oime,'roi_deletion');
        end
        
        function addSecondaryPositionCallback(oime,fcn)
            addlistener(oime,'roi_moved',fcn);
        end
        
        function addUpdateCallback(oime,fcn)
            addlistener(oime,'roi_update',fcn);
        end
    end
    
end

function pos_callback(position,oime)

pos=round(position);
pos_c=j_PositionVectorConvert(pos,'m->c');

% Update title text position
set(oime.title,'position',[ pos_c(1),pos_c(2),0]);
set(oime.info_box,'position',[pos(1)+pos(3),pos(2)+pos(4),0],...
    'string',sprintf('Position: %i,%i\nMean: %.2f\nSD: %.2f',pos(1),pos(2),oime.info.mean,oime.info.sd));
update_info(oime)
notify(oime,'roi_moved');
notify(oime,'roi_update');
end
function cm_toggle_info(r)
switch get(r.info_box,'visible')
    case 'on'
        set(r.info_box,'visible','off');
        r.info_hidden=true;
    case 'off'
        set(r.info_box,'visible','on');
        r.info_hidden=false;
end

end
function cm_roi_delete(r)
delete(r); 
end
function cm_roi_rename(r)
prompt={'Provide a name for the ROI:'};
name='ROI name...';
numlines=1;
defaultanswer={r.name};
answer=inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answer)
    name=r.name;
else
    name=answer{1};
end
r.name=name;
set(r.title,'string',name);
notify(r,'roi_update');
end