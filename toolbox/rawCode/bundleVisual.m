function [g1, g2, g3, y1, y2, y3, b1, b2, b3, r1, X_r1, Y_r1, X_r2, Y_r2, X_r3, Y_r3] = bundleVisual(geom)%% Bundle Visualization at the Upright Position
    % Angular increments.
    ang = 0-(pi/2-geom.a1_o):pi/20:pi-(pi/2-geom.a1_o);
    ang2_bot = 0-(pi/2-geom.a2_o):pi/20:pi-(pi/2-geom.a2_o);
    
    if geom.theta12 ~= pi/2 
        ang2 = 0-(pi/2-geom.a2_o):pi/1000:geom.theta12-(pi/2-geom.a2_o);
    else 
        ang2 = 0-(pi/2-geom.a2_o):pi/1000:pi-(pi/2-geom.a2_o);
    end

    ang3_bot = 0-(pi/2-geom.a5_o):pi/20:pi-(pi/2-geom.a5_o);
    if geom.theta23 ~= pi/2 
        ang3 = 0-(pi/2-geom.a5_o):pi/1000:geom.theta23-(pi/2-geom.a5_o);
    else 
        ang3 = 0-(pi/2-geom.a5_o):pi/1000:pi-(pi/2-geom.a5_o);
    end

    % Defining stereocilia colors
    g1 = 98/255;
    g2 = 160/255;
    g3 = 60/255;
    
    y1 = 232/255;
    y2 = 199/255;
    y3 = 70/255;
    
    b1 = 106/255;
    b2 = 191/255;
    b3 = 227/255;
    
    r1 = 192/255;
    
    % Row 1
    X_r1 = [-geom.r_1*cos(ang) geom.r_1 geom.r_1 geom.r_1*cos(ang) -geom.r_1 -geom.r_1];
    Y_r1 = [-geom.r_1*sin(ang) 0 geom.r_CA-geom.r_1 geom.r_CA-geom.r_1+geom.r_1*sin(ang) geom.r_CA-geom.r_1 0];
    
    % Row 2
    if geom.theta12 ~= pi/2
        fac = 0.25;
        
        X_spline_start = geom.r_2*cos(ang2(end))+(-geom.b_12+geom.r_BD*cos(geom.a2_o));
        X_spline_end  = -geom.b_12+(geom.r_BD*cos(geom.a2_o)-geom.r_2/sin(geom.a2_o)-fac*geom.r_2*cos(geom.a2_o));
        Y_spline_start = geom.r_BD*sin(geom.a2_o)+geom.r_2*sin(ang2(end));
        Y_spline_end = (geom.r_BD-fac*geom.r_2)*sin(geom.a2_o);
    
        % Create a smooth spline curve between the first two points
        % Use cubic spline interpolation
        t = linspace(0, 1, 1000);  % 100 points between the start and end
        control_points_x = [X_spline_start, (X_spline_start+X_spline_end)/1.98, X_spline_end];
        control_points_y = [Y_spline_start, (Y_spline_start+Y_spline_end)/1.98, Y_spline_end];
        
        X_smooth = spline([0 0.5 1], control_points_x, t);  % Spline interpolation for X
        Y_smooth = spline([0 0.5 1], control_points_y, t);  % Spline interpolation for Y  
        
        % Stereocilia visualization vectors
        X_r2 = [geom.r_2*cos(ang2)+(-geom.b_12+geom.r_BD*cos(geom.a2_o)) X_smooth -geom.b_12+(geom.r_BD*cos(geom.a2_o)-geom.r_2/sin(geom.a2_o)-fac*geom.r_2*cos(geom.a2_o)) -geom.r_2*cos(ang2_bot)+(-geom.b_12)];
        Y_r2 = [geom.r_BD*sin(geom.a2_o)+geom.r_2*sin(ang2) Y_smooth (geom.r_BD-fac*geom.r_2)*sin(geom.a2_o) -geom.r_2*sin(ang2_bot)];
        
        pp_x = spline([0 0.5 1], control_points_x);
        pp_y = spline([0 0.5 1], control_points_y);
        
        dx = ppval(pp_x, 0);  % where pp_x is the spline output for the X coordinates
        dy = ppval(pp_y, 0);  % where pp_x is the spline output for the X coordinates
    else
        fac = 0;
        % Stereocilia visualization vectors
        X_r2 = [geom.r_2*cos(ang3)+(-geom.b_12+geom.r_BD*cos(geom.a2_o)) -geom.b_12+(geom.r_BD*cos(geom.a2_o)-geom.r_2/sin(geom.a2_o)-fac*geom.r_2*cos(geom.a2_o)) -geom.r_2*cos(ang2)+(-geom.b_12)];
        Y_r2 = [geom.r_BD*sin(geom.a2_o)+geom.r_2*sin(ang3) (geom.r_BD-fac*geom.r_2)*sin(geom.a2_o) -geom.r_2*sin(ang2)];
        X_smooth = 0;
        Y_smooth = 0;
    end
    
    % Row 3
    if geom.theta23 ~= pi/2
        fac = 0.25;
        
        X_spline_start = geom.r_3*cos(ang3(end))+(-geom.b_23-geom.b_12+geom.r_EF*cos(geom.a5_o));
        X_spline_end  = -geom.b_23-geom.b_12+(geom.r_EF*cos(geom.a5_o)-geom.r_3/sin(geom.a5_o)-fac*geom.r_3*cos(geom.a5_o));
        Y_spline_start = geom.r_EF*sin(geom.a5_o)+geom.r_3*sin(ang3(end));
        Y_spline_end = (geom.r_EF-fac*geom.r_3)*sin(geom.a5_o);
    
        % Create a smooth spline curve between the first two points
        % Use cubic spline interpolation
        t = linspace(0, 1, 1000);  % 100 points between the start and end
        control_points_x = [X_spline_start, (X_spline_start+X_spline_end)/1.98, X_spline_end];
        control_points_y = [Y_spline_start, (Y_spline_start+Y_spline_end)/1.98, Y_spline_end];
        
        X_smooth3 = spline([0 0.5 1], control_points_x, t);  % Spline interpolation for X
        Y_smooth3 = spline([0 0.5 1], control_points_y, t);  % Spline interpolation for Y  
        
        % Stereocilia visualization vectors
        X_r3 = [geom.r_3*cos(ang3)+(-geom.b_23-geom.b_12+geom.r_EF*cos(geom.a5_o)) X_smooth3 -geom.b_23-geom.b_12+(geom.r_EF*cos(geom.a5_o)-geom.r_3/sin(geom.a5_o)-fac*geom.r_3*cos(geom.a5_o)) -geom.r_3*cos(ang3_bot)+(-geom.b_12-geom.b_23)];
        Y_r3 = [geom.r_EF*sin(geom.a5_o)+geom.r_3*sin(ang3) Y_smooth3 (geom.r_EF-fac*geom.r_3)*sin(geom.a5_o) -geom.r_3*sin(ang3_bot)];

        pp_x = spline([0 0.5 1], control_points_x);
        pp_y = spline([0 0.5 1], control_points_y);
        
        % disp(pp_x)
        % disp(pp_y)
        dx = ppval(pp_x, 0);  % where pp_x is the spline output for the X coordinates
        % disp(dx);
        dy = ppval(pp_y, 0);  % where pp_x is the spline output for the X coordinates
        % disp(dy);
    else
        fac = 0;
        % Stereocilia visualization vectors
        X_r3 = [geom.r_3*cos(ang3)+(-geom.b_23-geom.b_12+geom.r_EF*cos(geom.a5_o)) -geom.b_23-geom.b_12+(geom.r_EF*cos(geom.a5_o)-geom.r_3/sin(geom.a5_o)-fac*geom.r_3*cos(geom.a5_o)) -geom.r_3*cos(ang3)+(-geom.b_12-geom.b_23)];
        Y_r3 = [geom.r_EF*sin(geom.a5_o)+geom.r_3*sin(ang3) (geom.r_EF-fac*geom.r_3)*sin(geom.a5_o) -geom.r_3*sin(ang3)];
        X_smooth3 = 0;
        Y_smooth3 = 0;
    end
end