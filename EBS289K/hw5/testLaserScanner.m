
%test laser scanner


clear all; clear workspace;
% create robot workspace
R = 1000; C = 1000;
map=makemap(R);

Xmax = 100; Ymax = 100;

% map=zeros(R, C);
% %test rectangular obstacle
% Xsw=70; Ysw = 30;
% Xne=Xsw + 30; Yne= Ysw + 20;
% [Isw, Jsw] = XYtoIJ(Xsw, Ysw, Xmax, Ymax, R, C);
% [Ine, Jne] = XYtoIJ(Xne, Yne, Xmax, Ymax, R, C);
% map(Ine:Isw, Jsw:Jne) = 1;

angleSpan=pi;angleStep=pi/100;
rangeMax=50;
Tl=SE2([50 0.1 pi/2]); %current laser pose (coordinate frame) wrt world


p = laserScanner(angleSpan, angleStep, rangeMax, Tl.T, map, Xmax, Ymax); % contains angle and range readings

figure(2);
p(isinf(p(:,2)), 2)=-1; % replace all infinite/out of range values with -1 to plot them
plot(p(:,1)*180/pi, p(:,2)); % plot angle and range - it is displayed in ccw, from -angleSpan/2 to +angleSpan/2


