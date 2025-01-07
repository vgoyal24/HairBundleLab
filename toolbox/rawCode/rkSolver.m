function [u, v, w, t] = rkSolver(param, ~, tNoForceEnd, tAppliedForce, tAfterForceOff, tauF, Fo, geom, row, col, h, Fst)
    u = zeros(row,col+1); %HB
    v = zeros(row,col+1); %AM1  
    w = zeros(row,col+1); %AM2
     
    phi_o = param.phi_o;
    la1_o = param.la1_o;
    la2_o = param.la2_o;
    
    K_GS_1 = param.K_GS_1;
    K_GS_2 = param.K_GS_2;
    K_SP_1 = param.K_SP_1;
    K_SP_2 = param.K_SP_2;
    K_SP_3 = param.K_SP_3;
    K_ES_1 = param.K_ES_1;
    K_ES_2 = param.K_ES_2;
    lambda_1 = param.lambda_1;
    lambda_2 = param.lambda_2;
    lambda_3 = param.lambda_3;
    lambda_a1 = param.lambda_a1;
    lambda_a2 = param.lambda_a2;
    d1 = param.d1;
    d2 = param.d2;
    Fmax1 = param.Fmax1;
    Fmax2 = param.Fmax2;
    S = param.S;

    l1_o = geom.l1_o;
    l2_o = geom.l2_o;
    l1_gs = geom.l1_gs;
    l2_gs = geom.l2_gs;
    r_1 = geom.r_1;
    r_2 = geom.r_2;
    r_CA = geom.r_CA;
    b_12 = geom.b_12;
    a1_o = geom.a1_o;
    a2_o = geom.a2_o;
    a5_o = geom.a5_o;

    %% Solving- Runge-Kutta method (NL)
    parfor j=1:row
        x = zeros(1,col); %HB
        y = zeros(1,col); %AM1  
        z = zeros(1,col); %AM2 
        
        x(1) = phi_o;
        y(1) = la1_o;
        z(1) = la2_o;

        [~, func, l1, l2] = geometry_NL(phi_o, la1_o, la2_o);
        
        fun_a2 = func.fun_a2;
        fun_a1 = func.fun_a1;
        fun_e1 = func.fun_e1;
        fun_a5 = func.fun_a5;
        fun_e7 = func.fun_e7;
        fun_l1 = func.fun_l1;
        fun_a3 = func.fun_a3;
        fun_l2 = func.fun_l2;
        fun_a6 = func.fun_a6;

        prob = probability(geom, param, l1, l2)
        fun_Po1 = prob.fun_Po1;
        fun_Po2 = prob.fun_Po2;

        ft = forceTime(Fst, tNoForceEnd, tAppliedForce, tAfterForceOff, tauF, row, col, Fo, h);
        F0 = ft.F0(j,:);
        F1 = ft.F1(j,:);
        F2 = ft.F2(j,:);
        t_int = ft.t(j,:);
        
        for i = 1:col
            % Set 1
            a2_1 = fun_a2(x(i)); 
            a1_1 = fun_a1(x(i)); 
            e1_1 = fun_e1(x(i));
            a5_1 = fun_a5(x(i)); 
            e7_1 = fun_e7(x(i));
            Po1_1 = fun_Po1(y(i),x(i)); 
            l1_1 = fun_l1(y(i),x(i));
            a3_1 = fun_a3(y(i),x(i));
            Po2_1 = fun_Po2(z(i),x(i));
            l2_1 = fun_l2(z(i),x(i)); 
            a6_1 = fun_a6(z(i),x(i));
    
            K1 = (-K_GS_1*((l1_1-l1_o-d1*Po1_1)*((l1_gs-(y(i)-la1_o))...
                      *sin(a3_1)+r_1*cos(a3_1)))-K_GS_2*((l2_1-l2_o...
                      -d2*Po2_1)*((l2_gs-(z(i)-la2_o))*sin(a6_1)+r_2*cos(a6_1)...
                      +b_12*cos(a2_1-a6_1)))-K_SP_1*(a1_1-a1_o)...
                      -K_SP_2*(a2_1-a2_o)*e1_1-K_SP_3*(a5_1-a5_o)*e7_1...
                      +F0(i)*r_CA*cos(x(i)))/(lambda_1+lambda_2*e1_1^2+lambda_3*e7_1^2);
            L1 = (K_GS_1*((l1_1-l1_o-d1*Po1_1)*cos(a3_1))...
                      -K_ES_1*(y(i)-la1_o)-Fmax1)/(lambda_a1);
            M1 = (K_GS_2*((l2_1-l2_o-d2*Po2_1)*cos(a6_1))...
                      -K_ES_2*(z(i)-la2_o)-Fmax2*(1-S*Po1_1))/(lambda_a2);
            
            % Set 2
            a2_2 = fun_a2(x(i)+h*K1/2); 
            a1_2 = fun_a1(x(i)+h*K1/2); 
            e1_2 = fun_e1(x(i)+h*K1/2); 
            a5_2 = fun_a5(x(i)+h*K1/2); 
            e7_2 = fun_e7(x(i)+h*K1/2);
            Po1_2 = fun_Po1(y(i)+h*L1/2,x(i)+h*K1/2);
            l1_2 = fun_l1(y(i)+h*L1/2,x(i)+h*K1/2);
            a3_2 = fun_a3(y(i)+h*L1/2,x(i)+h*K1/2); 
            Po2_2 = fun_Po2(z(i)+h*M1/2,x(i)+h*K1/2);
            l2_2 = fun_l2(z(i)+h*M1/2,x(i)+h*K1/2);
            a6_2 = fun_a6(z(i)+h*M1/2,x(i)+h*K1/2);
            
            K2 = (-K_GS_1*((l1_2-l1_o-d1*Po1_2)*((l1_gs-(y(i)+h*L1/2-la1_o))...
                      *sin(a3_2)+r_1*cos(a3_2)))-K_GS_2*((l2_2-l2_o...
                      -d2*Po2_2)*((l2_gs-(z(i)+h*M1/2-la2_o))*sin(a6_2)+r_2*cos(a6_2)...
                      +b_12*cos(a2_2-a6_2)))-K_SP_1*(a1_2-a1_o)...
                      -K_SP_2*(a2_2-a2_o)*e1_2-K_SP_3*(a5_2-a5_o)*e7_2...
                      +F1(i)*r_CA*cos(x(i)+h*K1/2))/(lambda_1+lambda_2*e1_2^2+lambda_3*e7_2^2);
            L2 = (K_GS_1*((l1_2-l1_o-d1*Po1_2)*cos(a3_2))...
                      -K_ES_1*(y(i)+h*L1/2-la1_o)-Fmax1)/(lambda_a1);
            M2 = (K_GS_2*((l2_2-l2_o-d2*Po2_2)*cos(a6_2))...
                      -K_ES_2*(z(i)+h*M1/2-la2_o)-Fmax2*(1-S*Po1_2))/(lambda_a2);
    
            % Set 3
            a2_3 = fun_a2(x(i)+h*K2/2); 
            a1_3 = fun_a1(x(i)+h*K2/2); 
            e1_3 = fun_e1(x(i)+h*K2/2); 
            a5_3 = fun_a5(x(i)+h*K2/2); 
            e7_3 = fun_e7(x(i)+h*K2/2); 
            Po1_3 = fun_Po1(y(i)+h*L2/2,x(i)+h*K2/2);
            l1_3 = fun_l1(y(i)+h*L2/2,x(i)+h*K2/2); 
            a3_3 = fun_a3(y(i)+h*L2/2,x(i)+h*K2/2);
            Po2_3 = fun_Po2(z(i)+h*M2/2,x(i)+h*K2/2);
            l2_3 = fun_l2(z(i)+h*M2/2,x(i)+h*K2/2);
            a6_3 = fun_a6(z(i)+h*M2/2,x(i)+h*K2/2); 
            
            K3 = (-K_GS_1*((l1_3-l1_o-d1*Po1_3)*((l1_gs-(y(i)+h*L2/2-la1_o))...
                      *sin(a3_3)+r_1*cos(a3_3)))-K_GS_2*((l2_3-l2_o...
                      -d2*Po2_3)*((l2_gs-(z(i)+h*M2/2-la2_o))*sin(a6_3)+r_2*cos(a6_3)...
                      +b_12*cos(a2_3-a6_3)))-K_SP_1*(a1_3-a1_o)...
                      -K_SP_2*(a2_3-a2_o)*e1_3-K_SP_3*(a5_3-a5_o)*e7_3...
                      +F1(i)*r_CA*cos(x(i)+h*K2/2))/(lambda_1+lambda_2*e1_3^2+lambda_3*e7_3^2);
            L3 = (K_GS_1*((l1_3-l1_o-d1*Po1_3)*cos(a3_3))...
                      -K_ES_1*(y(i)+h*L2/2-la1_o)-Fmax1)/(lambda_a1);
            M3 = (K_GS_2*((l2_3-l2_o-d2*Po2_3)*cos(a6_3))...
                      -K_ES_2*(z(i)+h*M2/2-la2_o)-Fmax2*(1-S*Po1_3))/(lambda_a2);
    
            % Set 4
            a2_4 = fun_a2(x(i)+h*K3); 
            a1_4 = fun_a1(x(i)+h*K3); 
            e1_4 = fun_e1(x(i)+h*K3); 
            a5_4 = fun_a5(x(i)+h*K3); 
            e7_4 = fun_e7(x(i)+h*K3); 
            Po1_4 = fun_Po1(y(i)+h*L3,x(i)+h*K3);
            l1_4 = fun_l1(y(i)+h*L3,x(i)+h*K3);
            a3_4 = fun_a3(y(i)+h*L3,x(i)+h*K3); 
            Po2_4 = fun_Po2(z(i)+h*M3,x(i)+h*K3);
            l2_4 = fun_l2(z(i)+h*M3,x(i)+h*K3);
            a6_4 = fun_a6(z(i)+h*M3,x(i)+h*K3);
            
            K4 = (-K_GS_1*((l1_4-l1_o-d1*Po1_4)*((l1_gs-(y(i)+h*L3-la1_o))...
                      *sin(a3_4)+r_1*cos(a3_4)))-K_GS_2*((l2_4-l2_o...
                      -d2*Po2_4)*((l2_gs-(z(i)+h*M3-la2_o))*sin(a6_4)+r_2*cos(a6_4)...
                      +b_12*cos(a2_4-a6_4)))-K_SP_1*(a1_4-a1_o)...
                      -K_SP_2*(a2_4-a2_o)*e1_4-K_SP_3*(a5_4-a5_o)*e7_4...
                      +F2(i)*r_CA*cos(x(i)+h*K3))/(lambda_1+lambda_2*e1_4^2+lambda_3*e7_4^2);
            L4 = (K_GS_1*((l1_4-l1_o-d1*Po1_4)*cos(a3_4))...
                      -K_ES_1*(y(i)+h*L3-la1_o)-Fmax1)/(lambda_a1);
            M4 = (K_GS_2*((l2_4-l2_o-d2*Po2_4)*cos(a6_4))...
                      -K_ES_2*(z(i)+h*M3-la2_o)-Fmax2*(1-S*Po1_4))/(lambda_a2);
    
            x(i+1) = x(i) + h*(K1 + 2*K2 + 2*K3 + K4)/6;
            y(i+1) = y(i) + h*(L1 + 2*L2 + 2*L3 + L4)/6;
            z(i+1) = z(i) + h*(M1 + 2*M2 + 2*M3 + M4)/6;
        end
        if row > 1
            fprintf('Finished simulating force-step number %d...\n', j); 
        end
        u(j,:) = x;
        v(j,:) = y;
        w(j,:) = z;
        t(j,:) = t_int;
    end
end