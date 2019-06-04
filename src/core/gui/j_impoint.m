classdef j_impoint < handle
    properties
        id;
        roi;
    end

    events
        moved
    end
    
    methods
        function obj =j_impoint(pt1)
            obj.roi = pt1;
            obj.roi.addNewPositionCallback(@obj.new_position);
        end

        function setId(obj,i)
            obj.id = i;
        end

        function i = getId(obj)
            i = obj.id;
        end        

        function new_position(obj,h,e)
            obj.notify('moved');
        end

        function pos = getPosition(obj)
            pos = getPosition(obj.roi);
        end
    end

end