wp_file=fopen(strcat(folderName,'kaist_intersection_config.yaml'),'w');
count=0;
for num=1:length(way)
    if way(num).section_id
        count=count+1;
    end
end


fprintf(wp_file,'number_of_lanes: %d\n',count);
count=0;
for num=1:length(way)
    if way(num).section_id
        count=count+1;
        fprintf(wp_file,'#\n');
        fprintf(wp_file,'lane_%d:\n', count);
        fprintf(wp_file,'  road_id: %d\n', way(num).road_number);
        fprintf(wp_file,'  lane_id: %d\n', way(num).lane_number);
        fprintf(wp_file,'  intersection_id: %d\n', way(num).section_id);
        fprintf(wp_file,'  traffic_light_id: %d\n', way(num).light_id);
    end
end
disp(count)

fclose(wp_file);