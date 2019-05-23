function [angle, theta] = virtualForceField(fcr, fct, repules, target_x, target_y, start_x, start_y, start_angle)
    % angle: virtual force angle; 
    % theta: the angle difference between replusive force and the velocity of our robot
    
    [row, col] = size(repules);
    s_x = 0;
    s_y = 0;
    f_r_y = 0;
    f_r_x = 0;
    start_x = start_x + 1.25*cos(start_angle);
    start_y = start_y + 1.25*sin(start_angle);
    if row > 1
        for i = 1:row
            occupancy = repules(i,3);
            d = sqrt((start_x-repules(i,1))^2+(start_y-repules(i,2))^2);
            f_r_x = occupancy*fcr*(start_x - repules(i,1))/d^4;
            f_r_y = occupancy*fcr*(start_y - repules(i,2))/d^4;
            s_x = s_x + f_r_x;
            s_y = s_y + f_r_y;
        end
    end
    f_t_x = fct*(target_x - start_x);
    f_t_y = fct*(target_y - start_y);
    f_y = f_t_y+s_y;
    f_x = f_t_x+s_x;
    if abs(f_x) < 0.01
        angle = pi/2;
    else
        if f_x <0
            angle = pi + atan(f_y/f_x);
        else
            angle = atan(f_y/f_x);
        end
    end
    
    if abs(f_r_x) < 0.01
        theta = pi/2;
    else
        theta = angdiff(start_angle,atan(f_r_y/f_r_x));
    end
      
end