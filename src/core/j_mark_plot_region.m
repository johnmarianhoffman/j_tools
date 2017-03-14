function range_line=j_mark_plot_region(x_range,y_range,varargin)
% Demarcates a region on current or specified axes
% Following are accepted:
%
%    j_mark_plot_region(x_range,[]) - draws vertical lines spanning plot box
%    j_mark_plot_region([],y-range) - draws horizontal lines spanning plot box
%    j_mark_plot_region(x_range,y_range) - draws rectangle bounded by ranges

default_ax=gca;
default_color=[0 0 1];
default_weight=3;

p=inputParser;
p.addRequired('x_range',@isnumeric);
p.addRequired('y_range',@isnumeric);
p.addParameter('parent',default_ax);
p.addParameter('style','--');
p.addParameter('color',default_color);
p.addParameter('weight',default_weight);

p.parse(x_range,y_range,varargin{:});

x_range=p.Results.x_range;
y_range=p.Results.y_range;
ax=p.Results.parent;
style=p.Results.style;
color=p.Results.color;
weight=p.Results.weight;

if isempty(x_range) && isempty(y_range)
    error('Must provided either x_range, y_range, or both');
end

plot_x_range=get(ax,'xlim');
plot_y_range=get(ax,'ylim');

if isempty(y_range)
    range_line(1)=line([x_range(1) x_range(1)],[plot_y_range(1) plot_y_range(2)],'parent',ax);
    range_line(2)=line([x_range(2) x_range(2)],[plot_y_range(1) plot_y_range(2)],'parent',ax);

elseif isempty(x_range)

    range_line(1)=line([plot_x_range(1) plot_x_range(2)],[y_range(1) y_range(1)],'parent',ax);
    range_line(2)=line([plot_x_range(1) plot_x_range(2)],[y_range(2) y_range(2)],'parent',ax);

else

    range_line(1)=line([x_range(1) x_range(2)],[y_range(1) y_range(1)],'parent',ax);% Bottom 
    range_line(2)=line([x_range(1) x_range(2)],[y_range(2) y_range(2)],'parent',ax);% Top
    range_line(3)=line([x_range(1) x_range(1)],[y_range(1) y_range(2)],'parent',ax);% Right
    range_line(4)=line([x_range(2) x_range(2)],[y_range(1) y_range(2)],'parent',ax);% Left

end

set(range_line,'LineStyle',style);
set(range_line,'Color',color);
set(range_line,'LineWidth',weight);

end