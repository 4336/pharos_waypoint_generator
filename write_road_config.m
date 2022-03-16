wp_file=fopen(strcat(folderName,'kaist_road_config.yaml'),'w');

fprintf(wp_file,'number_of_roads: %d\n',way(length(way)).road_number);
way(1).speed=[];
for num=1:length(way)
    if way(num).lane_number == 1
        fprintf(wp_file,'#\n');
        fprintf(wp_file,'road_%d:\n', way(num).road_number);
        fprintf(wp_file,'  road_number: %d\n', way(num).road_number);
        fprintf(wp_file,'  road_type: %d\n', way(num).road_type);
        fprintf(wp_file,'  action: %d\n', way(num).action);
        if way(num).action == 2     %직진
            if way(num+1).lane_number == 2      %2차로
                way(num).speed=30;
            else
                if way(num).road_type == 1      %교차로
                    way(num).speed=25;
                else
                    way(num).speed=20;
                end
            end
        else
            way(num).speed=15;
        end
        fprintf(wp_file, '  speed_limit: ');
        fprintf(wp_file, strcat(num2str(way(num).speed), '\n'));
        fprintf(wp_file,'  distance: 0\n');
    end
end


fclose(wp_file);