

%load data in fil
filename = sprintf('MPR_DL_n_0_10_Pxdb20_b10_noise25_10_PC1');
data1 = load(filename);
filename = sprintf('MPR_DL_n_0_10_Pxdb20_b25_noise25_10_PC1');
data12 = load(filename);
filename = sprintf('MPR_DL_n_0_10_Pxdb20_b50_noise25_10_PC1');
data13 = load(filename);
filename = sprintf('phy7_resultscoex_nodes10_PC1');
data14 = load(filename);

data14

data13

figure
grid on;
hold on;
plot(0:data1.n_total,  data1.s_wifi_time, '-r');
plot(0:data12.n_total, data12.s_wifi_time, '-b');
plot(0:data13.n_total, data13.s_wifi_time, '-g');
plot(0:data14.n_total, data14.s_wifi_time, '-k');
plot(0:data1.n_total,  data1.s_laa, '--r');
plot(0:data12.n_total, data12.s_laa, '--b');
plot(0:data13.n_total, data13.s_laa, '--g');
plot(0:data14.n_total, data14.s_laa_time, '--k');
xlabel('Número de nós 802.11');
ylabel('Debito relativo');
legend('wifi b=0.110.',...
       'wifi b=0.25.',... 
       'wifi b=0.50.',...
       'wifi MAC',...
       'laa b=0.10.',...
       'laa b=0.25.',...
       'laa b=0.50.',...
       'laa MAC');
title(strcat('Simulação UL CP=1'));