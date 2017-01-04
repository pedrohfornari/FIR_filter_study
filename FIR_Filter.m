% Implementation of a FIR filter
% Lucas Pereira Luiz - 13101258
% Pedro Henrique Kappler Fornari - 13104320
% Digital Signal Processing
% Processamento Digital de Sinais
% This function implements a FIR filter following the pre seted specifications
% Esta funcao implementa um filtro FIR segundo as especificacoes escolhidas
% Pelo usuario.
function [ideal_order, ideal_cut_off_frq,...
          final_cut_off_frq, final_order,...
          filter_ok, thd_filter] = FIR_Filter(bits, janela)

% Inicialization of the specifications of the FIR Filter
% Inicialização das especificacoes do filtro FIR
% Here the user can set each requirement of the filter
% Aqui o usuario pode alterar as especificacoes do filtro se desejar
Fp = 10000;
Fs = 15000;
Fa = 44100;
Ap = 0.1;
As = 40; 
% End of inicialization
% Fim da inicializacao

% Declaration of variables related to the filter tests qualities
% Declaracao de variaveis relacionadas a qualidade dos testes do filtro
pontos_teste = 25; % Numero de senoides criadas para testar o filtro quantizado
                   % Number of sinusoids created to test the filter
N_fft = 2^12; % Numero de pontos da fft / Number of fft points

% End of variables declaration
% Fim Declaracao de variaveis

% Calculus of the first parameters
% Calculo de parametros primarios
wp = Fp*2*pi/Fa;
ws = Fs*2*pi/Fa;
deltap = (10^(Ap/20)-1)/(10^(Ap/20)+1);
deltas = 10^(-As/20);
M = estimativaordem(janela,wp,ws,deltap,deltas);
% End of first parameters calculation
% Fim do calculo de parametros primarios

% Check the requirements limits and improve the ideal filter if necessary
% Checa Requerimentos e melhora o filtro com precisao "ideal"
[filter_coef, ideal_order, ideal_cut_off_frq, filter_ok_ideal] = ...
    filter_improvment(N_fft, wp, ws, deltap, deltas, janela, M, 0);
% Fim
% End

% Quantize the filter coeficients with precision related to the number of
% bits choosen
% Quantiza os coeficientes do filtro com precisao relativa ao numero de
% bits escolhido
%filter_coef_quant = quantizador(filter_coef, bits);
% Fim
% End

% Check requerements and improve the quantized filter
% Checa Requerimentos e melhora o filtro quantizado
[filter_coef_quant, quant_order, quant_cut_off_frq, filter_ok_quant] = ...
    filter_improvment(N_fft, wp, ws, deltap, deltas, janela, ...
    ideal_order, bits);
% Fim
% End

% Test the quantized filter and improve it until it respect the filter
% requirements seted by the user.
% Realiza os testes no filtro quantizado até que o mesmo respeite as
% especificacoes setadas pelo usuario.
% Variables max_deltap, max_deltas and senoides controls the project, but
% they do not have any influence on the final result, which is presented to
% the user.
% As variaveis max_deltap, max_deltas e senoides servem para controle de
% projeto, mas não tem reelevancia no resultado final apresentado ao
% usuario
[filter_coef_quant, max_deltap, max_deltas, senoides, final_cut_off_frq,...
    final_order, filter_ok_final] = filter_improvment_quant(bits, filter_coef_quant,...
    deltap, deltas, janela, quant_order, N_fft, pontos_teste, wp, ws);
% Fim
% End

% Calculates the output filter thd to each sinusoid applied on the passband. 
% numero_pontos and percent_thd controls the project debug, so the user
% don't have to worry about them.
% Calcula o thd da saida do filtro para senoides aplicadas na banda
% passante. As variáveis numero_pontos e percent_thd servem para controle e
% debug de projeto, sendo que o usuário nao precisa se preocupar com elas.
[thd_filter, numero_pontos, percent_thd] = filter_thd(senoides,...
    filter_coef_quant, bits, pontos_teste, wp, Fa);
% Fim
% End

% This flag represents if the filter has been implemented with sucess or not
% Flag que indica se o filtro foi realizado com ou sem erros.
%   filter_ok == 3 --> filter could be implemented / filtro foi realizado sem problemas;
%   filter_ok ~= 3 --> number of attempts exceed the limit and project interrupted
%                       o numero de tentativas foi muito grande, e o projeto
%                      foi interrompido;
filter_ok = filter_ok_ideal+filter_ok_quant+filter_ok_final;

% Plot Function
% Funcao de graficos
[ok] = filter_plots(filter_coef, filter_coef_quant, senoides, bits, ...
    N_fft, pontos_teste, janela, deltap, deltas, wp, ws, ideal_order, ...
    quant_order, final_order);
% Fim
% End