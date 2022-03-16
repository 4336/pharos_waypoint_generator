clear;clc;
%%
zoom_offset = 25;
refer_dist = 2;

x_o = 352300.; y_o = 4025400.;

%% load map file
% rmap=imread('C:\Users\Motion\Documents\MATLAB\1027_DaeGu\deagu_road_raw2.pgm');

rmap=imread('road_map_bit.pgm');
rmap=flip(rmap,1);

% vmap=imread('vmap.pgm');
% vmap1=flip(vmap,1);
%% map plotting
figure(1)
clf;

rx = [x_o, x_o+1000];
ry = [y_o, y_o+1200];

rim=image(rx,ry,rmap);
rim.AlphaData=0.5;

set(gca,'xdir','normal')
set(gca,'ydir','normal')
hold on
axis equal
% clear rx ry rmap
zoom on
%% plot high precision map
if exist('xy.mat', 'file')       %load node
    load('xy.mat')
    plot(xy(:,1),xy(:,2),'o-')
end

%% high precision node list plot

if exist('nodl.mat', 'file')       %load node
    load('nodl.mat')
    plot(nodl(:,1),nodl(:,2),'ro','MarkerSize',10)
    zoom on
end

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
num=0;
while 1
    zoom on
    delete(findobj('Color','m'))
%     switch input('Do you want to fix node position? (y/n) ','s')
    switch 'y'
        case {'y', 'Y'}
