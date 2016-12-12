function [filter_coef, order, wc, filter_ok] = filter_improvment(Nfft, ...
    wp, ws, deltap, deltas, janela, M, bits)
% 
% [filter_coef, order, wc] = filter_improvment(Nfft, wp, ws, deltap, deltas, janela, M)
%
% Esta funcao otimiza o filtro, calculando os coeficientes com o melhor wc
% e a menor ordem possivel.
%
% Os parametros de entrada sao:
%
% > Nfft = numero de pontos da DFT a ser calculada;
% > wp = frequencia final da banda de passagem, normalizada;
% > ws = frequencia inicial da banda de corte, normalizada;
% > deltap = ripple na banda de passagem, em dB;
% > deltas = ripple na banda de corte, em dB;
% > janela = tipo de janela, podendo ser:
%     janela==0 --> Janela de Retangular;
%     janela==1 --> Janela de Hamming;
%     janela==2 --> Janela de Blackman;
%     janela==3 --> Janela de Kaiser;
% > M = ordem;
% > bits = numero de bits da quantizacao dos coeficientes. Se o teste for
%          para filtro ideal -> bits =0.
%
%
% As saidas sao:
%
% > filter_coef = coeficientes do filtro otimizado;
% > order = ordem do filtro otimizado;
% > wc = frequencia de corte do filtro otimizado;

% Inicia a ordem, no caso ideal, um pouco a baixo da estimada para garantir
% que vai testar a menor ordem possivel.
if bits ==0
    M = M-10;
else
    M = M;
end 

% Vetor com as frequencias de corte a ser testadas, com 200 pontos:
cut_off_test = linspace(wp+0.2, ws-0.2, 200);

% Decisao de projeto, media geometrica de deltap e deltas, para que possa
% ser minimizado os dois ripples de maneira proporcinal:
min_delta = sqrt(deltap*deltas);

% Flag que indica se o filtro esta pronto(0 = nao, 1 = sim, 2 =
% interrompido por excesso de tentativas).
filter_ok = 0;

% Contador que indica o numero de vezes que a ordem foi incrementada.
incremento_de_ordem = 0;

while(filter_ok==0)
    % Varia-se a frequencia de corte:
    for i = 1:length(cut_off_test)
        
        % Calcula-se os coeficientes do filtro, e calcula-se a resposta em
        % frequencia:
        htruncada = respostatruncada(cut_off_test(i),M);
        coef_janela = coefjanelas(janela,M,deltap,deltas);
        coef_janelada = htruncada.*coef_janela;
        freq_response = fft(coef_janelada,Nfft);
        % Fim do calculo.
        
        % Verifica se eh para fazer com quantizacao ou nao
        if bits ==0
            freq_response = fft(coef_janelada,Nfft);
        else
            freq_response = fft(quantizador((coef_janelada),bits),Nfft);
        end
        
        % Calcula os novos delta, obtidos para cada frequencia de corte:
        new_deltap = max(abs(abs(freq_response(1:ceil(wp*Nfft/(2*pi))))-1));
        new_deltas = max(abs(freq_response(ceil((ws*(Nfft))/(2*pi)):(Nfft/2))));
        new_min_delta = sqrt(new_deltap*new_deltas);
        
        % Verifica-se se os novos delta satisfazem as especificacoes e se a
        % media geometrica eh menor que a anterior:
        if((new_deltap<=deltap)&&(new_deltas<=deltas)&&(new_min_delta<min_delta))
            
            % Caso verdade, atualiza-se os valores de:
            deltap = new_deltap; % deltap
            deltas = new_deltas; % deltas
            min_delta = new_min_delta; % media geometrica dos delta
            wc = cut_off_test(i); % melhor frequencia de corte
            order = M; % melhor ordem
            filter_coef = coef_janelada; % melhores coeficientes
            
            filter_ok = 1; % Indica que o filtro esta pronto
            
            % Obs.: A flag indica que o filtro eh realizavel para uma
            % determinada frequencia de corte e uma ordem. Mas depois que
            % achou a primeira frequencia de corte que satisfaz, o calculo
            % continua sendo realizado mantendo-se a ordem, e variando a
            % frequencia, para ver se existe uma melhor opcao de frequencia
            % de corte para a mesma ordem.
        end
    end

    % Caso o numero de tentativas no incremento da ordem exceda 200, o
    % programa eh interrompido e os valores retornados sao os ultimos
    % calculados.
    if(incremento_de_ordem>=200)
        filter_ok = 2;
        filter_coef = coef_janelada;
        wc = cut_off_test(i);
        order = M;
    end
    
    % Caso a ordem atual nao satisfaca as especificacoes de deltap, deltas,
    % e media geometrica dos delta, para nenhuma frequencia de corte,
    % incrementa-se a ordem de 2 e o a varredura da frequencia de corte eh
    % reiniciada.
    M = M+2;
    incremento_de_ordem = incremento_de_ordem+1;
end

end