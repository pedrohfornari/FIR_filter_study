function [mem, MAC_out] = MAC(filter_coef_quant, MAC_input, Nbits)
%
% [MAC_out, mem] = MAC(filter_coef_quant, MAC_input, Nbits)
%
% This function calculates the output of an multiplier and accumulator at
% MAC_out and mem. MAC_out represents the value calculated by the MAC whit
% two times of memory bits. mem represents the value that should be saved
% at a limited size memory, which is the quantization whit half of the
% MAC_out bits. The output is calculated by the convolution between
% filter_coef_qunt and MAC_input.
% Esta funcao calcula a saida de um multiplicador acumulador, nas saidas
% MAC_out e mem. MAC_out representa o valor calculado pelo multiplicador
% acumulador, com o dobro de bits da memoria. mem representa o valor que
% seria salvo na memoria, que eh a quantizacao com metade dos bits de
% MAC_out. A saida eh calculada pela convolucao entre filter_coef_quant e
% MAC_input.
%
% Inputs are:
% Os parametros de entrada sao:
%
% > filter_coef_quant = vector of quantized filter coeficients / 
%                       vetor de coeficiente dos filtros já quantizados;
% > MAC_input = Input Signal / entrada do somador acumulador;
% > Nbits = number of bits for output quantization / 
%           numero de bits para a quantizacao das saidas, onde mem possui
%           Nbits e MAC_out possui 2*Nbits;
%

% Quantize the input
% Quantiza a entrada (caso nao esteja quantizada):
MAC_input = quantizador(MAC_input,Nbits)';

% Calculates the size of the output vector
% Cacula o tamanho do vetor de saida pelo tamanho das entradas dos vetores
% a ser convoluidos:
size_out = length(MAC_input)+length(filter_coef_quant)-1;

% The following function does the linear convolution by the circular 
% convolution of the inputs:
% A funcao a seguir realiza a convolucao linear atravez da convolucao
% circular das entradas:

% Fill MAC_input with zeros on the left
% Completa MAC_input com zeros a esquerda no vetor linha 'aux_input'
aux_input = [zeros(1, (size_out-length(MAC_input))), MAC_input'];

% Fill filter_coef_quant with zeros to the left and transposes the matrix 
% Completa filter_coef_quant com zeros a esquerda no vetor coluna
% 'aux_coef' e realiza a inversao do vetor
aux_coef = fold([zeros(1, (size_out-length(filter_coef_quant))), filter_coef_quant']', 1);

% Multiply the vectors of coeficients and input resulting in a square
% matrix with size_out lines named aux_out
% Calcula a matriz produto entre os vetores de coeficientes e entrada. A
% matriz resultante eh uma matriz quadrada de 'size_out' linhas chamada
% 'aux_out'.
aux_out = aux_coef*aux_input;

% The result of the convolution could be obtained by summing the aux_out
% diagonals, which is done in the next step:
% O resultado da convolucao pode ser obtido somando-se as diagonais da
% matriz 'aux_out'. A soma eh realizada pela funcao a seguir:

% Inicialize the output vector
% Primeiro inicializa-se o vetor de saida MAC_out
MAC_out = zeros(1, size_out);

% To each n we sum the elements of the nth diagonal and are placed in the
% nth + 1 element of the output vector
% Depois, para cada n, sao somados os valores da n-esima diagonal da matriz
% size out. e sao jogados na posicao n+1 do vetro MAC_out.

for n = 0:(size_out-1)
    % By conovention, the principal diagonal is repesented by n = 0, so as 
    % the indexes should be greater than 0 we use n+1
    % The sum is then quantized by 2*Nbits and placed in MAC_out
    % Por convencao, a diagonal principal eh representada por n = 0, e como
    % os indices de vetores devem ser maior que 0 eh usado o artificio
    % (n+1), o que nao interfere nos calculos.
    % A soma eh quantizada em 2*Nbits para ser jogada na saida do MAC_out
    MAC_out(n+1) = quantizador(sum(diag(aux_out, n)), 2*Nbits);
    
end

% Finally MAC_out is quantized by Nbits and placed in mem
% Por fim, MAC_out eh quantizado em Nbits para se jogar na memoria 'mem':

mem = quantizador(MAC_out,Nbits);
mem = mem(200:end);
