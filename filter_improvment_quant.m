function [filter_coef_quant, max_deltap, max_deltas, senoide, ...
    cut_off_frq, order, filter_ok] = filter_improvment_quant(Nbits, ...
    filter_coef_quant, deltap, deltas, janela, M, Nfft, pontos_teste, ...
    wp, ws)
%
% [filter_coef_quant, max_deltap, max_deltas, senoide] = 
% filter_improvment_quant(Nbits,filter_coef_quant, deltap, deltas, janela,
% M, Nfft, pontos_teste, wp, ws)
%
% Function that optimizes the quantized filter by calculating the filter
% output for some sinusoids in determined frequencies so is possible to
% estimate the filter response, which is the gain on each frequency.
% Funcao otimiza o filtro quantizado, calculando a saida do filtro para
% algumas senoides em determinadas frequencias a fim de estimar a reposta
% do filtro atraves do ganho em cada frequencia.
%
% The Inputs are:
% Os parametros de entrada sao:
%
% > Nbits = number of bits to quantize / numero de bits do quantizador
% > filter_coef_quant = first coeficient to be tried, that is the
%                       coeficients already quantized of an ideal response
%                       /
%                       primeiros coeficientes a serem testados. Na funcao
%                       principal, os primeiros coeficientes sao apenas os
%                       coeficientes do filtro otimizado depois de
%                       quantizados;
% > deltap = passband ripple / ripple na banda de passagem, em dB;
% > deltas = cutofband ripple / ripple na banda de corte, em dB;
% > janela = window / tipo de janela, podendo ser:
%     janela==0 --> Janela de Retangular;
%     janela==1 --> Janela de Hamming;
%     janela==2 --> Janela de Blackman;
%     janela==3 --> Janela de Kaiser;
% > M = order / ordem do filtro;
% > Nfft = number of point used to calculate the DFT / numero de pontos da DFT a ser calculada;
% > pontos_teste = number of sinusoids to be tested / 
%                  numero de senoides de diferentes frequencias a serem
%                  testadas no levantamento da resposta do filtro;
% > wp = normalized cutof starter frequency / frequencia final da banda de passagem, normalizada;
% > ws = nomalized cutof limit frequency / starfrequencia inicial da banda de corte, normalizada;
%
% Outputs are:
% As saidas são:
% 
% > filter_coef_quant = quantized optimized filter coeficients / 
%                       coeficientes quantizados do filtro otimizado;
% > max_deltap = greatest passband ripple / maior variacao na banda de passagem em dB;
% > max_deltas = greatest rejection band ripple / maior vairacao na banda de rejeicao em dB;
% > senoide = matrix with the test points at 'n' frequencies, where the lines
%             represent sinusoids filtered points and columns represents
%             frequencies variations
%             matriz de 'pontos_teste' linhas e 'n' colunas, onde cada
%             linha representa uma senoide que foi testada no filtro;
%

