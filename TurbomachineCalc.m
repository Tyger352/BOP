function [hout] = TurbomachineCalc(P1, P2, hin,iseneff,  type)


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% %                                 Turbine Calculations

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Pmin = 7380;
% Pratio = 3;
% hin = 976306;
% iseneff = .85;
% type = 1;


hout = 0;
hini = hin;


 
    sin = refpropm('S', 'P', P1, 'H', hini, 'CO2');
    houtifinal = refpropm('H', 'P', P2, 'S', sin, 'CO2');
    wifinal = (hin - houtifinal);



% for n =   1:200
% 
% 
% 
%     if type == 1
% 
%         P2 = P1+Pdiff;
%         sin = refpropm('S', 'P', P1, 'H', hini, 'CO2');
%         houti = refpropm('H', 'P', P2, 'S', sin, 'CO2');
%         wi = (hini - houti);
%         W(n) = wi/iseneff; %% Compressor
%       
%     else
% 
%         P2 = P1-Pdiff;
%         houti = refpropm('H', 'P', P2, 'S', refpropm('S', 'P', P1, 'H', hini, 'CO2'), 'CO2');
%         wi = (hini - houti);
%         W(n) = iseneff*wi;
%         
%                
%         
%     end
%     h(n) = houti-W(n);
%     hini = houti-W(n)
%     P1 = P2;
%     
%    
% 
% end

if type == 1

    hout = abs((hin-houtifinal)/iseneff)+hin;

else
  
    hout = hin - (iseneff*(hin-houtifinal));
end

    W = hin-hout;


% eqiseneff = ((houtifinal) - hin)/ ((hout)-hin)
% if type == 1
%     Wfinal = wifinal/eqiseneff;
% %      hout = hin - Wfinal;
% else
%    Wfinal = wifinal*eqiseneff;
% % %     hout = hin - Wfinal;
% end

