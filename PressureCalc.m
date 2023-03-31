function [StatePressures] = PressureCalc(Pmin,Pratio,HXLoss,PipeLoss,HXFlags,TurboFlags)

% This function calculates the state pressures for a given cycle. 
% Turbo flags indicates the outlet of a turbine or compressor. 1 = compressor, 2 = turbine

% HXFlags indicates the outlet of a heat exchanger. 1 = heat exchanger 


%% Pipe Loss is the pressure loss in that section of pipe, and can be entered in as a fixed value;
%% Pipe loss is stored as an array at same length as desired cycle, with there being an extra value for Recomp Cycle to account for the split at state 9

% Simple Cycle has 4 states, with 1 turbine and 1 compressor, and 2 heat exchangers outlets. [1 2 3 4]
% Recup Cycle has 6 states, with 1 turbine and 1 compressor, and 4 heat exchangers outlets. [1 2 3 A B 4]
% Reheat Cycle has 6 states, with 2 turbines and 1 compressor, and 2 heat exchangers outlets. [1 2 5 3 4 6]
% Recompression Cycle has 10 states, with 1 turbines and 2 compressors, and 6 heat exchangers outlets [1 2 3 4 5 6 7 8 9 10]

%% Example HXFlags for Simple Cycle = [1 0 1 0];
%% Example TurboFlags for Simple Cycle = [0 1 0 2];

%% Example HXFlags for Recup Cycle = [1 0 1 1 0 1];
%% Example TurboFlags for Recup Cycle = [0 1 0 0 2 0];

%% Example HXFlags for Reheat Cycle = [1 0 1 0 1 0];
%% Example TurboFlags for Reheat Cycle = [0 1 0 2 0 2];

%% Example HXFlags for Recompression Cycle = [0 0 1 0 0 1 0 1 1 0];
%% Example TurboFlags for Recompression Cycle = [0 1 0 0 0 0 2 0 0 1];

%% To calculate the pressure at each state, the first state is the minimum pressure, then the state pressure of each subsequent state
%% is calculated by multiplying the previous state pressure by the pressure loss of the component.
%% The first state is then re calculated by multiplying the last state pressure by the pressure loss of the heat exchanger.

%% State points 9 lead to state point 1 in Recompression Cycle, and State 9 also leads to the Recompressor, which go to state point 10.
%% The pressure losses of 9 change depending on which state point it leads to.



% Calculate Pressure At all states

StatePressures = zeros(1,length(HXFlags));

StatePressures(1) = Pmin;

for i = 2:length(HXFlags)
    if TurboFlags(i) == 1
        StatePressures(i) = StatePressures(i-1)*Pratio;

    elseif TurboFlags(i) == 2
        StatePressures(i) = Pmin;
    end

    if HXFlags(i) == 1
        StatePressures(i) = StatePressures(i)*HXLoss;
    end

    if HXFlags(i) == 0 && TurboFlags(i) == 0
        StatePressures(i) = StatePressures(i)*PipeLoss;
    end 


    %% Calculate Pressure loss for states 10 and 1 for Recompression Cycle
    %% These use the pressure from state 9, with different pressure losses


    if i == 10 
        StatePressures(i) = StatePressures(i-1)-Pipeloss(i)*Pratio;
        StatePressures(1) = (StatePressures(i-1)-Pipeloss(length(HXFlags)))*HXLoss-PipeLoss(1);
    end
    
if length(HXFlags) < 10
    StatePressures(1) = (StatePressures(length(HXFlags))*HXLoss)-PipeLoss(1);
end



end



