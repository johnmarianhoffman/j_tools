function game_of_life()
    
    global w;
    global h;
    global world;
    global color;
    
    w = 256;
    h = 256;

    world = randi([0,1],h,w);
    tmp_world = zeros(size(world));
    color = zeros(h,w,3);
    world2color()

    f = figure;
    ax = axes;
    set(ax,'position',[0 0 1 1]);
    img = imshow(color);

    while true
        update_world();
        world2color();
        set(img,'cdata',color);
        pause(1/20);
    end
        
end


function update_world()

    global w;
    global h;
    global world;
    global tmp_world;

    fade = .85;

    for (i=1:h)

        row_min = mod((i-1)-1,h) + 1;
        row = i;
        row_max = mod((i-1)+1,h) + 1;
        
        for (j=1:w)

            col_min = mod((j-1)-1,w) + 1;
            col = j;
            col_max = mod((j-1)+1,w) + 1;
            
            sum = ceil(world(row_min,col_min)) + ceil(world(row_min,col)) + ceil(world(row_min,col_max)) + ...
                  ceil(world(row    ,col_min)) +                            ceil(world(row    ,col_max)) + ...
                  ceil(world(row_max,col_min)) + ceil(world(row_max,col)) + ceil(world(row_max,col_max));
            
            if (sum<2 && world(i,j)>0)
                tmp_world(i,j) = -.99;
            elseif (sum > 3 && world(i,j)>0)
                tmp_world(i,j) = -.99;
            elseif (sum==3 && world(i,j)<=0)
                tmp_world(i,j) = 1.0;
            else
            
                if (world(i,j) < 0)
                    tmp_world(i,j) = fade*world(i,j);
                    if abs(tmp_world(i,j))<.05
                        tmp_world(i,j)=0;
                    end
                else
                    tmp_world(i,j) = fade*world(i,j);
                end
            
                
            end
            
        end
    end

    world = tmp_world;
    
end

function world2color()

    global w;
    global h;
    global world;
    global color;

    live = [1.0,1.0,1.0];
    dead = [0.0,0.8,0.0];
    
    for (i=1:h)
        for (j=1:w)
            if world(i,j) > 0
                color(i,j,:) = live;
            else
                color(i,j,:) = abs(world(i,j))*dead;
            end
        end
    end
    
end