% Implementation of a FIR filter
% Lucas Pereira Luiz - 13101258
% Pedro Henrique Kappler Fornari - 13104320
% Processamento Digital de Sinais
% Esta funcao implementa um filtro FIR segundo as especificacoes escolhidas
% Pelo usuario.
function [ideal_order, ideal_cut_off_frq,...
          final_cut_off_frq, final_order,...
          filter_ok, thd_filter] = FIR_Filter(bits, janela)

% Inicialização das especificacoes do filtro FIR
% Aqui o usuario pode alterar as especificacoes do filtro se desejar
Fp = 10000;
Fs = 15000;
Fa = 44100;
Ap = 0.1;
As = 40; 
%bits
%janela
            % 0 = Retangular; 
            % 1 = Hamming; 
            % 2 = Blackman; 
            % 3 = Kaiser;
% Fim da inicializacao

% Declaracao de variaveis relacionadas a qualidade dos testes do filtro
pontos_teste = 25; % Numero de senoides criadas para testar o filtro quantizado
N_fft = 2^12; % Numero de pontos da fft
       
% Fim Declaracao de variaveis

% Calculo de parametros primarios
wp = Fp*2*pi/Fa;
ws = Fs*2*pi/Fa;
deltap = (10^(Ap/20)-1)/(10^(Ap/20)+1);
deltas = 10^(-As/20);
M = estimativaordem(janela,wp,ws,deltap,deltas);
% Fim do calculo de parametros primarios


% Checa Requerimentos e melhora o filtro com precisao "ideal"
[filter_coef, ideal_order, ideal_cut_off_frq, filter_ok_ideal] = ...
    filter_improvment(N_fft, wp, ws, deltap, deltas, janela, M, 0);
% Fim

% Quantiza os coeficientes do filtro com precisao relativa ao numero de
% bits escolhido
%filter_coef_quant = quantizador(filter_coef, bits);
% Fim

% Checa Requerimentos e melhora o filtro quantizado
[filter_coef_quant, quant_order, quant_cut_off_frq, filter_ok_quant] = ...
    filter_improvment(N_fft, wp, ws, deltap, deltas, janela, ...
    ideal_order, bits);
% Fim

% Realiza os testes no filtro quantizado até que o mesmo respeite as
% especificacoes setadas pelo usuario.
% As variaveis max_deltap, max_deltas e senoides servem para controle de
% projeto, mas não tem reelevancia no resultado final apresentado ao
% usuario
[filter_coef_quant, max_deltap, max_deltas, senoides, final_cut_off_frq,...
    final_order, filter_ok_final] = filter_improvment_quant(bits, filter_coef_quant,...
    deltap, deltas, janela, quant_order, N_fft, pontos_teste, wp, ws);
%Fim

% Calcula o thd da saida do filtro para senoides aplicadas na banda
% passante. As variáveis numero_pontos e percent_thd servem para controle e
% debug de projeto, sendo que o usuário nao precisa se preocupar com elas.
[thd_filter, numero_pontos, percent_thd] = filter_thd(senoides,...
    filter_coef_quant, bits, pontos_teste, wp, Fa);
%Fim

% Flag que indica se o filtro foi realizado com ou sem erros.
%   filter_ok == 3 --> filtro foi realizado sem problemas;
%   filter_ok ~= 3 --> o numero de tentativas foi muito grande, e o projeto
%                      foi interrompido;
filter_ok = filter_ok_ideal+filter_ok_quant+filter_ok_final;

% Funcao de graficos
[ok] = filter_plots(filter_coef, filter_coef_quant, senoides, bits, ...
    N_fft, pontos_teste, janela, deltap, deltas, wp, ws, ideal_order, ...
    quant_order, final_order);
% Fim