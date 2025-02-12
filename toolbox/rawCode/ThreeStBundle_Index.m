tic;

clear;

% Symbolic degrees of freedom
syms phi la1 la2

%% Model Parameters and Initial Conditions
% Viscoelastic parameters
param = HB_params(); 

% Initial conditions stored in the same structure "param".
param.phi_o = 0;
param.la1_o = 0;
param.la2_o = 0;

fprintf("Parameters loaded...\n");

%% Geometry Solution, Bundle Visualization and Boltzmann Probability Functions
% "geom" stores the geometric constants, "func" stores the geometric
% functions that depend on phi, la1, and la2, "l1" is the length of the 
% tip link between rows 1 and 2, and "l2" is the length of the tip link 
% between rows 2 and 3. 
[geom, func, l1, l2] = geometry_NL(param.phi_o, param.la1_o, param.la2_o);

[g1, g2, g3, y1, y2, y3, b1, b2, b3, r1, X_r1, Y_r1, X_r2, Y_r2, X_r3, Y_r3] = bundleVisual(geom);
% The probability functions are computed in "probability.m" function file
% and their equations are stored in "func" structure.
prob = probability(geom, param, l1, l2);

func.fun_Po1 = prob.fun_Po1;
func.fun_Po2 = prob.fun_Po2;

fprintf("Geometric relations computed...\n");

%% External Force Definition
probe_flag = 0;

% Static force to change the resting open probability
Fst = 0e-12; 

% Applied force amplitudes.
if probe_flag == 0
    Fo = [-180, -115, -41, 51, 127, 217, 291, 375, 470, 569, 677, 797, 950]*1e-12;
else
    Fo = param.K_P*[-39, -25, -9, 11, 27, 47, 63, 81, 102, 123, 147, 173, 206]*1e-9;
end

% Idle time without force for HB to achieve the resting state.
tNoForce = 50e-3; 

% A short time of continued no-force condition after "tNoForce".
tNoForceEnd = 5.4e-3 + tNoForce; 

% Duration of the force application after "tNoForceEnd".
tAppliedForce = 50.4e-3 + tNoForceEnd; 

% Duration after the force application "tAppliedForce", for HB to return 
% to the resting state (no-force condition).
tAfterForceOff = 54.4e-3 + tAppliedForce;

% Force rise-time.
tauF = 0.1e-3;

% Time-step for nonlinear solution.
h = 1e-6;

col = int64(tAfterForceOff/h);
row = length(Fo);

fprintf("Numerical simulation inputs defined...\n");

%% Initiate Parallel Runge-Kutta Numerical Solver
fprintf('Initiating the Runge-Kutta solver...\n'); 

if probe_flag == 0
    [x, y, z, t] = rkSolver(param, func, tNoForceEnd, tAppliedForce, tAfterForceOff, tauF, Fo, geom, row, col, h, Fst);
else
    [x, y, z, t] = Probe_rkSolver(param, func, tNoForceEnd, tAppliedForce, tAfterForceOff, tauF, Fo, geom, row, col, h, Fst);
end

fprintf('Finished numerical solution...\n'); 

%% Post-Processing 
% Time instant right before force is applied. This is used to estimate the
% resting state: phiEqb, la1Eqb, and la2Eqb. The value is arbitrarily
% chosen as 0.5 milliseconds to stay as close to the force application time
% as possible.
tBeforeForce = int64(tNoForce/h - 0.5e-3/h); 
  
phiEqb = x(1,tBeforeForce);
la1Eqb = y(1,tBeforeForce);
la2Eqb = z(1,tBeforeForce);
  
% Rseting open probability.
po1Eqb = func.fun_Po1(la1Eqb,phiEqb); 
po2Eqb = func.fun_Po2(la2Eqb,phiEqb); 

% Channel open probabilities at each time step.
pOn1 = func.fun_Po1(y,x);
pOn2 = func.fun_Po2(z,x);

%% Outputs Computation
% Bundle displacement.
xHB = geom.r_CA*sin(x);

% MET current.
pOnTotal = pOn1+pOn2;
gMet = pOnTotal*param.gMax;
iMet = gMet*(param.deltaVHBo-param.EP);

fprintf("Model outputs computed...\n");

%% Activation Curves
% Activation curves are constructed using the peak MET current and
% corresponding HB dispalcement for each force amplitude F. Depending on 
% the time course defined under "Time Frame", the peak is isolated by 
% defining two time steps arbitrarily separated by 20 milliseconds.    
tBeforePeak = int64(tNoForceEnd/h);
tAfterPeak = int64(tBeforePeak + 40e-3/h);

% The peak may or may not be normalized by the maximum peak value
% corresponding to the highest force amplitude. In the for loop below, it
% it normalized. Please replace "max(pOnTotal(row,:))" with "1" if 
% normalization is not required.
pNorm = zeros(row,col+1);
peakVal = zeros(1,row);
peakValIndex = zeros(1,row);
xAct = zeros(1,row);

