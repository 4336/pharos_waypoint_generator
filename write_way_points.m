%% b_spline

% delete(findobj('LineStyle','-'))
for num=1
    disp(num)
    S = b_spline(way(num).points,7,0.02,1);
    hold on
    plot(S(:,1),S(:,2),'o-')
    way(num).b_spline = S;
end

%% curvature smoothing_1
refer_dist=5;
for num=1:length(way)
    disp([num2str(num/length(way)*100),'%'])
    spline=way(num).b_spline(:,1:2);
    len=length(spline);
    curv=zeros(len,1);
    
    for i=1:len
        dist = pdist([spline(1,:);spline(i,:)],'euclidean');
        if dist > refer_dist
            start_offset=i;
            break;
        end
    end
    for i=len:-1:1
        dist = pdist([spline(len,:);spline(i,:)],'euclidean');
        if dist > refer_dist
            finish_offset=len-i;
            break;
        end
    end
    
    for i=start_offset+1:len-finish_offset
        for j=1:len
            dist = pdist([spline(1,:);spline(j,:)],'euclidean');
            if dist > refer_dist
                s_offset=j;
                break;
            end
        end
        for j=len:-1:1
            dist = pdist([spline(len,:);spline(j,:)],'euclidean');
            if dist > refer_dist
                f_offset=len-j;
                break;
            end
        end
        
        c = LineCurvature2D(way(num).b_spline([i-s_offset,i,i+f_offset],:));
        curv(i)=c(2);
    end
    curv(1:start_offset+1)=linspace(0,curv(start_offset+1),start_offset+1);
    curv(len-finish_offset:len)=linspace(curv(len-finish_offset),0,finish_offset+1);
    
    way(num).road_info = [way(num).b_spline, curv];
    refer_curv(num,:) = [LineCurvature2D(spline([1,floor(len/4),floor(len/2)],:))', ...
        LineCurvature2D(spline([floor(len/2),floor(len*3/4),len],:))'];
end
disp('finish')


%% curvature smoothing_2
refer_dist=10;
for num=149
    disp([num2str(num/length(way)*100),'%'])
    spline=way(num).b_spline(:,1:2);
    len=length(spline);
    curv=zeros(len,1);
    
    for i=1:len
        dist = pdist([spline(1,:);spline(i,:)],'euclidean');
        if dist > refer_dist
            start_offset=i;
            break;
        end
    end
    for i=len:-1:1
        dist = pdist([spline(len,:);spline(i,:)],'euclidean');
        if dist > refer_dist
            finish_offset=len-i;
            break;
        end
    end
    
    for i=start_offset+1:len-finish_offset
        for j=1:len
            dist = pdist([spline(1,:);spline(j,:)],'euclidean');
            if dist > refer_dist
                s_offset=j;
                break;
            end
        end
        for j=len:-1:1
            dist = pdist([spline(len,:);spline(j,:)],'euclidean');
            if dist > refer_dist
                f_offset=len-j;
                break;
            end
        end
        
        c = LineCurvature2D(way(num).b_spline([i-s_offset,i,i+f_offset],:));
        curv(i)=c(2);
    end
    curv(1:start_offset+1)=linspace(curv(start_offset+1),curv(start_offset+1),start_offset+1);
    curv(len-finish_offset:len)=linspace(curv(len-finish_offset),curv(len-finish_offset),finish_offset+1);
    
    way(num).road_info = [way(num).b_spline, curv];
    refer_curv(num,:) = [LineCurvature2D(spline([1,floor(len/4),floor(len/2)],:))', ...
        LineCurvature2D(spline([floor(len/2),floor(len*3/4),len],:))'];
end
disp('finish')

%% curvature plot
for num=149
    ginput(1);figure(2);clf;
    subplot(2,2,2);plot(way(num).b_spline(:,1),way(num).b_spline(:,2),'o-')
    axis equal
    subplot(1,2,1);plot(1:length(way(num).b_spline),way(num).road_info(:,4),'o-')
    hold on; plot([1,length(way(num).b_spline)],[refer_curv(num,2) refer_curv(num,2)])
    hold on; plot([1,length(way(num).b_spline)],[refer_curv(num,5) refer_curv(num,5)])
    ylim([-abs(refer_curv(num,5))*2, abs(refer_curv(num,5))*2+0.00001])
    ylim([-0.1 0.1])
    subplot(2,2,4);plot(1:length(way(num).b_spline),1./way(num).road_info(:,4),'o-')
end

%% road_info
for num=149
    way(num).road_info = [way(num).b_spline, LineCurvature2D(way(num).b_spline)];
end

%% ---------------- File Printing ---------------------------------
for num=79
wp_file=fopen(strcat(num2str(way(num).start,'%03d'),num2str(way(num).finish,'%03d'),'.txt'),'w');
for i=1:length(way(num).road_info)-1
    fprintf(wp_file,'%f %f %f %f\n',way(num).road_info(i,1),way(num).road_info(i,2),way(num).road_info(i,3),way(num).road_info(i,4));
end
fclose(wp_file);

end
%% ---------------- File Printing 2 ---------------------------------
for num=1:length(way)
wp_file=fopen(strcat(num2str(way(num).start,'%03d'),num2str(way(num).finish,'%03d'),'.txt'),'w');
for i=1:length(way(num).curv_fixed_info)-1
    fprintf(wp_file,'%f %f %f %f\n',way(num).curv_fixed_info(i,1),way(num).curv_fixed_info(i,2),way(num).curv_fixed_info(i,3),way(num).curv_fixed_info(i,4));
end
fclose(wp_file);

end
%% ---------------- File Printing_merged ---------------------------------
wp_file=fopen(strcat('merged_wp.txt'),'w');
for num=length(way):-1:1
    for i=1:length(way(num).road_info)-1
        fprintf(wp_file,'%f %f %f %f\n',way(num).road_info(i,1),way(num).road_info(i,2),way(num).road_info(i,3),way(num).road_info(i,4));
    end
end
fclose(wp_file);