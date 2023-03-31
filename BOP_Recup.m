function [inveff] = BOP_Recup(Tmin, Tmax, Pmin, Pratio, iseneffturb, iseneffcomp, recupeff,NetWork)


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
                    eff = Wtotal/Qin;
                    inveff = 1-eff;

                    if isfile("BOP_Output.mat") == 1
                        delete BOP_Output.mat;
                    end

                    [BOP_Output.StatePoints] = {s1;s2;s3;s4};
                    [BOP_Output.eff] = eff;
                    [BOP_Output.Wcomp] = Wcomp;
                    [BOP_Output.Wturb] = Wturb;
                    [BOP_Output.Qout] = Qout;
                    [BOP_Output.Qin] = Qin;


                    save("BOP_Output.mat","BOP_Output");
                
%% State 5 Calculations %%

s5(2) = s3(2);
s5(3) = recupeff*(s4(3)-refpropm('H','T', s2(1), 'P', s1(2),'CO2'))+s2(3);
s5(1) = refpropm('T','P',s5(2),'H',s5(3),'CO2');
s5(4) = refpropm('S','P',s5(2),'H',s5(3),'CO2');


%% State 6 Calculations %%

s6(2) = s1(2);
s6(3) = s4(3)-(s5(3)-s2(3));
s6(1) = refpropm('T','P',s6(2),'H',s6(3),'CO2');
s6(4) = refpropm('S','P',s6(2),'H',s6(3),'CO2');

            %% Results

                    Wcomp = (s2(3)-s1(3)); %per mass
                    Qin = (s3(3)-s5(3)); %per mass
                    Qout = (s1(3)-s6(3)); %per mass
                    Wturb = (s3(3)-s4(3)); %per mass
                    Wtotal = Wturb-Wcomp;
                    massflow = (NetWork*1E6)/Wtotal;
                    eff = Wtotal/Qin;
                    %% inveff is used by BOP_Optimizer only to find max efficiency
                    inveff = 1-eff;

                    
%% Checks if BOP_Output.mat exists and deletes it if it does

                    if isfile("BOP_Output.mat") == 1
                        delete BOP_Output.mat;
                    end
%% Store State points in BOP_Output struct with all state points store in an array field StatePoints

                    [BOP_Output.StatePoints] = {s1;s2;s5;s3;s4;s6};
                    [BOP_Output.MassFlow] = massflow;
                    [BOP_Output.Efficiency] = eff;
                    [BOP_Output.Wcomp] = Wcomp;
                    [BOP_Output.Qin] = Qin;
                    [BOP_Output.Qout] = Qout;
                    [BOP_Output.Wturb] = Wturb;
                    [BOP_Output.Wtotal] = Wtotal;
                    [BOP_Output.NetWork] = NetWork;




                    save("BOP_Output.mat","BOP_Output");
                

end
