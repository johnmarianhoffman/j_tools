function j_join_edges(points,connectivity)

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
drawnow

end