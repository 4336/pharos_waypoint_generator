
%% -------------- Interpolation ------------------------------------------
for num=1:length(way)
% way(num).eq_wp = way(num).Eq_interval;
way(num).eq_wp = way(num).wp_utm;

multiply = 3; % multiply�� interpolation

way(num).interpolated_wp = zeros((size(way(num).eq_wp,1)-1)*multiply,2);


for i=1:size(way(num).eq_wp,1)-1
    for j=1:multiply
        way(num).interpolated_wp((i-1)*multiply+j,1) = way(num).eq_wp(i,1) + (j-1)*(way(num).eq_wp(i+1,1) - way(num).eq_wp(i,1))/multiply;
        way(num).interpolated_wp((i-1)*multiply+j,2) = way(num).eq_wp(i,2) + (j-1)*(way(num).eq_wp(i+1,2) - way(num).eq_wp(i,2))/multiply;
        way(num).interpolated_wp((i-1)*multiply+j,3) = way(num).eq_wp(i,3) + (j-1)*(way(num).eq_wp(i+1,3) - way(num).eq_wp(i,3))/multiply;
    end
end

% waypoint �� ��հŸ�check
total_dist=0;
for i=1:size(way(num).interpolated_wp,1)-1
    distance = sqrt((way(num).interpolated_wp(i+1,2)-way(num).interpolated_wp(i,2))^2 + (way(num).interpolated_wp(i+1,1)-way(num).interpolated_wp(i,1))^2);
    total_dist = total_dist + distance;
end
wp_dist_avg = total_dist / (size(way(num).interpolated_wp,1)-1);

end
%% plot
figure(1)
delete(findobj('Color','b'))
for i=1:length(way)
    plot(way(i).interpolated_wp(:,1)-map_origin_x, way(i).interpolated_wp(:,2)-map_origin_y,'--ob');
end

%% ----------------  SG Smoothing  ------------------------------------
for num=1:length(way)

sg_dots = 15;  % smoothing ����. have to be odd (Ȧ��)

front_trim = 10;
end_trim = 10;

[xg0, xg1, xg2] = sg_smooth(2, sg_dots, way(num).interpolated_wp(:, 1));
[yg0, yg1, yg2] = sg_smooth(2, sg_dots, way(num).interpolated_wp(:, 2));
[zg0, zg1, zg2] = sg_smooth(2, sg_dots, way(num).interpolated_wp(:, 3));

wp = cat(2, xg0, yg0, zg0, xg1, yg1, zg1, xg2, yg2, zg2);   

%wp = wp(round(sg_dots / 2 + 1) + front_trim: end-end_trim, :);   

wp = wp(round(sg_dots / 3 + 1): end, :);

%curvature
way(num).curv = calc_curvature_d(wp(:, 5), wp(:,8), wp(:,4), wp(:,6));

way(num).smooth_wp = [wp(:,1) wp(:,2) wp(:,3)];

end
%% Cutting zero
for num=1:length(way)
while way(num).smooth_wp(1:1)==0.0
    way(num).smooth_wp(1,:)=[];
end
end
%% -------------- Interpolation(by length) ------------------------------------------
way(1).interpolated_wp_2 = [];
for num=1:length(way)
% way(num).eq_wp = way(num).Eq_interval;
way(num).eq_wp_2 = way(num).smooth_wp;

multiply = 1; % multiply�� interpolation


for i=1:size(way(num).eq_wp_2,1)-1
    multiply = 5 * round(sqrt((way(num).eq_wp_2(i+1,1)-way(num).eq_wp_2(i,1))^2 ...
        +(way(num).eq_wp_2(i+1,2)-way(num).eq_wp_2(i,2))^2));
    for j=1:multiply
        way(num).interpolated_wp_2(length(way(num).interpolated_wp_2)+1,1) ...
            = way(num).eq_wp_2(i,1) ...
                + (j-1)*(way(num).eq_wp_2(i+1,1) - way(num).eq_wp_2(i,1))/multiply;
        way(num).interpolated_wp_2(length(way(num).interpolated_wp_2),2) ...
            = way(num).eq_wp_2(i,2) ...
                + (j-1)*(way(num).eq_wp_2(i+1,2) - way(num).eq_wp_2(i,2))/multiply;
        way(num).interpolated_wp_2(length(way(num).interpolated_wp_2),3) ...
            = way(num).eq_wp_2(i,3) ...
                + (j-1)*(way(num).eq_wp_2(i+1,3) - way(num).eq_wp_2(i,3))/multiply;
    end
end
way(num).interpolated_wp_2(length(way(num).interpolated_wp_2)+1,:) ...
    = way(num).eq_wp_2(i,:);
way(num).interpolated_wp_2(2:3,:)=[];

% waypoint �� ��հŸ�check
total_dist=0;
for i=1:size(way(num).interpolated_wp_2,1)-1
    distance = sqrt((way(num).interpolated_wp_2(i+1,2)-way(num).interpolated_wp_2(i,2))^2 + (way(num).interpolated_wp_2(i+1,1)-way(num).interpolated_wp_2(i,1))^2);
    total_dist = total_dist + distance;
end
wp_dist_avg = total_dist / (size(way(num).interpolated_wp_2,1)-1);

end

