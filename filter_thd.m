%
%
%
%
%
%
%
function [thd_out, pontos_w, percent_thd] = filter_thd(senoides_inp, filter_coef_final, Nbits, pontos_de_teste, wp, Fa)
w = linspace(0.1, pi-0.1, pontos_de_teste);
pontos_w = 0;
for i = 1:pontos_de_teste
    if(w(i)<=wp)
        pontos_w = pontos_w+1;
    end
end
percent_thd = zeros(pontos_w,1);
for i = 1:pontos_w
    percent_thd(i) = 100*(10^(thd(MAC(filter_coef_final, senoides_inp(i,:), Nbits), Fa,10)/20));
end

thd_out = max(percent_thd);