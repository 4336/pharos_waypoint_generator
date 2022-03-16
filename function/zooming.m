function zooming(points,zoom_offset)
    
    x_min = points(1,1);
    x_max = points(1,1);
    y_min = points(1,2);
    y_max = points(1,2);

    for i=1:length(points(:,1))
        if x_min > points(i,1)
            x_min = points(i,1);
        end
        if x_max < points(i,1)
            x_max = points(i,1);
        end
        if y_min > points(i,2)
            y_min = points(i,2);
        end
        if y_max < points(i,2)
            y_max = points(i,2);
        end
    end
    xlim([x_min - zoom_offset, x_max+zoom_offset])
    ylim([y_min - zoom_offset, y_max+zoom_offset])
    zoom on
end