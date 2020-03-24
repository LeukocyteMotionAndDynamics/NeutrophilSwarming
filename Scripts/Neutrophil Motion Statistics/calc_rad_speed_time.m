% Script to read the position of neutrophils (x,y) from the Microsoft(R) Excel 
% file that is generated from Imaris(R) and calculate their normalised radial 
% speed with time

% Last Update:  04 Nov 2019


%% Initialise some parameters

% Define the number of experiments (*)
num_exp = 5;

% Define the inner distance and maximum distance from the wound to calculate 
% the neutrophil speed
dist_inn = 0; dist_max = 400;

% Define the time duration of tracking in minutes
time_total = 60;

% Define the bin-size in minutes
bin_size = 7.5;


%% Loop over all experiments
for exp_id = 1:num_exp
    
    % Comment in command window to confirm which experiment runs
    disp(['Running experiment ' num2str(exp_id)]);
    
    % Get experiment properties: file name, pixel size, time interval, wound 
    % coordinates and areas to exclude (*)
    [name, pixel, time_int, frame_start, wound_x, wound_y, wound_z, x_excl] = ...
        data_tracking(exp_id);
    
    % Get the total number of frames to track
    frame_end = round(time_total * 60 / time_int);
    
    % Define the time bins
    time = (bin_size:bin_size:time_total);
    time_bins = [0, round(time*60/time_int)];
    
    
    %% Load the excel file with the 'neutrophil position' spreadsheet

    % Choose the directory of files (*)
    dir_data = 'Data';

    % Choose the spreadsheet file
    filename = [name '.xls'];
    file = fullfile(dir_data, filename);

    % Read the file with the worksheet 'Position'
    [xx, yy, zz] = read_xls_file_position(file, 'Position');
    
    
    %% Exclude area of non-moving neutrophils
    yy(xx<x_excl) = NaN; zz(xx<x_excl) = NaN; xx(xx<x_excl) = NaN;
    
    
    %% Find the number of neutrophils and empty further NaNs
    num_cells = find(sum(~isnan(xx),1) > 0, 1 , 'last');
    xx(:,num_cells+1:end) = []; yy(:,num_cells+1:end) = []; 
    zz(:,num_cells+1:end) = [];
    
    
    %% Delete neutrophil positions at wound
    
    % Loop over all neutrophils
    for hh = 1:num_cells
        % Find the neutrophils that are inside the wound area
        in = find(inpolygon(xx(:,hh),yy(:,hh),wound_x,wound_y) == 1);
        % Delete these positions
        xx(in,hh) = NaN; yy(in,hh) = NaN; zz(in,hh) = NaN;
    end
    
    
    %% Calculate the neutrophil speed and cosine theta 
    
    % Initialise variable for all speeds
    u_time_all = nan(frame_end, num_cells);
    costh_time_all = nan(frame_end, num_cells);
    
    % Loop over all time points
    for time_id = 1:frame_end-1
        
        % Calculate the parameters
        [u_time_cell, ~, ~, costh_time_cell] = ...
            velocity_xyz_costh(time_int, time_id, dist_inn, dist_max, ...
            xx, yy, zz, num_cells, wound_x, wound_y, wound_z);
        
        % Find the number of entries
        u_time_length = length(u_time_cell);
        costh_time_length = length(costh_time_cell);
        
        % Append the values to initialised variables
        u_time_all(time_id, 1:u_time_length) = u_time_cell;
        costh_time_all(time_id, 1:costh_time_length) = costh_time_cell;
        
    end
    
    
    %% Normalise neutrophil speed values with average fish speed
    u_time_all_mean = nanmean(u_time_all(:));
    u_time_all = u_time_all / u_time_all_mean;
    
    
    %% Calculate the neutrophil radial speed
    u_rad_time_all = u_time_all .* costh_time_all;
    
    
    %% Bin neutrophil radial speed with time (cell-based)
    
    % Initialise parameters
    if exp_id == 1
        speed_temp = cell(exp_id,length(time));
    end
    
    % Loop over all time bins
    for kk = 1:length(time_bins)-1
        % Append speed to various bins
        speed_temp = u_rad_time_all(time_bins(kk)+1:time_bins(kk+1),:);
        speed_temp = speed_temp(:);
        speed_rad_cell{exp_id,kk} = speed_temp;
    end
    
end


%% Save data (*)
save('rad_speed_time.mat', 'speed_rad_cell', 'time');


