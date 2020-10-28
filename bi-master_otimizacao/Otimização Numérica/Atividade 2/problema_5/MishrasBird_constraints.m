function [ c, c_eq ] = MishrasBird_constraints( vec )
%UNTITLED5 Summary of this function goes here
%   Restrições da funcao de MishrasBird
    x = vec(1);
    y = vec(2);
    
    c = [(x+5)^2 + (y+5)^2 - 25];
    c_eq = [];
end

