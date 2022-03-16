function [x, y] = find_center(a, x0, y0, theta)

x_o = 352300; y_o = 4025400;
delete(findobj('Color','g'))
search_dist = 30;

theta = theta + pi/2;

x = round((x0 - x_o) *10);
y = round((y0 - y_o) *10);
X = [x, y; x, y; x, y];
for i=1:search_dist
    if a(round(y+i*sin(theta)), round(x+i*cos(theta)))
       X(1,:) = [x+i*cos(theta),y+i*sin(theta)];
       break
    end
end
for i=1:search_dist
    if a(round(y-i*sin(theta)),round(x-i*cos(theta)))
       X(3,:) = [x-i*cos(theta),y-i*sin(theta)];
       break
    end
end
h = plot(X(:,1)/10+x_o, X(:,2)/10+y_o,'--og');
if i==search_dist || j==search_dist
    x = x0;
    y = y0;
else
    round(X(1,1)+X(3,1));
    x = (X(1,1)+X(3,1))/20+x_o;
    y = (X(1,2)+X(3,2))/20+y_o;
end
zoom on