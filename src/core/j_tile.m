function tiling=j_tile(stack,dims,start,borders_tf)
if nargin<4
    borders_tf=false;
end

if nargin<3
    start=1;
end

if numel(start:size(stack,3))<(dims(1)*dims(2))
    error('j_tools:j_tile:not_enough_images','Not enough images in stack for requested tiling');
end

tile_range=start:start+dims(1)*dims(2);


tiling=zeros(dims(1)*size(stack,1)+borders_tf*(dims(1)-1),dims(2)*size(stack,2)+borders_tf*(dims(2)-1));

for i=1:dims(1)

    row_range=((i-1)*size(stack,1)+1+borders_tf*(i-1)):(i*size(stack,1)+borders_tf*(i-1));

    for j=1:dims(2)

        col_range=((j-1)*size(stack,2)+1+borders_tf*(j-1)):(j*size(stack,2)+borders_tf*(j-1));
        
        % want to tile across a row first
        curr_slice=(i-1)*dims(2)+(j-1)+start;
        tiling(row_range,col_range)=stack(:,:,curr_slice);
    end
end


end