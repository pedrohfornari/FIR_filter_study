function [M] = estimativaordem(janela,wp,ws,deltap,deltas)
%
% [M] = estimativaordem(janela,wp,ws,deltap,deltas);
%
% Esta funcao calcula uma ordem estimada para o filtro de acordo com cada
% janela.
%
% Os parametros de entrada sao:
% 
% > janela = tipo de janela, podendo ser:
%     janela==0 --> Janela de Retangular;
%     janela==1 --> Janela de Hamming;
%     janela==2 --> Janela de Blackman;
%     janela==3 --> Janela de Kaiser;
% > wp = frequencia final da banda de passagem, normalizada;
% > ws = frequencia inicial da banda de corte, normalizada;
% > deltap = ripple na banda de passagem, em dB;
% > deltas = ripple na banda de corte, em dB;

deltaw = ws-wp;

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

M = 2*ceil(M/2); % Arredonda para o próximo inteiro par

end