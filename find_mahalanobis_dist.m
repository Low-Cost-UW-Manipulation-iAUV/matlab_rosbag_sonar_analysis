clear all
clc 
close all
%% Load a bag and get information about it
% Using load() lets you auto-complete filepaths.
bag = ros.Bag.load('2015-01-10-16-00-24.bag');
bag.info()
%% Read all messages on a few topics
%topic1 = '/sonarData';	% make sure it matches EXACTLY, including all / or without / the data shown in the command window here
topic2 = '/sonar/position/x';
topic3 = '/sonar/position/y';

%% Re-read msgs on topic1 and get their metadata
%[data_1, meta_1] = bag.readAll(topic1);
[data_2, meta_2] = bag.readAll(topic2);
[data_3, meta_3] = bag.readAll(topic3);

%% Plot the x,y data
%x
sonar_Position = @(Odometry) Odometry.pose.pose.position;
[plot_data_2] = ros.msgs2mat(data_2, sonar_Position); 
times_data_2 = cellfun(@(x) x.time.time, meta_2); % Get timestamps
baseline_time_data_2 = times_data_2-times_data_2(1);

%y
[plot_data_3] = ros.msgs2mat(data_3, sonar_Position); 
times_data_3 = cellfun(@(x) x.time.time, meta_3); % Get timestamps
baseline_time_data_3 = times_data_3-times_data_3(1);

figure(1001);
hold all;
plot(baseline_time_data_2, plot_data_2(1,:),'.-');
plot(baseline_time_data_3, plot_data_3(2,:),'.-');

title('');
legend('x','y');
%ylim([-5 5]);
hold off;


%% Calculate the Mohalanobis Distance
load('Wall Distance ground truth.mat');
X_x = ground_truth(:,1);
Y_x = plot_data_2(1,:).';

X_y = ground_truth(:,2);
Y_y = plot_data_3(2,:).';

% Compute the Mahalanobis distance of observations in Y from the reference sample in X .
d1_x = mahal(Y_x,X_x);
figure(3321234);
plot(d1_x);
title('Mahalanobis Distance of X data');

d1_y = mahal(Y_y,X_y);
figure(332187567);
plot(d1_y);
title('Mahalanobis Distance of Y data');
