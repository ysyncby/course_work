function updateOgrid(angleSpan, angleStep, rangeMax, Tl, map, Xmax, Ymax, R, C)
    
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