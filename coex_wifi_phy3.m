function [ypdf_idle, success_wifi_time, success_laa_time, matrix, matrix_wifi, matrix_laa, matrix_wifi_norm, matrix_laa_norm, matrix_ocr_norm, meanSINR_totdB] ...
    = coex_wifi_phy3(n_wifi, n_laa, simulation_time, CP, xpdf_idle)

time_line = zeros(4, simulation_time);
slot = 9;
sifs = 16;
mili = 10^3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cw_min_wifi = [3, 7, 15];
cw_max_wifi = [7, 15, 1023];
m_wifi = [2, 2, 3];
mcot_wifi = [2.080, 4.096, 2.528];


cw_min_laa = [3, 7, 15];
cw_max_laa = [7, 15, 63];
m_laa = [1, 1, 3];
mcot_laa = [2, 3, 8];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% duration of occupancy should be equal to the higher time packet
mcot_wifi_laa = max(mcot_wifi, mcot_laa); % <---- AF
mcot_wifi_laa_min = min(mcot_wifi, mcot_laa);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%sensing  = [34*ones(1, n_wifi) 18*ones(1, n_laa)];
sync=2;
cw_min   = [cw_min_wifi(CP)*ones(1, n_wifi) cw_min_laa(CP)*ones(1, n_laa)];
cw_max   = [cw_max_wifi(CP)*ones(1, n_wifi) cw_max_laa(CP)*ones(1, n_laa)];
cw       = cw_min;
m_vector = [m_wifi(CP)*ones(1, n_wifi) m_laa(CP)*ones(1, n_laa)];
m_vector2 = m_vector;
mcot     = [mcot_wifi(CP)*ones(1,n_wifi) mcot_laa(CP)*ones(1, n_laa)];
bc       = [randi([0, cw_min_wifi(CP)],1,n_wifi) randi([0, cw_min_laa(CP)],1,n_laa)];
transmissions = zeros(1, n_wifi);
trans_not_max_cw = [];
i=1;
m_q_2 = 0;
%filename = sprintf('ResultsMay_Simul_100011vPaper_RG0_RE10_b1000_PxdB20_noise5_Shad69_PL200.mat');
filename = sprintf('ResultsMay_Simul_100011vPaper_RG0_RE10_b100_PxdB20_noise25_Shad69_PL200.mat');
load(filename);
% Psucc_wifi
% Psucc_laa

while (i<simulation_time)
    Coll_nodes=[];
    Succ_node=[];
    n_transmissions   = numel(intersect(find(bc==0), find(m_vector==0)));
    transm_nodes      = intersect(find(bc==0), find(m_vector==0));
    backoff_nodes     = intersect(find(bc>0),find(m_vector==0));
    m_observ_nodes    = find(m_vector>0);
    
    if (n_transmissions > 0)
        n_wifi_nodes = numel(find(transm_nodes <= n_wifi));
        n_laa_nodes  = n_transmissions - n_wifi_nodes;
        
        if(n_transmissions == 1)
            RV= rand(1);
            if n_wifi_nodes
                Psucc=Psucc_wifi(2,1);
            else
                Psucc=Psucc_laa(1,2);
            end
            if RV<Psucc
                Succ_node=transm_nodes;
            else
                Coll_nodes=transm_nodes;
            end
        end
        
        if(n_transmissions > 1)
            
            % geracao de um RV e verificacao que nos transmitiram com sucesso
            RV_Psucc = rand(1);
            Ptotal = Psucc_total(n_wifi_nodes + 1, n_laa_nodes + 1);
            if(Ptotal > RV_Psucc)
                Succ_node = transm_nodes(randi([1 n_transmissions], 1));
                Coll_nodes = transm_nodes(transm_nodes~=Succ_node);
            else
                Succ_node = 0;
                Coll_nodes = transm_nodes;
            end
        end
        
        if Succ_node       %%%  SUCCESS  %%%                              % para os nos que transmitiram com sucesso
            
            cw(Succ_node) = cw_min(Succ_node);
            transmissions(Succ_node) = zeros(1, numel(Succ_node)); % reicioco contador de retransmissoes wifi
            time_line(1,i) = numel(find(Succ_node <= n_wifi));      % adicionar a timelime o nr de nos que tx com sucesso
            time_line(3,i) = numel(find(Succ_node > n_wifi));
            
        end
        
        
        if numel(Coll_nodes)        %%% COLLISION %%%
            
            n_wifi_coll_nodes = numel(find(Coll_nodes) <= n_wifi_nodes);
            % cw == cw_max (wifi)
            trans_max_cw = find(cw(Coll_nodes(1:n_wifi_coll_nodes)))==cw_max_wifi(CP);
            
            % cw < cw_max
            trans_not_max_cw = find(cw(Coll_nodes) < cw_max(Coll_nodes)==1);
            
            % double cw
            cw(Coll_nodes(trans_not_max_cw)) = cw(Coll_nodes(trans_not_max_cw)).*2+1;
            
            % discart when transmissions = 2
            transmissions(Coll_nodes(trans_max_cw)) = transmissions(Coll_nodes(trans_max_cw))+1;
            discard =(find(transmissions==2));
            transmissions(discard) = zeros(1, numel(discard));
            cw(discard)=cw_min(discard);
            
            time_line(2,i) = numel(find(Coll_nodes <= n_wifi));      % adicionar a timelime o nr de nós que tx sem sucesso
            time_line(4,i) = numel(find(Coll_nodes > n_wifi));
        end
        
        for k=transm_nodes
            bc(k)=randi([0,cw(k)]);
        end
        trans_not_max_cw = [];
        
        m_nodes = [transm_nodes m_observ_nodes];    % reiniciamos m dos nós que transmitiram e que estão em fase 'm'
        m_vector(m_nodes) = m_vector2(m_nodes);
        sync_nodes = backoff_nodes < n_wifi;        % nós wifi em backoff aguardam mais dois slots (16 micros de LAA + 2 slots x 9 micros)
        if(sync_nodes)
            m_vector(backoff_nodes(sync_nodes)) = sync;
        end
        
    else
        bc(backoff_nodes) = bc(backoff_nodes) - 1;  % decremento do backoff e m
        m_vector(m_observ_nodes) = m_vector(m_observ_nodes) - 1;
        time_line(:,i) = zeros(4,1);                             % idle
    end
    i=i+1;
