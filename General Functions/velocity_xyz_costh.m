% The function calculates the cell speed of neutrophils between two time points
% and the cosine theta and appends to a matrix
% The function decides the minimum distance of a cell from the wound perimeter

% Updated:  06 Mar 2019


%% Beginning of file

function [u_all, costh_all] = velocity_xyz_costh(time_int, time_id, ...
    dist_inn, dist_max, xx, yy, zz, num_cells, wound_x, wound_y, wound_z)

% Loop over all cells
for i = 1:num_cells
    
    % Calculate the distance from the wound points
    for kk = 1:length(wound_x)
        d1_wound(kk) = sqrt((xx(time_id,i) - wound_x(kk))^2 ...
            + (yy(time_id,i) - wound_y(kk))^2 ...
            + (zz(time_id,i) - wound_z(kk))^2);
        d2_wound(kk) = sqrt((xx(time_id+1,i) - wound_x(kk))^2 ...
            + (yy(time_id+1,i) - wound_y(kk))^2 ...
            + (zz(time_id+1,i) - wound_z(kk))^2);
    end
    
    % Find the minimum distance and use this distance
    [~, min_d2_id] = min(d2_wound);
    d1_wound = d1_wound(min_d2_id);
    d2_wound = d2_wound(min_d2_id);

    % If the cell lies in the distance between the inner and maximum one, 
    % then process it
    if (((d1_wound > dist_inn) && (d1_wound <= dist_max)) || ...
            (((d2_wound >= dist_inn) && (d2_wound <= dist_max))))
        
        % Find the distance travelled
        d = sqrt((xx(time_id+1,i) - xx(time_id,i))^2 + ...
            (yy(time_id+1,i) - yy(time_id,i))^2 + ...
            (zz(time_id+1,i) - zz(time_id,i))^2);
        
        % Calculate the speed in um/min using the time interval
        u = d * 60 / time_int;
        
        % Calculate the cosine theta
        nx = -(xx(time_id,i) - wound_x(min_d2_id))./d1_wound; 
        ny = -(yy(time_id,i) - wound_y(min_d2_id))./d1_wound;
        nz = -(zz(time_id,i) - wound_z(min_d2_id))./d1_wound;
        
        dx = (xx(time_id+1,i) - xx(time_id,i)); 
        dy = (yy(time_id+1,i) - yy(time_id,i));
        dz = (zz(time_id+1,i) - zz(time_id,i));
        rx = dx./d; ry = dy./d; rz = dz./d;
        
        costh = nx*rx + ny*ry + nz*rz;
        
        % Append the speed and cosine theta
        u_all(cell_id) = u;
        costh_all(cell_id) = costh;
        
    % If the cell lies outside the distance between the inner and maximum one, 
    % then add NaN
    else
        u_all(cell_id) = NaN;
        costh_all(cell_id) = NaN;
    end
end


