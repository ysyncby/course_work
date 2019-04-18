close all;
clear all;
clc;
run('startup_rvc.m') % run tool box first

% start point (x,y,theta)
x=0; 
y=0;
theta=0;

% running position' of the car contains (x',y',theta')
x_h=0; 
y_h=0; 
theta_h=0; 

% slippy parameters
s_l = 0.1; % left wheel slip 
s_r = 0.2; % right wheel slip 
delta = 5; % : wheel skidding

% Main Function
% step 1: build a tractor
tractor = tractor_builder(); 
T_old = transl2(x, y) * trot2(theta, 'deg');

% step 2: rectangle without slips and skidding
figure(1);
axis equal;
grid on;

for i=1:1:4
    % speed parameters for going straight
    V = 1;
    omega = 0;
    for ii=1:1:100
        [x_h, y_h, theta_h] = kinematic(V, omega, 0, 0, 0, x, y, theta);
        T = transl2(x_h, y_h) * trot2(theta_h, 'deg');
        hold on;
        plotTractor(tractor, T_old, 'white');
        plotTractor(tractor, T, 'blue');
        x=x_h;
        y=y_h;
        theta=theta_h;
        T_old = T;
    end
    
    % speed parameters for rotating
    V = 0;
    omega = pi/2;
    for iii=1:1:20
        [x_h, y_h, theta_h] = kinematic(V, omega, 0, 0, 0, x, y, theta);
        T = transl2(x_h, y_h) * trot2(theta_h, 'deg');
        hold on;
        plotTractor(tractor, T_old, 'white');
        plotTractor(tractor, T, 'blue');
        x=x_h;
        y=y_h;
        theta=theta_h;
        T_old = T;
    end
end

% step 3: rectangle with slips and skidding
for i=1:1:4
    % speed parameters for going straight
    V = 1;
    omega = 0;
    for ii=1:1:100
        [x_h, y_h, theta_h] = kinematic(V, omega, s_l, s_r, delta, x, y, theta);
        T = transl2(x_h, y_h) * trot2(theta_h, 'deg');
        hold on;
        plotTractor(tractor, T_old, 'white');
        plotTractor(tractor, T, 'blue');
        x=x_h;
        y=y_h;
        theta=theta_h;
        T_old = T;
    end
    
    % speed parameters for rotating
    V = 0;
    omega = pi/2;
    for iii=1:1:20
        [x_h, y_h, theta_h] = kinematic(V, omega, s_l, s_r, delta, x, y, theta);
        T = transl2(x_h, y_h) * trot2(theta_h, 'deg');
        hold on;
        plotTractor(tractor, T_old, 'white');
        plotTractor(tractor, T, 'blue');
        x=x_h;
        y=y_h;
        theta=theta_h;
        T_old = T;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function part
% Function 1: tractor builder
function tractor = tractor_builder()
tractor = [-0.5 0.5 0.5 -0.5 -0.5; 
           -0.5 -0.5 0.5 0.5 -0.5; 
           1 1 1 1 1];
end

% Function 2: kinematic model
function [x_h, y_h, theta_h] = kinematic(V, omega, s_l, s_r, delta, x, y, theta)
l = 1;
r_w = 0.5;
delta_t = 0.05;
% calcuate the desired vl, Omega_l and vr, Omega_r based on V and Omega
v_r = (omega*l + 2*V)/2; 
v_l = (2*V - omega*l)/2;
omega_l = v_l/r_w;
omega_r = v_r/r_w;

% add slip to v_l and v_r
v_l = (1-s_l)*r_w*omega_l;
v_r = (1-s_r)*r_w*omega_r;

% calculate new V_l and new Omega based on slip v_l and v_r
V_l = (v_l + v_r)/2;
omega = rad2deg((v_r - v_l)/l);

% add skidding
V_y = tand(delta)*V_l;

x_h = x + delta_t*(V_l*cosd(theta) - V_y*sind(theta));
y_h = y + delta_t*(V_l*sind(theta) + V_y*cosd(theta));
theta_h = theta + delta_t*omega;
end

% Function 3: tractor plotor
function plotTractor(tractor, T, color)
tractor = T*tractor;
tractor_xy = h2e(tractor);
tractor_x = tractor_xy(1,:);
tractor_y = tractor_xy(2,:);
% 
pause(0.00001);
plot(tractor_x,tractor_y, color, 'LineWidth', 0.5);
plot(mean(tractor_xy(1,1:4)), mean(tractor_xy(2,1:4)), 'Marker', '.', 'color', 'black');
xlim([-5, 10]);
ylim([-5, 10]);
end
