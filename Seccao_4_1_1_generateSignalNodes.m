function [SignalNodes] = generateSignalNodes(DistofNodes, SignalNodes_m, SignalNodes_var, pathloss, Shad_var, type_effect)

    
   if(~isempty(DistofNodes))
        SignalNodes = normrnd(SignalNodes_m, sqrt(SignalNodes_var),size(DistofNodes));  % RV 
        effects = ones(size(SignalNodes));
        
        % Pathloss
        if type_effect(1),
            %effectsPL = ((DistofNodes+1).^(-pathloss));
            effectsPL = ((DistofNodes).^(-pathloss));
            locRi1 = find(DistofNodes<1);
            effectsPL(locRi1) = 1;
            
            effects = effects.* effectsPL;
        end
        
        % Fast Fading
        if type_effect(2),
            effectsFF = exprnd(1, size(SignalNodes));
            effects = effects.*effectsFF;
        end;
    
        % Slow Fading
        if type_effect(3),
            effectsSFLog = lognrnd(0, Shad_var, size(SignalNodes));
             effects = effects.*effectsSFLog;
        end
        
        % Slow Fading Gamma
        if type_effect(4)
            %Gamma
            %miu =0;
            miu = -(Shad_var^2)/2;
            ms = 1/(exp(Shad_var^2) - 1);
            omegas = exp(miu)*(sqrt((ms+1)/ms));
            effectsSFGAMMA = gamrnd(ms, omegas/ms, size(SignalNodes));
            effects = effects.*effectsSFGAMMA;    
        end;
        
        % Slow and Fast Fading Gamma
        if type_effect(5)
            %miu =0;
            miu = -(Shad_var^2)/2;
            ms = 1/(exp(Shad_var^2) - 1);
            omegas = exp(miu)*(sqrt((ms+1)/ms));
            
            theta = (2*(ms + 1)/ms - 1)*omegas;
            k = 1/(2*(ms + 1)/ms - 1);
            
            effectsFGAMMA = gamrnd(k, theta, size(SignalNodes));
            effects = effects.*effectsFGAMMA;  
        end;
        
        SignalNodes = SignalNodes.*effects;
   else
       SignalNodes = DistofNodes;
   end;
end



