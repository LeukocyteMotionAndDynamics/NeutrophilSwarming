% Script to read the bacteria intensity from the Microsoft(R) Excel file that 
% is generated from Imaris and extract the values to plot over time

% Updated:  19 Nov 2019


%% Initialise some parameters

% Define the number of experiments
num_exp = 5;

% Define the time duration of tracking in minutes
time_total = 60;

% Define the bin-size in minutes
bin_size = 5;

% Bacteria lower threshold of size to eliminate false detected particles
bact_low_thresh = 3;


%% Loop over all experiments
for exp_id = 1:num_exp
    
    % Comment in command window to confirm which experiment runs
    disp(['Running experiment ' num2str(exp_id)]);
    
    % Get experiment properties: file name, time interval, frame to start
    [name, time_int, frame_start, bact_mean] = data_bacteria(exp_id);
    
    % Choose the directory of files
    dir_data = 'Data';
    
    % Choose the file
    filename = [name '.xls'];
    file = fullfile(dir_data, filename);
    
    % Read the file with the worksheet 'Intensity'
    fluoro = read_xls_file_intensity(file, 'Intensity Mean Ch=2');
    
    % Read the file with the worksheet 'Intensity'
    [bact_area, time_vector] = read_xls_file_area(file, 'Area');
    
    
    %% Eliminate bacteria with size smaller than threshold
    fluoro(bact_area <= bact_low_thresh) = NaN;
    bact_area(bact_area <= bact_low_thresh) = NaN;
    
    
    %% Calculate the time variables
    
    % Define the time duration of tracking in minutes
    % Get the total number of frames to track
    frame_end = round(time_total * 60 / time_int);
    
    % Define the time bins
    time = (bin_size:bin_size:time_total);
    time_bins = [0, round(time*60/time_int)];
    
    
    %% Normalise intensities with mean experiment bacteria intensity
    fluoro_norm = fluoro / bact_mean;
    
    
    %% Empty frames that we don't need
    
    % Empty the first frames to exclude the Ca2+ burst due to laser wound
    fluoro_norm(1:frame_start-1,:) = [];
    
    % Empty the frames after the time we want to track
    fluoro_norm(frame_end+1:end,:) = [];
    
    
    %% Find the number of neutrophils
    num_cells = find(sum(~isnan(fluoro_norm),1) > 0, 1 , 'last');
    fluoro_norm(:,num_cells+1:end) = [];
    
    
    %% Bin the bacteria intensity
    
    % Initialise variables
    if exp_id == 1
        fluoro_bact = cell(exp_id,length(time));
        fluoro_bact_exp = nan(exp_id,length(time));
    end
    
    % Loop over all bins
    for kk = 1:length(time_bins)-1
        % Intensity binning
        fluoro_temp = fluoro_norm(time_bins(kk)+1:time_bins(kk+1),:);
        fluoro_temp = fluoro_temp(:);
        fluoro_temp_mean = nanmean(fluoro_temp);
        fluoro_bact{exp_id,kk} = fluoro_temp;
        fluoro_bact_exp(exp_id,kk) = fluoro_temp_mean;
    end
    
end


%% Save data
save('bact_intens_time.mat', 'fluoro_bact_exp', 'time');


