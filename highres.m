clear; clc;
%%
if exist('LINK.mat', 'file')
    load('LINK.mat');
end

ngi = LINK;

%%

xy = [];
j = 1; num = 0;
for i=1:length(ngi)
    if strlength(ngi(i)) == 20
        if j
            j = 0;
            num = num + 1;
            link(num).xy=[];
        end
        link(num).xy = [link(num).xy; str2num(ngi(i))];
    else
        j = 1;
    end
end
%%
nodl=[];
for i=1:length(search)
    num=search(i);
    nodl=[nodl;link(num).xy(1,:);link(num).xy(length(link(num).xy),:)];
end

%%
for i=1:length(link)
    disp(i)
    ginput(1)
    xlim([link(i).xy(1,1)-300,link(i).xy(1,1)+300])
    ylim([link(i).xy(1,2)-300,link(i).xy(1,2)+300])
    delete(findobj('Marker','o'))
    delete(findobj('LineStyle','-'))
    plot(link(i).xy(:,1),link(i).xy(:,2),'o-')
end
zoom on

%%
for i=1:length(link)
    plot(link(i).xy(:,1),link(i).xy(:,2),'-')
end
zoom on

%%
plot(nodl(:,1),nodl(:,2),'o')
zoom on

%% connect link
link(1).lane_num=[];
[link(1:657).lane_num] = deal([]); 
[link(1:657).lane_order] = deal([]);
link(1).lane_order=[];
num=1;
order=1;found = 0;
for i=150:length(link)
    if isempty(link(1).lane_num)
        zooming(link(i).xy(1,:))
        delete(findobj('Marker','s'))
        plot(link(i).xy(:,1),link(i).xy(:,2),'s','MarkerFaceColor','r')
        [~, ~, b] = ginput(1);
        if b == 1
            link(i).lane_num = num;
            link(i).lane_order = order;
            order=order+1;
            next=i;
            while 1
                zooming(link(next).xy(length(link(next).xy),:))
                [x, y, b] = ginput(1)
                switch b
                    case 1
                        for z=1:length(link)
                            for p=1:length(link(z).xy)
                                if pdist([link(z).xy(p,:);x,y],'euclidean') < 2
                                    found = 1;
                                    break
                                end
                            end
                            if found
                                break
                            end
                        end
                        if z== 657 && pdist([link(657).xy(length(link(657).xy),:);x,y],'euclidean') >= 2
                            disp('too far')
                        else
                            fprintf('link %d\n', next)
                            link(z).lane_num = num;
                            link(z).lane_order = order;
                            delete(findobj('Marker','s'))
                            plot(link(z).xy(:,1),link(z).xy(:,2),'s-','MarkerFaceColor','r')
                            zooming(link(z).xy(length(link(z).xy),:))
                            
                        end
                        found = 0;
                        
                    case 2
                        1;
                end
            end
        elseif b == 2
            break;
        end
    end
end
    
    
%%
    
    
    
    