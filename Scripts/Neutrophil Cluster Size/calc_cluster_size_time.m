% Script to read the area of neutrophils from the Microsoft(R) Excel file that 
% is generated from Imaris(R) and extract the values to plot

% Last Update:  16 Nov 2019


%% Initialise some parameters

% Define the number of experiments
num_exp = 5;

% Define the time to start
time_start = 1;

% Define the time duration of tracking in minutes
time_total = 60;

% Define the bin-size in minutes
bin_size = 7.5;

% Define the threshold for cluster size
clust_thresh = 60;


%% Loop over all experiments
for exp_id = 1:num_exp
    
    % Comment in command window to confirm which experiment runs
    disp(['Running experiment ' num2str(exp_id)]);
    
    % Get the filename, pixel size
    [name, pixel, time_int, exp_start] = data_cluster(exp_id);
    
    
    %% Load the excel file with the neutrophil information
    
    % Choose the directory of files
    dir_data = 'Data';
    
    % Choose the file
    filename = [name '.xls'];
    file = fullfile(dir_data, filename);
    
    % Read the file with the worksheet 'Area' for area and time
    [cluster_size, cluster_time, first_idx] = read_xls_file_area(set, sheet);
        
    % Read the file with the worksheet 'Position'
    [xx, yy, zz] = read_xls_file_position(file, 'Position');
    
    % Get the start and end frames for tracking
    fram_track_start = 1 + time_start * 60 / time_int;
    fram_track_end = time_total * 60 / time_int;
    
    % Define the time bins
    time = (bin_size:bin_size:time_total);
    time_bins = [0, round(time*60/time_int)];
    
    % Tranform the time vector of time-frames into actual time-vector
    cluster_time = cluster_time + exp_start * 60 / time_int;
    
    
    %% Find the number of neutrophils and empty further NaNs
    num_cells = find(sum(~isnan(xx),1) > 0, 1 , 'last');
    xx(:,num_cells+1:end) = []; yy(:,num_cells+1:end) = []; 
    zz(:,num_cells+1:end) = []; cluster_size(:,num_cells+1:end) = [];
    cluster_time(:,num_cells+1:end) = [];
    
    
    %% Empty neutrophil positions outside wound
    
    % Loop over all neutrophils
    for hh = 1:num_cells
        % Find the neutrophils that are inside the wound area
        out = find(~inpolygon(xx(:,hh),yy(:,hh),wound_x,wound_y) == 1);
        % Empty these positions
        xx(out,hh) = NaN; yy(out,hh) = NaN; zz(out,hh) = NaN;
        cluster_size(out,hh) = NaN; cluster_time(out,hh) = NaN;
    end
    
    
    %% Empty entries before beginning and after end of tracking
    cluster_size(cluster_time(:) > fram_track_end) = nan;
    cluster_time(cluster_time(:) > fram_track_end) = nan;
    cluster_size(cluster_time(:) < fram_track_start) = nan;
    cluster_time(cluster_time(:) < fram_track_start) = nan;
    
    
    %% Empty entries of very small clusters
    cluster_time(cluster_size(:) < clust_thresh) = [];
    cluster_size(cluster_size(:) < clust_thresh) = [];
    
    
    %% Bin cluster size with time
    
    % Initialise parameters
    if exp_id == 1
        cluster_size_all = cell(1,length(time_bins)-1);
    end
    
    % Loop over all time bins
    for kk = 1:length(time_bins)-1
        % Cluster Size binning
        cluster_size_temp = cluster_size(cluster_time > time_bins(kk)+1 & ...
            cluster_time <= time_bins(kk+1));
        cluster_size_temp = cluster_size_temp(:);
        cluster_cell{kk} = cluster_size_temp;
    end
    
    
    %% Find the mean cluster size per bin
    
    % Initialise parameters
    if exp_id == 1
        cluster_size_exp = nan(num_exp,length(time_bins)-1);
    end
    
    % Loop over all bins
    for kk = 1:length(time_bins)-1
        cluster_size_temp = cluster_cell{kk};
        cluster_size_exp(exp_id,kk) = nanmean(cluster_size_temp);
    end
    
end


%% Save the list of cluster size
save('gcampf_ctr_cluster_time.mat', 'cluster_size_exp', 'time');


