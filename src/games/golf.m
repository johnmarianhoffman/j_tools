function golf(varargin)
% Simple infinite golf type game
    if ~isempty(varargin)        
        mode='debug';
    else
        mode='normal';
    end
    

% ASSETS ========================================

    global world;
    global screen;
    global background;
    global ball;
    global flag_gameover;
    global m_coord;
    global last_click;
    global state;
    global cursor;
    global flag_force_no_collision;
    global target
        
    % Enumerate states
    states.STABLE=0;
    states.EVOLVING=1;
    states.FIRING=2;
    
    state=states.EVOLVING;
    
    % Meta
    m_coord=[-1,-1];
    last_click=[-1,-1];    
    
    % world
    scale=100; % pixels per meter
    g=-9.8; 
    
    % Ball
    ball.start_pos=[50,250];
    ball.pos=ball.start_pos; % World coordinates (x,y)
    ball.prev_pos=ball.pos;    
    ball.velocity=[0,0];
    ball.radius=6;
    ball.bounce=0.4;
    ball.asset=false(2*ball.radius,2*ball.radius);
    ball.energy=0.5*sqrt(ball.velocity(1)^2+ball.velocity(2)^2);      
    coords=linspace(-ball.radius+.5,ball.radius-.5,2*ball.radius);
    for i=1:2*ball.radius
        for j=1:2*ball.radius
            if coords(i)^2+coords(j)^2<ball.radius^2
                ball.asset(i,j)=true;
            end
        end
    end   
    
    % Colors
    colors.sky          =uint8([214, 192, 141]);
    colors.ground       =uint8([219, 109, 0]  );
    colors.ball         =uint8([255, 251, 244]);
    colors.border       =uint8([0  ,   0, 0]  );
    
    % Flags
    flag_gameover = false;
   
    % Sizes
    sizes.target_width = 20;
    sizes.target_depth = 40;
    
    sizes.border_size  =  30;
    sizes.world_width   = 1000;
    sizes.world_height  = 500;
    
    sizes.screen_width      =  sizes.world_width +2*sizes.border_size;
    sizes.screen_height     =  sizes.world_height+2*sizes.border_size;

    % Buffers
    world             = zeros(sizes.world_height,sizes.world_width);
    screen            = uint8(zeros(sizes.screen_height,sizes.screen_width,3));
    background        = uint8(zeros(sizes.screen_height,sizes.screen_width,3));   
    
    % Image objects
    f=figure(5);
    set(f,'WindowButtonDownFcn',@click_callback,'WindowKeypressFcn',@keypress_callback,'CloseRequestFcn',@close_callback,'WindowButtonMotionFcn',@mouse_move_callback,'ResizeFcn',@resize_callback);
    ax=axes('parent',f);
    set(ax,'units','normalized','position',[0 0 1 1]);
    set(ax,'units','pixels');
    img=imshow(screen,'parent',ax);
    diagnostic_overlay=text(20,20,'Framerate: ');
    set(diagnostic_overlay,'color','green');
    
    handles.ax=ax;
    handles.img=img;
    handles.diagnostic_overlay=diagnostic_overlay;
    guidata(f,handles);    

    % Initialize world and screen
    %for i=1:sizes.world_width
    %    for j=1:sizes.world_height
    %        if j>sizes.world_height/4
    %            world(j,i)=1;
    %        else
    %            world(j,i)=2;
    %        end
    %    end
    %end
    generate_map(sizes);    
    target=generate_target(sizes);  
    initialize_screen(colors,sizes);
    background=screen;
    
    % Cursor
    cursor.radius=14;
    cursor.asset=false(2*cursor.radius,2*cursor.radius);
    cursor.stable_color=uint8([33 33 33]);
    cursor.active_color=uint8([239,239,239]);
    cursor.unavailable_color=uint8([160, 152, 138]);
    cursor.pos=m_coord;
    cursor.mouse_line=line([cursor.pos(1) last_click(1)],[cursor.pos(2) last_click(2)],'parent',ax,'color',cursor.active_color,'linestyle','--');
    cursor.firing_line=line([cursor.pos(1) last_click(1)],[cursor.pos(2) last_click(2)],'parent',ax,'color',cursor.active_color);

    coords=linspace(-cursor.radius+.5,cursor.radius-.5,2*cursor.radius);
    for i=1:2*cursor.radius
        for j=1:2*cursor.radius
            if (coords(i)^2+coords(j)^2<cursor.radius^2) && (coords(i)^2+coords(j)^2>((cursor.radius-2)^2))
                cursor.asset(i,j)=true;
            end
        end
    end   
    
          
    
    % Game loop
    counter=0;
    idle_counter=0;
    timeout=60*60;
    time=0;
    while ~flag_gameover

        % TIMING ========================================
        t=tic;
        pause(1/60)
        counter=counter+1;
        if mod(counter,15)==0
            set(diagnostic_overlay,'string',sprintf('Framerate:  %.2f fps | Mouse: %d,%d | State: %d',1/time,round(m_coord(1)),round(m_coord(2)),state));
        end
        
        if state==states.STABLE
            idle_counter=idle_counter+1;            
            if idle_counter==timeout
                flag_gameover=true;
            end
        else 
            idle_counter=0;
        end

        % STATE MACHINE =========================================        
        switch state
            case states.STABLE
                cursor.pos=m_coord;
                cursor.pos(2)=sizes.screen_height-m_coord(2);
                
                % Check for win condition (ONLY IF STABLE)
                if norm(ball.pos-target.pos)<2*ball.radius
                    new_board(colors,sizes);
                end
                
                
            case states.EVOLVING
                cursor.pos=m_coord;
                cursor.pos(2)=sizes.screen_height-m_coord(2);
            case states.FIRING                 
        end
                          
        % LOGIC =========================================

        % Ball kinematics
        if state==states.EVOLVING
            % Compute theoretical update
            tmp_prev_pos=ball.pos;
            tmp_velocity=[ball.velocity(1),ball.velocity(2)+time*g*scale];
            tmp_pos=ball.pos+tmp_velocity*time;
            
            % Collision detection
            if flag_force_no_collision
                collision_flag=false;
                flag_force_no_collision=false;
            else
                [collision_flag,type,normal]=is_collision(sizes,tmp_pos);
            end
            
            if collision_flag
                if type==1
                    ball.prev_pos=ball.prev_pos;
                    ball.velocity= ball.bounce*(ball.velocity-2*dot(ball.velocity,normal)*normal);
                    if isnan(ball.velocity)
                        ball.velocity=[0,0];
                    end
                    ball.pos=ball.pos+ball.velocity*time;
                    
                    if norm(ball.velocity)<2
                        ball.velocity=[0,0];
                        state=states.STABLE;
                    end
                elseif type==2
                    ball.pos=ball.start_pos;
                    ball.prev_pos=ball.start_pos;
                    ball.velocity=[0,0];
                end
            else
                ball.prev_pos=tmp_prev_pos;
                ball.pos=tmp_pos;
                ball.velocity=tmp_velocity;
            end
        end
        
        % RENDER ========================================
        render_frame(colors,sizes);
        set(img,'cdata',flipud(screen));
        
        if isequal(mode,'normal')
            time=toc(t);
        else
            time=1/60;
        end
        
        
        
    end
    
    delete(f);
