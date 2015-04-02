%close all
%figure(12313);
%clear sums
%data = plot_data_2;
%hold all;
function [] = sonar_processing_with_alex(data, figure_nh, left_limit, right_limit, center)
figure(figure_nh);
detect_limits = @(x)(x <= left_limit) && (x >= right_limit);
ignore_bins= 24; % initial 0.7 m ignored
max_distance = 106; % 6m
n_scanlines = 10;

%% Looking at the rolling sum of 10 scanlines with simple thresholding and min/max distances

threshold = 1000;
wall = 0;
data_counter = 1;
for x = n_scanlines: length(data) % The scanlines
    if detect_limits(data(1,x-(n_scanlines-1))) && detect_limits(data(1,x))
        sums = sum(data(4:end,x-(n_scanlines-1):x),2)';
        
        for y = ignore_bins+1:max_distance  %along each line
            if(sums(y)>=threshold)
                wall(data_counter,1) = y*6/211;
                wall(data_counter,2) = mean(data(1,x-(n_scanlines-1):x));
                data_counter = data_counter +1;
                break;
            end
        end
    end
end
plot(wall(:,2),wall(:,1), '.', 'DisplayName', 'rolling sum of 10 lines, simple threshold 1000, min/max distance (0.7, 3m)');
plot(center,mean(wall(:,1)), '.', 'DisplayName', 'mean(rolling sum of 10 lines, simple threshold 1000, min/max distance (0.7, 3m))');

hold all


%% Looking at squared array with simple threshold
hold all;
threshold = 1000;
clear wall;
wall=0;
data_counter = 1;
sqar = data(4:end,:).^2;
for x = 1: length(data)
    if detect_limits(data(1,x))
        for y = ignore_bins+1:max_distance
            if(sqar(y, x)>=threshold)
                wall(data_counter,1) = y*6/211;
                wall(data_counter,2) = data(1,x);
                data_counter = data_counter + 1;
                break;
            end
        end
    end
end
plot(wall(:,2),wall(:,1), 'o', 'DisplayName', 'squared data, simple threshold 1000, min/max distance (0.7, 3m)');
plot(center,mean(wall(:,1)), 'o', 'DisplayName', 'mean(squared data, simple threshold 1000, min/max distance (0.7, 3m))');


%% Looking at sum of 10 squared linescans
hold all;
threshold = 100000;
clear wall;
wall=0;
data_counter=1;
sqar = data(4:end,:).^2;

for x = 10: length(data)
    if detect_limits(data(1,x-(9))) && detect_limits(data(1,x))
        
        sums_sq = sum(sqar(:,x-9:x),2)';
        
        for y = ignore_bins+1:max_distance
            if(sums_sq(y)>=threshold)
                wall(data_counter,1) = y*6/211;
                wall(data_counter,2) = data(1,x);
                data_counter = data_counter + 1;
                break;
            end
        end
    end
end
plot(wall(:,2),wall(:,1), 'x', 'DisplayName', 'rolling sum of 10 squared lines, simple threshold 100000, min/max distance (0.7, 3m)');
plot(center,mean(wall(:,1)), 'x', 'DisplayName', 'mean(rolling sum of 10 squared lines, simple threshold 100000, min/max distance (0.7, 3m))');

hold all
end

