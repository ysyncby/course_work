close all;
clear all;
clc;
run('startup_rvc.m') % run tool box first

% if you choose 1, tractor will follow a circle
% if you choose 2, tractor will follow a step function

% path 1:
% x0 = 15; y0 = 5*pi/2; theta0 = deg2rad(90);path = pathGenerator('c');

% path 2:
x0 = 0; y0 = 0; theta0 = deg2rad(0);path = pathGenerator('s');

% main function
v_l0 = 0;   % velocity starts at 0 m/s
gamma0 = 0; % gamma starts at 0 degree
x = 0; y = 0; theta = 0;v_l = 0; gamma = 0; v_d = 10;
figure(1);
axis equal;
grid on;
hold on;
xlim([-5, 30]);
ylim([-5, 30]);
l_d = 3;
plot(path(1,:),path(2,:), '.')
err_store = zeros(1,1);
for i = 1:1:4000
    [angle, error, isend] = purePursuitController(x0, y0, theta0, 2.5, l_d, path);
    err_store(1,i) = error;
    [x, y, theta, v_l, gamma] = ackermann(x0, y0, theta0, v_l0, gamma0, angle, v_d);
    x0 = x; y0 = y; theta0 = theta;v_l0 = v_l; gamma0 = gamma;
    if isend == true
        break
    end
end
ploterror(err_store);
staterror(err_store);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions used in the assignment
function path = pathGenerator(type)
    %generate circle path
    if type == 'c'
        a=0:0.1:2*pi; 
        x=9+5*sin(a); 
        y=7-5*cos(a);
        path = [x;y];
    end
    %generate step path
    if type == 's'
        d_t = 0.1;
        
        x1=0:d_t:10;
        y1=0*x1;

        y2=0:d_t:5;
        x2 = 10+0*y2;

        x3=10:d_t:20;
        y3=0*x3+5;

        path = [x1 x2 x3; y1 y2 y3];   
    end
end

function [angle, error, isend] = purePursuitController(x, y, theta, L, l_d, path)
    % return the input angle of bicyle model and the error 
    [point, index] = closepoint([x;y],path);
    s = size(path);
    num = s(2);
    if index == num 
        isend = true;
    else
        isend = false;
    end
    target = findnext(point, index, path, l_d);
    
    T0 = transl2(x, y) * trot2(theta, 'rad');
    target_robot_frame = inv(T0)*[target;1];
    e_y = target_robot_frame(2);
    k = 2*e_y/(l_d^2);
    angle = atan(k*L);
    error = sqrt((point(1)-x)^2+(point(2)-y)^2);
end

function [closest, index] = closepoint(loc, path)
    % return the point close to us most and the index of that point
    min_dis = sqrt((path(1,1)-loc(1))^2 + (path(2,1)-loc(2))^2);
    s = size(path);
    num = s(2);
    closest = [0;0];
    index = 0;
    if num ~=0
        for i = 1:1:num
            dis = sqrt((path(1,i)-loc(1))^2 + (path(2,i)-loc(2))^2);
            if dis <= min_dis
                closest = path(:,i);
                min_dis = dis;
                index = i;
            end
        end
    end
end

function target = findnext(current, index, path, l_d)
    % return the next target which is the farthest point within Ld
    % return (0,0) if not found any
    for_path = path(:,index:end);
    s = size(for_path);
    num = s(2);
    target = [0;0];
    
    if num ~= 0 
        for i = 1:1:num
            dis = sqrt((for_path(1,i)-current(1))^2 + (for_path(2,i)-current(2))^2);
            if dis < l_d
                target = for_path(:,i);
            else
                break
            end
        end
    end
end

function [x, y, theta, v_l, gamma] = ackermann(x0, y0, theta0, v_l, gamma, gamma_d, v_d)
    % ackermann model
    
    % parameters we use most
    tau_v = 0;
    tau_gamma = 0;
    s = 0;
    gamma_max = deg2rad(45);
    v_max = 1;

    % time parameters
    dt = 0.01;
    DT = 0.1;
    t_max = 0;

    L = 2.5;
    delta1 = deg2rad(0);
    delta2 = deg2rad(0);

    tractor = tractor_builder();

    for t_DT = 0:DT:t_max  
        % check if tau of velocity is 0 or not
        if tau_v == 0
            v_l = (1-s)*v_d;
        else
            v_l = v_l + DT*(-v_l + (1-s)*v_d)/tau_v;
        end
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
        
        % used to show the figure
        pause(0.001); 

    end
end

function tractor = tractor_builder()
    % function to generate a tractor
    tractor = [0 1.5 0 0; 
               -0.5 0 0.5 -0.5; 
               1 1 1 1];
end

function plotTractor(tractor, T, color)
    % function: tractor plotor
    tractor = T*tractor;
    tractor_xy = h2e(tractor);
    tractor_x = tractor_xy(1,:);
    tractor_y = tractor_xy(2,:);
    plot(tractor_x,tractor_y, color, 'LineWidth', 0.5);
end

function ploterror(err_store)
    figure(2);
    plot(err_store);
    title('errors of each DT');
    xlabel('per DT');
    ylabel('distance to closest point');
end

function staterror(err_store)
% draw histogram of errors
figure(3)
histogram(err_store);
average = mean(err_store) 
max_error = max(err_store)
percentile95 = prctile(err_store,95)
RMS = sqrt(mean(err_store .^2))
end
