
clc;
clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% INPUTS %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

name_simul = 'ResultsMay';
% Simulation Time in Packet frames
SimulationTime = 200000; % Packet Frames
topologystatic = 0;
%%%%%%%%%%%%%%%%
% LAA Network %
%%%%%%%%%%%%%%%%
PxdB_laa = 20;
Px_laa = 10^(PxdB_laa/10);
min_nodes_laa = 0;
max_nodes_laa = 10;
Rinner_laa = 0;
Router_laa = 10;

%%%%%%%%%%%%%%%%
% Wifi Network %
%%%%%%%%%%%%%%%%
PxdB_wifi = 20;
Px_wifi = 10^(PxdB_wifi/10);
min_nodes_wifi = 0;
max_nodes_wifi = 10;
Rinner_wifi = 0;
Router_wifi = 10;

%%%%%%%%%%%%%%%
%   Channel   %
%%%%%%%%%%%%%%%
% Noise Additive white Gaussian noise
noise_var = 0.25; % Noise Variance
% Pathloss effect
pathloss = 2;
% Shadowing effect
dBShad_var = 3;  % antes = 3
Shad_var = dBShad_var/(10/log(10));
% Effect [patloss, fastfadind, slowfading,gammaSlowfading, gammafading, noise]
type_effect = [true, false, false, false, true, true];
% Success Threshold
beta_threshold = 0.10; 
beta_l = beta_threshold/(beta_threshold+1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Transmissions Signal Power for LAA nodes
SignalNodes_m_laa = Px_laa;
SignalNodes_var_laa = 0;

% Transmissions Signal Power for Wifi nodes
SignalNodes_m_wifi = Px_wifi;
SignalNodes_var_wifi = 0;

Numnodes_laa = min_nodes_laa:1:max_nodes_laa;
Numnodes_wifi = min_nodes_wifi:1:max_nodes_wifi;


[Numnodes_laa, Numnodes_wifi] = meshgrid(Numnodes_laa, Numnodes_wifi);
TotalSuccess_laa = zeros(size(Numnodes_laa)); 
TotalSuccess_wifi = zeros(size(Numnodes_wifi)); 

TotalSuccess = zeros(size(Numnodes_laa));    %????
TotalAccess = zeros(size(Numnodes_laa));




id_laa = 1;
for NumActiveNodes_laa=min_nodes_laa:1:max_nodes_laa
    id_wifi = 1;
    for NumActiveNodes_wifi=min_nodes_wifi:1:max_nodes_wifi
    
        % Nodes Position - N transmissions Uniform distributed over time
        if topologystatic 
            % Static Topology
            Fzaux_laa = rand(1, NumActiveNodes_laa);
            Fz_laa = repmat(Fzaux_laa, SimulationTime, 1);
            Fzaux_wifi = rand(1, NumActiveNodes_wifi);
            Fz_wifi = repmat(Fzaux_wifi, SimulationTime, 1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        else
            Fz_laa = rand(SimulationTime, NumActiveNodes_laa);
            Fz_wifi = rand(SimulationTime, NumActiveNodes_wifi);
        end;
        
        % Generate Distances for the LAA Network
        % Near Field scenario particular condition when Rinner < 1 
        if (Rinner_laa==0)
            DistofNodes_laa = sqrt(Fz_laa.*(Router_laa.^2)) + 1;
        else
            DistofNodes_laa = sqrt(Fz_laa.*(Router_laa^2 - Rinner_laa^2) + Rinner_laa^2);
        end;
        
        % Generate Distances for the Wifi Network
        % Near Field scenario particular condition when Rinner < 1 
        if (Rinner_wifi==0)
            DistofNodes_wifi = sqrt(Fz_wifi.*(Router_wifi.^2)) + 1;
        else
            DistofNodes_wifi = sqrt(Fz_wifi.*(Router_wifi^2 - Rinner_wifi^2) + Rinner_wifi^2);
        end;
         
        
        
        % Power of de LAA Nodes transmiting saw by a receiver in the center
        PowerNodesPj_laa = generateSignalNodes(DistofNodes_laa, SignalNodes_m_laa, SignalNodes_var_laa, pathloss, Shad_var, type_effect);
      
        % Power of de Wifi Nodes transmiting saw by a receiver in the center
        PowerNodesPj_wifi = generateSignalNodes(DistofNodes_wifi, SignalNodes_m_wifi, SignalNodes_var_wifi, pathloss, Shad_var, type_effect);
        
        
        % Lets join the Networks Powers in one matrix
        PowerNodesPj = [PowerNodesPj_laa, PowerNodesPj_wifi];
        
        %%%%%%%%%%%%%%%   Condition of Reception %%%%%%%%%%
        %   Alfa - Total Power
        PowerReceive = sum(PowerNodesPj,2); % Sum all power       %uma coluna 
        NumActiveNodes = NumActiveNodes_laa + NumActiveNodes_wifi;
        auxPowerReceive = repmat(PowerReceive,1, NumActiveNodes); % repete a matriz de soma   %matriz com duas colunas,2a copia da 1a
        PowerRec_withoutPj = auxPowerReceive-PowerNodesPj; % -> Psum - Pj
        
        %Condition of Reception with success
       if type_effect(6)         %Noise 
            Noise = exprnd(noise_var, size(PowerRec_withoutPj));    
            betaj = PowerNodesPj./(PowerRec_withoutPj + Noise);
       else
            betaj = PowerNodesPj./((PowerRec_withoutPj));
       end;
     
       if NumActiveNodes_laa 
            MSuccessNode_laa = betaj(:,1:NumActiveNodes_laa) > beta_threshold;
            MSuccessNode_wifi = betaj(:, NumActiveNodes_laa+1:end) > beta_threshold;
       elseif NumActiveNodes_wifi
           MSuccessNode_wifi = betaj(:, 1:NumActiveNodes_wifi) > beta_threshold;
       else
           MSuccessNode_laa = 0;
           MSuccessNode_wifi = 0;
       end
       
       MSuccessNode = betaj > beta_threshold;
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Total Number of Success in the simulation
       TotalSuccess_laa(id_wifi, id_laa) = TotalSuccess_laa(id_wifi, id_laa) + sum(sum(MSuccessNode_laa));   
       TotalSuccess_wifi(id_wifi, id_laa) = TotalSuccess_wifi(id_wifi, id_laa) + sum(sum(MSuccessNode_wifi));
       TotalAccess(id_wifi, id_laa) = TotalAccess(id_wifi, id_laa) + (NumActiveNodes*SimulationTime);
       TotalSuccess(id_wifi, id_laa) = TotalSuccess(id_wifi, id_laa) + sum(sum(MSuccessNode));
       
       
       %%%%%
       MeanSINR(id_wifi,id_laa) = mean(mean(betaj));
       
       
       id_wifi = id_wifi + 1;
    end;
    id_laa = id_laa + 1;
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Probability of Success of one transmission  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LAA Network
Psucc_laa = TotalSuccess_laa./TotalAccess;
Psucc_laa(isnan(Psucc_laa)) = 0;       % NaN -> 0
% Wifi Network
Psucc_wifi = TotalSuccess_wifi./TotalAccess;
Psucc_wifi(isnan(Psucc_wifi)) = 0;
% The two networks
Psucc_total = TotalSuccess./TotalAccess;
Psucc_total(isnan(Psucc_total)) = 0;
    

filename = sprintf('%2s_Simul_%d%d%d%d%d%dvPaper_RG%d_RE%d_b%d_PxdB%d_noise%d_Shad%d_PL%d.mat', name_simul, type_effect(1),type_effect(2),type_effect(3),type_effect(4),type_effect(5), type_effect(6), Rinner_laa, Router_laa, beta_threshold*100, PxdB_laa, 10*noise_var, round(Shad_var*100), round(pathloss*100));
save(filename,'Numnodes_laa', 'Numnodes_wifi', 'Psucc_laa', 'Psucc_wifi', 'Psucc_total', 'MeanSINR');



figure;
hold on;
grid on;
surf(Numnodes_laa ,Numnodes_wifi ,Psucc_laa)
xlabel('LAA number of Nodes');
ylabel('Wifi number of Nodes');
zlabel('Probability');
legend('LAA - Psucc');

figure;
hold on;
grid on;
surf(Numnodes_laa ,Numnodes_wifi ,Psucc_wifi)
xlabel('LAA number of Nodes');
ylabel('Wifi number of Nodes');
zlabel('Probability');
legend('Wifi - Psucc');
 

figure;
hold on;
grid on;
surf(Numnodes_laa ,Numnodes_wifi ,Psucc_total)
xlabel('LAA number of Nodes');
ylabel('Wifi number of Nodes');
zlabel('Probability');
legend('Total - Psucc');
 

Psucc_laa
Psucc_wifi

Psucc_total


MeanSINR


