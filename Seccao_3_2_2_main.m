function main


n_start = 5;
n_step = 5;
n_max =50;
n_vector = n_start:n_step:n_max;
length_vector = length(n_vector);
cw_min=16;
m=3;
time_simulation = 500000;
i=1;


s_idle_channel_probability = 0*logspace(0,0,length_vector);
s_busy_channel_probability = 0*logspace(0,0,length_vector);
s_collision_probability = 0*logspace(0,0,length_vector);
s_success_tx_probability = 0*logspace(0,0,length_vector);
s_transmission_probability = 0*logspace(0,0,length_vector);

t_transmission_probability =  0*logspace(0,0,length_vector);   
t_collision_probability = 0*logspace(0,0,length_vector);  
t_successful_tx_probability = 0*logspace(0,0,length_vector);
t_busy_channel_probability = 0*logspace(0,0,length_vector);
t_idle_probability = 0*logspace(0,0,length_vector);


for n = n_start:n_step:n_max
    
    [s_idle_channel_probability(i), s_busy_channel_probability(i), s_collision_probability(i), s_success_tx_probability(i), s_transmission_probability(i)] = feval ('backoff_s', n, m, cw_min, time_simulation);   
    [t_idle_probability(i), t_busy_channel_probability(i), t_transmission_probability(i), t_successful_tx_probability(i), t_collision_probability(i)] = feval ('backoff_t', n , m, cw_min); 
    i=i+1;
  
end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % save data in file
        filename = sprintf('LAA_5_5_50_nos');
        %filename = sprintf('phy7_resultscoex_nodes%d_PC%d', n_total, PC);
        save(filename, 's_idle_channel_probability', 's_busy_channel_probability', 's_collision_probability', 's_success_tx_probability', ...
            's_transmission_probability', 't_idle_probability', 't_busy_channel_probability', 't_transmission_probability',...
            't_successful_tx_probability', 't_collision_probability');
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


figure
grid on;
hold on;
plot(n_vector, s_idle_channel_probability, 'ob');
plot(n_vector, t_idle_probability, '-b');
plot(n_vector, s_busy_channel_probability, 'sr');
plot(n_vector, t_busy_channel_probability, '-r');
plot(n_vector, s_transmission_probability, '<g');
plot(n_vector, t_transmission_probability, '-g');
plot(n_vector, s_success_tx_probability, '^m');
plot(n_vector, t_successful_tx_probability, '-m');
plot(n_vector, s_collision_probability, 'dc');
plot(n_vector, t_collision_probability, '-c');
xlabel('Número de nós 802.11');
ylabel('Probabilidade de acesso ao canal');
legend('Simul. prob. livre', 'Teor. prob. livre',...
       'Simul. prob. ocupado', 'Teor. prob. ocupado',...
       'Simul. prob. transm.', 'Theor. prob. transm.',...
       'Simul. prob. sucesso', 'Theor. prob. sucesso',...
       'Simul. prob. colisao', 'Theor. prob. colisao');
title('Simulação');

end
