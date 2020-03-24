% Script to read the Ca2+ intensity of neutrophils from from the Microsoft(R) 
% Excel file that is generated from Imaris(R) and extract the mean intensity 
% value for neutrophils beyond wound and at the wound

% Last Update:  18 Nov 2019


%% Initialise some parameters

% Define the number of experiments (*)
num_exp = 5;

% Define the time duration of tracking in minutes
time_total = 60;


%% Loop over all experiments
for exp_id = 1:num_exp
    
    % Comment in command window to confirm which experiment runs
    disp(['Running experiment ' num2str(exp_id)]);
    
    % Get experiment properties: file name, pixel size, time interval and 
    % wound coordinates (*)
    [name, pixel, time_int, frame_start, wound_x, wound_y, wound_z] = ...
        data_intensity(exp_id);
    
    % Get the total number of frames to track
    frame_end = round(time_total * 60 / time_int);
    
    
    %% Load the excel file with the 'neutrophil intensity' and 'neutrophil 
    % position' spreadsheets
    
    % Choose the directory of files
    dir_data = 'Data';
    
    % Choose the file
    filename = [name '.xls'];
    file = fullfile(dir_data, filename);
    
    % Read the file with the worksheet 'Position'
    [xx, yy, zz] = read_xls_file_position(file, 'Position');
    
    % Read the file with the worksheet 'Intensity'
    fluoro = read_xls_file_intensity(file, 'Intensity Mean Ch=1');
    
    
    %% Empty first frames due to laser wound burst and last frames
    
    % Empty the first frames to exclude the Ca2+ burst due to laser wound
    xx(1:frame_start-1,:) = []; yy(1:frame_start-1,:) = [];
    zz(1:frame_start-1,:) = []; fluoro(1:frame_start-1,:) = [];
    
    % Empty the frames after the time we want to track
    xx(frame_end+1:end,:) = []; yy(frame_end+1:end,:) = [];
    zz(frame_end+1:end,:) = []; fluoro(frame_end+1:end,:) = [];
    
    
    %% Find the number of neutrophils
    num_cells = find(sum(~isnan(xx),1) > 0, 1 , 'last');
    xx(:,num_cells+1:end) = []; yy(:,num_cells+1:end) = []; 
    zz(:,num_cells+1:end) = []; fluoro(:,num_cells+1:end) = [];
    
    
    %% Get coordinates and intensities for neutrophils only outside the wound

    % Define the variables for neutrophils outside wound
    x_out = xx; y_out = yy; z_out = zz; fluoro_out = fluoro;
    
    % Loop over all neutrophils
    for hh = 1:num_cells
        % Find the first time that each neutrophil (xx,yy) is inside the 
        % perimeter of the wound area
        in = find(inpolygon(x_out(:,hh),y_out(:,hh),wound_x,wound_y) == 1);
        % Empty these positions
        if ~isempty(in)
            x_out(in,hh) = NaN; y_out(in,hh) = NaN; z_out(in,hh) = NaN;
            fluoro_out(in,hh) = NaN;
        end
    end
    
    
    %% Get coordinates and intensities for neutrophils only at wound
    
    % Define the variables for neutrophils in wound
    x_in = xx; y_in = yy; z_in = zz; fluoro_in = fluoro;
    
    % Loop over all neutrophils
    for hh = 1:num_cells
        % Find the first time that each neutrophil (xx,yy) is outside the 
        % perimeter of the wound area
        out = find(~inpolygon(x_in(:,hh),y_in(:,hh),wound_x,wound_y) == 1);
        % Empty these positions
        if ~isempty(out)
            x_in(out,hh) = NaN; y_in(out,hh) = NaN; z_in(out,hh) = NaN;
            fluoro_in(out,hh) = NaN;
        end
    end
    
    
    %% Find the mean value of intensity at first frame at wound
    neutro_mean = nanmean((fluoro_out(1,:)));
    
    
    %%  Calculate the neutrophil mean intensity and normalise
    fluoro_exp_out = nanmean(fluoro_out(:));
    fluoro_exp_out = fluoro_exp_out / neutro_mean;
    fluoro_exp_in = nanmean(fluoro_in(:));
    fluoro_exp_in = fluoro_exp_in / neutro_mean;
    
    
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
save('cell_intensity.mat', 'fluoro_migr_cell', 'fluoro_wound_cell');


