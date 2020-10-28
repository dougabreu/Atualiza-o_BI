function [ Result ] = MishrasBird( vec )
%UNTITLED4 Summary of this function goes here
%   Exercício para otimização Mishra's Bird function
%   -10<=x<=0 e -6.5<=y<=0 com restrições de (x+5)^2 + (y+5)^2 < 25
%   https://en.wikipedia.org/wiki/Test_functions_for_optimization
    x = vec(1);
    y = vec(2);
    
    Argumento1 = sin(y)*exp((1-cos(x))^2);
    Argumento2 = cos(x)*exp((1-sin(y))^2);
    Argumento3 = (x-y)^2;
       
    Result = (Argumento1 + Argumento2 + Argumento3);
    
end

