 function [] = BOP_Optimize()

    clear

% This function is used to optimize the parameters of a chosen Brayton Cycle
% The optimization is performed using MATLAB's genetic algorithm
% The function is called by the BOP_Main.m script


% Inputs are stored as (Tmin, Tmax, Pmin, Pratio,
% RecompFrac,iseneffturb,iseneffcomp,iseneffrcomp,UA,UAsplit, NetWork, Recupeff, Preheat, cLTR, cHTR, Qin)
% Indexed value for each parameter of inputs is:
% 1 = Tmin, 2 = Tmax, 3 = Pmin, 4 = Pratio, 5 = RecompFrac, 6 = iseneffturb, 7 = iseneffcomp, 8 = iseneffrcomp, 9 = UA, 10 = UAsplit, 11 = NetWork, 12 = Recupeff, 13 = Preheat, 14 = cLTR, 15 = cHTR, 16 = Qin

% CycleType: % 1 = Simple Cycle, 2 = Reheat Cycle, 3 = Recuperated Cycle, 4 = Recompression Cycle
% There are two types of Recompression Cycles: 1 = Dyreby Method, 2 = Textbook Method
% Bounds are stored as Lower Bounds (LBounds), and Upper Bounds (UBounds)
% LBounds & UBounds = [Tmin, Tmax, Pmin, Pratio, RecompFrac, UA, UAsplit, NetWork, Recupeff, Preheat, cLTR, cHTR]
% Indexed value for each parameter of bounds is: 
% 1 = Tmin, 2 = Tmax, 3 = Pmin, 4 = Pratio, 5 = RecompFrac, 6 = UA, 7 = UAsplit, 8 = NetWork, 9 = Recupeff, 10 = Preheat, 11 = cLTR, 12 = cHTR
% GenerationSize is the number of individuals in each generation
% MaxGenerations is the number of generations to run the optimization for





% Loads Inputs and Optimization Parameters
Optimize = load ("BOP_Optimize.mat","BOP_Optimize");
Optimize = Optimize.BOP_Optimize;
Inputs = load("BOP_Inputs.mat","BOP_Inputs");

Params = Inputs.BOP_Inputs.Parameters;
CycleType = Inputs.BOP_Inputs.CycleType;
GenerationSize = Optimize.GenerationSize;
MaxGenerations = Optimize.MaxGenerations;
%% Parameters are stored as (Tmin, Tmax, Pmin, Pratio, RecompFrac,iseneffturb,iseneffcomp,iseneffrcomp,UA,UAsplit, NetWork, Recupeff, Preheat, cLTR, cHTR, Qin)
%% Turbomachinery eff values (iseneffturb,iseneffcomp,iseneffrcomp), are inputted as value, as they are not optimized

Dyreby = Inputs.BOP_Inputs.Dyreby;
% Sets Flag for Dyreby Method

% Sets Optimization Parameters
problem.solver = 'ga';

problem.options = optimoptions('ga','Display','iter','PopulationSize',GenerationSize,'MaxGenerations',MaxGenerations);


