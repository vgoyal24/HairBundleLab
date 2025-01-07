% Toolbox Overview:
% This toolbox provides tools for simulating and visualizing cochlear 
% hair bundle responses. It includes raw computational code and a GUI 
% for interactive use.

% Contents:
%   - app/HairBundleLab.mlapp: Main GUI for visualization
%   - rawCode/ThreeStBundle_Index.m: This is the primary script file where 
%           you can specify input properties and numerical simulation 
%           parameters, such as time steps. Additionally, you can customize 
%           the initial time for which the static force is applied to the   
%           system, a feature not yet available in the application 
%           (for more details, refer to Section 4.3 of the documentation in 
%           ../resources. This file also offers customization options for 
%           your plots.
%   - rawCode/geometryNL.m This function is crucial for defining the HB 
%           geometry, including radii, lengths, and related quantities, 
%           which are saved in the geom structure. The file computes all 
%           geometric relationships between different stereocilia as both 
%           symbolic and mathematical functions, stored in the func structure. 
%   - rawCode/HB_params.m: This important function file allows you to 
%           define all mechanical and electrical parameters, saved in the 
%           param structure. It is likely you will modify this file 
%           frequently when designing your HB.
%   - rawCode/forceTime.m: This function defines the force matrix, which 
%           has dimensions of $m\times n$, where $m$ represents the number 
%           of force amplitudes you simulate, and $n$ represents the force 
%           values over time.
%   - rawCode/probability.m: Unless you wish to modify the Boltzmann 
%           functions for modeling channel open probability, you do not 
%           need to change this file. It utilizes parameters from geom, 
%           func and param.
%   - rawCode/rkSolver.m: This function contains a custom Runge-Kutta 
%           fourth-order numerical solver. It uses parameters defined in 
%           the previously mentioned files and applies the three equations 
%           of motion derived in the research to predict the HB response. 
%           This is also the file you need to modify if you do not have a 
%           Parallel Computing Toolbox license from MATLAB or if you choose 
%           not to use it. In line 41, simply change parfor to for.
%   - rawCode/Probe_rkSolver.m: Similar to rkSolver.m, this file includes 
%           slightly modified equations of motion due to the addition of 
%           the probe. In case you do not wish to use or have the Parallel 
%           Computing Toolbox, you can modify line 42 by replacing parfor 
%           with for.
%   - rawCode/bundleVisual.m: This function file is used for visualizing 
%           your HB. It is employed in ThreeStBundle_Index.m to plot the 
%           HB and typically does not require direct editing unless you 
%           are curious about its implementation.
