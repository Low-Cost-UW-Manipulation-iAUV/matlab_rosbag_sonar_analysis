function [ rad ] = sonar_steps2rad( steps )
%SONAR_STEPS2RAD Summary of this function goes here
%   Detailed explanation goes here
if (steps<=3200)
    rad = (-1*steps + 3200) * (2*pi)/6400;
else
    rad = (-1*steps + 9600) * (2*pi)/6400;
end

end

