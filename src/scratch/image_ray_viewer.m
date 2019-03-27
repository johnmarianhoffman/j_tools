function image_ray_viewer(data,confidence_map,depth_map)

global handles;
    
if nargin < 1
    %handles.filepath = '/la/Users/MAGICLEAP/jhoffman/john_farm_output/final_test_rsc_spotlight/image_rays/f001003_camRef51_camComp52.imgrays';
    handles.filepath = '/la/Users/MAGICLEAP/jhoffman/john_farm_output/final_test_rsc_spotlight/image_rays/f001003_camRef27_camComp28.imgrays';    
    handles.rays = image_ray_loader(handles.filepath);
    assignin('base','rays',handles.rays);
elseif nargin<2
    handles.rays = data;
else
    handles.rays = data;
    handles.confidence_map = confidence_map;
end

handles.rays.data = handles.rays.data';

handles.rays.data{1,1}.start_depth = -10000;
handles.rays.data{1,1}.step_size = 100;
handles.rays.data{1,1}.ray_length = 100;
handles.rays.data{1,1}.data = [1:100];

% Compute the boundary mask and a confidence map
image_ray_boundary_mask = false(size(handles.rays.data));
if (nargin<2)
    handles.confidence_map = zeros(size(handles.rays.data));
else
    handles.confidence_map = confidence_map;
end

%for i = 1:numel(image_ray_boundary_mask)
%    
%    if mod(i,4096)==0
%        fprintf('Row %d/%d\n',i/4096,3000);
%    end
%    
%    if ~isempty(handles.rays.data{i})
%        image_ray_boundary_mask(i) = true;
%        
%        if (nargin<2)
%            confidence_map(i) = confidence(handles.rays.data{i});
%        end
%    end
%end

if (nargin<2)
    assignin('base','confidence_map',confidence_map);
    save('~/Desktop/confidence_map_test.mat','confidence_map','-v7.3');    
end

handles.rows = 4096;
handles.cols = 3000;

%handles.img_path = '~/Desktop/depth_map_51.bin';
%handles.img_path = '~/Desktop/depth_map_18.bin';
%handles.image = j_bin_float(handles.img_path);
%handles.image = reshape(handles.image,[handles.rows,handles.cols]);
handles.image = depth_map;
assignin('base','depth',handles.image);

tmp = handles.image(handles.image~=0);
mini = min(tmp(:));
maxi = max(tmp(:));

handles.f = figure;
handles.box = uiextras.HBox('parent',handles.f);
handles.ax_img = axes('parent',handles.box);
handles.ax_ray = axes('parent',handles.box);

% Draw the image, image ray boundary, and confidence map
handles.img = imshow(imoverlay(j_imrescale(handles.image,[mini-200,maxi+200],'uint8'),boundarymask(image_ray_boundary_mask)),[],'parent',handles.ax_img);
hold(handles.ax_img,'on');
handles.img_confidence_map = imshow(confidence_to_rgb(handles.confidence_map),'parent',handles.ax_img);
hold(handles.ax_img,'off');

alpha = (1-confidence_map); % Good guess are invisible, bad guesses are visible
set(handles.img_confidence_map,'AlphaData',alpha.*(handles.confidence_map>0));
handles.curr_point = [handles.cols/2,handles.rows/2];
handles.point = impoint(handles.ax_img,handles.curr_point(1),handles.curr_point(2));

% Draw the ray plot, minima overlay, and auxiliary plot (second derivate)
handles.plt_handle = plot(handles.ax_ray,1:10,linspace(-1.0,0,10));
hold(handles.ax_ray,'on');
handles.plt_min_handle = scatter(handles.ax_ray,1:10,linspace(-1.0,0,10),'r*');
handles.plt_aux_handle = plot(handles.ax_ray,1:10,linspace(-1.0,0,10),'r');
hold(handles.ax_ray,'off');

handles.info_text = text(handles.image(handles.curr_point(2),handles.curr_point(1)),-.1,sprintf("Depth: %.2f",handles.image(handles.curr_point(2),handles.curr_point(1))));

set(handles.ax_ray,'ylimmode','manual');
set(handles.ax_ray,'ylim',[-1 0]);

curr_ray = handles.rays.data{handles.curr_point(1),handles.curr_point(2)};

if ~isempty(curr_ray)
    x = curr_ray.start_depth:curr_ray.step_size:curr_ray.step_size*(curr_ray.ray_length-1);
    y = curr_ray.data;
else
    x = [];
    y = [];
end
set(handles.plt_handle,'xdata',x,'ydata',y);

set(handles.f,'windowkeypressfcn',@keypress_callback);
handles.point.addNewPositionCallback(@point_moved_callback);


guidata(handles.f,handles);
end

