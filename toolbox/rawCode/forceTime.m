function ft = forceTime(Fst, tNoForceEnd, tAppliedForce, tAfterForceOff, tauF, row, col, Fo, h)
    t = zeros(row,col);
    
    % Defining initial time value.
    to = 0; 
    t(:,1) = to*10^-3;
    tauF2 = 0.1e-3;
    
    % F0, F1, and F2 are all forces, but incremented differently as defined
    % by the Runge-Kutta method. These are used in "rkSolver.m".
    F0(:,1) = Fst;
    F1(:,1) = Fst;
    F2(:,1) = Fst;
    
    for j = 1:row
        for i = 1:col
            if t(j,i) <= tNoForceEnd 
                F0(j,i+1) = Fst;
                F1(j,i+1) = Fst;
                F2(j,i+1) = Fst;
            % Arbitrary value of 1 millisecond below, giving tauF sufficient time
            % to process.
            elseif t(j,i) <= tAppliedForce-1e-3 
                F0(j,i+1) = Fst + Fo(j)*(1 - exp(-(1/tauF)*(t(j,i)-tNoForceEnd)));
                F1(j,i+1) = Fst + Fo(j)*(1 - exp(-(1/tauF)*(t(j,i)-tNoForceEnd+h/2)));
                F2(j,i+1) = Fst + Fo(j)*(1 - exp(-(1/tauF)*(t(j,i)-tNoForceEnd+h)));
            elseif t(j,i) <= tAppliedForce
                F0(j,i+1) = Fst + Fo(j)*(1 - exp((1/tauF2)*(t(j,i)-tAppliedForce)));
                F1(j,i+1) = Fst + Fo(j)*(1 - exp((1/tauF2)*(t(j,i)-tAppliedForce+h/2)));
                F2(j,i+1) = Fst + Fo(j)*(1 - exp((1/tauF2)*(t(j,i)-tAppliedForce+h)));
            elseif t(j,i) > tAppliedForce && t(j,i) < tAfterForceOff
                F0(j,i+1) = Fst;
                F1(j,i+1) = Fst;
                F2(j,i+1) = Fst;    
            end
            % Time increment.
            t(j,i+1) = t(j,i) + h;
        end
    end
    
    % Storing outputs in a structure.
    ft.t = t;
    ft.h = h;
    ft.Fst = Fst;
    ft.F0 = F0;
    ft.F1 = F1;
    ft.F2 = F2;
end