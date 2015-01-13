function [surf_polar_data_x, surf_polar_data_y, surf_polar_data_z] = plot_sonar(data, min, max, fig_nr )
%PLOT_SONAR Summary of this function goes here


%% convert to meters and turn into cartesian coordiantes
convert2distance_in_meters = (data(3,1)*0.1) / data(2,1);

[surf_polar_data_x, surf_polar_data_y, surf_polar_data_z] = pol2cart(...
    repmat(data(1,:), length( data(4:end, 1) ), 1 )...
    ,repmat((1:1:length( data(4:end,1) ) )'* convert2distance_in_meters ,1 , size(data,2) )...
    , data(4:end,:));

%% Plot a contour plot
% figure(fig_nr);
% 
% contour(surf_polar_data_x, surf_polar_data_y, surf_polar_data_z);
% colormap( parula( max+ abs(min) ) );
% colorbar;
% title('Sonar Contour plot - Pool Wall (red)')
% xlabel('x axis [m]');
% ylabel('y axis [m]');
% 
% grid on
% grid minor
% rectangle('Position', [-0.7 -4 2.687 4.75], 'Curvature', [0.3 0.3],'EdgeColor', 'red');
%rectangle('Position', [1.48 0 0.15 0.5], 'EdgeColor', 'green', 'LineWidth', 0.75);

figure(fig_nr+1);
mesh(surf_polar_data_x, surf_polar_data_y, surf_polar_data_z);
colormap( parula( max+ abs(min) ) )
colorbar
title('Sonar Contour plot - Pool Wall (red)')
xlabel('x axis [m]');
ylabel('y axis [m]');

grid on
grid minor
rectangle('Position', [-0.7 -4 2.687 4.841], 'Curvature', [0.3 0.3],'EdgeColor', 'red');
end

