clear all
clc

n_vars = 8;
A = [1 0 1 0 1 0 0 0; 0 1 0 1 0 1 0 0; 1 0 1 0 1 0 -1 0; 0 1 0 1 0 1 0 -1; ...
    1 0 0 0 0 0 0 0; 0 1 0 0 0 0 0 0; 0 0 1 0 0 0 0 0; 0 0 0 1 0 0 0 0; 0 0 0 0 1 0 0 0; 0 0 0 0 0 1 0 0; 0 0 0 0 0 0 1 0; 0 0 0 0 0 0 0 1];
b = [18; 12; 0; 0; ...
    7; 5; 4; 5; 2; 5; 17; 12];
Aeq = [0 0 0 0 0 0 1 1; 1 1 0 0 0 0 0 0; 0 0 1 1 0 0 0 0; 0 0 0 0 1 1 0 0;];
beq = [25; 12; 8; 5];
LB = [0 0 0 0 0 0 0 0];
UB = [Inf Inf Inf Inf Inf Inf Inf Inf];
NON_linear = [];
Integral_variables = [];

settings = gaoptimset('generation', 200, 'StallGenLimit', 10000, ...
    'PopulationSize',100, 'CrossoverFraction',0.65);

[x,fval] = ga(@BiomassaEnergia,n_vars,A,b,Aeq,beq,LB,UB,NON_linear,Integral_variables,settings)
