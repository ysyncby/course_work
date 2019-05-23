close all;
clear;
clc;
run('startup_rvc.m') % run tool box first

points = pointGenerator();
DMAT = costMat(60, points);
N = 10;
W = 2.5;
v_l = 0; v_l0 = 0; gamma = 0; v_d = 10;
% imagesc(DMAT)
resultStruct = tspof_ga('xy', points , 'DMAT', DMAT, 'SHOWRESULT', false, 'SHOWWAITBAR', false, 'SHOWPROG', false);
route = [1 resultStruct.optRoute 2*N+2];
L = 3;
l_d = 2;
gamma0 = 0;
start_x = -W;
start_y = 10;
start_angle = deg2rad(-90);
if route(2)>N
    start_angle = deg2rad(90);
end
currentIndex = 1;
Rmin = L/tan(deg2rad(60));


path = pathMaker(route, points, Rmin, W, N);
ss = size(path);
s = ss(2);
figure(1);
axis equal;
grid on;
hold on;
xlim([-5, 25]);
ylim([-5, 25]);
for i = 1:1:s
    hold on;
    plot(path(1,i),path(2,i),'.');
%     pause(0.01);
end

for i = 1:1:40000
    [angle, error, isend] = purePursuitController(start_x, start_y, start_angle, L, l_d, path, currentIndex);
    [x, y, theta, v_l, gamma] = ackermann(start_x, start_y, start_angle, v_l0, gamma0, angle, v_d);
    start_x = x; start_y = y; start_angle = theta;v_l0 = v_l; gamma0 = gamma;
    if isend == true
        break
    end
    [closest, newIndex] = closepoint2([x;y], path, currentIndex);
    currentIndex = newIndex;
end



function [closest, index] = closepoint2(loc, path, curIndex)
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

function points = pointGenerator()
    W = 2.5;
    RL = 20;
    N = 10;
    points = zeros(2,1);
    % start point
    points(:,1) = [-W;RL/2];
    % 2 to N+1
    for i = 2:1:N+1
        points(:,i) = [(i-2)*W;0];
    end    
    % N+2 to 2N+1
    for i = N+2:1:2*N+1
        points(:,i) = [(i-2-N)*W;RL];
    end    
    %end point
    points(:,2*N+2) = [-W;RL/2];
    points = transpose(points);
end

function DMAT = costMat(gamma, points)
    N = 10;
    W = 2.5;
    L = 3;
    Rmin = L/tan(deg2rad(gamma));
    startnode = points(1,:);
    endnode = points(2*N+2,:);
    % cost 0: move straight up and down 
    % cost Inf: move diagonal
    DMAT = zeros(1,1);
    for i = 2:1:N+1
        for j = N+2:1:2*N+1
            if j-i == N
                DMAT(i,j) = 0;
                DMAT(j,i) = 0;
            else
                DMAT(i,j) = Inf;
                DMAT(j,i) = Inf;
            end
        end
    end
    
    for i = 2:1:N % for each node at the ‘bottom’
        for j= i+1:1:N+1 % for each node to the ‘right’ of the node
            dis = abs(i-j);
            % a PI turn can be made (plus a straight line of length (d-1) row widths)
            if (Rmin <= dis*W/2) 
                DMAT(i,j) = dis*W + (pi-2)*Rmin;
            else % make an omega turn
                DMAT(i,j) = 3*pi*Rmin-2*Rmin*acos(1-(2*Rmin+dis*W)^2/(8*Rmin^2));
            end
            DMAT(j,i)=DMAT(i,j);
            DMAT(i+N, j+N) = DMAT(i,j); 
            DMAT(j+N, i+N)= DMAT(i,j);
        end
    end
    
    for i = 2:1:2*N+1
        node = points(i,:);
        DMAT(1,i) = abs(startnode(1)-node(1))+abs(startnode(2)-node(2));
        DMAT(i,1) = DMAT(1,i);
        DMAT(2*N+2,i) = abs(endnode(1)-node(1))+abs(endnode(2)-node(2));
        DMAT(i,2*N+2) = DMAT(2*N+2,i);
    end
end

function path = pathMaker(route, points, Rmin, W, N)
    size_route = size(route);
    num = size_route(2);
    path = [;];
%     direction = 0;
    for i = 2:1:num
        index1 = route(i-1);
        index2 = route(i);
        % start path
        if index1 == 1 
            tmp_path = endPath(index1, index2, points, Rmin);
        % end path
        elseif index2 == num
            tmp_path = endPath(index1, index2, points, Rmin);
        % straight path
        elseif abs(index1 - index2) == N    
            tmp_path = straightPath(index1, index2, points);
        % maneuver path
        else
            if index1>(N+1)
                direction = 'u';
            else
                direction = 'd';
            end
            
            if abs(index1 - index2)*W >= 2*Rmin
                tmp_path = piPath(index1, index2, points, Rmin, direction);
            else
                tmp_path = omegaPath(index1, index2, points, Rmin, direction);
            end
        end
        path = cat(2,path, tmp_path);
    end
end

