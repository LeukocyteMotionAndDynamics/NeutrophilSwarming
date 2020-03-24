% Script to read data from Microsoft(R) Excel file (made by Imaris(R)) and 
% convert into variables in the workspace and then to save the data as .mat 
% files

% Last Update:  09 Feb 2019


%% Start of file

function [xx, yy, zz, first_time_frame] = read_xls_file_position(set, sheet)

% Read xls file
file = xlsread(set, sheet);

% Create empty NaN matrices to append the data
data_x = NaN(500, 1000);
data_y = NaN(500, 1000);
data_z = NaN(500, 1000);

% TrackID starts from 1,000,000,000 etc. Subtract 999,999,999 from that column. 
% TrackID now starts from 1.
file(:,8) = file(:,8) - 999999999;

% The paramters obtained are the following:
% Column 1 --> Position X, Column 2 --> Position Y, Column 3 --> Position Z, 
% Column 7 --> Time.

% Find whether 'Time' starts from 1; if not, substract and make it start from 1
first_idx = file(1,7);
if first_idx ~= 1
    file(:,7) = file(:,7) - file(1,7) + 1;
end
first_time_frame = first_idx;

% Find the maximum cell id in the file
max_cell_id = max(file(:,8));

% Append the x matrix
% Loop over the sum of file rows
for file_line = 1:size(file(:,8))
    % Loop over the sum of cell number
    for cell_id = 1:max_cell_id
        % Find where in file are x values of specific cell
        idx = find(file(:,8)==cell_id);
        % Find the first frame that this cell appears
        first_idx = file(idx(1),7);
        % Append the data to respective column: 1st column is for 1st cell etc.
        % Start from row-frame that this cell appears
        data_x(first_idx:first_idx+length(idx)-1,cell_id) = file(idx,1);
    end
end

% Append the y matrix
% Loop over the sum of file rows
for file_line = 1:size(file(:,8))
    % Loop over the sum of cell number
    for cell_id = 1:max_cell_id
        % Find where in file are x values of specific cell
        idx = find(file(:,8)==cell_id);
        % Find the first frame that this cell appears
        first_idx = file(idx(1),7);
        % Append the data to respective column: 1st column is for 1st cell etc.
        % Start from row-frame that thi`s cell appears
        data_y(first_idx:first_idx+length(idx)-1,cell_id) = file(idx,2);
    end
end

% Append the z matrix
% Loop over the sum of file rows
for file_line = 1:size(file(:,8))
    % Loop over the sum of cell number
    for cell_id = 1:max_cell_id
        % Find where in file are x values of specific cell
        idx = find(file(:,8)==cell_id);
        % Find the first frame that this cell appears
        first_idx = file(idx(1),7);
        % Append the data to respective column: 1st column is for 1st cell etc.
        % Start from row-frame that thi`s cell appears
        data_y(first_idx:first_idx+length(idx)-1,cell_id) = file(idx,3);
    end
end

% Rename variables according to functions needs
xx = data_x; yy = data_y; zz = data_z;