%% ------- Equal interval ����Ʈ�鸸 ���� ---------------------------
for num=1:length(way)
interval = 0.5; %0.5m
way(num).Eq_interval = [way(num).interpolated_wp_2(1,1) way(num).interpolated_wp_2(1,2) way(num).interpolated_wp_2(1,3)];

i=1;
k=1;

while i < length(way(num).wp_utm)-1
    dist=0;
    x1 = way(num).wp_utm(i,1); y1 = way(num).wp_utm(i,2); z1 = way(num).wp_utm(i,3);
    j=1;
    while dist < interval
        x2 = way(num).wp_utm(i+j,1);
        y2 = way(num).wp_utm(i+j,2);
        z2 = way(num).wp_utm(i+j,3);
        dist = sqrt((x2-x1)^2 + (y2-y1)^2);
        j=j+1;
        if i+j == length(way(num).wp_utm)
            break;
        end
    end
    x0 = way(num).wp_utm(1,1);
    y0 = way(num).wp_utm(1,2);
    z0 = way(num).wp_utm(1,3);
    dist2 = sqrt((x2-x0)^2 + (y2-y0)^2);
    if i > length(way(num).wp_utm)/2
%         if dist2 < 1
%             break;
%         end
    end
    if i+j == length(way(num).wp_utm)
        break;
    end
    
    way(num).Eq_interval = [way(num).Eq_interval; x2 y2 z2];
    
    i=i+j;
end
end
%% ----------------  SG Smoothing_2 ------------------------------------
for num=1:length(way)

sg_dots = 15;  % smoothing ����. have to be odd (Ȧ��)

front_trim = 10;
end_trim = 10;

[xg0, xg1, xg2] = sg_smooth(2, sg_dots, way(num).interpolated_wp_2(:, 1));
[yg0, yg1, yg2] = sg_smooth(2, sg_dots, way(num).interpolated_wp_2(:, 2));
[zg0, zg1, zg2] = sg_smooth(2, sg_dots, way(num).interpolated_wp_2(:, 3));

wp = cat(2, xg0, yg0, zg0, xg1, yg1, zg1, xg2, yg2, zg2);   

%wp = wp(round(sg_dots / 2 + 1) + front_trim: end-end_trim, :);   

wp = wp(round(sg_dots / 3 + 1): end, :);

%curvature
way(num).curv_2 = calc_curvature_d(wp(:, 5), wp(:,8), wp(:,4), wp(:,6));

way(num).smooth_wp_2 = [wp(:,1) wp(:,2) wp(:,3)];

end
%% plot
figure(1)
delete(findobj('Color','k'))
for i=1:length(way)
    plot(way(i).smooth_wp_2(:,1)-map_origin_x, way(i).smooth_wp_2(:,2)-map_origin_y,'--ok');
end


%% -------------  Road information -------------------------------------
for num=1:length(way)
way(num).road_info = [way(num).smooth_wp_2(:,1) way(num).smooth_wp_2(:,2) way(num).smooth_wp_2(:,3) way(num).curv_2(:,1)];

end
%% Cutting zero
for num=1:length(way)
while way(num).road_info(1:1)==0.0
    way(num).road_info(1,:)=[];
end
end
%% plot
figure(1)
delete(findobj('Marker','o'))
for i=1:length(way)
    plot(way(i).road_info(:,1)-map_origin_x, way(i).road_info(:,2)-map_origin_y,'--og');
end

%% ---------------- File Printing ---------------------------------
for num=1:length(way)
wp_file=fopen(strcat(num2str(way(num).start,'%03d'),num2str(way(num).finish,'%03d'),'.txt'),'w');
for i=1:length(way(num).road_info)
    fprintf(wp_file,'%f %f %f %f\n',way(num).road_info(i,1),way(num).road_info(i,2),way(num).road_info(i,3),way(num).road_info(i,4));
end
fclose(wp_file);

end
%% ---------------- File Printing_merged ---------------------------------
wp_file=fopen(strcat('merged_wp.txt'),'w');
for num=length(way):-1:1
    for i=1:length(way(num).road_info)
        fprintf(wp_file,'%f %f %f %f\n',way(num).road_info(i,1),way(num).road_info(i,2),way(num).road_info(i,3),way(num).road_info(i,4));
    end
end
fclose(wp_file);
%% Plotting
for num=1:length(way)
figure(2)
plot(way(num).wp_utm(1:length(way(num).wp_utm),1), way(num).wp_utm(1:length(way(num).wp_utm),2),...
    'b-',way(num).wp_utm(1:length(way(num).wp_utm),1), way(num).wp_utm(1:length(way(num).wp_utm),2),'bo-');
hold on
plot(way(num).road_info(1:length(way(num).road_info),1),way(num).road_info(1:length(way(num).road_info),2),'r-',...
    way(num).road_info(1:length(way(num).road_info),1),way(num).road_info(1:length(way(num).road_info),2),'ro-');
legend('origin','origin','modified','modified');
title('waypoint');
grid on
axis equal
end
%% plot
figure(1)
delete(findobj('Color','k'))
for i=1:length(way)
    if isfield(way(i),'plot')
        delete(way(i).plot)
    end
    way(i).plot = plot(way(i).road_info(:,1)-map_origin_x, way(i).road_info(:,2)-map_origin_y,'--ok');
end