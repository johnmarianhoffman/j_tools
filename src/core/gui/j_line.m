classdef j_line < handle

    properties
        pt1 = j_impoint.empty(0);
        pt2 = j_impoint.empty(0);
        l;
    end
    
    methods
        
        function obj = j_line(pt1,pt2)
        % pt1 and pt2 are j_impoints
            obj.pt1 = pt1;
            obj.pt2 = pt2;

            pt1 = pt1.getPosition();
            pt2 = pt2.getPosition();

            ax = gca;
            obj.l = line(ax,[pt1(1) pt2(1)],[pt1(2) pt2(2)]);

            addlistener(obj.pt1,'moved',@obj.update_end_points);
            addlistener(obj.pt2,'moved',@obj.update_end_points);
        end

        function update_end_points(obj,h,e,varargin)
            pos1 = obj.pt1.getPosition();
            pos2 = obj.pt2.getPosition();
            set(obj.l,'xdata',[pos1(1) pos2(1)],'ydata',[pos1(2) pos2(2)]);            
        end
    end
end