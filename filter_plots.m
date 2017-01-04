function [ok] = filter_plots(filter_coef, filter_coef_final, senoides,...
    bits, N_fft, pontos_teste, janela, deltap, deltas, wp, ws, ...
    ideal_order, quant_order, final_order)

%Function to name the plot window
%função pra colocar nome da janela no plot
tipo_janela = {'Retangular','Hamming','Blackman','Kaiser'};    
%%%%%%%%%%%

% plot axis
% eixo dos plots
w = 2*pi * (0:(N_fft-1)) / N_fft;
% end

% Specifications Function
% Função das especificações 
x1 = deltas*ones(1,length(w)/2); 
x1(abs(w) < wp) = 1+deltap;

x2 = zeros(1,length(w)/2);
x2(abs(w) < ws) = 1-deltap;
% End

% dB specification function 
% Função das especificações em dB
x3 = -40*ones(1,length(w)/2); 
x3(abs(w) < wp) = 0.1;

x4 = -1000*ones(1,length(w)/2);
x4(abs(w) < ws) = -0.1;
% End

% frequency ideal optimal response
% Resposta em freq ideal otima
ideal_freq_response = fft(filter_coef, N_fft);
% end

% frequency quantized coef optimal response
% Resposta em freq dos coef quantizados otima
freq_response_quant = fft(quantizador(filter_coef_final,bits), N_fft);
% end

% non linearities evaluation with quantized input and output
% Avaliacao da nao linearidade com entrada quantizada e saida quantizada
% usando senoides
eixo_teste_senoides = linspace(0.1,pi-0.1,pontos_teste)/pi;

teste_senoides = zeros(1,pontos_teste);
for i=1:pontos_teste
    teste_senoides(i) = max(abs(fft(MAC(filter_coef_final, senoides(i,:), bits),N_fft)));
    teste_senoides(i) = teste_senoides(i)/max(abs(fft(senoides(i,200:end),N_fft)));
end

% end


% Plots
figure('Name',['Janela ',tipo_janela{janela+1},', ',num2str(bits),' bits'],'NumberTitle','off');

subplot (3,3,1); 
    plot(w(1:length(w)/2)/pi, abs(ideal_freq_response(1:length(w)/2)),'k');
    hold on;
    plot(w(1:length(w)/2)/pi, x1,'r');
    plot(w(1:length(w)/2)/pi, x2,'r');
    hold off;
    title(['Resposta ideal ordem ', num2str(ideal_order)]);
    ylim([0 1.1]);
    xlabel('\omega/\pi');
    ylabel('Magnitude');
    
subplot (3,3,2); 
    plot(w(1:length(w)/2)/pi, 20*log10(abs(ideal_freq_response(1:length(w)/2))),'k');
    hold on;
    plot(w(1:length(w)/2)/pi, x3,'r');
    plot(w(1:length(w)/2)/pi, x4,'r');
    hold off;
    title(['Resposta ideal ordem ',num2str(ideal_order)]);
    ylim([-100 10]);
    xlabel('\omega/\pi');
    ylabel('Magnitude (dB)');
    
subplot (3,3,3); 
    plot(w(1:length(w)/2)/pi, angle(ideal_freq_response(1:length(w)/2)),'k');
    title(['Resposta ideal ordem ', num2str(ideal_order)]);
    xlabel('\omega/\pi');
    ylabel('Fase (rad)');

    
subplot (3,3,4);
    plot(w(1:length(w)/2)/pi, abs(freq_response_quant(1:length(w)/2)),'k')
    hold on;
    plot(w(1:length(w)/2)/pi, x1,'r');
    plot(w(1:length(w)/2)/pi, x2,'r');
    hold off;
    title(['Resposta quantizada ordem ',num2str(quant_order)]);
    ylim([0 1.1]);
    xlabel('\omega/\pi');
    ylabel('Magnitude');
    
subplot (3,3,5);
    plot(w(1:length(w)/2)/pi, 20*log10(abs(freq_response_quant(1:length(w)/2))),'k')
    hold on;
    plot(w(1:length(w)/2)/pi, x3,'r');
    plot(w(1:length(w)/2)/pi, x4,'r');
    hold off;
    title(['Resposta quantizada ordem ',num2str(quant_order)]);
    ylim([-100 10]);
    xlabel('\omega/\pi');
    ylabel('Magnitude (dB)');
    
    
subplot (3,3,6);
    plot(w(1:length(w)/2)/pi, angle(freq_response_quant(1:length(w)/2)),'k')
    title(['Resposta quantizada ordem ',num2str(quant_order)]);
    xlabel('\omega/\pi');
    ylabel('Fase (rad)');
    
subplot (3,2,5);
    stem(eixo_teste_senoides,teste_senoides,'.','b','linestyle','none');
    hold on;
    plot(w(1:length(w)/2)/pi, x1,'r');
    plot(w(1:length(w)/2)/pi, x2,'r');
    hold off;
    title(['Resposta final ordem ',num2str(final_order)]);
    ylim([0 1.1]);
    xlabel('\omega/\pi');
    ylabel('Magnitude');
    
subplot (3,2,6);
    stem(eixo_teste_senoides,20*log10(abs(teste_senoides)),'.','b','linestyle','none');
    hold on;
    plot(w(1:length(w)/2)/pi, x3,'r');
    plot(w(1:length(w)/2)/pi, x4,'r');
    hold off;
    ylim([-100 10]);
    title(['Resposta final ordem ',num2str(final_order)]);
    xlabel('\omega/\pi');
    ylabel('Magnitude (dB)');

% Flag that means the end
% Flag que indica que terminou
ok = 1;

end