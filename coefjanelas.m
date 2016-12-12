function [coef_janela] = coefjanelas(janela,M,deltap,deltas)
%
% [coef_janela] = coefjanelas(janela,M,delta_s, delta_p)
%
% Esta funcao calcula o os coeficientes da janela a partir de deltap,
% deltas e da ordem, sendo possivel ser feito para 4 janelas diferentes.
%
% Os parametros de entrada sao:
%
% > janela = tipo de janela, podendo ser:
%     janela==0 --> Janela de Retangular;
%     janela==1 --> Janela de Hamming;
%     janela==2 --> Janela de Blackman;
%     janela==3 --> Janela de Kaiser;
% > M = ordem;
% > deltap = ripple na banda de passagem, em dB;
% > deltas = ripple na banda de corte, em dB;

% Calculo do L, de acordo com a Tabela 10.3, Cap 10.3 Manolakis:
L = M+1;

% A condicional 'if' determina para qual janela serao calculados os
% coeficientes 'coef_janela'. A janela eh determinada pela variavel
% 'janela'.

if janela == 0 %Retangular
    % Funcao de janela Retangular do MATLAB:
    coef_janela=ones(L,1);

elseif janela == 1 %Hamming
    % Funcao de janela Hamming do MATLAB:
    coef_janela = hamming(L); 

elseif janela == 2 %Blackman
    % Funcao de janela Blackman do MATLAB:
    coef_janela = blackman(L);

elseif janela == 3 %Kaiser
    % Funcao de janela Kaiser:
    
    % Calculo da maior amplitude de ripple, Manolakis Cap 10.3.
    A=-20*log10(max(deltap,deltas));
    
    % Caculo de beta, Manolakis Cap 10.3 Equacao 10.84:
    if  A < 21
        beta = 0;
    elseif A > 50
        beta = 0.1102*(A - 8.7);
    else
        beta = 0.5842*((A-21)^0.4)+0.07886*(A-21);
    end
    
    % Funcao de Kaiser do MATLAB, usando beta.
    coef_janela = kaiser(L,beta);

end

end