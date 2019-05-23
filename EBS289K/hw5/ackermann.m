function [x, y, theta, v_l, gamma] = ackermann(x0, y0, theta0, v_l, gamma, gamma_d, v_d)
    % ackermann model
    
    % parameters we use most
    tau_v = 0;
    tau_gamma = 0;
    s = 0;
    gamma_max = deg2rad(60);
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
%         dot = [-1.25; 0; 1];
%         dot = T0*dot;
%         plot(dot(1),dot(2),'.','color','red', 'DisplayName','tau = 0'); % draw the trajectory
        % used to show the figure
        pause(0.001); 

    end
end

function tractor = tractor_builder()
    % function to generate a tractor
    tractor = [-1.25 1.25 1.25 -1.25; 
           -0.75 -0.75 0.75 0.75; 
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