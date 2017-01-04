function htruncado = respostatruncada(wc,M)
%
% [htruncado,pontos]=respostatruncada(wc, M)
%
% Function that implements the impulse response of a causal truncated ideal
% rectangular filter 
% Função para implementar a resposta ao impulso truncada e causal do filtro
% ideal. 
%
% Inputs are
% Parametros de entrada são:
%
% > wc = cut of frequency / frequencia de corte;
% > M = fiflter order / ordem do filtro;
%

htruncado = (wc/pi)*sinc(wc/pi*((-M/2:M/2)'));
% We could note that the calculus is made from -M/2 to M/2, but as MATLAB
% calculates by index, htruncado becomes causal when the first term is
% considered as the axis center, which occurs out of this function.
% Nota-se que o calculo eh feito de -M/2 ate M/2, porem como o MATLAB faz
% calculo por indice, 'htruncado' torna-se causal quando o primeiro
% elemento eh considerado como estando no zero do eixo, que eh o que ocorre
% fora desta funcao.

end