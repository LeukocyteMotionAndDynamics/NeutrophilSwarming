% Script to read the Ca2+ intensity and area of neutrophils from the Microsoft(R) 
% Excel file that is generated from Imaris(R) and extract the values to plot 
% beyond wound and at the wound

% Updated:  18 Nov 2019


%% Initialise some parameters

% Define the number of experiments
num_exp = 5;

% Define the time duration of tracking in minutes
time_total = 60;


%% Loop over all experiments
for exp_id = 1:num_exp
    
    % Comment in command window to confirm which experiment runs
    disp(['Running experiment ' num2str(experiment)]);
    
    % Get experiment properties: file name, pixel size, time interval, frame to
    % start tracking, wound coordinates
    [name, pixel, time_int, frame_start, wound_x, wound_y, wound_z] = ...
        data_intensity(experiment);
    
    % Get the total number of frames to track
    frame_end = round(time_total * 60 / time_int);
    
    
    %% Load the excel file with the 'neutrophil intensity', 'neutrophil area' 
    % and 'neutrophil position' spreadsheets
    
    % Choose the directory of files
    dir_data = 'Data';
    
    % Choose the file
    filename = [name '.xls'];
    file = fullfile(dir_data, filename);
    
    % Read the file with the worksheet 'Position'
    [xx, yy, zz] = read_xls_file_position(file, 'Position');
    
    % Read the file with the worksheet 'Intensity' and 'Area'
    fluoro = read_xls_file_intensity(file, 'Intensity Mean Ch=1');
    area = read_xls_file_area(file, 'Area');
        
    
    %% Calculate the normalisation factor 
    
    % Find the mean intensity of the neutrophils in first image, before wound
    neutro_mean = nanmean(fluoro(1,:));
    
    
    %% Empty first frames due to laser wound burst and last frames
    
    % Empty the first frames to exclude the Ca2+ burst due to laser wound
    xx(1:frame_start-1,:) = []; yy(1:frame_start-1,:) = [];
    zz(1:frame_start-1,:) = []; fluoro(1:frame_start-1,:) = [];
    area(1:frame_start-1,:) = [];
    
    % Empty the frames after the time we want to track
    xx(frame_end+1:end,:) = []; yy(frame_end+1:end,:) = [];
    zz(frame_end+1:end,:) = []; fluoro(frame_end+1:end,:) = [];
    area(frame_end+1:end,:) = [];
    
    
    %% Find the number of neutrophils
    num_cells = find(sum(~isnan(xx),1) > 0, 1 , 'last');
    xx(:,num_cells+1:end) = []; yy(:,num_cells+1:end) = []; 
    zz(:,num_cells+1:end) = []; fluoro(:,num_cells+1:end) = [];
    area(:,num_cells+1:end) = [];
    
    
    %% Initialise data for inisde and outside the wound
    xx_out = xx; xx_in = xx; yy_out = yy; yy_in = yy; zz_out = zz; zz_in = zz; 
    fluoro_out = fluoro; fluoro_in = fluoro; area_out = area; area_in = area; 
    
    
    %% Get coordinates, intensities and areas for neutrophils outside the wound
    
    % Loop over all neutrophils
    for hh = 1:num_cells
        % Find the neutrophils that are inside the wound area
        in = find(inpolygon(xx_out(:,hh),yy_out(:,hh),wound_x,wound_y) == 1);
        % Empty these positions
        xx_out(in,hh) = NaN; yy_out(in,hh) = NaN; zz_out(in,hh) = NaN;
        fluoro_out(in,hh) = NaN; area_out(in,hh) = NaN; 
    end
    
    
    %% Get coordinates, intensities and areas for neutrophils at wound
    
    % Loop over all neutrophils
    for hh = 1:num_cells
        % Find the neutrophils that are inside the outside area
        in = find(inpolygon(xx_in(:,hh),yy_in(:,hh),wound_x,wound_y) == 0);
        % Empty these positions
        xx_in(in,hh) = NaN; yy_in(in,hh) = NaN; zz_in(in,hh) = NaN;
        fluoro_in(in,hh) = NaN; area_in(in,hh) = NaN; 
    end
    
    
    %% Rearrange data for ease of handling and normalise
    
    % Make variables as vectors
    fluoro_out_temp = fluoro_out(:);
    area_out_temp = area_out(:);
    fluoro_in_temp = fluoro_in(:);
    area_in_temp = area_in(:);
    
    % Delete NaNs
    fluoro_out_temp(isnan(u_time_out_temp(:,:))) = [];
    area_out_temp(isnan(u_time_out_temp(:,:))) = [];
    area_in_temp(isnan(fluoro_in_temp)) = [];
    fluoro_in_temp(isnan(fluoro_in_temp)) = [];
    
    % Normalise intensities
    fluoro_exp_out = fluoro_out_temp / neutro_mean;
    fluoro_exp_in = fluoro_in_temp / neutro_mean;
    
    % Assign area variable a similar name to intensity
    area_exp_out = area_out_temp;
    area_exp_in = area_in_temp;
    
    
    %% Append to matrix of all data
    if experiment == 1
        fluoro_migr_cell = fluoro_exp_out;
        fluoro_wound_cell = fluoro_exp_in;
        area_migr_cell = area_exp_out;
        area_wound_cell = area_exp_in;
    else
        fluoro_migr_cell = [fluoro_migr_cell; fluoro_exp_out];
        fluoro_wound_cell = [fluoro_wound_cell; fluoro_exp_in];
        area_migr_cell = [area_migr_cell; area_exp_out];
        area_wound_cell = [area_wound_cell; area_exp_in];
    end
    
end


%% Save data
save('cell_intensity_area.mat', 'fluoro_migr_cell', 'fluoro_wound_cell', ...
    'area_migr_cell', 'area_wound_cell');


