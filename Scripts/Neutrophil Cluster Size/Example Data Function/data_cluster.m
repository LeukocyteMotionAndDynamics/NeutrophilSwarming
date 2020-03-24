% Function that receives the experiment index and returns all parameters
% associated with this experiment
% Pixel size (pixel) is given in um/pixel; experiment starting time (frame_start) 
% and laser wound time are given in frame index; time_interval in seconds

% Last Update:  18 Nov 2019


%% Beginning of function

function [name, pixel, time_int, frame_start] = data_cluster(experiment)

if experiment == 1
    name = 'samplecellintensity';
    pixel = 0.3840231;
    time_int = 22;
    frame_start = 9;
elseif experiment == 2
    name = 'file 2';
    pixel = 0.3840231;
    time_int = 23.54;
    frame_start = 9;
elseif experiment == 3
    name = 'file 3';
    pixel = 0.4808432;
    time_int = 24.47;
    frame_start = 13;
elseif experiment == 4
    name = 'file 4';
    pixel = 0.2642091;
    time_int = 36.68;
    frame_start = 6;
elseif experiment == 5
    name = 'file 5';
    pixel = 0.4800001;
    time_int = 36.71;
    frame_start = 6;
end

