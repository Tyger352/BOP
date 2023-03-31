function [UA, Error, hColdOut, meaneff] = HeatExchangerCalc(tColdIn, tHotIn, Qdot, pColdIn, pHotIn, massflowCold, massflowHot, nSubHxrs, HXLoss)

% tHotIn = 508.38;
% tColdIn = 350.11;
% pColdIn = 28000;
% pHotIn = 8133.9;
% Qdot = 8.53508e6;
% massflowCold = 49.66*(1-0.281);
% massflowHot = 49.66;
% nSubHxrs = 20;
% Qdot = massflowHot*(6.79e5-4.95e5);
% HXLoss = 1;


%% T8 & T9 Assumed
%% Pressure Known and constant

 if tColdIn > tHotIn
    Error = 1;
    UA = 1e6;
    meaneff = 0;
    hColdOut = 0;
    disp("Cold temp is higher then Hot temp")
    return
 end

 pHot = linspace(pHotIn, pHotIn*HXLoss, nSubHxrs+1);
 pCold = linspace(pColdIn, pColdIn*HXLoss, nSubHxrs+1);


hHot(1) = refpropm('H', 'T',tHotIn,'P', pHotIn,'CO2');
hHotIn = hHot(1);
hColdIn = refpropm('H', 'T',tColdIn,'P', pColdIn,'CO2');
hColdOut = (hColdIn*massflowCold + Qdot)/massflowCold;
hCold(1) =hColdOut;

tHot(1) = tHotIn;


% hHotOut = hHot(1) - Qdot/massflowHot;
hHotOut = (hHot(1)*massflowHot - Qdot)/massflowHot;
%  hColdOut = hCold(1) + Qdot/massflowCold;


 tCold(1) = refpropm('T','P',pCold(end),'H',hColdOut,'CO2');



for n = 1:(nSubHxrs)

    hHot(n+1) = hHotIn - n*(hHotIn-hHotOut)/nSubHxrs;
    tHot(n+1) = refpropm('T', 'P', pHot(n+1), 'H', hHot(n+1), 'CO2');
   
    hCold(n+1) = hColdOut + n*(hColdIn-hColdOut)/nSubHxrs;
    tCold(n+1) = refpropm('T', 'P', pCold(n+1), 'H', hCold(n+1), 'CO2');


    cCold(n) = massflowCold * ((hCold(n+1)-hCold(n))) / (tCold(n+1)-tCold(n));
    cHot(n) = massflowHot *((hHot(n)-hHot(n+1))) / (tHot(n)-tHot(n+1));

    if tCold(n) > tHot(n)
        UA = -1;
        Error = 1;
        meaneff = 0;
%         disp("Second Law Violation")
%         disp(tCold(n))
%         disp(tHot(n))
        return
    end

   

    cMin(n) = min(cCold(n),cHot(n));
    cMax(n) = max(cCold(n),cHot(n));
    CR(n) = cMin/cMax;

    

    eff(n) = (Qdot/nSubHxrs)/(cMin(n)*(tHot(n)-tCold(n+1)));


     if CR ~= 1

         NTU(n) = (log((1-(eff(n)*CR(n)))/(1-eff(n))))/(1-CR(n));

     else

         NTU = eff(n)/(1-eff(n));
     end

 

%      if (IsCriticalCold(n)||IsCriticalHot(n)) ~= 999
%          Error = 1;
%          return
%      end
    
end





     UA = (sum(NTU(1:(nSubHxrs)).*cMin(1:(nSubHxrs))));
%      meaneff = 2*mean(eff);
     meaneff = (hHotIn - hHotOut)/(hHotIn-refpropm('H','T',tColdIn,'P',pHotIn,'CO2'));
 
     if UA == real(UA)
             Error = 0;
     else
             Error = 2;
     end

%  plot(tHot,tCold)
% % hold on
% % plot(tHot(1,1:20),eff)
% % plot(tCold(1,1:20),eff)
% figure(2);
% % plot(cCold,cHot)




%  end


     
    
