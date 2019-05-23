close all;
clear all;
clc;
run('startup_rvc.m') % run tool box first

% parameters we use most
gamma_d = deg2rad(68);
v_d = 5;
tau_v = 0;
tau_gamma = 2;
s = 0;
gamma_max = deg2rad(45);
v_max = 5;

% other parameters
dt = 0.01;
DT = 0.01;
t_max = pi/0.1;

x=0; x0 = 0;
y=0; y0 = 0;
theta=0; theta0=0;

gamma0 = 0; gamma = 0;
L = 2.5;
radius = 0.5;
omega = 2;
delta1 = deg2rad(0);
delta2 = deg2rad(0);

v_l = 0;
v_y = 0;

% initialize a figure
figure(1);
axis equal;
grid on;
hold on;
xlim([-5, 10]);
ylim([-5, 10]);

v_store = zeros(1,100);
i = 1;
tractor = tractor_builder();

for t_DT = 0:DT:t_max  
    % check if tau of velocity is 0 or not
    if tau_v == 0
        v_l = (1-s)*v_d;
    else
        v_l = v_l + DT*(-v_l + (1-s)*v_d)/tau_v;
    end
    v_store(i) = v_l;
    i = i+1;
    
    % check if tau of gamma is 0 or not
    if tau_gamma == 0
        gamma = gamma_d;
    else
        gamma = (-gamma + gamma_d)/tau_gamma;
    end
    
    % control v_l
    if v_l < -v_max % constraint
        v_l = -v_max;
    elseif v_l > v_max
        v_l = v_max;
    end

    % control gamma
    if gamma < -gamma_max % constraint
        gamma = -gamma_max;
    elseif gamma > gamma_max
        gamma = gamma_max;
    end
    
    % calculate v_y based on delta2
    v_y = v_l*tan(delta2);
    T0 = transl2(x0, y0) * trot2(theta0, 'rad');
    plotTractor(tractor, T0, 'white');
    % solve the kinematic differential equations
    for t_dt = t_DT:dt:t_DT+DT-dt 
        x = x0+dt*(v_l*cos(theta0)-v_y*sin(theta0));
        y = y0+dt*(v_l*sin(theta0)+v_y*cos(theta0));
        theta = theta0+dt*(v_l/L*tan(gamma+delta1)-v_y/L);
        x0 = x;
        y0 = y;
        theta0 = theta;
    end
    T0 = transl2(x0, y0) * trot2(theta0, 'rad');
    plotTractor(tractor, T0, 'blue');

    
    plot(x,y,'.','color','red', 'DisplayName','tau = 0'); % draw the trajectory
    gamma0 = gamma;
    % used to show the figure
    pause(0.001); 
    if abs(x-0) < 0.03 && y>2
        break
    end
end

% function to generate a tractor
function tractor = tractor_builder()
tractor = [0 1.5 0 0; 
           -0.5 0 0.5 -0.5; 
           1 1 1 1];
end

% function: tractor plotor
function plotTractor(tractor, T, color)
tractor = T*tractor;
tractor_xy = h2e(tractor);
tractor_x = tractor_xy(1,:);
tractor_y = tractor_xy(2,:);

pause(0.00001);
plot(tractor_x,tractor_y, color, 'LineWidth', 0.5);
xlim([-5, 10]);
ylim([-5, 10]);
end