%             num = input('Input node number : ');
            num = num+1;
            while isempty(nodes(num,1))
                num = input('Input correct node number : ');
            end
            xlim([nodes(num,1)-zoom_offset, nodes(num,1)+zoom_offset]);
            ylim([nodes(num,2)-zoom_offset, nodes(num,2)+zoom_offset]);
            plot(nodes(num,1), nodes(num,2), 'sm')
            [x, y, b] = ginput(1);
            if b==3
                num=num-2;
            else

                taxi_dist = [0, 999];
                for i=1:length(nodl)
                    x_ = nodl(i,1);
                    y_ = nodl(i,2);
                    sum = abs(x-x_)+abs(y-y_);
                    if taxi_dist(2) > sum
                        taxi_dist = [i sum];
                    end
                end
                disp(taxi_dist)
                if taxi_dist(2) < 2
                    x = nodl(taxi_dist(1),1);
                    y = nodl(taxi_dist(1),2);
                end

                plot(x, y, 'sm')
                [~, ~, b] = ginput(1);
                if b == 1
                    nodes(num,:) = [x, y];
                    delete(node_plot)
                    node_plot = plot(nodes(:,1), nodes(:,2), 'rs', ...
                        'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
                end
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
% way = [];
zoom on;
if exist('drawn_way', 'var')
    delete(drawn_way)
end
if exist('way.mat', 'file')       %load node
    if input('Node information already exists....\ndo you want to use it? (y/n)','s')=='y'
        load('way.mat')
        broken = 1;
    else
        while 1
            if input('start drawing? (y/n) ','s')=='y'
                break
            end
        end
    end
else
    zoom on;
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
    way(i).plot = plot(way(i).points(:,1), way(i).points(:,2), ...
        '--sc', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'c');
end
%% draw trajectory
num = 1;
while num <= length(way)
    zooming(way(num).points,20)
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
    zooming(way(num).points, 30)
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
                        disp('broken')
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

%% use highprecision map for trajectory
if exist('linc.mat', 'file')
    load('linc.mat')
end

num=1;
delete(findobj('MarkerFaceColor','m'))
for i=1:length(way)
    plot(way(num).points(:,1),way(num).points(:,2),'sk-','MarkerFaceColor','m');

    while 1
        delete(findobj('MarkerFaceColor','m'))
        plot(way(num).points(:,1),way(num).points(:,2),'sk-','MarkerFaceColor','m');
        zooming(way(num).points(length(way(num).points)-1,:), 30)
        [x, y, b] = ginput(1);
        switch b
            case 1
                taxi_dist = [0, 999];
                for j=1:length(linc)
                    sum = abs(x-linc(j).xy(1,1))+abs(y-linc(j).xy(1,2));
                    if taxi_dist(2) > sum
                        taxi_dist = [j sum];
                    end
                end
                if taxi_dist(1)
                    way(num).points = [way(num).points(1:length(way(num).points)-1,:); ...
                                        linc(taxi_dist(1)).xy; ...
                                        way(num).points(length(way(num).points),:)];
                else
                    disp('too far')
                end
                
            case 2
                break;
                
            case 3
                if length(way(num).points)==2
                    num=num-1;
                else
                    way(num).points(length(way(num).points)-1,:)=[];
                end
            case 48
                [x, y, b] = ginput(1);
                taxi_dist = [0, 999];
                for j=1:length(linc)
                    sum = abs(x-linc(j).xy(1,1))+abs(y-linc(j).xy(1,2));
                    if taxi_dist(2) > sum
                        taxi_dist = [j sum];
                    end
                end
                if taxi_dist(1)
                    offset=b-48;
                    way(num).points = [way(num).points(1:length(way(num).points)-1,:); ...
                                            linc(taxi_dist(1)).xy(offset+1:length(linc(taxi_dist(1)).xy),:); ...
                                            way(num).points(length(way(num).points),:)];
                else
                    disp('too far')
                end
            case 96
                way(num).points = [way(num).points(1:length(way(num).points)-1,:); ...
                                            x, y; ...
                                            way(num).points(length(way(num).points),:)];

            otherwise
                taxi_dist = [0, 999];
                for j=1:length(linc)
                    sum = abs(x-linc(j).xy(1,1))+abs(y-linc(j).xy(1,2));
                    if taxi_dist(2) > sum
                        taxi_dist = [j sum];
                    end
                end
                if taxi_dist(1)
                    offset=b-48;
                    way(num).points = [way(num).points(1:length(way(num).points)-1,:); ...
                                            linc(taxi_dist(1)).xy(1:offset,:); ...
                                            way(num).points(length(way(num).points),:)];
                else
                    disp('too far')
                end
        end
    end
    num=num+1;
    delete(findobj('MarkerFaceColor','m'))
    plot(way(num).points(:,1),way(num).points(:,2),'sk-','MarkerFaceColor','m');
    zooming(way(num).points(1,:),20)
end
delete(findobj('MarkerFaceColor','m'))


%% road & lane info
delete(findobj('Color','r'))
road_number = 1;
road_type = 1;
way_number = 1;

while 1
    zooming(way(way_number).points, 20)
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

%% action info

delete(findobj('Color','r'))
action = 2;

way(1).action = action;
for num=1:length(way)
    if way(num).lane_number > 1
        way(num).action = action;
    else
        zooming(way(num).points, 20)
        if exist('h','var')
            delete(h)
        end
        h=plot(way(num).points(:,1),way(num).points(:,2),'--or');
        action = input('action = ');
        way(num).action = action;
    end
end
delete(h)


%% sign info

broken = 0;
refer_dist=2;
way(1).section_id=[];
way(1).light_id=[];
% section=[10010 10020 10030 10040 10050 10140 10160 10170 10180 10190 10200 10210 10220]';
section=[10010 10020 10030 10040 10050 10140 10160 10170 10180 10190 10200 10210 10220]';
for i=1:length(section)
    zoom on
    input('');
    [x y b] = ginput(1);
    section(i,2:3) = [x y];
end
    
%%
zoom on
hold on
i=4;
delete(findobj('Color','g'))
while i <= length(section)
    for num=1:length(way)
        if way(num).section_id==section(i,1)
            way(num).section_id=[];
        end
    end
    disp(['section ',num2str(section(i,1))])
    zooming(section(i,2:3),50)
    for j=1:4
        disp(['light',num2str(j)])
        [x y] = ginput();
        for k=1:length(x)
            for l=1:length(way)
                dist = pdist([x(k),y(k);way(l).points(1,1),way(l).points(1,2)],'euclidean');
                if dist<refer_dist
                    way(l).section_id = section(i,1)
                    way(l).light_id = j;
                    plot(way(l).points(:,1),way(l).points(:,2),'og-')
                    if way(l).road_type==4
                        break;
                    end
                end
            end
        end
    end
    disp('next?')
    [~, ~, b] = ginput(1);
    if length(b)
        switch b
            case 1
                i=i+1;
                disp('next section')
            case 2
                break;
            case 3
                if i > 1
                    i = i-1;
                end
        end
    else
        if i>length(section)
            disp('finish')
        else
            i=i+1;
            disp('next section')
        end
    end
end

for num=1:length(way)
    if ~length(way(num).section_id)
        way(num).section_id=0;
        way(num).light_id=0;
    end
end



%% road & lane check
number = 94 %road num
delete(findobj('Color','r'))
for num=1:length(way)
    if way(num).road_number == number
        plot(way(num).points(:,1),way(num).points(:,2),'--or')
        num
        disp(way(num).road_type)
        zooming(way(num).points, zoom_offset)
    end
end


%% road check
delete(findobj('Color','r'))
delete(findobj('LineWidth',5))
figure(1)
for num=1:length(way)
    plot(way(num).points(:,1),way(num).points(:,2),'-','LineWidth',5,'Color',[way(num).road_type/4,way(num).road_type/4,way(num).road_type/4])
end

%% lane check
delete(findobj('Color','r'))
delete(findobj('LineStyle','-'))
for num=1:length(way)
    plot(way(num).points(:,1),way(num).points(:,2),'-','LineWidth',5,'Color',[way(num).lane_number/3,way(num).lane_number/3,way(num).lane_number/3])
end

%% action check
delete(findobj('Color','r'))
for num=1:length(way)
    plot(way(num).points(:,1),way(num).points(:,2),'-','LineWidth',5,'Color',[way(num).action/3,way(num).action/3,way(num).action/3])
end


%% speed ref
for num=1:length(way)
    if way(num).action==2
        way(num).speed = 30;
    elseif (way(num).action==1 || way(num).action==3)
        way(num).speed = 20;
    end
end

%% speed check
delete(findobj('LineWidth',5))
for num=1:length(way)
    if way(num).lane_number==1
        plot(way(num).points(:,1),way(num).points(:,2),'-','LineWidth',5,'Color',[(way(num).speed==30),(way(num).speed==30),(way(num).speed==30)])
    end
end

%% +z
for num=1:length(way)
    way(num).points_3d = [way(num).points, zeros(length(way(num).points),1)];
end