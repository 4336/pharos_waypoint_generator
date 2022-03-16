clear; clc;
%%

if exist('LINK.mat', 'file')
    load('LINK.mat');
end

ngi = LINK;

%%

xy = [];
for i=1:length(ngi)
    if strlength(ngi(i)) == 20
        xy = [xy; str2num(ngi(i))];
    end
end
% 
% 
% wp_file=fopen('LANE.txt','w');
% for i=1:length(xy)
%     fprintf(wp_file,'%f %f %f %f\n', xy(i,1), xy(i,2), 0, 0);
% end
% fclose(wp_file);

%%

plot(xy(:,1),xy(:,2),'-')
zoom on