function j_tri_plot(tri,x,y)

f = figure('visible','off');
ax = axes('parent',f);

scatter(x,y,'black','parent',ax);

for i = 1:size(tri,1)

    curr_tri = tri(i,:);
    p1 = [x(curr_tri(1)),y(curr_tri(1)),0];
    p2 = [x(curr_tri(2)),y(curr_tri(2)),0];
    p3 = [x(curr_tri(3)),y(curr_tri(3)),0];    
    
    triangle(p1,p2,p3);
    
end

set(f,'visible','on');

end