end

function initialize_screen(colors,sizes)

global world;
global screen;

offset=sizes.border_size;

% Map world into screen buffer
for i=1:sizes.world_width
    for j=1:sizes.world_height
        
        if world(j,i)==0 % Border
            screen(offset+j,offset+i,:)=colors.border;
        elseif world(j,i)==1 % Sky
            screen(offset+j,offset+i,:)=colors.sky;
        elseif world(j,i)==2 % Ground
            screen(offset+j,offset+i,:)=colors.ground;
        else
            % nothing
        end
        
    end
end
end

function render_frame(colors,sizes)

global world;
global background;
    global screen;
    global ball;
    global m_coord;
    global cursor;
    global state;
    global last_click;
    
    % Redraw background
    screen=background;
    
    % Draw ball
    x_offset_screen=round(ball.pos(1))+sizes.border_size-ball.radius+1;
    y_offset_screen=round(ball.pos(2))+sizes.border_size-ball.radius+1;
    x_offset_world=round(ball.pos(1))-ball.radius;
    y_offset_world=round(ball.pos(2))-ball.radius;
        
    for i=1:2*ball.radius
        for j=1:2*ball.radius
            if ball.asset(j,i)
                if (i+x_offset_world>sizes.world_width)||(i+x_offset_world<1)||...
                        (j+y_offset_world>sizes.world_height)||(j+x_offset_world<1)                    
                    continue;
                end

                screen(j+y_offset_screen,i+x_offset_screen,:) = colors.ball;
            end
        end
    end  
    
    % Draw cursor
    x_offset_screen=round(cursor.pos(1))-cursor.radius;
    y_offset_screen=round(cursor.pos(2))-cursor.radius;
    
    for i=1:2*cursor.radius
        for j=1:2*cursor.radius
            if cursor.asset(j,i)
                if (i+x_offset_screen>sizes.screen_width)||(i+x_offset_screen<1)||...
                        (j+y_offset_screen>sizes.screen_height)||(j+y_offset_screen<1)                    
                    continue;
                end

                if state==2
                    screen(j+y_offset_screen,i+x_offset_screen,:) = cursor.active_color;
                elseif state==0
                    screen(j+y_offset_screen,i+x_offset_screen,:) = cursor.stable_color;                    
                elseif state==1
                    screen(j+y_offset_screen,i+x_offset_screen,:) = cursor.unavailable_color;                    
                end
                                        
            end
        end
    end
    
    % Bedazzle cursor if active
    if state==2
        set(cursor.mouse_line,'visible','on');        
        set(cursor.mouse_line,'xdata',[last_click(1) m_coord(1)],'ydata',[last_click(2) m_coord(2)])        
        
        set(cursor.firing_line,'visible','on');        
        mouse_vec=m_coord-last_click;
        target_point=last_click-mouse_vec;
        line_thickness=min(max(norm(target_point-last_click)/50,0.25),4);
        set(cursor.firing_line,'xdata',[last_click(1) target_point(1)],'ydata',[last_click(2) target_point(2)],'linewidth',line_thickness);
    else
        set(cursor.mouse_line,'visible','off');        
        set(cursor.firing_line,'visible','off');        
    end
    
