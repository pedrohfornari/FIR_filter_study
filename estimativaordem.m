function [M] = estimativaordem(janela,wp,ws,deltap,deltas)
%
% [M] = estimativaordem(janela,wp,ws,deltap,deltas);
%
% This function calculates a first kick order to the filter with respect of
% its specifications and window
% Esta funcao calcula uma ordem estimada para o filtro de acordo com cada
% janela.
%
% Inputs are:
% Os parametros de entrada sao:
% 
% > janela = Window / tipo de janela, podendo ser:
%     janela==0 --> Janela de Retangular;
%     janela==1 --> Janela de Hamming;
%     janela==2 --> Janela de Blackman;
%     janela==3 --> Janela de Kaiser;
% > wp = normalized cut off starter frequency / frequencia final da banda de passagem, normalizada;
% > ws = normalized cut off limit frequency / frequencia inicial da banda de corte, normalizada
% > deltap = passband ripple / ripple na banda de passagem, em dB;
% > deltas = rejection band ripple / ripple na banda de corte, em dB;

deltaw = ws-wp;

% The following functions are used to estimat the order 
% As funcoes a seguir, usadas para estimar-se a ordem foram retiradas do
% livro do Manolakis, Cap 10.3, Tabela 10.3.

if janela == 0; %Retangular
    M = 1.8*pi/deltaw - 1; 
    
elseif janela == 1; %Hamming
    M = 6.6*pi/deltaw - 1;
        
elseif janela == 2; %Blackman
    M = 11*pi/deltaw - 1;
        
elseif janela == 3; %Kaiser
    M = (-20*log10(sqrt(deltap*deltas))-13)/(14.6*deltaw/(2*pi));
        
end

M = 2*ceil(M/2); % Round to the closest pair integer / Arredonda para o próximo inteiro par

end