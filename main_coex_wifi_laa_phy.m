function main_coex_wifi_laa_phy

%clear all;

%n_total=10;
simulation_time = 500000;


for  n_total= 10% 6:2:10 
    

    s_wifi=zeros(1, n_total);
    s_laa=zeros(1, n_total);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    aux_matrix = zeros(4, n_total);
    matrix_wifi_succ = zeros(n_total+1, n_total);
    matrix_wifi_coll = zeros(n_total+1, n_total);
    matrix_laa_succ = zeros(n_total+1, n_total);
    matrix_laa_coll = zeros(n_total+1, n_total);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    matrix_wifi=zeros(5, 5);
    matrix_laa=zeros(5, 5);
    matrix_wifi_norm=zeros(5, 5);
    matrix_laa_norm=zeros(5, 5);
    matrix_ocr_norm=zeros(5, 5);
    xpdf_idle = 1:10;
    ypdf_idle = zeros(n_total+1, length(xpdf_idle));
    meanSINR_totdB=zeros(1, n_total+1);
    
    for PC = 1:1:3
    
        for i = 0:1:n_total
            
            aux_matrix_wifi=zeros(i,n_total-i);
            aux_matrix_laa=zeros(i,n_total-i);
            aux_matrix_wifi_norm=zeros(i,n_total-i);
            aux_matrix_laa_norm=zeros(i,n_total-i);
            [ypdf_idle(i+1,:), s_wifi(i+1), s_laa(i+1), aux_matrix, aux_matrix_wifi, aux_matrix_laa,...
                 aux_matrix_wifi_norm, aux_matrix_laa_norm, matrix_ocr_norm, meanSINR_totdB(i+1)]...
                = feval('coex_wifi_phy3', i, n_total-i, simulation_time, PC, xpdf_idle);   % n_wifi, n_laa
                                    
            matrix_wifi_succ(i+1,:) = aux_matrix(:,1);
            matrix_wifi_coll(i+1,:) = aux_matrix(:,2);
            matrix_laa_succ(i+1,:)  = aux_matrix(:,3);
            matrix_laa_coll(i+1,:)  = aux_matrix(:,4);
            
            if i==5               
                matrix_wifi=aux_matrix_wifi;
                matrix_laa=aux_matrix_laa;
                matrix_wifi_norm=aux_matrix_wifi_norm;
                matrix_laa_norm=aux_matrix_laa_norm;
            end
        end
        
%         figure
%         grid on;
%         hold on;
%         plot(0:n_total, s_wifi, '-r');
%         plot(0:n_total, s_laa, '-g');
%         xlabel('Number of nodes');
%         ylabel('Probability');
%         legend('succ. wifi prob.', 'succ. laa prob.');
%         title(strcat('Simulation - timings - Priority Class = ', num2str(PC)));
        
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % save data in file
        filename = sprintf('DL_n_0_10_Pxdb20_noise25_%d_PC%d_NOVO', n_total, PC);
        %filename = sprintf('phy7_resultscoex_nodes%d_PC%d', n_total, PC);
        save(filename, 'PC', 'meanSINR_totdB', 'n_total', 's_wifi', 's_laa', 'matrix_wifi_succ',...
            'matrix_wifi_coll', 'matrix_laa_succ', 'matrix_laa_coll', 'xpdf_idle', 'matrix_ocr_norm',...
            'ypdf_idle', 'matrix_wifi', 'matrix_laa', 'matrix_wifi_norm', 'matrix_laa_norm');
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end


end

end
