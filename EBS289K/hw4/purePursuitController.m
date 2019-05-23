
function [angle, error, isend] = purePursuitController(x, y, theta, L, l_d, path, curIndex)
    % return the input angle of bicyle model and the error 
    [point, index] = closepoint([x;y],path, curIndex);
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

function [closest, index] = closepoint(loc, path, curIndex)
    % return the point close to us most and the index of that point
    range = 30;
    min_dis = sqrt((path(1,1)-loc(1))^2 + (path(2,1)-loc(2))^2);
    s = size(path);
    num = s(2);
    closest = [0;0];
    index = 0;
    left = curIndex-range;
    if curIndex-range<1
        left = 1;
    end
    right = curIndex+range;
    if curIndex+range>num
        right = num;
    end
    if num ~=0
        for i = left:1:right
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
    range = 30;
    right = index+range;
    s = size(path);
    num = s(2);
    if index+range > num
        right = num;
    end
    for_path = path(:,index:right);
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
