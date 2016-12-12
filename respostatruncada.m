function htruncado = respostatruncada(wc,M)
%
% [htruncado,pontos]=respostatruncada(wc, M)
%
% Função para implementar a resposta ao impulso truncada e causal do filtro
% ideal. 
%
% Parametros de entrada são:
%
% > wc = frequencia de corte;
% > M = ordem do filtro;
%

htruncado = (wc/pi)*sinc(wc/pi*((-M/2:M/2)'));
% Nota-se que o calculo eh feito de -M/2 ate M/2, porem como o MATLAB faz
% calculo por indice, 'htruncado' torna-se causal quando o primeiro
% elemento eh considerado como estando no zero do eixo, que eh o que ocorre
% fora desta funcao.

end