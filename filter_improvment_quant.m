function [filter_coef_quant, max_deltap, max_deltas, senoide, ...
    cut_off_frq, order, filter_ok] = filter_improvment_quant(Nbits, ...
    filter_coef_quant, deltap, deltas, janela, M, Nfft, pontos_teste, ...
    wp, ws)
%
% [filter_coef_quant, max_deltap, max_deltas, senoide] = 
% filter_improvment_quant(Nbits,filter_coef_quant, deltap, deltas, janela,
% M, Nfft, pontos_teste, wp, ws)
%
% Funcao otimiza o filtro quantizado, calculando a saida do filtro para
% algumas senoides em determinadas frequencias a fim de estimar a reposta
% do filtro atraves do ganho em cada frequencia.
%
% Os parametros de entrada sao:
%
% > Nbits = numero de bits do quantizador
% > filter_coef_quant = primeiros coeficientes a serem testados. Na funcao
%                       principal, os primeiros coeficientes sao apenas os
%                       coeficientes do filtro otimizado depois de
%                       quantizados;
% > deltap = ripple na banda de passagem, em dB;
% > deltas = ripple na banda de corte, em dB;
% > janela = tipo de janela, podendo ser:
%     janela==0 --> Janela de Retangular;
%     janela==1 --> Janela de Hamming;
%     janela==2 --> Janela de Blackman;
%     janela==3 --> Janela de Kaiser;
% > M = ordem do filtro;
% > Nfft = numero de pontos da DFT a ser calculada;
% > pontos_teste = numero de senoides de diferentes frequencias a serem
%                  testadas no levantamento da resposta do filtro;
% > wp = frequencia final da banda de passagem, normalizada;
% > ws = frequencia inicial da banda de corte, normalizada;
%
%
% As saidas são:
% 
% > filter_coef_quant = coeficientes quantizados do filtro otimizado;
% > max_deltap = maior variacao na banda de passagem em dB;
% > max_deltas = maior vairacao na banda de rejeicao em dB;
% > senoide = matriz de 'pontos_teste' linhas e 'n' colunas, onde cada
%             linha representa uma senoide que foi testada no filtro;
%

% Flag que indica se o filtro esta pronto(0 = nao, 1 = sim, 2 =
% interrompido por excesso de tentativas).
filter_ok = 0;

% A variavel 'n' calcula as senoides no tempo.
n = (0:5000);

% A variavel 'w' controla as frequencias de cada senoide. Os pontos sao
% igualmente espacados.
w = linspace(0.1,pi-0.1,pontos_teste);

% Variavel que determina quais valores de frequencia de corte vao ser
% testados para otimizar o filtro. Sao 20 valores igualmente espacados e
% comecam um pouco depois de wp e terminam um pouco antes de ws pois a
% medida que wc se aproxima das bordas o filtro piora.
cut_off_test = linspace(wp+0.2, ws-0.2, 20);

% Inicializa o indice de varredura do teste da frequencia de corte.
k = 1;

% Contador que indica o numero de vezes que a ordem foi incrementada.
incremento_de_ordem = 0;

