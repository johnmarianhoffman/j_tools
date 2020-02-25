function h=j_plot_adjacency(points,adjacency_mat)

    lines = zeros(0,2);
    
    for i=1:size(adjacency_mat,1)
        for j=1:size(adjacency_mat,2)
            if adjacency_mat(i,j)
                p1 = points(i,:);
                p2 = points(j,:);
                lines(end+1:end+3,:) = [p1;p2;nan(1,2)];
            end
        end
    end

    h = line(lines(:,1),lines(:,2));

end
