function [inveff] = BOP_Simple(Tmin, Tmax, Pmin,Pratio,iseneffturb,iseneffcomp,NetWork)




%% State 1 Calculations %%
               s1(1) = Tmin;
               s1(2) = Pmin;
               s1(3) = refpropm('H','T',s1(1),'P',s1(2),'CO2');

              s1(4) = refpropm('S', 'T', s1(1), 'P', s1(2), 'CO2');

                %% State 2 Calculations %%

                s2(2) = s1(2)*Pratio;       %Compresses based on pressure ratio
                [s2(3)] = TurbomachineCalc(s1(2),s2(2), s1(3),iseneffcomp,1);

                s2(1) = refpropm('T', 'P', s2(2), 'H', s2(3), 'CO2');
                s2(4) = refpropm('S', 'P', s2(2), 'H', s2(3), 'CO2');

                %% State 3 Calculations %%

                s3(1) = Tmax;
                s3(2) = Pmin*Pratio;
                s3(3) = refpropm('H','T',s3(1),'P',s3(2),'CO2');
                s3(4) = refpropm('S', 'T', s3(1), 'P', s3(2), 'CO2');

                

                    %% State 4 Calculations %%

                  

                  
                    s4(2) = Pmin;                            
                   
                    s4(3) = TurbomachineCalc(s3(2),s4(2), s3(3),iseneffturb,0);
                     s4(1) = refpropm('T', 'P', s4(2), 'H', s4(3), 'CO2');
                    s4(4) = refpropm('S','P',s4(2),'H',s4(3),'CO2');


                    %% Results

                    Wcomp = (s2(3)-s1(3)); %per mass
                    Qin = (s3(3)-s2(3)); %per mass
                    Qout = (s1(3)-s4(3)); %per mass
                    Wturb = (s3(3)-s4(3)); %per mass
                    Wtotal = Wturb-Wcomp;
                    massflow = (NetWork*1E6)/Wtotal;
                    eff = Wtotal/Qin;
                    inveff = 1-eff;

                    if isfile("BOP_Output.mat") == 1
                        delete BOP_Output.mat;
                    end

                    [BOP_Output.Temp] = {s1(1),s2(1),s3(1),s4(1)};
                    [BOP_Output.Pressure] = {s1(2),s2(2),s3(2),s4(2)};
                    [BOP_Output.Enthalpy] = {s1(3), s2(3), s3(3), s4(3)};
                    [BOP_Output.Entropy] = {s1(4), s2(4), s3(4), s4(4)};

                    save("BOP_Output.mat","BOP_Output");
                
end