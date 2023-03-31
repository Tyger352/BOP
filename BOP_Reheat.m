function [inveff] = BOP_Reheat(Tmin, Tmax, Pmin, Pratio, Preheat,iseneffturb, iseneffcomp,NetWork)

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


%% State A Calculations %%


sA(2) = (s2(2)-s1(2))*(Preheat)+s1(2);
sA(3) = TurbomachineCalc(s3(2),sA(2), s3(3),iseneffturb,0);
sA(1) = refpropm('T', 'P', sA(2), 'H', sA(3), 'CO2');
sA(4) = refpropm('S','P',sA(2),'H',sA(3),'CO2');


%% State B Calculations %%


sB(2) = sA(2);
sB(1) = s3(1);

sB(3) = refpropm('H', 'T', sB(1), 'P', sB(2), 'CO2');
sB(4) = refpropm('S', 'T', sB(1), 'P', sB(2), 'CO2');

%% State 4 Calculations %%

s4(2) = Pmin;
s4(3) = TurbomachineCalc(s3(2),s4(2), s3(3),iseneffturb,0);
s4(1) = refpropm('T', 'P', s4(2), 'H', s4(3), 'CO2');
s4(4) = refpropm('S','P',s4(2),'H',s4(3),'CO2');

%% Results

Wcomp = (s2(3)-s1(3)); %per mass
Qin = (s3(3)-s2(3)); %per mass
Qout = (s1(3)-s4(3)); %per mass
Wturb = (s3(3)-sA(3)); %per mass
WReheatturb = sB(4)-s4(3);
Wtotal = Wturb+WReheatturb-Wcomp;
massflow = (NetWork*1E6)/Wtotal;
eff = Wtotal/Qin;
inveff = 1-eff;



%% Checks if BOP_Output.mat exists and deletes it if it does

if isfile("BOP_Output.mat") == 1
    delete BOP_Output.mat;
end
%%Create an output struct called BOP_Output that stores all state points together in field called statepoints

BOP_Output.statepoints = [s1;s2;s3;sA;sB;s4];

%%Saves other important results to the BOP_Output struct

BOP_Output.Wcomp = Wcomp;
BOP_Output.Qin = Qin;
BOP_Output.Qout = Qout;
BOP_Output.Wturb = Wturb;
BOP_Output.WReheatturb = WReheatturb;
BOP_Output.Wtotal = Wtotal;
BOP_Output.massflow = massflow;
BOP_Output.eff = eff;

%% saves output struct

save("BOP_Output.mat","BOP_Output");


