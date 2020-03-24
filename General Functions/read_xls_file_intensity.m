% Script to read data from Microsoft(R) Excel file (made by Imaris(R)) and 
% convert into variables in the workspace and then to save the data as .mat 
% files

% Last Update:  09 Feb 2019


%% Start of file

function [intensity, time, first_idx] = read_xls_file_intensity(set, sheet)

% Read xls file
file = xlsread(set, sheet);

% Create empty matrices to append the data
intensity = NaN(500, 1000);
time = file(:,5);

% If there is bug in Group id and ids appear as 1,000,000,000 etc., then
% subtract 999,999,999 from that column. Ids now start from 1. 
% Otherwise, comment the following line.
file(:,6) = file(:,6) - 999999999;

% Find the first time-frame
first_idx = file(1,5);

% Find the maximum cell id in the file
max_cell_id = max(file(:,6));

% Append the x matrix
% Loop over the sum of file rows
for file_line = 1:size(file(:,6))
    % Loop over the sum of cell ids
    for cell_id = 1:max_cell_id
        % Find where in file there are area values of specific cell
        idx = find(file(:,6)==cell_id);
        % Find the first frame that this cell appears
        first_idx = file(idx(1),5);
        % Append the data to respective column: 1st column is for 1st cell etc.
        % Start from row-frame that this cell appears
        intensity(first_idx:first_idx+length(idx)-1,cell_id) = file(idx,1);
    end
end

