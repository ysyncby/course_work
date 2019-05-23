% function assumes a laser scanner with a pose in world coordinates defined by Tl. It shoots rays from
% -angleSpan/2 to +angleSpan/2 with step angleStep.
% Given a bitmap (boolean occupancy grid with obstacles) with origin at (0,0) and uper NE corner (Xmax, Ymax),
% the result is a bitmap with detected obstacle pixels and free pixels.
function p = updateLaserBeamGrid(angle, range, Tl, R, C, Xmax, Ymax)
global ogrid;
global pOcc;
%transform laser origin to world frame
P1 = Tl*[0 0 1]';
x1=P1(1);     y1=P1(2);

if (isinf(range)) % handle Inf return values
    range = Xmax^2+Ymax^2;  % assign arbitrary huge value
end

%first produce target point for laser in scanner frame
Xl = range * cos(angle);
Yl = range * sin(angle);

%Transform target point in world frame
P2 = Tl*[Xl Yl 1]';
x2=P2(1); y2=P2(2);

%clip laser beam to boundary polygon so that 'infinite' (rangeMax) range
% extends up to the boundary
dy = y2-y1; dx = x2-x1;
% ATTENTION: if dy or dx is close to 0 but negative, make it almost zero
% positive
if (abs(y2-y1)) < 1E-6
    dy = 1E-6;
end
edge = clipLine([x1,y1,dx,dy],[0 Xmax 0 Ymax]);
%laser origin is always inside map
%decide if clipping is necessary
l1 = sqrt( (x1-edge(3))^2 + (y1 - edge(4))^2);
if range >= l1
    x2 = edge(3); y2 = edge(4);
end

% map world points to integer coordninates
[ I1, J1 ] = XYtoIJ(x1, y1, Xmax, Ymax, R, C); % laser source
[ I2, J2 ] = XYtoIJ(x2, y2, Xmax, Ymax, R, C); % obstacle pixel

%update detected obstacle pixel
ogrid(I2, J2) = ogrid(I2, J2) * (pOcc/(1-pOcc));
if ogrid(I2, J2) > 9000
    ogrid(I2, J2) = 10000;
end
% use bresenham to find all pixels that are between laser and obstacle
l=bresenhamFast(I1,J1,I2,J2);

for k=1:length(l)-1 %skip the target pixel
    ogrid(l(k,1),l(k,2)) = ogrid(l(k,1),l(k,2))/(pOcc/(1-pOcc)); % free pixels
end

p = length(l) + 1;  % number of updated pixels

end

