delete(findobj('Color','m'))
delete(findobj('Marker','o'))
%%
delete(findobj('Marker','o'))
for num=1:length(way)
    way(num).plot = plot(way(num).road_info(:,1), way(num).road_info(:,2),'o--')
end
%% xx
for num=1:length(nodes)
    xlim([nodes(num,1)-zsize,nodes(num,1)+zsize])
    ylim([nodes(num,2)-zsize,nodes(num,2)+zsize])
    st=[];
    fi=[];
    for i=1:length(way)
        if way(i).start==num
            st=[st,i];
        end
        if way(i).finish==num
            fi=[fi,i];
        end
    end
    disp(st)
    disp(fi)
    shift=input('shift?');
end
%%
hold on
zsize=30;
offset=10;
no=[];
way(1).shifted_info=[];
delete(findobj('LineStyle','-'))
for num=1:length(way)
    if way(num).road_type==3
        no=[no,way(num).start];
    end
end
p=plot(1,1);
for num=1:length(no)
    num_=no(num)
    xlim([nodes(num_,1)-zsize,nodes(num_,1)+zsize])
    ylim([nodes(num_,2)-zsize,nodes(num_,2)+zsize])
    
    st=[];
    fi=[];
    for i=1:length(way)
        if way(i).start==num_
            st=i;
        end
        if way(i).finish==num_
            fi=i;
        end
    end
    
    for i=1:length(way(st).road_info)
        if pdist([nodes(num_,:);way(st).road_info(i,1:2)],'euclidean')>10
            offset_p=i
            break
        end
    end
    l=[nodes(num_,:);way(st).road_info(offset_p,1:2)];
    delete(p);
    p=plot(l(:,1),l(:,2),'k','LineWidth',5);
    
    
    key=input('y/n?','s');
    while 1
        if key=='y'
            way(st).shifted_info...
                =way(st).road_info(offset_p:length(way(st).road_info),:);
            way(fi).shifted_info...
                =[way(fi).road_info;way(st).road_info(2:offset_p,:)];
            break
        elseif key=='n'
            disp('jump')
            break
        else
            key=input('y/n?','s');
        end
    end
end

%%
for num=1:length(way)
    if isempty(way(num).shifted_info)
        way(num).shifted_info=way(num).road_info;
    end
end
%%
delete(findobj('Marker','o'))
for num=1:length(way)
    way(num).plot = plot(way(num).shifted_info(:,1), way(num).shifted_info(:,2),'o--')
end