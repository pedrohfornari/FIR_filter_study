function [saida_quantizador]=quantizador(entrada_quantizador,bits)
%
% [saida_quantizador]=quantizador(entrada_quantizador,bits)
%
% Fun��o implementa um quantizador de n bits com satura��o em (1-delta) e
% (-1), onde delta eh o passo do quantizador.
%
% As entradas sao:
%
% > entrada_quantizador = sinal a ser quantizado
% > bits = numero de bits do quantizador, ou ainda (1+bits de mantissa)

bits_de_mantissa = bits-1;

% Calculo do passo do quantizador
passo_quantizador = power(2,-bits_de_mantissa); 

% Calculo da sa�da fazendo (passo do quantizador)*(n�vel de quantiza��o da
% entrada)
saida_quantizador = passo_quantizador*round(entrada_quantizador/passo_quantizador); 

% Satura��o negativa
saida_quantizador(saida_quantizador < -1) = -1;

% Satura��o positiva
saida_quantizador(saida_quantizador >1-passo_quantizador) = 1-passo_quantizador;

end