end

function [tf,type,normal]=is_collision(sizes,pos)
    global world
    global ball

    tf=false;
    type=0;
    normal=[0,0];

    x_offset_world=round(pos(1))-ball.radius;
    y_offset_world=round(pos(2))-ball.radius;
                
    % Scan over each element of the asset in the new position to see if there's ground
    for i=1:2*ball.radius
        for j=1:2*ball.radius
            % Collision with edge of world                        
            if (j+x_offset_world>sizes.world_width)||(j+x_offset_world<1)
                tf=true;
                type=2;
                return;
            end 
            
            % Above the type of the visible world
            if (i+y_offset_world>sizes.world_height)
                tf=false;
                type=0;
                return;
            end
            
            % Collision with ground
            if (ball.asset(i,j)==1) && (world(i+y_offset_world,j+x_offset_world)~=1)                
                tf=true;
                type=1;

                % Compute normal
                n_samples=20;
                for ii=1:n_samples
                    angle=2*(ii-1)*pi/n_samples;
                    x=ball.radius*cos(angle)+pos(1);
                    y=ball.radius*sin(angle)+pos(2);
                    if world(round(y),max(round(x),1))==2
                        v=pos-[x,y];
                        normal=normal+v;
                    end                    
                end
                normal=-normal/norm(normal);
                return
            end        
        end
    end
end

function target=generate_target(sizes)

global world

% Pick a location within the right half of the screen
col=randi([sizes.world_width/2+1,sizes.world_width],1,1);
for i=sizes.world_height:-1:1
    if world(i,col)==2;
        row=i;
        break;
    end    
end

target.pos=[col,row+1];

% Add target to map
for i=1:sizes.target_width
    for j=1:sizes.target_depth
        world(target.pos(2)-j,i+target.pos(1)-sizes.target_width/2)=1;
    end
end

target.pos(2)=target.pos(2)-sizes.target_depth;

end

function click_callback(h,e)
    global ball
    global state
    global m_coord
    global last_click
    global flag_force_no_collision
    
    if state==1 % Evolving, ignore mouse clicks
        return;
    elseif state==0 % Store coordinates for further evaluation
        last_click=m_coord;
        state=2;
    elseif state==2 % Firing, use current point and last point to compute velocity vector
        ball.velocity=5*(m_coord-last_click);
        ball.velocity=-ball.velocity;
        flag_force_no_collision=true;
        ball.velocity(2)=-ball.velocity(2); % flip since y axis inverted        
        state=1;
    end
end
function keypress_callback(h,e)
global flag_gameover;
if isequal(e.Character,'q')
    flag_gameover=true;
end
end
function close_callback(h,e)
global flag_gameover;
flag_gameover=true;
end
function mouse_move_callback(h,e)
global m_coord
global cursor
global state
p=get(gca,'CurrentPoint');
if p(1,3)==1
    m_coord=[p(1,1),p(1,2)];
else
    m_coord=[-1,-1];
end
end
function resize_callback(h,e)
handles=guidata(h);
set(handles.ax,'units','normalized','position',[0 0 1 1]);

end

function generate_map(sizes)

    global world;

    variation_factor=4; % Increasing this will make more bumps

    slopes=[0 15 30 45 60 75];
    
    max_height=round(5/8*sizes.world_height);
    min_height=round(1/8*sizes.world_height);

    x=1;
    y=round(sizes.world_height/8);      
    
    while x<sizes.world_width
        
        % Grab a slope
        if x<sizes.world_width/8
            m=0;
        else
            n=randi([1,numel(slopes)],1,1);
            m=tand(slopes(n));
            if randi([0,1],1,1)
                m=-m;
            end
        end
        
        % Grab a run
        run = randi(round(sizes.world_width/variation_factor),1,1);
        
        % Compute the target point
        % y=mx+b b=y-mx
        b=y-m*x;
        line=@(x) m*x+b;
                
        offset=x;
        for i=1:run
            curr_col=i+offset;
            curr_height=min(max(line(i+offset),min_height),max_height);
            col=1:sizes.world_height;
            
            ground=(col<=curr_height);
            sky=(col>curr_height);
            
            col(ground)=2;
            col(sky)=1;
            
            world(:,i+x)=col;            
            
        end        
        x=offset+run;
        y=min(max(line(i+offset),min_height),max_height);
    end


end
function new_board(colors,sizes)

global ball
global background
global target
global screen
global state

% Reset the map
generate_map(sizes);
target=generate_target(sizes);
initialize_screen(colors,sizes);
background=screen;

% Reset the ball
ball.pos=ball.start_pos;
ball.velocity=[0,0];

% Set state to evolving
state=1;
end