function endpath = endPath(index1, index2, points, Rmin)
    N = 10;
    node1 = points(index1,:);
    node2 = points(index2,:);
    if index2 < N || index1 > N
        [node1, node2] = deal(node2, node1);
    end
    if (index2 == 2*N+2 && index1<N+2) || (index1 == 1 && index2<N+2)
        y1 = node1(2):-0.1:node1(2)-Rmin;
        x1 = node1(1) + 0*y1;
        p1 = [x1;y1];
        
        x2 = node1(1):-0.1:node2(1);
        y2 = node1(2)-Rmin+0*x2;
        p2 = [x2;y2];
        endpath = cat(2, p1, p2);

        y3 = node1(2)-Rmin:0.1:node2(2);
        x3 = node2(1)+0*y3;
        p3 = [x3;y3];
        endpath = cat(2, endpath, p3);
    else
        y1 = node1(2):0.1:node2(2)+Rmin;
        x1 = node1(1) + 0*y1;
        p1 = [x1;y1];
        
        x2 = node1(1):0.1:node2(1);
        y2 = node2(2)+Rmin+0*x2;
        p2 = [x2;y2];
        endpath = cat(2, p1, p2);

        y3 = node2(2)+Rmin:-0.1:node2(2);
        x3 = node2(1)+0*y3;
        p3 = [x3;y3];
        endpath = cat(2, endpath, p3);
    end
    if index2 < N || index1 > N
        endpath = fliplr(endpath);
    end
end

function strapath = straightPath(index1, index2, points)
    node1 = points(index1,:);
    node2 = points(index2,:);
    if index1> index2
        y = node1(2):-0.1:node2(2);
        x = node1(1) + 0*y;
        strapath = [x;y];
    else
        y = node1(2):0.1:node2(2);
        x = node1(1) + 0*y;
        strapath = [x;y];
    end
end
function pipath = piPath(index1, index2, points, Rmin, direction)

    node1 = points(index1,:);
    node2 = points(index2,:);
    if index1 > index2
        [node1, node2] = deal(node2, node1);
    end
    if direction == 'u'
        % first quarter
        a = 3/2*pi:-0.1:pi; 
        x = node1(1)+Rmin+Rmin*sin(a); 
        y = node1(2)-Rmin*cos(a);
        opath1 = [x;y];

        % mid straight
        a = node1(1)+Rmin:0.2:node2(1)-Rmin; 
        x = a;
        y = node1(2) + Rmin + 0*a;
        opath2 = [x;y];
        pipath = cat(2, opath1, opath2);

        % second quarter
        a = pi:-0.1:pi/2; 
        x = node2(1)-Rmin+Rmin*sin(a); 
        y = node2(2)-Rmin*cos(a);
        opath3 = [x;y];
        pipath = cat(2, pipath, opath3);
    else
                % first quarter
        a = -pi/2:0.1:0; 
        x = node1(1)+Rmin+Rmin*sin(a); 
        y = node1(2)-Rmin*cos(a);
        opath1 = [x;y];

        % mid straight
        a = node1(1)+Rmin:0.2:node2(1)-Rmin; 
        x = a;
        y = node1(2) - Rmin + 0*a;
        opath2 = [x;y];
        pipath = cat(2, opath1, opath2);

        % second quarter
        a = 0:0.1:pi/2; 
        x = node2(1)-Rmin+Rmin*sin(a); 
        y = node2(2)-Rmin*cos(a);
        opath3 = [x;y];
        pipath = cat(2, pipath, opath3);
    end
    if index1>index2
        pipath = fliplr(pipath);
    end
end

function opath = omegaPath(index1, index2, points, Rmin, direction)

    node1 = points(index1,:);
    node2 = points(index2,:);
    if index1 > index2
        [node1, node2] = deal(node2, node1);
    end
    theta = acos((0.5*abs(node1(1)-node2(1))+Rmin)/(2*Rmin));
    if direction == 'u'
        % first left
        a = pi/2:0.1:(pi/2+theta);
        x = node1(1)-Rmin+Rmin*sin(a); 
        y = node1(2)-Rmin*cos(a);
        opath1 = [x;y];

        % mid right
        a = (theta-pi/2):-0.1:(-3*pi/2-theta);
        x = (node1(1)+node2(1))/2+Rmin*sin(a); 
        y = 2*Rmin*sin(theta)+node1(2)-Rmin*cos(a);
        opath2 = [x;y];
        opath = cat(2, opath1, opath2);
        
        % second left
        a = 3/2*pi-theta:0.1:3*pi/2; 
        x = node2(1)+Rmin+Rmin*sin(a); 
        y = node1(2)-Rmin*cos(a);
        opath3 = [x;y];
        opath = cat(2,opath, opath3);
    else
        % first right
        a = pi/2:-0.1:(pi/2-theta);
        x = node1(1)-Rmin+Rmin*sin(a); 
        y = node1(2)-Rmin*cos(a);
        opath1 = [x;y];

        % mid left
        a = (-pi/2-theta):0.1:(pi/2+theta);
        x = (node1(1)+node2(1))/2+Rmin*sin(a); 
        y = -2*Rmin*sin(theta)-Rmin*cos(a);
        opath2 = [x;y];
        opath = cat(2, opath1, opath2);
        
        % second right
        a = 3/2*pi+theta:-0.1:3*pi/2; 
        x = node2(1)+Rmin+Rmin*sin(a); 
        y = node1(2)-Rmin*cos(a);
        opath3 = [x;y];
        opath = cat(2,opath, opath3);
    end
    if index1>index2
        opath = fliplr(opath);
    end
end

