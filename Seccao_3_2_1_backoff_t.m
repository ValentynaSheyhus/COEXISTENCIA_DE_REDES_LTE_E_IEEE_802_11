function [idle_probability, busy_channel_probability, transmission_probability, successful_transmission_probability, collision_probability_2] = backoff_t(n, m , W)

    
    syms p_collision p_transmission
    syms p_transmission positive
    syms p_collision positive
    eqns = [p_transmission == (2*(1-2*p_collision))/((1-2*p_collision)*(W+1) + p_collision * W * (1-(2*p_collision)^m)), p_collision == 1-(1-p_transmission)^(n-1)];   % p - busy channel probability / colision probability
    X = solve(eqns, [p_collision p_transmission]);%                                                                                         % W - backoff windows size
    
    transmission_probability = vpa(X.p_transmission)    % tau
    collision_probability = vpa(X.p_collision)          % p -> probability that at least one of the remaining stations transmit

    idle_probability = (1-transmission_probability).^(n)
    busy_channel_probability= 1 - idle_probability
    successful_transmission_probability = n * (transmission_probability * (1-transmission_probability)^(n-1)); % / (1-(1-transmission_probability(i)).^n) ;     % ps7  
    collision_probability_2 = busy_channel_probability - successful_transmission_probability;
  
    
end