% Determines which cycle is being optimized and sets parameters
switch CycleType

    case 1

        %% Sets Optimization Parameters for CycleType 1: Simple Cycle
        %% Simple States (Tmin, Tmax, Pmin, Pratio)
        problem.fitnessfcn = @(x)BOP_Simple(x(1), x(2), x(3), x(4),Params(6),Params(7),x(5));
        problem.nvars = 5;
        problem.lb = [Optimize.LBounds(1:4),Optimize.LBounds(10)];
        problem.ub = [Optimize.UBounds(1:4),Optimize.UBounds(10)];

    case 2

        %% Sets Optimization Parameters for CycleType 2: Reheat Cycle
        %% Reheat States (Tmin, Tmax, Pmin, Pratio, Preheat,iseneffturb, iseneffcomp,NetWork)
        problem.fitnessfcn = @(x)BOP_Reheat(x(1), x(2), x(3), x(4), Params(6),Params(7),x(5))
        problem.nvars = 5;
        problem.lb = [Optimize.LBounds(1), Optimize.LBounds(2), Optimize.LBounds(3), Optimize.LBounds(4), Optimize.LBounds(10)];
        problem.ub = [Optimize.UBounds(1), Optimize.UBounds(2), Optimize.UBounds(3), Optimize.UBounds(4), Optimize.UBounds(10)];
        
    case 3

        %% Sets Optimization Parameters for CycleType 3: Recuperated Cycle
        %% Recuperated States (Tmin, Tmax, Pmin, Pratio, iseneffturb, iseneffcomp, recupeff,NetWork)
        problem.fitnessfcn = @(x)BOP_Recup(x(1), x(2), x(3), x(4), Params(6),Params(7),x(5),x(6));
        problem.nvars = 8;
        problem.lb = [Optimize.LBounds(1:4), Optimize.LBounds(9), Optimize.LBounds(8)];
        problem.ub = [Optimize.UBounds(1:4), Optimize.UBounds(9), Optimize.UBounds(8)];

    case 4

        if Dyreby == 1
        %% Dyreby Recommpression Method
        %% Sets Optimization Parameters for CycleType 4: Recompression Cycle
        %% Recompression States (Tmin, Tmax, Pmin, Pratio, RecompFrac,iseneffturb,iseneffcomp,iseneffrcomp,UA,UAsplit, NetWork)
        problem.fitnessfcn = @(x)BOP_RecompDyreby(x(1),x(2),x(3),x(4),x(5),Params(6),Params(7),Params(8),x(6),x(7),x(8));
        problem.nvars = 8;
        problem.lb = [Optimize.LBounds(1:5), Optimize.LBounds(6:8)];
        problem.ub = [Optimize.UBounds(1:5), Optimize.UBounds(6:8)];
        
        else
        
        %% Textbook Recommpression Method: BOP_RecompText
        %% Sets Optimization Parameters for CycleType 4: Recompression Cycle
        %% Recompression Inputs (Tmin, Tmax, Pmin, Pratio, Q_in,iseneffturb,iseneffcomp,iseneffrcomp, c_ltr, c_htr)
        problem.fitnessfcn = @(x)BOP_RecompText(x(1),x(2),x(3),x(4),Params(16),Params(6),Params(7),Params(8),x(5),x(6));
        problem.nvars = 6;
        problem.lb = [Optimize.LBounds(1:4), Optimize.LBounds(11:12)];
        problem.ub = [Optimize.UBounds(1:4), Optimize.UBounds(11:12)];
        
        end



end

% Runs Optimization

OptimizedOutput = ga(problem);
disp(OptimizedOutput);

%%Optimized output array corresponds to chosen cycle type and chosen optimization parameters:
%%Simple Cycle: (Tmin, Tmax, Pmin, Pratio)
%%Reheat Cycle: (Tmin, Tmax, Pmin, Pratio, Preheat)
%%Recuperated Cycle: (Tmin, Tmax, Pmin, Pratio, iseneffturb, iseneffcomp, recupeff,NetWork)
%%Recompression Cycle: (Tmin, Tmax, Pmin, Pratio, RecompFrac UA,UAsplit, NetWork)
%% Textbook Method Recompression: (Tmin, Tmax, Pmin, Pratio, c_ltr, c_htr)

% Check if output struct exists, and if it does delete it
if exist('BOP_OptimizedOutput.mat', 'file') == 2
    delete('BOP_OptimizedOutput.mat');
end

%% Store Optimized Output in a Struct BOP_OptimizedOutput
BOP_OptimizedOutput = struct('OptimizedOutput',OptimizedOutput);
save('BOP_OptimizedOutput.mat','BOP_OptimizedOutput');

%% Save outputs to a csv file
% Check if output csv exists, and if it does delete it

if exist('BOP_OptimizedOutput.csv', 'file') == 2
    delete('BOP_OptimizedOutput.csv');
end

% Write to csv file

writematrix(OptimizedOutput,'OptimizedOutput.csv');


