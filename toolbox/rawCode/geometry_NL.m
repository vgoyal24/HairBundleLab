function [geom, func, l1, l2] = geometry_NL(phi_o, la1_o, la2_o, theta12, theta23)
    syms phi la1 la2
    
    % Updated from Furness (2008), Tobin (2019), Zhu et al. (2024)- Input geometric values.
    geom.r_1 = 281e-9/2;                  % Radius of tallest stereocilia (row 1). 
    geom.r_2 = 269e-9/2;                  % Radius of middle stereocilia (row 2).
    geom.r_3 = 265e-9/2;                  % Radius of shortest stereocilia (row 3).

    % geom.l1_gs = 2.3225e-6;                % Height of the first tip link insertion point in row 1 stereocilia from its pivot point.
    % geom.l2_gs = 1.3852e-6;                  % Height of the second tip link insertion point in row 2 stereocilia from its pivot point.
    
    % Adjusted based on linearized geometric analysis for unchanged theta
    % after or before SEM.
    geom.l1_gs = 2.31545e-06;                % Height of the first tip link insertion point in row 1 stereocilia from its pivot point.
    geom.l2_gs = 1.3811e-06;                  % Height of the second tip link insertion point in row 2 stereocilia from its pivot point.

    geom.r_CA = 4.186e-6;                 % Length of the tallest stereocilia.
    geom.lr2 = 2.184e-6;                  % Length of the middle stereocilia.
    geom.r_BD = -geom.r_2*sin(theta12)+sqrt(geom.lr2^2-geom.r_2^2*cos(theta12)^2);
    geom.lr3 = 1.358e-6;                  % Length of the shortest stereocilia.
    geom.r_EF = -geom.r_3*sin(theta23)+sqrt(geom.lr3^2-geom.r_3^2*cos(theta23)^2);

    geom.b_12 = 0.567e-6;               % Horizontal separation between rows 1 and 2.
    geom.b_23 = 0.594e-6;               % Horizontal separation between rows 2 and 3.

    % Old Input geometric values.
    % geom.r_1 = 113e-9;                  % Radius of tallest stereocilia (row 1). 
    % geom.r_2 = 118e-9;                  % Radius of middle stereocilia (row 2).
    % geom.r_3 = 225e-9/2;                % Radius of shortest stereocilia (row 3) (modified).
    % 
    % geom.l1_gs = 2.3257e-6;                % Height of the first tip link insertion point in row 1 stereocilia from its pivot point.
    % geom.l2_gs = 1.0757e-6;                  % Height of the second tip link insertion point in row 2 stereocilia from its pivot point.
    % 
    % geom.r_CA = 4.2e-6;                 % Length of the tallest stereocilia.
    % geom.lr2 = 2.2e-6;                  % Length of the middle stereocilia.
    % geom.r_BD = -geom.r_2*sin(theta12)+sqrt(geom.lr2^2-geom.r_2^2*cos(theta12)^2);
    % geom.lr3 = 1.1e-6;                  % Length of the shortest stereocilia.
    % geom.r_EF = -geom.r_3*sin(theta23)+sqrt(geom.lr3^2-geom.r_3^2*cos(theta23)^2);
    % 
    % geom.b_12 = 0.81e-6/1.33;           % Horizontal separation between rows 1 and 2.
    % geom.b_23 = 0.81e-6/1.33;           % Horizontal separation between rows 2 and 3.
    
    % Geometric definitions and derivatives 
    geom.a1_o = pi()/2+phi_o;
    a1 = pi()/2+phi;
    
    rBA = geom.b_12*cos(a1)+sqrt((geom.b_12*cos(a1))^2-(geom.b_12^2+(geom.r_1+geom.r_2)^2-2*geom.b_12*(geom.r_1+geom.r_2)*sin(a1)-geom.r_BD^2));
    e2 = diff(rBA, phi);
    
    a2 = acos((geom.b_12-rBA*cos(a1)-(geom.r_1+geom.r_2)*sin(a1))/geom.r_BD);
    e1 = diff(a2, phi);
    
    l1 = sqrt((geom.l1_gs-(la1-la1_o))^2+(geom.r_BD)^2+(geom.r_2)^2+geom.r_1^2+geom.b_12^2+2*(geom.r_BD) ...
        *(geom.l1_gs-(la1-la1_o))*cos(a1+a2)+2*geom.r_2*(geom.l1_gs-(la1-la1_o))*sin(a1+a2+theta12)+2*geom.r_1*(geom.r_BD)*sin(a1+a2) ...
        -2*geom.r_1*(geom.r_2)*cos(a1+a2+theta12)+2*geom.r_BD*geom.r_2*sin(theta12)-2*geom.b_12 ...
        *((geom.r_BD)*cos(a2)+geom.r_2*sin(a2+theta12)+geom.r_1*sin(a1)+(geom.l1_gs-(la1-la1_o))*cos(a1)));    
    
    e4 = diff(l1, phi);
    e5 = diff(l1, la1);
    
    a3 = acos(((geom.r_BD)*cos(a2)+geom.r_2*sin(a2+theta12)+geom.r_1*sin(a1)-geom.b_12+(geom.l1_gs-(la1-la1_o))*cos(a1))/l1)-a1;
    
    e3 = diff(a3, phi);
    e6 = diff(a3, la1);
    
    a4 = pi()-a2;
    
    rED = geom.b_23*cos(a4)+sqrt((geom.b_23*cos(a4))^2-(geom.b_23^2+(geom.r_2+geom.r_3)^2-2*geom.b_23*(geom.r_2+geom.r_3)*sin(a4)-geom.r_EF^2));
    e8 = diff(rED, phi);
    
    a5 = acos((geom.b_23-rED*cos(a4)-(geom.r_2+geom.r_3)*sin(a4))/geom.r_EF);
    e7 = diff(a5, phi);
    
    l2 = sqrt((geom.l2_gs-(la2-la2_o))^2+(geom.r_EF)^2+(geom.r_3)^2+geom.r_2^2+geom.b_23^2+2*(geom.r_EF) ...
        *(geom.l2_gs-(la2-la2_o))*cos(a4+a5)+2*geom.r_3*(geom.l2_gs-(la2-la2_o))*sin(a4+a5+theta23)+2*geom.r_2*(geom.r_EF)*sin(a4+a5) ...
        -2*geom.r_2*(geom.r_3)*cos(a4+a5+theta23)+2*geom.r_EF*geom.r_3*sin(theta23)-2*geom.b_23 ...
        *((geom.r_EF)*cos(a5)+geom.r_3*sin(a5+theta23)+geom.r_2*sin(a4)+(geom.l2_gs-(la2-la2_o))*cos(a4)));
    
    e10 = diff(l2, phi);
    e11 = diff(l2, la2);
    
    a6 = acos(((geom.r_EF)*cos(a5)+geom.r_3*sin(a5+theta23)+geom.r_2*sin(a4)-geom.b_23+(geom.l2_gs-(la2-la2_o))*cos(a4))/l2)-a4;
    
    e9 = diff(a6, phi);
    e12 = diff(a6, la2);
    
    % Generate functions of symbolic expressions
    fun_rBA = matlabFunction(rBA);
    fun_l1 = matlabFunction(l1);
    fun_a4 = matlabFunction(a4);
    fun_rED = matlabFunction(rED);
    fun_e4 = matlabFunction(e4);
    fun_a3 = matlabFunction(a3);
    fun_l2 = matlabFunction(l2);
    fun_a6 = matlabFunction(a6);
    fun_a2 = matlabFunction(a2);
    fun_e1 = matlabFunction(e1);
    fun_a5 = matlabFunction(a5);
    fun_e7 = matlabFunction(e7);
    fun_e10 = matlabFunction(e10);
    fun_a1 = matlabFunction(a1);
    fun_e5 = matlabFunction(e5);
    fun_e11 = matlabFunction(e11);
    
    % Evaluation of some functions at the initial condition and storing in
    % "geom" structure.
    geom.rBA_o = fun_rBA(phi_o);
    geom.a2_o = fun_a2(phi_o);
    geom.l1_o = fun_l1(la1_o, phi_o);
    geom.a3_o = fun_a3(la1_o, phi_o);
    geom.a4_o = fun_a4(phi_o);
    geom.rED_o = fun_rED(phi_o);
    geom.a5_o = fun_a5(phi_o);
    geom.l2_o = fun_l2(la2_o,phi_o);
    geom.a6_o = fun_a6(la2_o,phi_o);
    geom.e1_o = fun_e1(phi_o);
    geom.e4_o = fun_e4(la1_o,phi_o);
    geom.e7_o = fun_e7(phi_o);
    geom.e5_o = fun_e5(la1_o,phi_o);
    geom.e10_o = fun_e10(la2_o,phi_o);
    geom.e11_o = fun_e11(la2_o,phi_o);
    geom.theta12 = theta12;
    geom.theta23 = theta23;
    geom.gain1 = geom.e4_o/geom.r_CA;

    % Storing functions in "func" structure.
    func.fun_a2 = fun_a2;
    func.fun_a1 = fun_a1;
    func.fun_e1 = fun_e1;
    func.fun_a5 = fun_a5;
    func.fun_e7 = fun_e7;
    func.fun_l1 = fun_l1;
    func.fun_a3 = fun_a3;
    func.fun_l2 = fun_l2;
    func.fun_a6 = fun_a6;
    func.fun_e4 = fun_e4;
    func.fun_e10 = fun_e10;

    % Storing some symbolic forms in "func" structure.
    func.a2 = a2;
    func.a1 = a1;
    func.e1 = e1;
    func.a5 = a5;
    func.e7 = e7;
    func.l1 = l1;
    func.a3 = a3;
    func.l2 = l2;
    func.a6 = a6;
end