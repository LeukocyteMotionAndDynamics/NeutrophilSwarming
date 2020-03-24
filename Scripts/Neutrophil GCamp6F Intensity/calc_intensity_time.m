% Script to read the Ca2+ intensity of neutrophils from the Microsoft(R) Excel 
% file that is generated from Imaris(R) and extract the values to plot

% Antonios Georgantzoglou
% Department of PDN, University of Cambridge

% Created:  29 Sep 2018
% Updated:  04 Dec 2019


%% Initialise some parameters

% Define the number of experiments
num_exp = 5;

% Define the time duration of tracking in minutes
time_total = 60;

% Define the bin-size in minutes
bin_size = 5;


%% Loop over all experiments
for exp_id = 1:num_exp

    % Comment in command window to confirm which experiment runs
    disp(['Running experiment ' num2str(exp_id)]);
    
    % Get experiment properties: file name, pixel size, time interval, frame to 
    % start tracking and wound coordinates
    [name, pixel, time_int, ~, wound_x, wound_y, wound_z, ~, frame_lw] = ...
        data_intensity(exp_id);
    
    % Start tracking from the frame of laser wound
    frame_start = frame_lw;
    
    % Get the total number of frames to track
    frame_end = round(time_total * 60 / time_int) + frame_start;
    
    % Define the time bins
    time = (bin_size:bin_size:time_total);
    time_bins = [0, round(time*60/time_int)];
    
    
    %% Load the excel file with the 'neutrophil intensity' and 'neutrophil 
    % position' spreadsheets
    
    % Choose the directory of files
    dir_data = 'Data';
    
    % Choose file
    filename_out = [name '.xls'];
    file_out = fullfile(dir_data, filename_out);
    
    % Read the file with the worksheet 'Position'
    [xx_out, yy_out, zz_out] = read_xls_file_position(file_out, 'Position');
    
    % Read the file with the worksheet 'Intensity'
    fluoro_out = read_xls_file_intensity(file_out, 'Intensity Mean Ch=1');
    
    
    %% Load the excel file with the 'neutrophil intensity' and 'neutrophil 
    % position' spreadsheets
    
    % Choose the laser wound file
    filename_in = [name '.xls'];
    file_in = fullfile(dir_data, filename_in);
    
    % Read the file with the worksheet 'Position'
    [xx_in, yy_in, zz_in] = read_xls_file_position(file_in, 'Position');
    
    % Read the file with the worksheet 'Intensity'
    fluoro_in = read_xls_file_intensity(file_in, 'Intensity Mean Ch=1');
    
    
    %% Calculate the normalisation factor 
    
    % Find the mean intensity of the neutrophils in first image, before wound
    neutro_mean = nanmean(fluoro_out(1,:));
    
    
    %% Empty frames that we don't need
    
    % Empty the first frames to exclude the Ca2+ burst due to laser wound
    xx_out(1:frame_start-1,:) = []; yy_out(1:frame_start-1,:) = [];
    zz_out(1:frame_start-1,:) = []; fluoro_out(1:frame_start-1,:) = [];
    xx_in(1:frame_start-1,:) = []; yy_in(1:frame_start-1,:) = [];
    zz_in(1:frame_start-1,:) = []; fluoro_in(1:frame_start-1,:) = [];
    
    % Empty the frames after the time we want to track
    xx_out(frame_end+1:end,:) = []; yy_out(frame_end+1:end,:) = [];
    zz_out(frame_end+1:end,:) = []; fluoro_out(frame_end+1:end,:) = [];
    xx_in(frame_end+1:end,:) = []; yy_in(frame_end+1:end,:) = [];
    zz_in(frame_end+1:end,:) = []; fluoro_in(frame_end+1:end,:) = [];
    
    
    %% Find the number of neutrophils
    num_cells_out = find(sum(~isnan(xx_out),1) > 0, 1 , 'last');
    xx_out(:,num_cells_out+1:end) = []; yy_out(:,num_cells_out+1:end) = []; 
    zz_out(:,num_cells_out+1:end) = []; fluoro_out(:,num_cells_out+1:end) = [];
    num_cells_in = find(sum(~isnan(xx_in),1) > 0, 1 , 'last');
    xx_in(:,num_cells_in+1:end) = []; yy_in(:,num_cells_in+1:end) = []; 
    zz_in(:,num_cells_in+1:end) = []; fluoro_in(:,num_cells_in+1:end) = [];
    
    
    %% Get coordinates and intensities for neutrophils outside the wound
    
    % Loop over all neutrophils
    for hh = 1:num_cells_out
        % Find the neutrophils that are inside the wound area
        in = find(inpolygon(xx_out(:,hh),yy_out(:,hh),wound_x,wound_y) == 1);
        % Empty these positions
        xx_out(in,hh) = NaN; yy_out(in,hh) = NaN; zz_out(in,hh) = NaN;
        fluoro_out(in,hh) = NaN;
    end
    
    
    %% Delete coordinates and intensities for neutrophils at wound
    
    % Loop over all neutrophils
    for hh = 1:num_cells_in
        % Find the neutrophils that are inside the wound area
        out = find(inpolygon(xx_in(:,hh),yy_in(:,hh),wound_x,wound_y) == 0);
        % Empty these positions
        xx_in(out,hh) = NaN; yy_in(out,hh) = NaN; zz_in(out,hh) = NaN;
        fluoro_in(out,hh) = NaN;
    end
    
    
    %% Bin Ca2+ intensity with time

    % Initialise parameters
    fluoro_out_mean = nan(1, length(time));
    fluoro_in_mean = nan(1, length(time));
    
    % Loop over all bins for intensity outside the wound
    for kk = 1:length(time_bins)-1
        fluoro_out_temp = fluoro_out(time_bins(kk)+1:time_bins(kk+1),:);
        fluoro_out_temp(isnan(fluoro_out_temp)) = [];
        fluoro_out_mean(kk) = nanmean(fluoro_out_temp(:));
    end
    
    % Normalise the intensity outside the wound
    fluoro_exp_out = fluoro_out_mean/neutro_mean;
    
    % Loop over all bins for intensity at wound
    for kk = 1:length(time_bins)-1
        fluoro_in_temp = fluoro_in(time_bins(kk)+1:time_bins(kk+1),:);
        fluoro_in_temp(isnan(fluoro_in_temp)) = [];
        fluoro_in_mean(kk) = nanmean(fluoro_in_temp(:));
    end
    
    % Normalise the intensity at wound
    fluoro_exp_in = fluoro_in_mean/neutro_mean;
    
    
    %% Append to matrix of all data
    if exp_id == 1
        fluoro_migr_cell = fluoro_exp_out;
        fluoro_wound_cell = fluoro_exp_in;
    else
        fluoro_migr_cell = [fluoro_migr_cell; fluoro_exp_out];
        fluoro_wound_cell = [fluoro_wound_cell; fluoro_exp_in];
    end
    
end


%% Save data
save('cell_intensity_time.mat', 'fluoro_migr_cell', 'fluoro_wound_cell', 'time');


