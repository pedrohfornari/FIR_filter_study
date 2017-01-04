function [thd_out, pontos_w, percent_thd] = filter_thd(senoides_inp, filter_coef_final, Nbits, pontos_de_teste, wp, Fa)
%
% [thd_out, pontos_w, percent_thd]=filter_thd(senoides_inp, filter_coef_final, Nbits, pontos_de_teste, wp, Fa)
%
% Function that calculates the filter thd
% Função que calcula o thd do filtro implementado

% Inputs are:
% As entradas sao:
%
% > senoides_inp = signal to be filtered / sinal a ser filtrado
% > filter_coef_final = final filter coeficients / coeficientes finais
% > Nbits = number of bits passed to the quantizer / numero de bits passados ao quantizador
% > pontos_de_teste = number of points beeing tested / numero de pontos sendo testados
% > wp = normalized passband frequency / banda passante normalizada
% > Fa = sampling frequency / frequenciaa de amostragem
%

% create a space along the passband to check each sinusoid
% Cria o espaço ao longo da banda passante para checar cada senoide
w = linspace(0.1, pi-0.1, pontos_de_teste);
pontos_w = 0;
% Calculates the number of points to be tested
% calcula o numero de pontos a serem testados
for i = 1:pontos_de_teste
    if(w(i)<=wp)
        pontos_w = pontos_w+1;
    end
end
% Inicializes the output vector
% Inicializa o vetor de saida
percent_thd = zeros(pontos_w,1);

% Calculates thd for each test point
% Calcula o thd para cada ponto de teste
for i = 1:pontos_w
    percent_thd(i) = 100*(10^(thd(MAC(filter_coef_final, senoides_inp(i,:), Nbits), Fa,10)/20));
end

% Outputs the maximum thd found, which is the worst case
% Retorna o maximo thd encontrado, que eh o pior caso
thd_out = max(percent_thd);