% Function that receives the experiment index and returns all parameters
% associated with this experiment
% Time interval is given in seconds, frame that experiment starts in frame
% index, bacteria mean intensity has been calculated from Imaris(R) from
% the first frame before laser wound

% Last Update:  11 Dec 2019


%% Beginning of function

function [name, time_int, frame_start, bact_mean] = data_bacteria(experiment)

if experiment == 1
    name = 'samplebacteriaintensity';
    time_int = 30;
    frame_start = 2;
    bact_mean = 288;
elseif experiment == 2
    name = 'file 2';
    time_int = 30;
    frame_start = 2;
    bact_mean = 405;
elseif experiment == 3
    name = 'file 3';
    time_int = 30;
    frame_start = 2;
    bact_mean = 364;
elseif experiment == 4
    name = 'file 4';
    time_int = 30;
    frame_start = 2;
    bact_mean = 677;
elseif experiment == 5
    name = 'file 5';
    time_int = 30;
    frame_start = 2;
    bact_mean = 203;
end

