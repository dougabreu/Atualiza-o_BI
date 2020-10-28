clear all
clc


ObjectiveFunction = @(n) -(3*n(1) + 5*n(2));

n_vars = 2;
A = [1 0; 0 2; 3 2];
b = [4000; 12000; 18000];
Aeq = [];
beq = [];
LB = [-Inf -Inf];
UB = [Inf Inf];
NON_linear = [];
Integral_variables = [1 2];
settings = gaoptimset('generation', 100, 'StallGenLimit', 10000, ...
        'PopulationSize',80, 'CrossoverFraction',0.65);

[x,fval] = ga(ObjectiveFunction,n_vars,A,b,Aeq,beq,LB,UB,NON_linear,Integral_variables,settings)