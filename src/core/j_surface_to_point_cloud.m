function  p = j_surface_to_point_cloud(surface_grid)
[x,y,z] = ind2sub(size(surface_grid),find(surface_grid~=0));
p = pointCloud([x,y,z]);
end