function [inveff] = BOP_RecompText(Tmin, Tmax, Pmin, Pratio, Q_in,iseneffturb,iseneffcomp,iseneffrcomp, c_ltr, c_htr)


P_low = Pmin;
Pr = Pratio;
T1 = Tmin;
T6 = Tmax;





% P_low = 8600; % kPa
% 
% Pr = 3.6; % Pressure ratio
% 
% T6 = 823.00; % K
% T1 = 305; % K
% Q_in = 15; % MW
% c_ltr = 0.8;
% c_htr = 0.8;
nt = iseneffturb;
nc = iseneffcomp;
nrc = iseneffrcomp;

PipeLoss = 1;
HXLoss = 1;
  Pmin = P_low;
    Pratio = Pr;

% Sets HX Outlet Flag  
HXFlags = [1 0 1 0 1 1 0 1 1 0];
TurboFlags = [0 1 0 0 0 0 2 0 0 1];

%% Gets State Pressures

StatePressures = StatePressures(Pmin,Pratio,HXLoss,PipeLoss,HXFlags,TurboFlags);


p9 = StatePressures(9);
p8 = StatePressures(8);
p7 = StatePressures(7);

p1 = StatePressures(1);
p2 = StatePressures(2);
p3 = StatePressures(3);
p4 = StatePressures(4);
p5 = StatePressures(5);
p6 = StatePressures(6);


% =========================================================

P_high = P_low*Pr;

s1 = refpropm('S','T',T1,'P',p1,'co2'); % J/kgK
h1 = refpropm('H','T',T1,'P',p1,'co2'); % J/kg

s2s = s1;
h2s = refpropm('H','P',p2,'S',s2s,'co2'); % J/kg
h2 = -1*(((h1-h2s)/nc)-h1);
T2 = refpropm('T','P',p2,'H',h2,'co2'); % K
s2 = refpropm('S','P',p2,'H',h2,'co2'); % J/kg

s6 = refpropm('S','T',T6,'P',p6,'co2'); % J/kgK
h6 = refpropm('H','T',T6,'P',p6,'co2'); % J/kg

s7s = s6;
h7s = refpropm('H','P',p7,'S',s7s,'co2'); % J/kg
h7 = -1*(nt*(h6-h7s)-h6);
T7 = refpropm('T','P',p7,'H',h7,'co2'); % K
s7 = refpropm('H','P',p7,'H',h7,'co2'); % J/kg




fun = @(x)Solve1(x(1),T2,h1,h2,h6, h7, p4,p8, p9,nrc,c_ltr,c_htr,Q_in);
options = optimoptions('fmincon','Display', 'none');
lb = T2;
ub = T7;
x0 = T2+20;

T4 = fmincon(fun,x0,[],[],[],[],lb,ub,[],options);


fun = @(x)Solve2(x(1),T4, T2,h1,h2,h6, h7, p4,p8, p9,nrc,c_ltr,c_htr,Q_in);
options = optimoptions('fmincon','Display', 'none');
lb = T2;
ub = T7;
x0 = T7-20;

T4a = fmincon(fun,x0,[],[],[],[],lb,ub,[],options);

if abs(T4-T4a) >= 2
    n = 1;
    disp("invalid")
end

[Hdiff,n,f,m,W_net,Q_out,inveff,StatePoints] = Solve2(T4a,T4, T2,h1,h2,h6, h7, p4,p8, p9,nrc,c_ltr,c_htr,Q_in);

  %% Checks if BOP_Output.mat exists, if it does, delete it

    if exist('BOP_Output.mat','file') == 2
        delete('BOP_Output.mat')
    end

  %% Store Statepoints in a structure, BOP_Output
  [BOP_Output.StatePoints] = StatePoints;

  %% Store work, heat, and efficiency in a structure, BOP_Output
  [BOP_Output.totalwork] = W_net;
  [BOP_Output.Q_out] = Q_out;
  [BOP_Output.eff] = n;
  [BOP_Output.RecompFrac] = f;
  [BOP_Output.massflow] = m;

  %% Save BOP_Output structure to a .mat file
  save('BOP_Output.mat','BOP_Output')
  
%% Stores all results in a structure, BOP_Output

    function [diff_h8, n,f,m,W_net,Q_out] = Solve1(T4, T2,h1,h2,h6, h7, p4,p8, p9,nrc,c_ltr,c_htr,Q_in)
    s4 = refpropm('S','T',T4,'P',p4,'co2'); % J/kgK
    h4 = refpropm('H','P',p4,'S',s4,'co2'); % J/kg
    
    s9s = s4;
    h9s = refpropm('H','P',p9,'S',s9s,'co2'); % J/kg
    h9 = -1*(nrc*(h4-h9s)-h4);
    T9 = refpropm('T','P',p9,'H',h9,'co2'); % K
    s9 = refpropm('S','P',p9,'H',h9,'co2'); % J/kg
    
    h8_ltr = (h9 - c_ltr*(refpropm('H','T',T2,'P',p9,'co2')))/(1 - c_ltr);
    h8_htr = h7 - c_htr*(h7 - refpropm('H','T',T4,'P',p8,'co2'));
    
    % CONVERGENCE --> h8_a needs to be approximately = to h8_b
 
    diff_h8 = abs(h8_ltr - h8_htr);

    f = 1 - (h8_ltr-h9)/(h4-h2);
    
    h5 = h7 - h8_htr + h4;
    
    m = Q_in*1000000/(h6-h5);
    n = (h6-h7 + (1-f)*(h1-h2) + f*(h9-h4))/(h6-h5);
    W_net = (h6-h7 + (1-f)*(h1-h2) + f*(h9-h4))*m/1000000;
    Q_out = (1-f)*m*(h1-h9)/1000000;
    

end





    function [Hdiff,n,f,m,W_net,Q_out,inveff,StatePoints] = Solve2(T4a,T4, T2,h1,h2,h6, h7, p4,p8, p9,nrc,c_ltr,c_htr,Q_in)
    s4 = refpropm('S','T',T4a,'P',p4,'co2'); % J/kgK
    h4 = refpropm('H','P',p4,'S',s4,'co2'); % J/kg
    
    s9s = s4;
    h9s = refpropm('H','P',p9,'S',s9s,'co2'); % J/kg
    h9 = -1*(nrc*(h4-h9s)-h4);
    T9 = refpropm('T','P',p9,'H',h9,'co2'); % K
    s9 = refpropm('S','P',p9,'H',h9,'co2'); % J/kg
    
    h8_ltr = (h9 - c_ltr*(refpropm('H','T',T2,'P',p9,'co2')))/(1 - c_ltr);
    h8_htr = h7 - c_htr*(h7 - refpropm('H','T',T4,'P',p8,'co2'));

    
    
    % CONVERGENCE --> h8_a needs to be approximately = to h8_b
   
    Hdiff = abs(h8_ltr-h8_htr);
   
    
    f = 1 - (h8_ltr-h9)/(h4-h2);
    
    h5 = h7 - h8_htr + h4;
    
    m = Q_in*1e6/(h6-h5);
    n = 1-((h6-h7 + (1-f)*(h1-h2) + f*(h9-h4))/(h6-h5));
    inveff = 1-n;

    W_net = (h6-h7 + (1-f)*(h1-h2) + f*(h9-h4))*m/1e6;
    Q_out = (1-f)*m*(h1-h9)/1e6;

    for n = 1:9

        StatePoints(n) = [T(n) p(n) h(n) s(n)];
    end
    
    end


    
    
  

    
end