end

%%%%%%debitos%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
aux=true;
time_line;
if mcot_wifi(CP)<mcot_laa(CP)
    time_line = circshift(time_line, [2 0]);
    aux=false;
end

vec_slot_durations = zeros(1, simulation_time);
Max= max(time_line, [], 1);
vec_slot_durations(Max==0) = slot.*ones(1, numel(find(Max==0)));
Index_mcot_min = sum(time_line(3:4,:), 1);
vec_slot_durations(Index_mcot_min>0) = mcot_wifi_laa_min(CP)*mili.*ones(1, numel(find(Index_mcot_min>0)));
Index_mcot_max = sum(time_line(1:2,:), 1);
vec_slot_durations(Index_mcot_max>0) = mcot_wifi_laa(CP)*mili.*ones(1, numel(find(Index_mcot_max>0)));


sim_total_duration = sum(vec_slot_durations) + sifs * numel(find(Max>0));    % + sifs cada vez que o meio fica ocupado

if (aux)
    success_wifi_time =  sum(time_line(1,:)) * mcot_wifi(CP)*mili / sim_total_duration;
    success_laa_time = sum(time_line(3,:)) * mcot_laa(CP)*mili / sim_total_duration;
else
    success_wifi_time =  sum(time_line(3,:)) * mcot_wifi(CP)*mili / sim_total_duration;
    success_laa_time = sum(time_line(1,:)) * mcot_laa(CP)*mili / sim_total_duration;
    time_line = circshift(time_line, [2 0]);
end

%%%%%%ocorrencia de cada evento%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
matrix = zeros(n_wifi+n_laa, 4);
for i=1:1:4
    numbers=unique(time_line(i,:));
    occur = zeros(length(numbers),2);
    for j=1:1:length(numbers)
        occur(j,:) = [numbers(j) length(find(time_line(i,:)==numbers(j)))/simulation_time];
    end
    matrix(occur(2:end,1), i) = occur(2:end,2);
    
end
%%%%%matrix_sucesso%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
access = zeros(2, simulation_time);
access(1,:) = sum(time_line(1:2,:), 1);
access(2,:) = sum(time_line(3:4,:), 1);
f_access = access';
poss = (unique(f_access, 'rows'));
matrix_wifi=zeros(n_wifi+1,n_laa+1);
matrix_laa=zeros(n_wifi+1,n_laa+1);
matrix_wifi_norm=zeros(n_wifi+1,n_laa+1);
matrix_laa_norm=zeros(n_wifi+1,n_laa+1);
matrix_ocr = zeros(n_wifi+1,n_laa+1);
for i=1:size(poss,1)
    
    columns = intersect(find(access(1,:)==poss(i,1)),find(access(2,:)==poss(i,2)));
    
    matrix_wifi(poss(i,1)+1,poss(i,2)+1) = sum(time_line(1,columns));
    matrix_laa(poss(i,1)+1,poss(i,2)+1)  = sum(time_line(3,columns));
    matrix_wifi_norm(poss(i,1)+1,poss(i,2)+1)=matrix_wifi(poss(i,1)+1,poss(i,2)+1)/numel(columns);
    matrix_laa_norm(poss(i,1)+1,poss(i,2)+1)=matrix_laa(poss(i,1)+1,poss(i,2)+1)/numel(columns);
    %matrix_ocr(poss(i,1)+1,poss(i,2)+1) = sum(time_line(1,columns))+sum(time_line(2,columns));
    
end

matrix_ocr = zeros(n_wifi+1, n_laa+1);
matrix_ocr = matrix_laa + matrix_wifi;
matrix_ocr(1,2)=0;
matrix_ocr(2,1)=0;
matrix_ocr_norm = zeros(n_wifi+1, n_laa+1);
matrix_ocr_norm = matrix_ocr/sum(sum(matrix_ocr,2), 1);
MeanSINR(1,1)=0;
MeanSINR(1,2)=0;
MeanSINR(2,1)=0;
meanSINR_aux=zeros(6,6);
for i=1:1:n_wifi+1
    for j=1:1:n_laa+1
        meanSINR_aux(i,j) = matrix_ocr_norm(i,j) * MeanSINR(i,j);
    end
end

meanSINR_aux;
meanSINR_tot = sum(sum(meanSINR_aux,1),2);
meanSINR_totdB = 10*log10(meanSINR_tot)


%%%%%%%Slots consecutivos idle%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vect_slots = Max';
idx = vect_slots([1,1:end,end],:)==0;
idx([1,end],:) = false;
tmp = diff(idx,1,1);
num_slotidle = find(tmp<0)-find(tmp>0); % resultado: vector com o numero de slots consecutivos idle
[ypdf_idle] = hist(num_slotidle, xpdf_idle);


end
