clear;clc;
zoom_offset = 25;
refer_dist = 2;

map_origin_x= 352300.0; map_origin_y= 4025400.0;
%% load map file
rmap=imread('road_map_bit.pgm');
rmap=flip(rmap,1);

% vmap=imread('vmap.pgm');
% vmap1=flip(vmap,1);
%% map plotting
figure(1)
clf;

rx = [map_origin_x, map_origin_x+1000];
ry = [map_origin_y, map_origin_y+1200];

rim=image(rx,ry,rmap);
rim.AlphaData=0.5;

set(gca,'xdir','normal')
set(gca,'ydir','normal')
hold on
axis equal
% clear rx ry rmap
%% node position info import
delete(findobj('Color','r'))
if exist('nodes.mat', 'file')       %load node
    load('nodes.mat')
    clear('node_plot')
    node_plot = plot(nodes(:,1), nodes(:,2), 'rs', ...
        'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
    zoom on
else                                %draw node
    num = 1;
    nodes = [];
    % node position info
    while 1
        zoom on
        while 1
            fprintf('node %d : ',num)
            switch input('Do you want to draw node position? (y/n) ','s')
            case {'y', 'Y'}
                [x, y, b] = ginput(1);
                switch b
                    case 1
                        nodes(num,:) = [x, y];
                        disp(nodes(num,:))
                        num=num + 1;
                    case 2
                        num = num-1;
                        break
                    case 3
                        if num>1
                            num=num-1;
                            nodes=nodes(1:num-1,:);
                            disp('back')
                        end
                    otherwise
                        continue
                end
                if exist('node_plot', 'var')
                    delete(node_plot)
                end
                node_plot = plot(nodes(:,1), nodes(:,2), 'rs', ...
                        'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
                size(nodes)
                break
            case {'n', 'N'}
                break
            otherwise
                disp('Please input y or n')
            end
        end
            
    end
    fprintf('\nnumer of nodes are %d\n',num);
end
zoom on
%% fix node position
while 1
    zoom on
    delete(findobj('Color','m'))
    switch input('Do you want to fix node position? (y/n) ','s')
        case {'y', 'Y'}
            num = input('Input node number : ');
            while isempty(nodes(num,1))
                num = input('Input correct node number : ');
            end
            xlim([nodes(num,1)-zoom_offset, nodes(num,1)+zoom_offset]);
            ylim([nodes(num,2)-zoom_offset, nodes(num,2)+zoom_offset]);
            plot(nodes(num,1), nodes(num,2), 'sm')
            [x, y] = ginput(1);
            plot(x, y, 'sm')
            [~, ~, b] = ginput(1);
            if b == 1
                nodes(num,:) = [x, y];
                delete(node_plot)
                node_plot = plot(nodes(:,1), nodes(:,2), 'rs', ...
                    'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
            end
        case {'n', 'N'}
            break
        otherwise
            disp('Please input y or n')
    end
end        
%% node connection
delete(findobj('Color','c'))
num = 1;
broken = false;
start_node = 0;
finish_node = 0;
way = [];

if exist('drawn_way', 'var')
    delete(drawn_way)
end
if exist('way.mat', 'file')       %load node
    if input('Node information already exists....\ndo you want to use it? (y/n)','s')=='y'
        load('way.mat')
        for i=1:length(way)
            way(i).points(1,:) = nodes(way(i).start,:);
            way(i).points(2,:) = nodes(way(i).finish,:);
        end
        broken = 1;
    else
        while 1
            if input('start drawing? (y/n) ','s')=='y'
                break
            end
        end
    end
else
    zoom on
    while 1
        if input('start drawing? (y/n) ','s')=='y'
            break
        end
    end
end

while ~broken
    while ~start_node
        zoom on
        fprintf('road %d >>\n', length(way)+1)
        [x, y, b] = ginput(1);
        switch b
            case 1
                for i=1:length(nodes)
                    if (nodes(i,1)-x)^2+(nodes(i,2)-y)^2 < refer_dist
                        start_node = i;
                        break
                    end
                end
                if start_node
                    way(num).start = start_node;
                    way(num).points(1,:) = [nodes(start_node,1), nodes(start_node,2)];    
                    way(num).plot = plot(way(num).points(1,1),way(num).points(1,2), ...
                        'sc', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'c');
                    fprintf('start node %d --',start_node)
                end
            case 2
                broken = 1;
                break;
            case 3
                if num > 1
                    num = num - 1;
                    fprintf('clear the way from %d to %d\n', way(num).start, way(num).finish);
                    delete(way(num).plot)
                    way(num) = [];
                else
                    disp('no way left')
                end
        end
    end
    
    while start_node && ~finish_node
        [x, y, b] = ginput(1);
        switch b
            case 1
                for i=1:length(nodes)
                    if (nodes(i,1)-x)^2+(nodes(i,2)-y)^2 < refer_dist
                        if start_node == i
                            disp('choose another node')
                            fprintf('start node %d --',start_node)
                        else
                            finish_node = i;
                            break
                        end
                    end
                end
                if finish_node
                    way(num).finish = finish_node;
                    way(num).points(2,:) = nodes(finish_node,:);

                    delete(way(num).plot)
                    way(num).plot = plot(way(num).points(:,1), way(num).points(:,2), ...
                        '--sc', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'c');
                    fprintf('-->finish node %d\n', finish_node)

                end
            case 2
                delete(way(num).plot)
                way(num) = [];
                broken = 1;
                break;
            case 3
                if num > 1
                    delete(way(num).plot)
                    way(num) = [];
                end
                start_node = 0;
        end
    end
    if ~start_node || ~finish_node
        zoom on
        switch input('\ndrawing paused...will you resume? (y/n)','s')
            case {'y', 'Y'}
                broken = 0;
            otherwise
                disp('drawing finished')
        end
    else
        num = num + 1;
    end
    start_node = 0;
    finish_node = 0;
end
%% plot & save node connection info
delete(findobj('Color','c'))
for i=1:length(way)
    if isfield(way(i),'plot')
        delete(way(i).plot)
    end
    way(i).plot = plot(way(i).points(:,1), way(i).points(:,end), ...
        '--sc', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'c');
end
%% draw trajectory
num = 1;
while num <= length(way)
    zooming(way(num).points,zoom_offset)
    way(num).plot.Color = 'm';
    broken = 0;
    while ~broken
        zoom on
        fprintf('node %d to node %d\n', way(num).start, way(num).finish)
        delete(findobj('Color','g'))
        switch input('Do you want to fix trajectory? (y/n)','s')
            case {'y', 'Y'}
                way(num).points = way(num).points([1,length(way(num).points(:,1))],:);
                delete(way(num).plot)
                way(num).plot = plot(way(num).points(:,1),way(num).points(:,2), ...
                    '--sm', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'c');
                point_num = 1;
                
                while 1
%                   zooming2(way(num).points(point_num:point_num+1,:))
                    xlim([way(num).points(point_num,1)-zoom_offset, way(num).points(point_num,1)+zoom_offset])
                    ylim([way(num).points(point_num,2)-zoom_offset, way(num).points(point_num,2)+zoom_offset])
                    [x, y, b] = ginput(1);
                    if isempty(b)~=1
                        switch b
                            case 1
                                theta = atan2(y-way(num).points(length(way(num).points),2), ...
                                    x-way(num).points(length(way(num).points),1));

                                [x_tune, y_tune] = find_center(rim.CData, x, y, theta);
                                way(num).points = [way(num).points(1:point_num,:); x_tune, y_tune; ...
                                    way(num).points(length(way(num).points),:)];
                                delete(way(num).plot)
                                way(num).plot = plot(way(num).points(:,1), way(num).points(:,2), ...
                                    '--sm', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'c');

                                [~, ~, b] = ginput(1);
                                if b==3
                                    delete(way(num).plot)
                                    way(num).points = [way(num).points(1:point_num,:); x, y; ...
                                    way(num).points(point_num+2:length(way(num).points),:)];
                                    way(num).plot = plot(way(num).points(:,1), way(num).points(:,2), ...
                                    '--sm', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'c');
                                end
                                point_num = point_num+1;
                            case 2

                                way(num).plot.Color = 'c';
                                point_num = point_num-1;
                                broken = 1;
                                break
                            case 3
                                way(num).points(point_num,:) = [];
                                delete(way(num).plot)
                                way(num).plot = plot(way(num).points(:,1), way(num).points(:,2), ...
                                    '--sm', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'c');
                                if point_num > 1
                                    point_num = point_num-1;
                                end
                        end
                    end
                end
            case {'n', 'N'}
                way(num).plot.Color = 'c';
                break
                
            case {'b', 'B'}
                way(num).plot.Color = 'c';
                if num > 1
                    num = num - 2;
                else
                    num = num - 1;
                end
                break
                
            otherwise
                disp('Please input y or n')
        end
    end
    num = num+1;
end
delete(findobj('Color','g'))

%% choose trajectory & draw
broken = 0;
while ~broken
    num = input('which road will you draw?');
    zooming(way(num).points)
    way(num).plot.Color = 'm';
    zoom on
    fprintf('node %d to node %d\n', way(num).start, way(num).finish)
    delete(findobj('Color','g'))
    switch input('Do you want to fix trajectory? (y/n)','s')
        case {'y', 'Y'}
            way(num).points = way(num).points([1,length(way(num).points(:,1))],:);
            delete(way(num).plot)
            way(num).plot = plot(way(num).points(:,1),way(num).points(:,2), ...
                '--sm', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'c');
            point_num = 1;

            while 1
%                   zooming2(way(num).points(point_num:point_num+1,:))
                xlim([way(num).points(point_num,1)-zoom_offset, way(num).points(point_num,1)+zoom_offset])
                ylim([way(num).points(point_num,2)-zoom_offset, way(num).points(point_num,2)+zoom_offset])
                [x, y, b] = ginput(1);
                switch b
                    case 1
                        theta = atan2(y-way(num).points(length(way(num).points),2), ...
                            x-way(num).points(length(way(num).points),1));

                        [x_tune, y_tune] = find_center(rim.CData, x, y, theta);
                        way(num).points = [way(num).points(1:point_num,:); x_tune, y_tune; ...
                            way(num).points(length(way(num).points),:)];
                        delete(way(num).plot)
                        way(num).plot = plot(way(num).points(:,1), way(num).points(:,2), ...
                            '--sm', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'c');

                        [~, ~, b] = ginput(1);
                        if b==3
                            delete(way(num).plot)
                            way(num).points = [way(num).points(1:point_num,:); x, y; ...
                            way(num).points(point_num+2:length(way(num).points),:)];
                            way(num).plot = plot(way(num).points(:,1), way(num).points(:,2), ...
                            '--sm', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'c');
                        end
                        point_num = point_num+1;
                    case 2

                        way(num).plot.Color = 'c';
                        point_num = point_num-1;
                        broken=1;
                        break
                    case 3
                        way(num).points(point_num,:) = [];
                        delete(way(num).plot)
                        way(num).plot = plot(way(num).points(:,1), way(num).points(:,2), ...
                            '--sm', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'c');
                        if point_num > 1
                            point_num = point_num-1;
                        end
                end
            end
        case {'n', 'N'}
            way(num).plot.Color = 'c';
            break

        case {'b', 'B'}
            way(num).plot.Color = 'c';
            if num > 1
                num = num - 2;
            else
                num = num - 1;
            end
            break

        otherwise
            disp('Please input y or n')
    end
end
delete(findobj('Color','g'))

%% road & lane
delete(findobj('Color','r'))
road_number = 1;
road_type = 1;
way_number = 1;

while 1
    zooming(way(way_number).points,zoom_offset)
    if exist('h','var')
        delete(h)
    end
    h=plot(way(way_number).points(:,1),way(way_number).points(:,2),'--or');
    
    
    road_type = input('road_type = ');
    lane_counts = input('lane_counts = ');
    for i=1:lane_counts
        way(way_number+i-1).road_type = road_type;
        way(way_number+i-1).road_number = road_number;
        way(way_number+i-1).lane_number = i;
    end
    
    
    road_number = road_number+1;
    way_number = way_number+lane_counts;
end
delete(h)


%% road & lane check
number = 1
delete(findobj('Color','r'))
for num=1:length(way)
    if way(num).road_number == number
        plot(way(num).points(:,1),way(num).points(:,2),'--or')
        disp(way(num).road_type)
        zooming(way(num).points,zoom_offset)
    end
end

%%
num=3;
way(num).points = PointsInit(nodes, way, 10)

%%
function points = PointsInit(nodes, way, num)
    points = [nodes(way(num).start,:); nodes(way(num).finish,:)];
end
