function [idle_channel_probability, busy_channel_probability, collision_probability, success_tx_probability, transmission_probability] = backoff_s(x, m, cw_min, time_simulation)

i=1;
cw_max = cw_min*2^m;

cw = cw_min*logspace(0,0,x); % contention window initialization, set all nodes = cw_min
bc = -1*logspace(0,0,x);     % backoff counter initialization (-1)
time_line = 0*logspace(0,0,time_simulation);


for k = 1:x
    bc(k)=randi([0,cw(k)-1]);
end


while (i<time_simulation);
    
    transm_nodes = find(bc==0);
    not_transm_nodes = find(bc>0);
    n_transmissions = numel(find(bc==0));
    
    
    if (n_transmissions > 1)                                       % Collision
        for k = transm_nodes
            if (cw(k) < cw_max)
                cw(k) = cw(k)*2;
            end
            bc(k) = randi([0,cw(k)-1]);
        end
        
    elseif (n_transmissions == 1)                                  % Transmission
        cw(transm_nodes) = cw_min;
        bc(transm_nodes) =  randi([0,cw(transm_nodes)-1]);         % randi(cw(k)+1)-1;
    end
    
    
    for k = not_transm_nodes
        bc(k)=bc(k)-1;
    end
    
    
    time_line(i) = n_transmissions;
    i=i+1;
    
end

%disp('transmissions/slot:')
%disp(time_line)


idle_channel_probability = length(find(time_line ==0)) / length(time_line)
busy_channel_probability = 1- length(find(time_line ==0)) / length(time_line);
success_tx_probability = length(find(time_line ==1)) / length(time_line);
collision_probability = length(find(time_line >1)) / length(time_line);
transmission_probability = sum(time_line) / length(time_line)/x;


confirm = idle_channel_probability + collision_probability + success_tx_probability


end

