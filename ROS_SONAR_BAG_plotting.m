clear all
clc 
close all
%% Load a bag and get information about it
% Using load() lets you auto-complete filepaths.
bag = ros.Bag.load('2015-01-09-11-51-33.bag');
bag.info()
%% Read all messages on a few topics
topic1 = '/sonarData';	% make sure it matches EXACTLY, including all / or without / the data shown in the command window here
topic2 = '/sonar/position/x';
topic3 = '/sonar/position/y';

%% Re-read msgs on topic1 and get their metadata
[data_1, meta_1] = bag.readAll(topic1);
[data_2, meta_2] = bag.readAll(topic2);
[data_3, meta_3] = bag.readAll(topic3);

%% Plot the raw data
sonar_Output = @(Int32MultiArray) Int32MultiArray.data;

[plot_data_1] = ros.msgs2mat_broken_msgs(data_1, sonar_Output); 
times_data_1 = cellfun(@(x) x.time.time, meta_1); % Get timestamps
baseline_time_data_1 = times_data_1-times_data_1(1);

% Manually repair the broken messages...

for x = 1:length(plot_data_1)
    if length(plot_data_1{1,x}) ~= 214;
        plot_data_1{:,x} = [];
    end
end
plot_data_1 = double([plot_data_1{:}]);

%% Calculate the heading
for x = 1:length(plot_data_1)
    plot_data_1(1,x) = sonar_steps2rad(plot_data_1(1,x));
end

%% Filter the data - high pass filter with nyquist = 13187.5Hz and cutoff = 2639Hz (10 samples ??)
[b,a] = butter(5, 0.1, 'low');
plot_data_1(4:end,:) = filter(b,a, plot_data_1(4:end,:));
%% Plot the sonar
sfp = plot_sonar(plot_data_1, -127, 127, 200);
%% Plot the x,y data
% %x
% sonar_Position = @(Odometry) Odometry.pose.pose.position;
% [plot_data_2] = ros.msgs2mat(data_2, sonar_Position); 
% times_data_2 = cellfun(@(x) x.time.time, meta_2); % Get timestamps
% baseline_time_data_2 = times_data_2-times_data_2(1);
% 
% %y
% [plot_data_3] = ros.msgs2mat(data_3, sonar_Position); 
% times_data_3 = cellfun(@(x) x.time.time, meta_3); % Get timestamps
% baseline_time_data_3 = times_data_3-times_data_3(1);
% 
% figure(1001);
% hold all;
% plot(baseline_time_data_2, plot_data_2(1,:),'.-');
% plot(baseline_time_data_3, plot_data_3(2,:),'.-');
% 
% title('');
% legend('x','y');
% %ylim([-5 5]);
% hold off;


%% Learn more
