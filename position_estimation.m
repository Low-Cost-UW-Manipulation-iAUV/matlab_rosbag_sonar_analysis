clear all
clc
close all

break_the_x_axis = [0,0];

%% Sonar data:
range = 6;
nbins = 211;

%% Detection limits
left_limit = 2;
right_limit = 358;
center = 360;

% limits crossing the wrapping point
detect_limits = @(x)(x <= left_limit) || (x >= right_limit);
plot_limits = [-0.5, 360+0.5];
break_the_x_axis = [left_limit+0.1, right_limit-0.1];
% continous crossings
%detect_limits = @(x)(x <= left_limit) && (x >= right_limit);
%plot_limits = [left_limit+0.5, right_limit-0.5];


%% Load a bag and get information about it
% Using load() lets you auto-complete filepaths.
bag = ros.Bag.load('2015-01-13-12-56-19.bag');
bag.info()
%% Read all messages on a few topics
topic1 = '/sonarData';	% make sure it matches EXACTLY, including all / or without / the data shown in the command window here


%% Re-read msgs on topic1 and get their metadata
[data_1, meta_1] = bag.readAll(topic1);


%% Extract the data from the rosbag
sonar_Output = @(Int32MultiArray) Int32MultiArray.data;

[plot_data_1] = ros.msgs2mat_broken_msgs(data_1, sonar_Output);
% Get timestamps
times_data_1 = cellfun(@(x) x.time.time, meta_1);
baseline_time_data_1 = times_data_1-times_data_1(1);

%% Manually repair the broken messages...

for x = 1:length(plot_data_1)
    if length(plot_data_1{1,x}) ~= 214;
        plot_data_1{:,x} = [];%zeros(214,1);
    end
end
% by removing them
plot_data_1 = double([plot_data_1{:}]);

%% Calculate the heading
for x = 1:length(plot_data_1)
    plot_data_1(1,x) = sonar_steps2deg(plot_data_1(1,x));
end

%% Different approaches to finding the position of the wall

%% Single Beam Approaches

%% Finding a sequence of x values above a threshold and return the center distance
clear data
clear x
clear y
threshold = 120;
sequence_threshold = 3;

data = 0;
% insert the angle in deg.
data_counter = 1;
for x = 1: length(plot_data_1)
    
    sequence_counter = 0;
    if detect_limits(plot_data_1(1,x))
        for y = 4:length(plot_data_1(4:end,1))
            if plot_data_1(y,x) >= threshold
                sequence_counter = sequence_counter + 1;
            else
                sequence_counter = 0;
            end
            
            if sequence_counter >= sequence_threshold
                data(1,data_counter) = plot_data_1(1,x);
                data(2,data_counter) = (y + (y - sequence_counter ) ) / 2;
                data(2,data_counter) = data(2,data_counter) * range/nbins;
                data_counter = data_counter + 1;
                break;
                sequence_counter=0;
            end
        end
    end
end
figure(12372)
hold all
try
    plot(data(1,:),data(2,:),'o','DisplayName','Cont. sequence of 3 above 120');
    plot(center,mean(data(2,:)),'*','DisplayName','mean(Cont. sequence of 3 above 120)');
catch
end

%% Find sequence of n datapoints whose average is above x
clear data
clear x
clear y

threshold = 110;
% 0.1m averaging...
filter_length = round(0.1/(range/nbins));

data = 0;
data_counter = 1;

for x = 1: length(plot_data_1)
    if detect_limits(plot_data_1(1,x))
        for y = 4:length(plot_data_1(4:end-filter_length, 1))
            rolling_avg = mean(plot_data_1(y:(y+filter_length),x));
            if rolling_avg >= threshold
                %insert the angle
                data(1,data_counter) = plot_data_1(1,x);
                data(2,data_counter) = (y + (y + filter_length) )/2 *range/nbins;
                data_counter = data_counter + 1;
                break;
            end
        end
    end
end
try
    plot(data(1,:),data(2,:),'*','DisplayName','center of area of 10cm with average above 110');
    plot(center,mean(data(2,:)),'o','DisplayName','mean(center of area of 10cm with average above 110)');
catch
end
%% Multi Beam analysis
%% Blurring across 5° aka 10 lines @ 0.45°/line, ...
% Then some

s = ones(3) * 1/8;
s(2,2) = 0;

H = conv2(plot_data_1(4:end,:),s);
new_plot_data_1 = plot_data_1;
new_plot_data_1(4:end, :) = H(2:end-1, 2:end-1);
threshold = 100;
sequence_threshold = 3;

data = 0;
% insert the angle in deg.
data_counter = 1;
for x = 1: length(plot_data_1)
    if detect_limits(plot_data_1(1,x))
        sequence_counter = 0;
        for y = 4:length(new_plot_data_1(4:end,1))
            if new_plot_data_1(y,x) >= threshold
                sequence_counter = sequence_counter + 1;
            else
                sequence_counter = 0;
            end
            
            if sequence_counter >= sequence_threshold
                data(1,data_counter) = plot_data_1(1,x);
                data(2,data_counter) = (y + (y - sequence_counter ) ) / 2;
                data(2,data_counter) = data(2,data_counter) * range/nbins;
                data_counter = data_counter + 1;
                break;
                sequence_counter = 0;
            end
        end
    end
end
try
    plot(data(1,:),data(2,:),'*','Displayname','Cont. sequence of 3 above 120 after blurring with "ones(3), center=0"');
    plot(center,mean(data(2,:)),'o','DisplayName','mean(Cont. sequence of 3 above 120 after blurring with "ones(3), center=0")');
catch
end
xlim(plot_limits)
title('Sonar X Position Filtering - 3 Approaches')
ylabel('distance [m]');
xlabel('angle [°]');
legend(gca,'show', 'Location','SouthOutside')
if break_the_x_axis(1,2) ~= 0 && break_the_x_axis(1,1)~= 0
    h = breakxaxis(break_the_x_axis);
end