% Flag to control if the filter is ready or not ( 0 = no, 1 = yes, 2 =
% exceed iterations interrupt 
% Flag que indica se o filtro esta pronto(0 = nao, 1 = sim, 2 =
% interrompido por excesso de tentativas).
filter_ok = 0;

% 'n'calculates the sinusoids along the time
% A variavel 'n' calcula as senoides no tempo.
n = (0:5000);

% 'w'controls frequencies of each sinusoid. Points are spaced equally
% A variavel 'w' controla as frequencias de cada senoide. Os pontos sao
% igualmente espacados.
w = linspace(0.1,pi-0.1,pontos_teste);

% Variable to determine which cut off frequencies will be tested to
% optimize the filter. There will be 20 values equally spaced and they
% start right after wp and end right before ws.
% Variavel que determina quais valores de frequencia de corte vao ser
% testados para otimizar o filtro. Sao 20 valores igualmente espacados e
% comecam um pouco depois de wp e terminam um pouco antes de ws pois a
% medida que wc se aproxima das bordas o filtro piora.
cut_off_test = linspace(wp+0.2, ws-0.2, 20);

% Inicialize the test sweep index of the cut off frequency
% Inicializa o indice de varredura do teste da frequencia de corte.
k = 1;

% Ccounter that indicates how many times the order was incremented.
% Contador que indica o numero de vezes que a ordem foi incrementada.
incremento_de_ordem = 0;

% While the flag is 0 the program tries to optimize it's coeficients
% Enquanto a flag for igual a 0 (filtro nao pronto) o programa tenta
% otimizar os valores dos coeficientes.
while(filter_ok == 0)
    % The sinusoids matrix is pre alocated
    % A matriz senoide eh previamente alocada para velocidade do programa.
    senoide = zeros(pontos_teste, length(n));
    
    % 'i' calculates the frequency of each sinusoid
    % 'i' calcula a frequencia de cada senoide.
    for i = 1:pontos_teste
        % 'j' get n values of each senoid along the time.
        % 'j' obtem n valores de cada senoide no tempo.
        for j = 1:length(n)
            senoide(i, j) = (0.5*sin(w(i)*j));
        end
        
        % Senoid values are quantized by Nbits
        % Os valores de cada senoide no tempo sao quantizados em Nbits.
        senoide = quantizador(senoide,Nbits);
        
        % The maximum value of each output represents the first harmonic.
        % This value is obtained by filtering the sinusoid and then apply
        % the DFT with Nfft points. From this we can get the maximum
        % absolute value.
        % When we divide this maximum by the maximum absolute value of the
        % input sinusoid we normalize it and the result is the filter gain
        % so whit this we can check our limits.
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
        
        % Right now we divide the points along the frequencies, so we can
        % get values on the passband and rejection band and check the
        % limits
        % 'max_passante' recebe 'max_ponto' para poder ser feita analise do
        % ripple em banda passante.
        max_passante(i) = max_ponto(i);
        
        % 'max_rejeicao' recebe 'max_ponto' para poder ser feita analise do
        % ripple em banda de rejeicao.
        max_rejeicao(i) = max_ponto(i);

        % 'cut_off_frq' recebe o valor atual da frequencia de corte sendo
        % testada.
        cut_off_frq = cut_off_test(k);
        
        % The points that are not important to the ripple calculation are
        % throwed away. It means the values of 'w' greater than wp
        % Os pontos que nao sao importantes para o calculo do ripple na
        % banda passante sao descartados. Isso equivale a descartar os
        % pontos que estão com frequencia w > wp.
        if w(i)>wp
            % To do this we can match this values to 1 so the ripple here
            % will be null.
            % O descarte equivale a igualar-se a 1 pois depois todos os
            % valores de 'max_passante' sao subtraidos de 1, resultando
            % apenas no ripple nos pontos que importam, e nos pontos
            % descartados o valor fica igual a 0. O ripple eh analisado
            % pelo valor maximo do modulo de (max_passante-1), logo, os
            % valores que ficam igual a 0 na subtracao nao interferem na
            % conta.
            max_passante(i) = 1;
        end

        % The same discard is done to the rejection band
        % Os pontos que nao sao importantes para o calculo do ripple na
        % banda de rejeicao sao descartados. Isso equivale a descartar os
        % pontos que estão com frequencia w < ws.
        if w(i)<ws
            % For this we match each value of max_rejeicao with w lower
            % than ws to 0, so it means -inf dB.
            % O descarte equivale a igualar-se a 0 pois o ripple eh
            % analisado pelo valor maximo do modulo de (max_rejeicao), logo
            % os valores que ficam igual a 0 nao interfemrem na conta.
            max_rejeicao(i) = 0;
        end
    end
    % Check the gratest ripple at the passband
    % O maior ripple em banda passante eh calculado por
    % 'max(abs(abs(max_passante)-1))', como explicado anteriormente, e eh
    % armazenado em max_deltap
    max_deltap = max(abs(abs(max_passante)-1));
    
    % Check the greatest ripple at the rejection band
    % O maior ripple em banda de rejeicao eh calculado por
    % 'max(abs(abs(max_rejeicao))', como explicado anteriormente, e eh
    % armazenado em max_deltas
    max_deltas = max(abs(max_rejeicao));
    
    % The flag filter_ok is seted as 1, so if it pass the tests the filter
    % is done
    % A flag filter_ok eh setada como 1 para sair do while caso o filtro
    % satisfaca as conicoes de projeto.
    filter_ok = 1;
    
    % In the case of the order be incremented more than 15 times we get an
    % exceed iterations interrupt and the program ends without get a right
    % filter
    % Caso a ordem seja incrementada mais de 15 vezes, o programa encerra
    % por excesso de tentativas, e eh carregado na saida o ultimo valor
    % testado na otimizacao.
    if(incremento_de_ordem>15)
        filter_ok = 2;
        filter_coef_quant= quantizador(coef_janelada, Nbits);
        disp(M);
    
    % Test the bandpass ripple and the rejection band ripple
    % Caso o ripple em banda passante ou de rejeicao seja maior que o da
    % especificacao, o indice da frequencia de corte eh incrementado para
    % ser realizado novo teste
    elseif((max_deltap >= deltap)||(max_deltas >= deltas))
        k = k+1;
        
        % If the frequency index reach the final value the order is
        % incremented by 2 and we run the tests again
        % Caso o indice da frequencia chegue no valor final a ordem eh
        % incrementada de 2, o indice da frequencia de corte eh reiniciado
        % e o contador 'incremento_de_ordem' aumenta de uma unidade.
        if cut_off_test(k) == cut_off_test(end)
            M = M+2;
            k = 1;
            incremento_de_ordem = incremento_de_ordem + 1;
        end
        
        % If the filter does not pass the tests filter_ok is switche to 0
        % and the project is restarted by calculating the filter
        % coeficients and quantazing them.
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

