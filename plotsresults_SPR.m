

%load data in fil
filename = sprintf('UL_n_0_10_Pxdb20_noise25_10_PC1_NOVO');
data1 = load(filename);
filename = sprintf('UL_n_0_10_Pxdb20_noise50_10_PC1_NOVO');
data12 = load(filename);
filename = sprintf('UL_n_0_10_Pxdb20_noise100_10_PC1_NOVO');
data13 = load(filename);
filename = sprintf('UL_resultscoex_nodes10_PC1');
data14 = load(filename);

data14
data12.matrix_wifi_succ
data12.matrix_wifi
data12.matrix_wifi_norm
data12.matrix_laa_norm
data12.matrix_ocr_norm
data13

figure
grid on;
hold on;
plot(0:data1.n_total,  data1.s_wifi, '-r');
plot(0:data12.n_total, data12.s_wifi, '-b');
plot(0:data13.n_total, data13.s_wifi, '-g');
plot(0:data14.n_total, data14.s_wifi_time, '-k');
plot(0:data1.n_total,  data1.s_laa, '--r');
plot(0:data12.n_total, data12.s_laa, '--b');
plot(0:data13.n_total, data13.s_laa, '--g');
plot(0:data14.n_total, data14.s_laa_time, '--k');
xlabel('Número de nós 802.11');
ylabel('Debito relativo');
legend('wifi N0=0.25.',...
       'wifi N0=0.50.',... 
       'wifi N0=1.00.',...
       'wifi MAC',...
       'laa N0=0.25.',...
       'laa N0=0.50.',...
       'laa N0=1.00.',...
       'laa MAC');
title(strcat('Simulação UL CP=1'));