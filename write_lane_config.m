wp_file=fopen(strcat(folderName,'kaist_lane_config.yaml'),'w');

fprintf(wp_file,'number_of_lanes: %d\n',length(way));

for num=1:length(way)
    fprintf(wp_file,'#\n');
    fprintf(wp_file,'lane_%d:\n', num);
    fprintf(wp_file,'  road_number: %d\n', way(num).road_number);
    fprintf(wp_file,'  lane_number: %d\n', way(num).lane_number);
    fprintf(wp_file,'  begin_node: %d\n', way(num).start);
    fprintf(wp_file,'  end_node: %d\n', way(num).finish);
    fprintf(wp_file,'  lane_width: %0.2f\n', 3.0);
    fprintf(wp_file,'  waypoint_file: ''%03d%03d.txt''\n', way(num).start, way(num).finish);
end


fclose(wp_file);