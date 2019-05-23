clear;
close all;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% There are two situations:
% choose situation 1: 1 obstacle, 
% choose situation 2: 8 obstacles.
% situation = 1;
situation = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ackermann system variables
L = 2.5;
v_l = 0; v_l0 = 0; gamma = 0; v_max = 10;gamma0 = 0;

start_x = 25;start_y = 5;start_angle = pi/2;% start pose
target_x = 25;target_y = 30;% target position

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% map and lidar variables
global rangeMax;
rangeMax = 200; angleSpan = 2*pi; angleStep = angleSpan/360; 
Xmax = 50; Ymax = 50; %physical dimensions of space (m)
global pOcc;pOcc = 0.9;

R = 500; C = 500; %rows and columns; discretization of physical space in a grid
map=zeros(R, C);

global ogrid;ogrid = ones(R,C);
thres_occup = 0.7;%a filter to elimite occupancy grid

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% virtual force field variables
fcr = 6; % repulsive force magnitude
fct = 1; % target attraction magnitude
window = 2*R/Xmax;  % range we considered for obstacels

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% low pass filter variables
lowpass_t = 0.1;
lowpass_tau = 0.3;
old_angle = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create a figure to show the trajectory 
figure(1);
axis equal;
grid on;
hold on;
xlim([20, 30]);
ylim([0, 35]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create obstacles for bitmap 
% which is the real obstacles for laser to detect. 
if situation == 1
    % 1 obstacle
    Xsw=25.4; Ysw = 15;
    Xne=Xsw + 1; Yne= Ysw + 1;
    [Isw, Jsw] = XYtoIJ(Xsw, Ysw, Xmax, Ymax, R, C);
    [Ine, Jne] = XYtoIJ(Xne, Yne, Xmax, Ymax, R, C);
    map(Ine:Isw, Jsw:Jne) = 1;
    
elseif situation == 2
    % 8 obstacles
    v1 = 24.5; v2 = 16.5;
    Xsw=v1; Ysw = v2;
    Xne=Xsw + 0.3; Yne= Ysw + 0.3;
    [Isw, Jsw] = XYtoIJ(Xsw, Ysw, Xmax, Ymax, R, C);
    [Ine, Jne] = XYtoIJ(Xne, Yne, Xmax, Ymax, R, C);
    map(Ine:Isw, Jsw:Jne) = 1;
    
    Xsw=v1+0.3; Ysw = v2-1;
    Xne=Xsw + 0.3; Yne= Ysw + 0.3;
    [Isw, Jsw] = XYtoIJ(Xsw, Ysw, Xmax, Ymax, R, C);
    [Ine, Jne] = XYtoIJ(Xne, Yne, Xmax, Ymax, R, C);
    map(Ine:Isw, Jsw:Jne) = 1;
    
    Xsw=v1+0.6; Ysw = v2-2;
    Xne=Xsw + 0.3; Yne= Ysw + 0.3;
    [Isw, Jsw] = XYtoIJ(Xsw, Ysw, Xmax, Ymax, R, C);
    [Ine, Jne] = XYtoIJ(Xne, Yne, Xmax, Ymax, R, C);
    map(Ine:Isw, Jsw:Jne) = 1;
    
    Xsw=v1+0.9; Ysw = v2-3;
    Xne=Xsw + 0.3; Yne= Ysw + 0.3;
    [Isw, Jsw] = XYtoIJ(Xsw, Ysw, Xmax, Ymax, R, C);
    [Ine, Jne] = XYtoIJ(Xne, Yne, Xmax, Ymax, R, C);
    map(Ine:Isw, Jsw:Jne) = 1;
    
    Xsw=v1-3; Ysw = v2;
    Xne=Xsw + 0.3; Yne= Ysw + 0.3;
    [Isw, Jsw] = XYtoIJ(Xsw, Ysw, Xmax, Ymax, R, C);
    [Ine, Jne] = XYtoIJ(Xne, Yne, Xmax, Ymax, R, C);
    map(Ine:Isw, Jsw:Jne) = 1;
    
    Xsw=v1-3+0.3; Ysw = v2-1;
    Xne=Xsw + 0.3; Yne= Ysw + 0.3;
    [Isw, Jsw] = XYtoIJ(Xsw, Ysw, Xmax, Ymax, R, C);
    [Ine, Jne] = XYtoIJ(Xne, Yne, Xmax, Ymax, R, C);
    map(Ine:Isw, Jsw:Jne) = 1;
    
    Xsw=v1-3+0.6; Ysw = v2-2;
    Xne=Xsw + 0.3; Yne= Ysw + 0.3;
    [Isw, Jsw] = XYtoIJ(Xsw, Ysw, Xmax, Ymax, R, C);
    [Ine, Jne] = XYtoIJ(Xne, Yne, Xmax, Ymax, R, C);
    map(Ine:Isw, Jsw:Jne) = 1;
    
    Xsw=v1-3+0.9; Ysw = v2-3;
    Xne=Xsw + 0.3; Yne= Ysw + 0.3;
    [Isw, Jsw] = XYtoIJ(Xsw, Ysw, Xmax, Ymax, R, C);
    [Ine, Jne] = XYtoIJ(Xne, Yne, Xmax, Ymax, R, C);
    map(Ine:Isw, Jsw:Jne) = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create obstacles for the display figure
if situation == 1
    Xsw=25.4;
    obstale = [Xsw Xsw+1 Xsw+1 Xsw Xsw; 
               15 15 16 16 15];
    plot(obstale(1,:),obstale(2,:), 'black', 'LineWidth', 0.5);
else
    obstale = [v1 v1+0.3 v1+0.3 v1 v1; 
               v2 v2     v2+0.3 v2+0.3 v2];
    plot(obstale(1,:),obstale(2,:), 'black', 'LineWidth', 0.5);hold on;
    v1 = v1-3;
    obstale = [v1 v1+0.3 v1+0.3 v1 v1; 
               v2 v2     v2+0.3 v2+0.3 v2];
    plot(obstale(1,:),obstale(2,:), 'black', 'LineWidth', 0.5);hold on;
    v1 = v1+0.3; v2 = v2-1;
    obstale = [v1 v1+0.3 v1+0.3 v1 v1; 
               v2 v2     v2+0.3 v2+0.3 v2];
    plot(obstale(1,:),obstale(2,:), 'black', 'LineWidth', 0.5);hold on;
    v1 = v1+3; 
    obstale = [v1 v1+0.3 v1+0.3 v1 v1; 
               v2 v2     v2+0.3 v2+0.3 v2];
    plot(obstale(1,:),obstale(2,:), 'black', 'LineWidth', 0.5);hold on;
    v1 = v1+0.3; v2 = v2-1;
    obstale = [v1 v1+0.3 v1+0.3 v1 v1; 
               v2 v2     v2+0.3 v2+0.3 v2];
    plot(obstale(1,:),obstale(2,:), 'black', 'LineWidth', 0.5);hold on;
    v1 = v1-3; 
    obstale = [v1 v1+0.3 v1+0.3 v1 v1; 
               v2 v2     v2+0.3 v2+0.3 v2];
    plot(obstale(1,:),obstale(2,:), 'black', 'LineWidth', 0.5);hold on;
    v1 = v1+0.3; v2 = v2-1;
    obstale = [v1 v1+0.3 v1+0.3 v1 v1; 
               v2 v2     v2+0.3 v2+0.3 v2];
    plot(obstale(1,:),obstale(2,:), 'black', 'LineWidth', 0.5);hold on;
    v1 = v1+3; 
    obstale = [v1 v1+0.3 v1+0.3 v1 v1; 
               v2 v2     v2+0.3 v2+0.3 v2];
    plot(obstale(1,:),obstale(2,:), 'black', 'LineWidth', 0.5);hold on;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main running loop
st_angle_raw = zeros(1,1);
st_angle_lowPass = zeros(1,1);
for i = 1:1:40000
    Tl = SE2([start_x  start_y 0]);
    % update occupancy grid
    updateOgrid(angleSpan, angleStep, rangeMax, Tl, map, Xmax, Ymax, R, C)
    % list all repulsive points in current window
    repulsive_points = repulesPoints(start_x, start_y, window, Xmax, Ymax, R, C, thres_occup);
    % angle: virtual force angle; 
    % theta: the angle difference between replusive force and the velocity of our robot
    [angle, theta] = virtualForceField(fcr, fct, repulsive_points, target_x, target_y, start_x, start_y, start_angle);
    % based on theta, adjust velocity of the robot
    v_d = (1-abs(cos(theta)))*v_max;
    % transform the desired angle to steering angle
    new_angle = atan(L*(angle-start_angle)/v_d);
    % add a low pass filter to the steering angle
    real_angle = (lowpass_t*new_angle + (lowpass_tau-lowpass_t)*old_angle)/lowpass_tau;
    % run the ackermann system
    [x, y, theta, v_l, gamma] = ackermann(start_x, start_y, start_angle, v_l0, gamma0, new_angle, v_d);
    % update variables
    old_angle = new_angle;
    start_x = x; 
    start_y = y; 
    start_angle = theta;
    v_l0 = v_l; 
    gamma0 = gamma;
    st_angle_raw = [st_angle_raw; rad2deg(new_angle)];
    st_angle_lowPass = [st_angle_lowPass; rad2deg(real_angle)];
    % stop the robot when we close to the target
    if start_y > 30
        break
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2);
plot(st_angle_raw,'--b.'); hold on;
plot(st_angle_lowPass,'--r.'); hold on;
legend('raw steering angle','steering angle lowpass filter')