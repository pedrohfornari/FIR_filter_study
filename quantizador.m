function [saida_quantizador]=quantizador(entrada_quantizador,bits)
%
% [saida_quantizador]=quantizador(entrada_quantizador,bits)
%
% Função implementa um quantizador de n bits com saturação em (1-delta) e
% (-1), onde delta eh o passo do quantizador.
%
% As entradas sao:
%
% > entrada_quantizador = sinal a ser quantizado
% > bits = numero de bits do quantizador, ou ainda (1+bits de mantissa)

bits_de_mantissa = bits-1;

% Calculo do passo do quantizador
passo_quantizador = power(2,-bits_de_mantissa); 

% Calculo da saída fazendo (passo do quantizador)*(nível de quantização da
% entrada)
saida_quantizador = passo_quantizador*round(entrada_quantizador/passo_quantizador); 

% Saturação negativa
saida_quantizador(saida_quantizador < -1) = -1;

% Saturação positiva
saida_quantizador(saida_quantizador >1-passo_quantizador) = 1-passo_quantizador;

end