function rep_pnts = repulesPoints(start_x, start_y, window, Xmax, Ymax, R, C, thres_occup)
    % one rep_pnt = [x,y,occupancy]
    % rep_pnts is a list of repulsive points
    global ogrid;
    ii = 0;
    rep_pnts = zeros(1,1);
    [Ix, Jy] = XYtoIJ(start_x, start_y, Xmax, Ymax, R, C);
    xleft = Ix-window;
    xright = Ix+window;
    yup = Jy + window;
    ydown = Jy - window;
    for i = xleft:xright
        for j = ydown:yup
            if ogrid(i,j) > thres_occup 
                [Xx, Yy] = IJtoXY(i, j, Xmax, Ymax, R, C);
                r_x = round(Xx,1);
                r_y = round(Yy,1);
                if ~(ismember(r_x,rep_pnts(:,1)) && ismember(r_y,rep_pnts(:,2)))
                    ii = ii + 1;
                    rep_pnts(ii,1) = r_x;
                    rep_pnts(ii,2) = r_y;
                    occupancy = ogrid(i,j);
                    if occupancy > 1
                        occupancy = 1;
                    end
                    rep_pnts(ii,3) = occupancy;
                end
            end
        end
    end
end