function prob = probability(geom, param, l1, l2)
    prob.l1_nat = geom.l1_o;
    prob.l2_nat = geom.l2_o;
    
    % Boltzmann robability functions.
    Po1 = 1/(1+param.A1*exp(-param.K_GS_1*param.d1*(l1-prob.l1_nat)/(param.N1*param.kB*param.T))); %Probability of each of the Nc transduction channels in row 2 being open
    Po2 = 1/(1+param.A2*exp(-param.K_GS_2*param.d2*(l2-prob.l2_nat)/(param.N2*param.kB*param.T))); %Probability of each of the Nc transduction channels in row 3 being open
    
    prob.fun_Po1 = matlabFunction(Po1);
    prob.fun_Po2 = matlabFunction(Po2);

    prob.Po1 = Po1;
    prob.Po2 = Po2;
end