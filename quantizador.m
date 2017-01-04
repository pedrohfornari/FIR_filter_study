function [saida_quantizador]=quantizador(entrada_quantizador,bits)
%
% [saida_quantizador]=quantizador(entrada_quantizador,bits)
%
% Function that implements a quantizer of n bits with saturation at
% (1-delta) and (-1), where delta is the quantizer step
% Função implementa um quantizador de n bits com saturação em (1-delta) e
% (-1), onde delta eh o passo do quantizador.
%
% Inputs are:
% As entradas sao:
%
% > entrada_quantizador = signal to be quantized / sinal a ser quantizado
% > bits = number of bits the quantizer has / 
%          numero de bits do quantizador, ou ainda (1+bits de mantissa)

bits_de_mantissa = bits-1;

% Calculus of the quantizer step
% Calculo do passo do quantizador
passo_quantizador = power(2,-bits_de_mantissa); 

% Calculus of the output
% Calculo da saída fazendo (passo do quantizador)*(nível de quantização da
% entrada)
saida_quantizador = passo_quantizador*round(entrada_quantizador/passo_quantizador); 

% negative saturation
% Saturação negativa
saida_quantizador(saida_quantizador < -1) = -1;

% positive saturation
% Saturação positiva
saida_quantizador(saida_quantizador >1-passo_quantizador) = 1-passo_quantizador;

end