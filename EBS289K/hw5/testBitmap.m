clear;
close all;
clc;
global bitmap;
global rangeMax;
global ogrid;
%lidar values
rangeMax = 200; angleSpan = 2*pi; angleStep = angleSpan/360; 
global pOcc;
Xmax = 150; Ymax = 150; %physical dimensions of space (m)
pOcc = 0.9;
R = 500; C = 500; %rows and columns; discretization of physical space in a grid
map=zeros(R, C);
% bitmap = 0.0* ones(R, C); %initialize as empty
ogrid = ones(R,C);
%create test rectangular obstacle
Xsw=70; Ysw = 30;
Xne=Xsw + 30; Yne= Ysw + 20;
[Isw, Jsw] = XYtoIJ(Xsw, Ysw, Xmax, Ymax, R, C);
[Ine, Jne] = XYtoIJ(Xne, Yne, Xmax, Ymax, R, C);
map(Ine:Isw, Jsw:Jne) = 1;
imagesc(map);
for k=1:5
    Tl = SE2([50+10*k  140 -pi/2]);
    p = laserScanner(angleSpan, angleStep, rangeMax, Tl.T, map, Xmax, Ymax);  
    for i=1:length(p)
        angle = p(i,1); range = p(i,2);
        % handle infinite range
        if(isinf(range)) 
            range = rangeMax+1;
        end
        n = updateLaserBeamGrid(angle, range, Tl.T, R, C, Xmax, Ymax);
    end
end
% 
% for k=1:5
%     Tl = SE2([90+10*k  5 pi/2]);
%     p = laserScanner(angleSpan, angleStep, rangeMax, Tl.T, map, Xmax, Ymax);  
%     for i=1:length(p)
%         angle = p(i,1); range = p(i,2);
%         % handle infinite range
%         if(isinf(range)) 
%             range = rangeMax+1;
%         end
%         n = updateLaserBeamGrid(angle, range, Tl.T, R, C, Xmax, Ymax);
%     end
% end
% for k=1:5
%     Tl = SE2([10+10*k  5 pi/2]);
%     p = laserScanner(angleSpan, angleStep, rangeMax, Tl.T, map, Xmax, Ymax);  
%     for i=1:length(p)
%         angle = p(i,1); range = p(i,2);
%         % handle infinite range
%         if(isinf(range)) 
%             range = rangeMax+1;
%         end
%         n = updateLaserBeamGrid(angle, range, Tl.T, R, C, Xmax, Ymax);
%     end
% end
new = ogrid./(1+ogrid);
imagesc(new);

% imagesc(ogrid);
colorbar;
