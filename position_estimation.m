clear all
clc 
close all
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
    plot_data_1(1,x) = sonar_steps2rad(plot_data_1(1,x));
end

%% Different approaches to finding the position of the wall

%% Single Beam Approaches

%% Finding a sequence of x values above a threshold