% Enquanto a flag for igual a 0 (filtro nao pronto) o programa tenta
% otimizar os valores dos coeficientes.
while(filter_ok == 0)
    
    % A matriz senoide eh previamente alocada para velocidade do programa.
    senoide = zeros(pontos_teste, length(n));
    
    % 'i' calcula a frequencia de cada senoide.
    for i = 1:pontos_teste
        % 'j' obtem n valores de cada senoide no tempo.
        for j = 1:length(n)
            senoide(i, j) = (0.5*sin(w(i)*j));
        end
        
        % Os valores de cada senoide no tempo sao quantizados em Nbits.
        senoide = quantizador(senoide,Nbits);
        
        % O valor maximo de cada na saida senoide representa a primeira
        % harmonica. Esse valor eh obtido passando os coeficientes
        % quantizados do filtro e os valores de uma das senoides no tempo
        % pelo multiplicador acumulador com Nbits, depois feita a DFT com
        % Nfft pontos, depois eh tirado o modulo e por fim pego o valor
        % maximo.
        % Ao se dividir esse valor maximo pelo valor maximo em modulo da
        % DFT com Nfft pontos da senoide de entrada obtem-se o ganho
        % (resposta em frequencia) do filtro para a frequencia de cada
        % senoide.
        % Os pontos maximos sao colocados em 'max_ponto':
        max_ponto(i) = max(abs(fft(MAC(filter_coef_quant,senoide(i,:),Nbits),Nfft)))/max(abs(fft(senoide(i,200:end),Nfft)));
        
        % 'max_passante' recebe 'max_ponto' para poder ser feita analise do
        % ripple em banda passante.
        max_passante(i) = max_ponto(i);
        
        % 'max_rejeicao' recebe 'max_ponto' para poder ser feita analise do
        % ripple em banda de rejeicao.
        max_rejeicao(i) = max_ponto(i);

        % 'cut_off_frq' recebe o valor atual da frequencia de corte sendo
        % testada.
        cut_off_frq = cut_off_test(k);
        
        % Os pontos que nao sao importantes para o calculo do ripple na
        % banda passante sao descartados. Isso equivale a descartar os
        % pontos que estão com frequencia w > wp.
        if w(i)>wp
            % O descarte equivale a igualar-se a 1 pois depois todos os
            % valores de 'max_passante' sao subtraidos de 1, resultando
            % apenas no ripple nos pontos que importam, e nos pontos
            % descartados o valor fica igual a 0. O ripple eh analisado
            % pelo valor maximo do modulo de (max_passante-1), logo, os
            % valores que ficam igual a 0 na subtracao nao interferem na
            % conta.
            max_passante(i) = 1;
        end

        % Os pontos que nao sao importantes para o calculo do ripple na
        % banda de rejeicao sao descartados. Isso equivale a descartar os
        % pontos que estão com frequencia w < ws.
        if w(i)<ws
            % O descarte equivale a igualar-se a 0 pois o ripple eh
            % analisado pelo valor maximo do modulo de (max_rejeicao), logo
            % os valores que ficam igual a 0 nao interfemrem na conta.
            max_rejeicao(i) = 0;
        end
    end

    % O maior ripple em banda passante eh calculado por
    % 'max(abs(abs(max_passante)-1))', como explicado anteriormente, e eh
    % armazenado em max_deltap
    max_deltap = max(abs(abs(max_passante)-1));
    
    % O maior ripple em banda de rejeicao eh calculado por
    % 'max(abs(abs(max_rejeicao))', como explicado anteriormente, e eh
    % armazenado em max_deltas
    max_deltas = max(abs(max_rejeicao));
    
    % A flag filter_ok eh setada como 1 para sair do while caso o filtro
    % satisfaca as conicoes de projeto.
    filter_ok = 1;
    
    % Caso a ordem seja incrementada mais de 15 vezes, o programa encerra
    % por excesso de tentativas, e eh carregado na saida o ultimo valor
    % testado na otimizacao.
    if(incremento_de_ordem>15)
        filter_ok = 2;
        filter_coef_quant= quantizador(coef_janelada, Nbits);
        disp(M);

    % Caso o ripple em banda passante ou de rejeicao seja maior que o da
    % especificacao, o indice da frequencia de corte eh incrementado para
    % ser realizado novo teste
    elseif((max_deltap >= deltap)||(max_deltas >= deltas))
        k = k+1;
        
        % Caso o indice da frequencia chegue no valor final a ordem eh
        % incrementada de 2, o indice da frequencia de corte eh reiniciado
        % e o contador 'incremento_de_ordem' aumenta de uma unidade.
        if cut_off_test(k) == cut_off_test(end)
            M = M+2;
            k = 1;
            incremento_de_ordem = incremento_de_ordem + 1;
        end
        
        % Ao se pegar um novo valor de frequencia de corte ou ordem, a flag
        % 'filter_ok' eh zerada e os coeficientes sao recalculados e
        % quantizados.
        filter_ok = 0;
        htruncada = respostatruncada(cut_off_test(k),M);
        coef_janela = coefjanelas(janela,M,deltap,deltas);
        coef_janelada = htruncada.*coef_janela;
        filter_coef_quant = quantizador(coef_janelada, Nbits);
    end
    order = M;
end

end

