clear all
clc


ObjectiveFunction = @(vector) MishrasBird(vector);
n_vars = 2;
A = [];
b = [];
Aeq = [];
beq = [];
LB = [-10 -6.5];
UB = [0 0];
NON_linear = @(vector) MishrasBird_constraints(vector);
Integral_variables = [];
settings = gaoptimset('generation', 100, 'StallGenLimit', 10000, ...
        'PopulationSize',80, 'CrossoverFraction',0.65);

[x,fval] = ga(ObjectiveFunction,n_vars,A,b,Aeq,beq,LB,UB,NON_linear,Integral_variables,settings)








