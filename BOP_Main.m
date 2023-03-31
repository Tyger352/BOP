function [] = BOP_Main()
%% Main BOP function file
% Tyler Blair
% Carleton University
% This file acts as the main logic file for BOP, and runs all of the child
% functions
%
%
%% The functions of BOP are as follows: Single Solve, Sensitivity Study, and Optimization
%% BOP accepts the following Brayton cycles: Simple, Reheat, Recuperation, and Recompression

%% Loads parameters for main

InputStruct = load("BOP_Inputs.mat","BOP_Inputs");

Params = InputStruct.BOP_Inputs.Parameters;
CycleType = InputStruct.BOP_Inputs.CycleType;
SolveType = InputStruct.BOP_Inputs.SolveType;
Dyreby = InputStruct.BOP_Inputs.Dyreby;


%% Input Structure

% Inputs are stored as (Tmin, Tmax, Pmin, Pratio,
% RecompFrac,iseneffturb,iseneffcomp,iseneffrcomp,UA,UAsplit, NetWork, Recupeff, Preheat, cLTR, cHTR, Qin)


% Params are stored in a structure, with the parameters being
% (Cycle type,Solve type, Results type)
%

%% Cycle Type Determination

% The cyle type is stored as an integer type value, with the following integers
% representing the associated cycles:
% 1 = Simple Cycle
% 2 = Reheat Cylce
% 3 = Recuperation Cycle
% 4 = Recompression Cycle

% These values get inputted as inut argument to children functions


%% Solve Type Determination

% The solve type is also stored as an integer value, with the following
% associated solve types:
% 1 = Single Solve
% 2 = Sens Study
% 3 = Optimize

% These values get inputted as input arguments to child functions

switch SolveType

    case 1 %% Single Solve Component

        switch CycleType
            case 1
                BOP_Simple(Params(1),Params(2),Params(3),Params(4),Params(6), Params(7),Params(11)); % Calls Simple Cycle Function
            case 2
                BOP_Reheat(Params(1),Params(2),Params(3),Params(4),Params(13),Params(6), Params(7),Params(11)); % Calls Reheat Cycle Function
            case 3
                BOP_Recup(Params(1),Params(2),Params(3),Params(4),Params(6),Params(7),Params(12),Params(11)); % Calls Recuperation Cycle Function
            case 4
               
                if Dyreby == 1
               BOP_RecompDyreby(Params(1:11))
                else 
               BOP_RecompText(Params(1),Params(2),Params(3),Params(4),Params(16),Params(6),Params(7),params(8),Params(14),Params(15));
                end

            %% Load BOP_Output.mat, then save as csv file BOP_Output.csv

            %check if BOP_Output.csv exists, if it does, delete it

            if exist("BOP_Output.csv","file") == 2
                delete("BOP_Output.csv")
            end

            OutputStruct = load("BOP_Output.mat","BOP_Output");
            Output = OutputStruct.BOP_Output;
            writetable(Output,"BOP_Output.csv");

        end
        
    case 2
        %% Runs Sensitivity Study
        BOP_SensitivityStudy()
    case 3
        %% Runs Optimization
        BOP_Optimize()


end