for n = 1:row
    pNorm(n,:) = pOnTotal(n,:)/max(pOnTotal(row,:));
    if Fo(n) < 0
        [peakVal(n), peakValIndex(n)] = min(pNorm(n,tBeforePeak:tAfterPeak));
    else
        [peakVal(n), peakValIndex(n)] = max(pNorm(n,tBeforePeak:tAfterPeak));
    end
    
    % The corresponding bundle displacement at "peakValIndex" is given by xAct.
    xAct(n) = geom.r_CA*sin(x(n,tBeforePeak+peakValIndex(n))')*10^9;
end

%% HB Sensitivity
% The sensitivity is defined as the maximum slope of the Activation Curve.
% In the next for loop, the slope is computed for each consecutive pair.
slopeAct = zeros(1,row-1);

for n = 1:row-1
    slopeAct(n) = (peakVal(n+1)-peakVal(n))/(xAct(n+1)-xAct(n));
end

% The sensitivity is given by the maximum value of "slopeAct".
hbSensitivity = max(slopeAct);

%% HB Stiffness
% The time step at which the stiffness must be calculated is 
% "steadyStateTimeStep". This value corresponds to steadyStateTimeStep/1e4
% in milliseconds. 1.6 milliseconds below is arbitrarily set to stay as 
% close to the steady-state as possible.
steadyStateTimeStep = int64(tAppliedForce/h - 1.6e-3/h); 

% HB displacement at that time instant for each force amplitude F.
xStiff = geom.r_CA*sin(x(:,steadyStateTimeStep)')*10^9;
kStiff = zeros(1,row-1);

% The stiffness of the bundle "K_stiff" is obtained as the slope of the
% force-displacement relation given below.
if probe_flag == 0
    % This formula will be used when running the fluid-jet model
    for n = 1:row-1
        kStiff(n) = (Fo(n+1)-Fo(n))*1e12/(xStiff(n+1)-xStiff(n));
    end
else
    % This formula will be used when running the rigid-probe model
    for n = 1:row-1
        kStiff(n) = (Fo(n+1)*1e12-param.K_P*1e3*xStiff(n+1)-(Fo(n)*1e12-param.K_P*1e3*xStiff(n)))/(xStiff(n+1)-xStiff(n));
    end
end

%% Plotting the Results
fprintf('Plotting the Results...\n'); 

% Use "range" to plot specific traces.
range = 1:13;

figure(1)
plot((t(range,:)')*10^3-tNoForce*1e3-0*4.9, xHB(range,:)'*10^9, '-k', LineWidth=2); 
title('HB Displacements');
xlab = xlabel('Time [ms]');
ylab = ylabel('X_{hb} [nm]');
xlim([0, 100]);
ylim([-50 250])
set(gca, 'fontname', 'helvetica', 'fontsize', 26)  
set(xlab, 'fontsize', 28);
set(ylab, 'fontsize', 28);

figure(2)
plot((t(range,:)')*10^3-tNoForce*1e3-0*4.9, iMet(range,:)'*10^9, 'color', [0 0 0], LineWidth=2); 
title('MET Currents');
xlab = xlabel('Time [ms]');
ylab = ylabel('I_{met} [nA]');
xlim([0, 100]);
ylim([-0.85 0])
set(gca, 'fontname', 'helvetica', 'fontsize', 26)  
set(xlab, 'fontsize', 28);
set(ylab, 'fontsize', 28);

figure(3)
plot(xStiff(1:end-1), kStiff, LineWidth=1.5)
title('HB Stiffness');
xlab = xlabel('X_{hb} [nm]');
ylab = ylabel('K_{HB} [mN/m]');
xlim([-50, 200]);
set(gca, 'fontname', 'helvetica', 'fontsize', 26)  
set(xlab, 'fontsize', 28);
set(ylab, 'fontsize', 28);

figure(4)
plot(xAct, peakVal, LineWidth=1.5)
title('Activation Curve');
xlab = xlabel('X_{hb} [nm]');
ylab = ylabel('I_{met}/I_{max} [-]');
xlim([-50, 200]);
set(gca, 'fontname', 'helvetica', 'fontsize', 26)
set(xlab, 'fontsize', 28);
set(ylab, 'fontsize', 28);

figure(5)
plot(xAct(1:end-1), slopeAct, LineWidth=1.5)
title('Activation Curve Slopes');
xlab = xlabel('X_{hb} [nm]');
ylab = ylabel('Slopes [nm^{-1}]');
xlim([-50, 200]);
set(gca, 'fontname', 'helvetica', 'fontsize', 26)
set(xlab, 'fontsize', 28);
set(ylab, 'fontsize', 28);

figure(6)
hold on
fill(X_r1*1e6, Y_r1*1e6, [g1 g2 g3])
fill(X_r2*1e6, Y_r2*1e6, [y1 y2 y3])
fill(X_r3*1e6, Y_r3*1e6, [b1 b2 b3])
plot([-geom.b_12+geom.r_BD*cos(geom.a2_o)+geom.r_2*cos(geom.a2_o) -geom.r_1]*1e6, [geom.r_BD*sin(geom.a2_o)+geom.r_2*sin(geom.a2_o) geom.l1_gs]*1e6, 'color', [r1 0 0], LineWidth=2)
plot([-geom.b_12-geom.b_23+geom.r_EF*cos(geom.a5_o)+geom.r_3*cos(geom.a5_o) -geom.b_12+geom.l2_gs*cos(geom.a2_o)-geom.r_2*cos(pi/2-geom.a2_o)]*1e6, [geom.r_EF*sin(geom.a5_o)+geom.r_3*sin(geom.a5_o) geom.l2_gs*sin(geom.a2_o)+geom.r_2*sin(pi/2-geom.a2_o)]*1e6, 'color', [r1 0 0], LineWidth=2)
hold off
ylim([-0.5 4.5])
xlim([-1.5 0.5])
xlab = xlabel('\mum');
ylab = ylabel('\mum');
set(gca, 'fontname', 'helvetica', 'fontsize', 26) 
set(xlab, 'fontsize', 28);
set(ylab, 'fontsize', 28);

tOfCompletion = toc;
