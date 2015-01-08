function [surf_polar_data_x, surf_polar_data_y, surf_polar_data_z] = plot_sonar(data, min, max, fig_nr )
%PLOT_SONAR Summary of this function goes here
%   Detailed explanation goes here%% Calculate the heading
figure(fig_nr);
convert = (data(3,1)*0.1) /data(2,1);

[surf_polar_data_x, surf_polar_data_y, surf_polar_data_z] = pol2cart(...
    repmat(data(1,:), length( data(4:end, 1) ), 1 )...
    ,repmat((1:1:length( data(4:end,1) ) )'* convert ,1 , size(data,2) )...
    , data(4:end,:));
%mesh(surf_polar_data_x, surf_polar_data_y, surf_polar_data_z);
%colormap( default( max+ abs(min) ) )

%figure(fig_nr+1);
contour(surf_polar_data_x, surf_polar_data_y, surf_polar_data_z);
colormap( parula( max+ abs(min) ) )
colorbar

end

