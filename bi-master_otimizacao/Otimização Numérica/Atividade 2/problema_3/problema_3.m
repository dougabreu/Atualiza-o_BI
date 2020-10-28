%% init
close all;
clear;
clc;

%%
f=@(x11,x12,x21,x22,y1,y2) 2000*x11 + 1700*x12 + 1600*x21 + 1100*x22 + ...
    400*y1 + 800*y2;

fitness = @(ind) f(ind(1),ind(2),ind(3),ind(4),ind(5),ind(6));

LB = [0; 0; 0; 0; 0; 0];
UB = [30; 30; 50; 50; 70; 70];

Aeq = [1 1 0 0 0 0; 0 0 1 1 0 0; 1 0 1 0 -1 0; 0 1 0 1 0 -1; 0 0 0 0 1 1];
beq = [40; 60; 0; 0; 100];

n_vars = 6;
options = gaoptimset('display','iter', 'generations', 100, ...
    'StallGenLimit', 10000, 'PopulationSize', 20);
[x, fval] = ga(fitness, n_vars, [], [], Aeq, beq, LB, UB, [], options);




