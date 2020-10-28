clear all
clc

ObjetiveFunction = @(tarefa) -(5*tarefa(1) + 9*tarefa(2));


variaveis = 2;
A = [0.1667 0.25; 0 0.2; 0.0667 0.1];   % Em ciclo/min
b = [4200 500 1800];    % Restrições em horas/mês
b = b*60;               % Convertendo para min/mês
Aeq = [];
beq = [];
LB = [0 0];         % Não é possível ter ciclos menos que 0
UB = [Inf Inf];
NON_linear = [];
Integral_variables = [1 2];     % Índices inteiros tanto para tarefa 1 como pra tarefa 2

settings = gaoptimset('generation', 100,  'PopulationSize',80);

[x,fval] = ga(ObjetiveFunction,variaveis,A,b,Aeq,beq,LB,UB,NON_linear,Integral_variables,settings)
