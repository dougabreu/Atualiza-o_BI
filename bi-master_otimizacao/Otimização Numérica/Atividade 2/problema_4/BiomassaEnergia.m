function [ Resultado_custo ] = BiomassaEnergia( entradas )
%   Funcao que retorna o custo da quantidade de biomassa transportada para a
%   geração de energia elétrica
%   Detailed explanation goes here
    xa1 = entradas(1);
    xa2 = entradas(2);
    xb1 = entradas(3);
    xb2 = entradas(4);
    xc1 = entradas(5);
    xc2 = entradas(6);
    y1p = entradas(7);
    y2p = entradas(8);
    Resultado_custo = (42*xa1 + 64*xa2 + 71*xb1 + 76*xb2 + 84*xc1 + 38*xc2 + 135*y1p + 95*y2p);
    
%     A = [1 1 0 0 0 0 0 0; 0 0 1 1 0 0 0 0; 0 0 0 0 1 1 0 0; 1 0 1 0 1 0 0 0; 0 1 0 1 0 1 0 0; 1 0 0 0 0 0 0 0; 0 1 0 0 0 0 0 0; 0 0 1 0 0 0 0 0; 0 0 0 1 0 0 0 0; 0 0 0 0 1 0 0 0; 0 0 0 0 0 1 0 0; 0 0 0 0 0 0 1 0; 0 0 0 0 0 0 0 1];
%     b = [12; 8; 5; 18; 12; 8; 4; 3; 5; 1; 4; 17; 12];
%     Aeq = [0 0 0 0 0 0 1 1];
%     beq = [26];

end