function keypress_callback(h,e)
    global handles;    
    pos = getPosition(handles.point);
    switch e.Key
      case 'uparrow'
        setConstrainedPosition(handles.point,pos+[0,-1]);
      case 'downarrow'
        setConstrainedPosition(handles.point,pos+[0,1]);        
      case 'rightarrow'
        setConstrainedPosition(handles.point,pos+[1,0]);                
      case 'leftarrow'
        setConstrainedPosition(handles.point,pos+[-1,0]);
      case 'space'
        if (~isempty(e.Modifier) && strcmp(e.Modifier{1},'shift'))
            % Jump window to impoint
            xlim = get(handles.ax_img,'xlim');
            ylim = get(handles.ax_img,'ylim');

            xrange = xlim(2)-xlim(1);
            yrange = ylim(2)-ylim(1);
            
            set(handles.ax_img,'xlim',[pos(1)-xrange/2,pos(1)+xrange/2]);
            set(handles.ax_img,'ylim',[pos(2)-yrange/2,pos(2)+yrange/2]);                        
            
        else
            % Jump point to current window
            xlim = get(handles.ax_img,'xlim');
            ylim = get(handles.ax_img,'ylim');
            setConstrainedPosition(handles.point,[mean(xlim) mean(ylim)]);
        end

      case 'j'
        prompt = {'X:','Y:'};
        name = 'Jump to position';
        numlines = 1;        
        answer = inputdlg(prompt,name,numlines,{'',''});
        x = str2double(answer{1});
        y = str2double(answer{2});

        if (isempty(x) || isempty(y))
            return;
        end
        
        setConstrainedPosition(handles.point,[x y]);

        % Jump window to impoint
        xlim = get(handles.ax_img,'xlim');
        ylim = get(handles.ax_img,'ylim');

        xrange = xlim(2)-xlim(1);
        yrange = ylim(2)-ylim(1);

        pos = getPosition(handles.point);

        set(handles.ax_img,'xlim',[pos(1)-xrange/2,pos(1)+xrange/2]);
        set(handles.ax_img,'ylim',[pos(2)-yrange/2,pos(2)+yrange/2]);
        
    end
end

function point_moved_callback(pos)

    global handles

    handles.curr_point = round(pos(1:2));
    %setConstrainedPosition(handles.point,handles.curr_point);

    ray = handles.rays.data{handles.curr_point(2),handles.curr_point(1)};
    if ~isempty(ray)
        x = ray.start_depth + [0:ray.step_size:(ray.ray_length-1)];
        y = ray.data';

        c = confidence(ray);

        % Preprocess the data
        y = smooth(smooth(y))';

        set(handles.plt_handle,'xdata',x,'ydata',y);

        [global_min,loc] = min(y(:));
        tf = islocalmin(y);
        set(handles.plt_min_handle,'xdata',[x(loc) x(tf)],'ydata',[y(loc) y(tf)]);

        der2 = gradient(gradient(y));
        der2 = 10*der2 - .5;
        der2 = smooth(smooth(der2));

        set(handles.plt_aux_handle,'xdata',x,'ydata',der2);

        % update the text
        xlims = get(handles.ax_ray,'xlim');
        ylims = get(handles.ax_ray,'ylim');
        xrange = xlims(2) - xlims(1);
        yrange = ylims(2) - ylims(1);
        xpos = xlims(1) + 0.1*xrange;
        ypos = ylims(1) + 0.1*yrange;
        
        s = sprintf('Depth: %.3f\nConfidence: %.5f\nPosition: %s',handles.image(handles.curr_point(2),handles.curr_point(1)),handles.confidence_map(handles.curr_point(2),handles.curr_point(1)),mat2str(round(pos)));
        set(handles.info_text,'position',[xpos ypos],'string',s);
    else
        x = [];
        y = [];        
    end
    %guidata(handles.f,handles);
end

function c = confidence(ray)
    ray = ray.data;
    if isempty(ray)
        c = 0.0;
        return;
    end

    tau_threshold = 0.05;
    beta = 1750;

    % Preprocess the ray
    ray = smooth(smooth(ray))';

    % Find local minima 
    [global_min,loc] = min(ray(:));
    tf = islocalmin(ray);
    mins = [ray(tf) global_min];

    % Reject minima not within threshold
    mins(abs(global_min-mins) > tau_threshold) = [];
    mins = unique(mins);

    % Compute the second derivative
    der2 = gradient(gradient(ray));

    % Compute the final confidence
    c = (1-exp(-beta*der2(loc)))/numel(mins);

    % Confidence can sometime be <0 (indicating local curvature negative)
    % My first thought is that this likely implies that we're not at
    % the true minimum, meaning the depth value is likely imperfect and should
    % not be very confident.  That being said, I've observed cases where this
    % would throw away depths that are very good, just have a weird undulation
    % right at the edge. This is a heuristic that will keep depth around however.
    % express the because we're right on the edge, in general we don't have enough
    % information to determine if this is good depth or bad depth.
    if (c<=0 && (loc==1))
        c = 0.5;
    end

    % If we're too close the right boundary of the image ray, we need to get that
    % measurement from a different depth map. Penalize it heavily.
    if (loc>=numel(ray)-0.1*numel(ray))
        c = 0.0001;
    end

    %fprintf('====================\n');
    %disp(loc);
    %disp(der2(loc));
    %disp(numel(mins));
    %disp(c);
end

function map = stoplight(length)

if nargin < 1
    length = size(get(gcf,'colormap'),1);
end

h = (0:length-1)' / (length-1) / 3;

if isempty(h)
	map = [];
else
	map = hsv2rgb([h ones(length, 1) repmat(.9, length, 1)]);
end

end

function rgb = confidence_to_rgb(confidence_map)
    map = stoplight(1024);
    rgb = zeros([size(confidence_map) 3]);
    
    for j = 1:size(confidence_map,2)
        for i = 1:size(confidence_map,1)        
            if confidence_map(i,j)==0
                continue
            else
                colorID = max(1, sum(confidence_map(i,j) > [0:1/length(map(:,1)):1]));
                rgb(i,j,:) = map(colorID,:);
            end
        end
    end    
end

function s = generate_text_string()
    
end