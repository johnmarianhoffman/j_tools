classdef j_dgraph < handle

    properties
        n_nodes;
        nodes = [];
        edges = [];
    end

    methods (Access=public)
        function obj = j_dgraph(filepath)

            if (~exist(filepath,'file'))
                fprintf('File does not exist! (%s)\n',filepath);
                fprintf('Exiting.\n');
                return
            end
            
            fid = fopen(filepath,'r');

            l = string(fgetl(fid)); % DGRAPH
            if (l~="DGRAPH")
                could_not_read_file(1);
                return;
            end
            
            l = string(fgetl(fid)); % NODES

            % Parse nodes line
            info = strsplit(l);
            if (info{1}=="NODES")                
                obj.n_nodes = str2double(info{2});
            else
                could_not_read_file(2);
                return;
            end

            obj.nodes = zeros(obj.n_nodes,3);
            obj.edges = false(obj.n_nodes,obj.n_nodes);

            for i=1:obj.n_nodes
                l = string(fgetl(fid));
                p = str2double(strsplit(l));
                p(isnan(p))=[];
                obj.nodes(i,:) = p;
            end

            for i=1:obj.n_nodes
                l = string(fgetl(fid));
                l = str2double(strsplit(l));
                l(isnan(l)) = [];
                l = logical(l);

                obj.edges(i,:) = l;
            end 
        end

        function display(obj)
            points = obj.nodes;
            connectivity = obj.edges;
            f = figure;
            ax = axes;
            axis('equal')
            for j=1:size(connectivity,2)    
                for i=1:size(connectivity,1)
                    if (i>j)
                        continue
                    else
                        if connectivity(i,j)==1
                            pt1 = points(i,:);
                            pt2 = points(j,:);
                            line([pt1(1) pt2(1)],[pt1(2) pt2(2)],[pt1(3) pt2(3)]);
                        end
                    end
                end    
            end
            drawnow;
            
        end

        function could_not_read_file(err)
            fprintf(1,"Error reading file.  Does not match DGRAPH format. Code %d\n",err);
            return;
        end
        

    end


    
end