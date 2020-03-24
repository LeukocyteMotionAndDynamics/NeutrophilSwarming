% Function that receives the experiment index and returns all parameters
% associated with this experiment
% Wound points (wound_x, wound_y, wound_z) and x-coordinate for neutrophils to 
% exclude are given in pixels; pixel size (pixel) is given in um/pixel; 
% experiment starting time (frame_start) and laser wound time are given in frame 
% index; time_interval in seconds

% Last Update:  18 Nov 2019


%% Beginning of function

function [name, pixel, time_int, frame_start, wound_x, wound_y, wound_z, ...
    x_excl, frame_lw] = data_intensity(experiment)

if experiment == 1
    name = 'samplecellintensity';
    pixel = 0.3840231;
    time_int = 22;
    frame_start = 9;
    frame_lw = 5;
    wound_x = [211;191;185;179;175;174;194;216;243;246;252;245;245;242;231]*pixel;
    wound_y = [160;169;189;214;238;267;287;279;268;249;236;209;195;172;152]*pixel;
    wound_z = [1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0];
    x_excl = 50;
elseif experiment == 2
    name = 'file 2';
    pixel = 0.3840231;
    time_int = 23.54;
    frame_start = 9;
    frame_lw = 5;
    wound_x = [169;153;156;137;128;118;136;143;140;167;193;206;232;229;214;207;187;182]*pixel;
    wound_y = [219;226;240;245;260;284;295;314;348;332;318;323;323;294;269;248;260;235]*pixel;
    wound_z = [1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0];
    x_excl = 122;
elseif experiment == 3
    name = 'file 3';
    pixel = 0.4808432;
    time_int = 24.47;
    frame_start = 13;
    frame_lw = 3;
    wound_x = [247;231;215;208;224;258;278;287;284;267]*pixel;
    wound_y = [219;229;246;270;292;292;280;251;233;229]*pixel;
    wound_z = [1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0];
    x_excl = 85;
elseif experiment == 4
    name = 'file 4';
    pixel = 0.2642091;
    time_int = 36.68;
    frame_start = 6;
    frame_lw = 2;
    wound_x = [434;365;348;346;345;361;379;410;443;453;461;459;454;448]*pixel;
    wound_y = [367;387;422;451;481;530;550;560;548;517;482;446;415;390]*pixel;
    wound_z = [1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0];
    x_excl = 60;
elseif experiment == 5
    name = 'file 5';
    pixel = 0.4800001;
    time_int = 36.71;
    frame_start = 6;
    frame_lw = 3;
    wound_x = [274;260;253;256;252;252;253;271;294;308;319;307;300;296;285]*pixel;
    wound_y = [267;269;277;290;296;314;331;344;345;335;321;299;282;269;267]*pixel;
    wound_z = [1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0;1.0];
    x_excl = 500;
end

