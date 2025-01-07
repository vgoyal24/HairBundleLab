function [g1, g2, g3, y1, y2, y3, b1, b2, b3, r1, X_r1, Y_r1, X_r2, Y_r2, X_r3, Y_r3] = bundleVisual(geom)%% Bundle Visualization at the Upright Position
    % Angular increments.
    ang = 0:pi/20:pi;
    ang2 = 0-(pi/2-geom.a2_o):pi/20:pi-(pi/2-geom.a2_o);
    ang3 = 0-(pi/2-geom.a5_o):pi/20:pi-(pi/2-geom.a5_o);
    
    % Defining stereocilia colors
    g1 = 126/255;
    g2 = 171/255;
    g3 = 85/255;
    
    y1 = 245/255;
    y2 = 194/255;
    y3 = 66/255;
    
    b1 = 165/255;
    b2 = 194/255;
    b3 = 227/255;
    
    r1 = 192/255;
    
    % Stereocilia visualization vectors
    % Row 1
    X_r1 = [-geom.r_1*cos(ang) geom.r_1 geom.r_1 geom.r_1*cos(ang) -geom.r_1 -geom.r_1];
    Y_r1 = [-geom.r_1*sin(ang) 0 geom.r_CA-geom.r_1 geom.r_CA-geom.r_1+geom.r_1*sin(ang) geom.r_CA-geom.r_1 0];
    
    % Row 2
    X_r2 = [geom.r_2*cos(ang2)+(-geom.b_12+geom.r_BD*cos(geom.a2_o)) -geom.r_2*cos(ang2)+(-geom.b_12)];
    Y_r2 = [geom.r_BD*sin(geom.a2_o)+geom.r_2*sin(ang2) -geom.r_2*sin(ang2)];
    
    % Row 3
    X_r3 = [geom.r_3*cos(ang3)+(-geom.b_12-geom.b_23+geom.r_EF*cos(geom.a5_o)) -geom.r_3*cos(ang3)+(-geom.b_12-geom.b_23)];
    Y_r3 = [geom.r_EF*sin(geom.a5_o)+geom.r_3*sin(ang3) -geom.r_3*sin(ang3)];
end