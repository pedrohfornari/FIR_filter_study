function [filter_coef, order, wc, filter_ok] = filter_improvment(Nfft, ...
    wp, ws, deltap, deltas, janela, M, bits)
% 
% [filter_coef, order, wc] = filter_improvment(Nfft, wp, ws, deltap, deltas, janela, M)
%
% This function iptimizes the filter by calculating its coeficients with
% the best wc and lowest order possible
% Esta funcao otimiza o filtro, calculando os coeficientes com o melhor wc
% e a menor ordem possivel.
%
% Inputs are:
% Os parametros de entrada sao:
%
% > Nfft = number of DFT points / numero de pontos da DFT a ser calculada;
% > wp = normalized cut off starter frequency / frequencia final da banda de passagem, normalizada;
% > ws = normalized cut off limit frequency / frequencia inicial da banda de corte, normalizada;
% > deltap = passband ripple / ripple na banda de passagem, em dB;
% > deltas = rejection band ripple / ripple na banda de corte, em dB;
% > janela = window / tipo de janela, podendo ser:
%     janela==0 --> Janela de Retangular;
%     janela==1 --> Janela de Hamming;
%     janela==2 --> Janela de Blackman;
%     janela==3 --> Janela de Kaiser;
% > M = order / ordem;
% > bits = number of bits for quantization, if ideal test bits = 0 / 
%          numero de bits da quantizacao dos coeficientes. Se o teste for
%          para filtro ideal -> bits =0.
%
% Outputs are:
% As saidas sao:
% 
% > filter_coef = filter coeficients / coeficientes do filtro otimizado;
% > order = filter order / ordem do filtro otimizado;
% > wc = cut off frequency of the optimized filter / frequencia de corte do filtro otimizado;

% Inicialize the order right before the estimated, to try the best option
% Inicia a ordem, no caso ideal, um pouco a baixo da estimada para garantir
% que vai testar a menor ordem possivel.
if bits ==0
    M = M-10;
else
    M = M;
end 

% Vector with cut off frequencies to be tested, with 200 points
% Vetor com as frequencias de corte a ser testadas, com 200 pontos:
cut_off_test = linspace(wp+0.2, ws-0.2, 200);

% To minimize the ripples proporcionally we decided to do the geometric 
% mean of deltap and deltas.
% Decisao de projeto, media geometrica de deltap e deltas, para que possa
% ser minimizado os dois ripples de maneira proporcinal:
min_delta = sqrt(deltap*deltas);

% Flag to control if the filter is ready or not ( 0 = no, 1 = yes, 2 =
% exceed iterations interrupt 
% Flag que indica se o filtro esta pronto(0 = nao, 1 = sim, 2 =
% interrompido por excesso de tentativas).
filter_ok = 0;

% Ccounter that indicates how many times the order was incremented.
% Contador que indica o numero de vezes que a ordem foi incrementada.
incremento_de_ordem = 0;

while(filter_ok==0)
    % Varies the cut off frequency:
    % Varia-se a frequencia de corte:
    for i = 1:length(cut_off_test)
        
        %Calculate the filter coeficients and its frequency response
        % Calcula-se os coeficientes do filtro, e calcula-se a resposta em
        % frequencia:
        htruncada = respostatruncada(cut_off_test(i),M);
        coef_janela = coefjanelas(janela,M,deltap,deltas);
        coef_janelada = htruncada.*coef_janela;
        freq_response = fft(coef_janelada,Nfft);
        % Fim do calculo.
        
        % Verify if the quantization should be done or not
        % Verifica se eh para fazer com quantizacao ou nao
        if bits ==0
            freq_response = fft(coef_janelada,Nfft);
        else
            freq_response = fft(quantizador((coef_janelada),bits),Nfft);
        end
        
        % Calculates news delta
        % Calcula os novos delta, obtidos para cada frequencia de corte:
        new_deltap = max(abs(abs(freq_response(1:ceil(wp*Nfft/(2*pi))))-1));
        new_deltas = max(abs(freq_response(ceil((ws*(Nfft))/(2*pi)):(Nfft/2))));
        new_min_delta = sqrt(new_deltap*new_deltas);
        
        % Verify if new delta satisfies the requirements and if the mean is
        % lower than before
        % Verifica-se se os novos delta satisfazem as especificacoes e se a
        % media geometrica eh menor que a anterior:
        if((new_deltap<=deltap)&&(new_deltas<=deltas)&&(new_min_delta<min_delta))
            
            % If truth
            % Caso verdade, atualiza-se os valores de:
            deltap = new_deltap; % deltap
            deltas = new_deltas; % deltas
            min_delta = new_min_delta; % media geometrica dos delta
            wc = cut_off_test(i); % melhor frequencia de corte
            order = M; % melhor ordem
            filter_coef = coef_janelada; % melhores coeficientes
            
            filter_ok = 1; % Indica que o filtro esta pronto
            
            
            % Ps: the flag indicates that the fiter is realizable at one
            % specific cut off frequency and one order. But after find the
            % first cut off frequency that satisfies, the calculus still
            % being realized keeping the order and varing the frequency, so
            % we could see if there is a better option
            % Obs.: A flag indica que o filtro eh realizavel para uma
            % determinada frequencia de corte e uma ordem. Mas depois que
            % achou a primeira frequencia de corte que satisfaz, o calculo
            % continua sendo realizado mantendo-se a ordem, e variando a
            % frequencia, para ver se existe uma melhor opcao de frequencia
            % de corte para a mesma ordem.
        end
    end
    
    % In the case of the number of tries exceed 200 the program is
    % interrupted and the values are returned to the previous sucessfull
    % calculation.
    % Caso o numero de tentativas no incremento da ordem exceda 200, o
    % programa eh interrompido e os valores retornados sao os ultimos
    % calculados.
    if(incremento_de_ordem>=200)
        filter_ok = 2;
        filter_coef = coef_janelada;
        wc = cut_off_test(i);
        order = M;
    end
    
    % In the case the current order do not satisfies the requirements, the
    % order is incremented and the sweep is repeted.
    % Caso a ordem atual nao satisfaca as especificacoes de deltap, deltas,
    % e media geometrica dos delta, para nenhuma frequencia de corte,
    % incrementa-se a ordem de 2 e o a varredura da frequencia de corte eh
    % reiniciada.
    M = M+2;
    incremento_de_ordem = incremento_de_ordem+1;
end

end